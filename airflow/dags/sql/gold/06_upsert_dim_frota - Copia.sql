CREATE TABLE IF NOT EXISTS gold_mobilidade.fato_frota (
    dt_ref              date NOT NULL,
    empresa_codigo      text,
    total_veiculos      int,
    veiculos_acessiveis int,
    idade_media         numeric,
    created_at          timestamptz DEFAULT now()
);
