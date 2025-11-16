from datetime import datetime

from airflow import DAG
from airflow.utils.task_group import TaskGroup
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator

from etl.load_to_staging import load_all_staging


default_args = {
    "owner": "vini",
    "depends_on_past": False,
    "retries": 1,
}


with DAG(
    dag_id="mobilidade_curitiba_etl",
    default_args=default_args,
    start_date=datetime(2022, 2, 11),
    schedule_interval="@daily",
    catchup=False,
    tags=["mobilidade", "curitiba", "dw", "etl"],
) as dag:

    dt_ref = "{{ ds }}"  # partição de data que vai alimentar o ETL

    # STAGING
    with TaskGroup("staging_layer", tooltip="Ingestão bruta em staging") as staging_tg:
        load_staging = PythonOperator(
            task_id="load_all_staging",
            python_callable=load_all_staging,
            op_kwargs={"dt_ref": dt_ref},
        )

    # SILVER
    with TaskGroup("silver_layer", tooltip="Camada silver - dados limpos") as silver_tg:
        create_linhas_clean = PostgresOperator(
            task_id="create_linhas_clean",
            postgres_conn_id="dw_postgres",
            sql="sql/silver/01_create_linhas_clean.sql",
        )

        upsert_linhas_clean = PostgresOperator(
            task_id="upsert_linhas_clean",
            postgres_conn_id="dw_postgres",
            sql="sql/silver/02_upsert_linhas_clean.sql",
        )

        create_empresas_clean = PostgresOperator(
            task_id="create_empresas_clean",
            postgres_conn_id="dw_postgres",
            sql="""
            CREATE TABLE IF NOT EXISTS silver_mobilidade.empresas_clean (
                empresa_codigo   text NOT NULL,
                empresa_nome     text NOT NULL,
                dt_ref           date NOT NULL,
                created_at       timestamptz NOT NULL DEFAULT now(),
                CONSTRAINT empresas_clean_pk PRIMARY KEY (empresa_codigo, dt_ref)
            );
            """,
        )

        upsert_empresas_clean = PostgresOperator(
            task_id="upsert_empresas_clean",
            postgres_conn_id="dw_postgres",
            sql="sql/silver/03_upsert_empresas_clean.sql",
        )

        create_frota_clean = PostgresOperator(
            task_id="create_frota_clean",
            postgres_conn_id="dw_postgres",
            sql="""
            CREATE TABLE IF NOT EXISTS silver_mobilidade.frota_clean (
                placa              text,
                prefixo            text NOT NULL,
                empresa_codigo     text,
                empresa_nome       text,
                ano_fabricacao     integer,
                ano_modelo         integer,
                tipo_veiculo       text,
                acessivel          boolean,
                dt_ref             date NOT NULL,
                created_at         timestamptz NOT NULL DEFAULT now(),
                CONSTRAINT frota_clean_pk PRIMARY KEY(prefixo, dt_ref)
            );
            """,
        )

        upsert_frota_clean = PostgresOperator(
            task_id="upsert_frota_clean",
            postgres_conn_id="dw_postgres",
            sql="sql/silver/04_upsert_frota_clean.sql",
        )

        create_linhas_clean >> upsert_linhas_clean
        create_empresas_clean >> upsert_empresas_clean
        create_frota_clean >> upsert_frota_clean

    # GOLD
    with TaskGroup("gold_layer", tooltip="Camada gold - dim e fatos") as gold_tg:
        create_dim_linha = PostgresOperator(
            task_id="create_dim_linha",
            postgres_conn_id="dw_postgres",
            sql="sql/gold/01_create_dim_linha.sql",
        )

        upsert_dim_linha = PostgresOperator(
            task_id="upsert_dim_linha",
            postgres_conn_id="dw_postgres",
            sql="sql/gold/02_upsert_dim_linha.sql",
        )

        create_dim_empresa = PostgresOperator(
            task_id="create_dim_empresa",
            postgres_conn_id="dw_postgres",
            sql="sql/gold/03_create_dim_empresa.sql",
        )

        upsert_dim_empresa = PostgresOperator(
            task_id="upsert_dim_empresa",
            postgres_conn_id="dw_postgres",
            sql="sql/gold/04_upsert_dim_empresa.sql",
        )

        create_dim_frota = PostgresOperator(
            task_id="create_dim_frota",
            postgres_conn_id="dw_postgres",
            sql="sql/gold/05_create_dim_frota.sql",
        )

        upsert_dim_frota = PostgresOperator(
            task_id="upsert_dim_frota",
            postgres_conn_id="dw_postgres",
            sql="sql/gold/06_upsert_dim_frota.sql",
        )

        create_fato_frota = PostgresOperator(
            task_id="create_fato_frota",
            postgres_conn_id="dw_postgres",
            sql="sql/gold/07_create_fato_frota.sql",
        )

        upsert_fato_frota = PostgresOperator(
            task_id="upsert_fato_frota",
            postgres_conn_id="dw_postgres",
            sql="sql/gold/08_upsert_fato_frota.sql",
        )

        create_dim_linha >> upsert_dim_linha
        create_dim_empresa >> upsert_dim_empresa
        create_dim_frota >> upsert_dim_frota
        create_fato_frota >> upsert_fato_frota

    # Ordem das camadas
    staging_tg >> silver_tg >> gold_tg
