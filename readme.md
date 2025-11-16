# Curitiba Mobility Data Platform  
ETL com Airflow + Data Warehouse PostgreSQL + API Spring Boot


Este projeto implementa uma plataforma completa de engenharia de dados utilizando dados públicos de mobilidade urbana de Curitiba. O pipeline realiza ingestão incremental, transformação estruturada, modelagem dimensional e exposição dos dados tratados por uma API REST Java Spring Boot.
<img width="1761" height="372" alt="diagramapirest" src="https://github.com/user-attachments/assets/aad15dae-6589-424b-a4fa-b80b743c299a" />

-------------------------------------------------------------------------------

Resumo do Projeto

A solução simula um cenário real de uma empresa de transporte, enfrentando desafios como:

- grande volume de dados históricos e georreferenciados
- custo alto de processamento
- necessidade de pipelines incrementais
- padronização do Data Warehouse
- disponibilização dos dados como um data product

O objetivo é demonstrar como construir uma arquitetura moderna e escalável, unindo Airflow, Python, PostgreSQL e Spring Boot.

-------------------------------------------------------------------------------

Arquitetura Geral

flowchart LR
    A[Arquivos JSON<br/>Landing Zone] --> B[Airflow ETL]
    B --> C[Staging Layer<br/>PostgreSQL]
    C --> D[Silver Layer<br/>Curadoria e Limpeza]
    D --> E[Gold Layer<br/>Modelagem Dimensional]
    E --> F[Spring Boot API]
    F --> G[Dashboards / Aplicações Externas]

-------------------------------------------------------------------------------

Estrutura de Pastas

mobilidade-curitiba/
│
├── airflow/
│   ├── dags/
│   │   └── dag_mobilidade_curitiba.py
│   └── docker-compose.yaml
│
├── data/
│   └── landing/
│       └── dt=YYYY-MM-DD/
│           ├── linhas.json
│           ├── tabelalinha.json
│           ├── shapelinha.json
│           ├── trechos_itinerarios.json
│           ├── pontos_linha.json
│           ├── pois.json
│           └── tabelaveiculo.json
│
├── etl/
│   ├── extract_gtfs.py
│   ├── load_to_staging.py
│   ├── load_silver.py
│   ├── load_gold.py
│   ├── utils/
│   │   └── schema_validation.py
│   └── sql/
│       ├── silver/
│       └── gold/
│
├── api/
│   ├── src/main/java/com/mobility
│   ├── src/main/resources/application.yml
│   └── pom.xml
│
└── README.md

-------------------------------------------------------------------------------

Pipeline ETL

1. Landing → Staging
- Leitura dos arquivos brutos
- Validação de schema
- Padronização de colunas
- Particionamento por dt_ref
- Inserção nas tabelas raw

2. Staging → Silver
- Normalização
- Conversão de tipos
- Deduplicação
- Padronização de nomes

3. Silver → Gold (Star Schema)
Tabelas dimensionais:
- dim_linha
- dim_empresa
- dim_tempo

Tabelas fato:
- fato_viagem
- fato_frota

-------------------------------------------------------------------------------

Modelo Dimensional (Star Schema)

erDiagram

    FATO_VIAGEM {
        bigint id
        bigint linha_id
        bigint tempo_id
        int viagens_realizadas
        int passageiros
    }

    DIM_LINHA {
        bigint id
        string codigo
        string nome
        string tipo
    }

    DIM_EMPRESA {
        bigint id
        string empresa
    }

    DIM_TEMPO {
        bigint id
        date data
        int ano
        int mes
        int dia
        int dia_semana
    }

    DIM_LINHA ||--o{ FATO_VIAGEM : relaciona
    DIM_TEMPO ||--o{ FATO_VIAGEM : relaciona
    DIM_EMPRESA ||--o{ DIM_LINHA : opera

-------------------------------------------------------------------------------

Airflow: DAG

Principais características:
- TaskGroups para staging, silver e gold
- Execução incremental
- SQLs externalizados
- Retry configurado
- Organização profissional de DAG

-------------------------------------------------------------------------------

Como Rodar o Projeto

1. Subir o Airflow com Docker

cd airflow
docker-compose up -d

Inicializar o banco do Airflow:

docker exec -it airflow-standalone bash -c "airflow db init"

Acessar UI:
http://localhost:8082

-------------------------------------------------------------------------------

2. Configurar Conexões no Airflow

Connection ID: postgres_dw  
Host: host.docker.internal  
Login: postgres  
Password: sua_senha  
Database: mobilidade_dw  
Port: 5432  

-------------------------------------------------------------------------------

3. Rodar o ETL local

python etl/load_to_staging.py
python etl/load_silver.py
python etl/load_gold.py

Ou via Airflow: Trigger DAG

-------------------------------------------------------------------------------

API Spring Boot

Endpoints disponíveis:

GET /linhas/top  
GET /viagens/dia?data=AAAA-MM-DD  
GET /empresas  
GET /indicadores/geral  

Rodar a API:

cd api
./mvnw spring-boot:run

API em:
http://localhost:8080

-------------------------------------------------------------------------------

Este projeto nasceu ao explorar o dataset público de mobilidade urbana de Curitiba. O volume e variedade dos dados permitiram simular os desafios reais de uma empresa de transporte, 
como alto custo de processamento, múltiplas fontes e necessidade de padronização.
A solução implementa ingestão incremental, camadas medallion, um DW robusto e uma API REST que transforma o pipeline em produto de dados.

-------------------------------------------------------------------------------

Roadmap

[x] Camada Landing  
[x] Pipelines Airflow  
[x] Staging  
[x] Silver  
[x] Gold  
[x] API Spring Boot  


-------------------------------------------------------------------------------

Licença

MIT License
