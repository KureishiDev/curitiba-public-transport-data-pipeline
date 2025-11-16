INSERT INTO gold_mobilidade.fato_frota (
    dt_ref,
    empresa_codigo,
    total_veiculos,
    veiculos_acessiveis,
    idade_media
)
SELECT
    dt_ref,
    empresa_codigo,
    COUNT(*)                                        AS total_veiculos,
    SUM(CASE WHEN acessivel THEN 1 ELSE 0 END)     AS veiculos_acessiveis,
    AVG(EXTRACT(YEAR FROM CURRENT_DATE)::int - ano_fabricacao) AS idade_media
FROM silver_mobilidade.frota_clean
WHERE dt_ref = DATE '{{ ds }}'
GROUP BY dt_ref, empresa_codigo
ON CONFLICT (dt_ref, empresa_codigo) DO UPDATE
SET
    total_veiculos      = EXCLUDED.total_veiculos,
    veiculos_acessiveis = EXCLUDED.veiculos_acessiveis,
    idade_media         = EXCLUDED.idade_media,
    created_at          = now();
