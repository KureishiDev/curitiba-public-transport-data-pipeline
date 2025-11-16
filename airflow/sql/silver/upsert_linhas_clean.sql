CREATE SCHEMA IF NOT EXISTS silver_mobilidade;

INSERT INTO silver_mobilidade.linhas_clean AS c (
    cod,
    nome,
    somente_cartao,
    categoria_servico,
    nome_cor,
    dt_ref
)
SELECT DISTINCT
    trim(cod),
    trim(nome),
    UPPER(TRIM(somente_cartao)),
    UPPER(TRIM(categoria_servico)),
    UPPER(TRIM(nome_cor)),
    dt_ref
FROM staging_mobilidade.linhas_raw s
WHERE s.dt_ref = '{{ ds }}'
ON CONFLICT (cod, dt_ref) DO UPDATE
SET 
    nome = EXCLUDED.nome,
    somente_cartao = EXCLUDED.somente_cartao,
    categoria_servico = EXCLUDED.categoria_servico,
    nome_cor = EXCLUDED.nome_cor;
