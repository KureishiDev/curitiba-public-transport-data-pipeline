INSERT INTO silver_mobilidade.linhas_clean (
    cod,
    nome,
    somente_cartao,
    categoria_servico,
    nome_cor,
    dt_ref
)
SELECT
    trim(cod) as cod,
    initcap(lower(trim(nome))) as nome,
    CASE
        WHEN upper(trim(somente_cartao)) IN ('S', 'SIM', 'Y') THEN true
        WHEN upper(trim(somente_cartao)) IN ('N', 'NAO', 'NÃO', 'NO') THEN false
        ELSE null
    END as somente_cartao,
    trim(categoria_servico) as categoria_servico,
    trim(nome_cor) as nome_cor,
    dt_ref
FROM staging_mobilidade.linhas_raw
WHERE dt_ref = DATE '{{ dt_ref }}'
ON CONFLICT (cod, dt_ref) DO UPDATE
SET
    nome              = EXCLUDED.nome,
    somente_cartao    = EXCLUDED.somente_cartao,
    categoria_servico = EXCLUDED.categoria_servico,
    nome_cor          = EXCLUDED.nome_cor,
    created_at        = now();
