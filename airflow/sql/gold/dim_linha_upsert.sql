CREATE SCHEMA IF NOT EXISTS gold_mobilidade;

INSERT INTO gold_mobilidade.dim_linha AS d (
    cod_linha,
    nome_linha,
    somente_cartao,
    categoria_servico,
    nome_cor
)
SELECT DISTINCT
    cod,
    nome,
    somente_cartao,
    categoria_servico,
    nome_cor
FROM silver_mobilidade.linhas_clean
WHERE dt_ref = '{{ ds }}'
ON CONFLICT (cod_linha) DO UPDATE
SET 
    nome_linha       = EXCLUDED.nome_linha,
    somente_cartao   = EXCLUDED.somente_cartao,
    categoria_servico = EXCLUDED.categoria_servico,
    nome_cor         = EXCLUDED.nome_cor;
