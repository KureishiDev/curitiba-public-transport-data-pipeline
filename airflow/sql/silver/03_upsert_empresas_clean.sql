INSERT INTO silver_mobilidade.empresas_clean (
    empresa_codigo,
    empresa_nome,
    dt_ref
)
SELECT DISTINCT
    trim(payload_json->>'EMPRESA') AS empresa_codigo,
    initcap(lower(trim(payload_json->>'NOME_EMPRESA'))) AS empresa_nome,
    dt_ref
FROM (
    SELECT
        dt_ref,
        CAST(payload AS json) AS payload_json
    FROM staging_mobilidade.tabela_linha_raw
    WHERE dt_ref = DATE '{{ dt_ref }}'
) t
WHERE payload_json->>'EMPRESA' IS NOT NULL
  AND payload_json->>'EMPRESA' <> ''
ON CONFLICT (empresa_codigo, dt_ref) DO UPDATE
SET empresa_nome = EXCLUDED.empresa_nome,
    created_at = now();
