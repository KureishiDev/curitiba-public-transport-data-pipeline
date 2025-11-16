INSERT INTO gold_mobilidade.dim_empresa (
    empresa_codigo,
    empresa_nome,
    dt_ref
)
SELECT
    empresa_codigo,
    empresa_nome,
    dt_ref
FROM silver_mobilidade.empresas_clean
WHERE dt_ref = DATE '{{ ds }}'
ON CONFLICT (empresa_codigo, dt_ref) DO UPDATE
SET
    empresa_nome = EXCLUDED.empresa_nome,
    created_at   = now();
