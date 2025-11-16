INSERT INTO silver_mobilidade.frota_clean (
    placa,
    prefixo,
    empresa_codigo,
    empresa_nome,
    ano_fabricacao,
    ano_modelo,
    tipo_veiculo,
    acessivel,
    dt_ref
)
SELECT DISTINCT
    trim(payload_json->>'PLACA')                       AS placa,
    trim(payload_json->>'PREFIXO')                     AS prefixo,
    trim(payload_json->>'EMPRESA')                     AS empresa_codigo,
    initcap(lower(trim(payload_json->>'NOME_EMPRESA'))) AS empresa_nome,
    NULLIF(payload_json->>'ANO_FABRICACAO', '')::int   AS ano_fabricacao,
    NULLIF(payload_json->>'ANO_MODELO', '')::int       AS ano_modelo,
    trim(payload_json->>'TIPO_VEICULO')                AS tipo_veiculo,
    CASE
        WHEN upper(payload_json->>'VEICULO_ACESSIVEL') IN ('S','SIM','Y','1','TRUE') THEN true
        WHEN upper(payload_json->>'VEICULO_ACESSIVEL') IN ('N','NAO','NÃO','NO','0','FALSE') THEN false
        ELSE null
    END                                               AS acessivel,
    dt_ref
FROM (
    SELECT
        dt_ref,
        CAST(payload AS json) AS payload_json
    FROM staging_mobilidade.tabela_veiculo_raw
    WHERE dt_ref = DATE '{{ ds }}'
) t
WHERE payload_json->>'PREFIXO' IS NOT NULL
ON CONFLICT (prefixo, dt_ref) DO UPDATE
SET
    placa          = EXCLUDED.placa,
    empresa_codigo = EXCLUDED.empresa_codigo,
    empresa_nome   = EXCLUDED.empresa_nome,
    ano_fabricacao = EXCLUDED.ano_fabricacao,
    ano_modelo     = EXCLUDED.ano_modelo,
    tipo_veiculo   = EXCLUDED.tipo_veiculo,
    acessivel      = EXCLUDED.acessivel,
    created_at     = now();
