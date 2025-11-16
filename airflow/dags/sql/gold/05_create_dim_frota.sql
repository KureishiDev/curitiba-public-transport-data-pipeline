CREATE TABLE IF NOT EXISTS gold_mobilidade.dim_frota (
    frota_sk          bigserial PRIMARY KEY,
    prefixo           text NOT NULL,
    placa             text,
    empresa_codigo    text,
    empresa_nome      text,
    tipo_veiculo      text,
    acessivel         boolean,
    ano_fabricacao    int,
    ano_modelo        int,
    dt_ref            date NOT NULL,
    created_at        timestamptz DEFAULT now(),
    CONSTRAINT unique_frota UNIQUE(prefixo, dt_ref)
);
