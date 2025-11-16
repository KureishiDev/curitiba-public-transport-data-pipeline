INSERT INTO gold_mobilidade.dim_linha (
    cod,
    nome,
    somente_cartao,
    categoria_servico,
    nome_cor,
    dt_ref
)
SELECT
    cod,
    nome,
    somente_cartao,
    categoria_servico,
    nome_cor,
    dt_ref
FROM silver_mobilidade.linhas_clean
WHERE dt_ref = DATE '{{ ds }}'
ON CONFLICT (cod, dt_ref) DO UPDATE
SET
    nome              = EXCLUDED.nome,
    somente_cartao    = EXCLUDED.somente_cartao,
    categoria_servico = EXCLUDED.categoria_servico,
    nome_cor          = EXCLUDED.nome_cor,
    created_at        = now();
