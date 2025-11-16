CREATE TABLE IF NOT EXISTS gold_mobilidade.dim_linha (
    linha_sk          bigserial PRIMARY KEY,
    cod               text      NOT NULL,
    nome              text      NOT NULL,
    somente_cartao    boolean,
    categoria_servico text,
    nome_cor          text,
    dt_ref            date      NOT NULL,
    created_at        timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_dim_linha_cod_dt
ON gold_mobilidade.dim_linha (cod, dt_ref);
