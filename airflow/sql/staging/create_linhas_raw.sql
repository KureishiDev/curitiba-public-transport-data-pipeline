CREATE SCHEMA IF NOT EXISTS staging_mobilidade;

CREATE TABLE IF NOT EXISTS staging_mobilidade.linhas_raw (
    cod                text,
    nome               text,
    somente_cartao     text,
    categoria_servico  text,
    nome_cor           text,
    dt_ref             date        NOT NULL,
    ingestion_ts       timestamptz NOT NULL DEFAULT now()
);
