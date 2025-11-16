CREATE TABLE IF NOT EXISTS gold_mobilidade.dim_empresa (
    empresa_sk        bigserial PRIMARY KEY,
    empresa_codigo    text NOT NULL,
    empresa_nome      text NOT NULL,
    dt_ref            date NOT NULL,
    created_at        timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_dim_empresa_cod_dt
ON gold_mobilidade.dim_empresa (empresa_codigo, dt_ref);
