import os
import json
from pathlib import Path
from datetime import date

import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv


def get_engine():
    load_dotenv()
    conn_str = os.getenv("DW_CONN_STR")
    if not conn_str:
        raise RuntimeError("DW_CONN_STR não definido no .env")
    return create_engine(conn_str)


def _get_landing_dir(dt_ref: str) -> Path:
    base_dir = Path(__file__).resolve().parents[1]
    landing_dir = base_dir / "data" / "landing" / f"dt={dt_ref}"
    if not landing_dir.exists():
        raise FileNotFoundError(f"Pasta de landing não existe: {landing_dir}")
    return landing_dir


def load_linhas_json(dt_ref: str):
    """
    Carrega o arquivo linhas.json do tipo:
    [
      {"COD": "...", "NOME": "...", "SOMENTE_CARTAO": "...", ...}
    ]
    """
    landing_dir = _get_landing_dir(dt_ref)
    json_path = landing_dir / "linhas.json"

    print("Procurando linhas.json em:", json_path)

    if not json_path.exists():
        raise FileNotFoundError(f"Arquivo não encontrado: {json_path}")

    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    df = pd.DataFrame(data)
    df.columns = [c.lower() for c in df.columns]

    # validação básica de colunas esperadas
    expected = {"cod", "nome", "somente_cartao", "categoria_servico", "nome_cor"}
    missing = expected - set(df.columns)
    if missing:
        raise ValueError(f"Colunas faltando em linhas.json: {missing}")

    df["dt_ref"] = date.fromisoformat(dt_ref)

    engine = get_engine()

    df.to_sql(
        "linhas_raw",
        schema="staging_mobilidade",
        con=engine,
        if_exists="append",
        index=False,
        chunksize=5000,
        method="multi",
    )

    print(f"Ingestão OK: {len(df)} linhas carregadas para staging_mobilidade.linhas_raw")

def load_generic_json_to_payload(dt_ref: str, filename: str, table_name: str):
    """
    Loader genérico: lê JSON (lista de objetos) e grava em staging_mobilidade.<table_name>
    em uma coluna 'payload' (TEXT) + 'dt_ref'.
    Se o arquivo estiver vazio ou com JSON inválido, apenas loga um aviso e não interrompe o ETL.
    """
    base_dir = Path(__file__).resolve().parents[1]
    landing_dir = base_dir / "data" / "landing" / f"dt={dt_ref}"
    json_path = landing_dir / filename

    print(f"Procurando {filename} em: {json_path}")

    if not json_path.exists():
        print(f"⚠ Aviso: {filename} não encontrado. Pulando carga de {table_name}.")
        return

    # Tenta UTF-8 e, se der ruim, tenta Latin-1 (ISO-8859-1)
    raw_text = None
    for enc in ("utf-8", "latin1"):
        try:
            with open(json_path, "r", encoding=enc) as f:
                raw_text = f.read()
            break
        except UnicodeDecodeError:
            continue

    if raw_text is None:
        print(f"⚠ Aviso: não foi possível ler {filename} em UTF-8 nem Latin-1. Pulando {table_name}.")
        return

    raw_text = raw_text.strip()
    if not raw_text:
        print(f"⚠ Aviso: {filename} está vazio. Pulando {table_name}.")
        return

    try:
        data = json.loads(raw_text)
    except json.JSONDecodeError:
        print(f"⚠ Aviso: {filename} não contém JSON válido. Pulando {table_name}.")
        return

    if isinstance(data, dict):
        data = [data]

    payload_strs = [json.dumps(obj, ensure_ascii=False) for obj in data]

    df = pd.DataFrame(
        {
            "payload": payload_strs,
            "dt_ref": date.fromisoformat(dt_ref),
        }
    )

    engine = get_engine()

    df.to_sql(
        table_name,
        schema="staging_mobilidade",
        con=engine,
        if_exists="append",
        index=False,
        chunksize=2000,
        method="multi",
    )

    print(f"Ingestão OK: {len(df)} registros em staging_mobilidade.{table_name}")







def load_all_staging(dt_ref: str):
    """
    Função que ingere TODOS os JSONs da partição dt=YYYY-MM-DD.
    """
    load_linhas_json(dt_ref)

    load_generic_json_to_payload(dt_ref, "pois.json",               "pois_raw")
    load_generic_json_to_payload(dt_ref, "pontos_linha.json",       "pontos_linha_raw")
    load_generic_json_to_payload(dt_ref, "shape_linha.json",        "shape_linha_raw")
    load_generic_json_to_payload(dt_ref, "tabela_linha.json",       "tabela_linha_raw")
    load_generic_json_to_payload(dt_ref, "tabela_veiculo.json",     "tabela_veiculo_raw")
    load_generic_json_to_payload(dt_ref, "trechos_itinerarios.json","trechos_itinerarios_raw")


if __name__ == "__main__":
    # por enquanto, você pode testar só o de linhas:
    # load_linhas_json("2022-02-11")

    # ou já tudo:
    load_all_staging("2022-02-11")
