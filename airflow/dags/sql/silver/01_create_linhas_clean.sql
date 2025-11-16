CREATE TABLE IF NOT EXISTS silver_mobilidade.linhas_clean (
    cod               text      NOT NULL,
    nome              text      NOT NULL,
    somente_cartao    boolean,
    categoria_servico text,
    nome_cor          text,
    dt_ref            date      NOT NULL,
    created_at        timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT linhas_clean_pk PRIMARY KEY (cod, dt_ref)
);
