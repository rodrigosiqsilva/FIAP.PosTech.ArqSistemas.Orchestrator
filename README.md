# FIAP.PosTech.ArqSistemas.Orchestrator

Centraliza e armazena todos os manifestos de infraestrutura, arquivos de orquestração local (Docker Compose), manifestos de orquestração em contêineres (Kubernetes) e scripts de Infraestrutura como Código (IaC) para nuvem (Amazon EKS) do ecossistema **FIAP Cloud Games (FCG)**.

---

## 🚀 Começando

Este repositório contém os seguintes arquivos de configuração, manifestos e scripts:

### 🐳 Orquestração Local (Docker Compose)
* **`docker-compose.yaml`**: Utilizado para orquestrar e rodar as APIs e serviços de background em ambiente de desenvolvimento **local** com Kafka.
* **`docker-compose-elasticsearch.yaml`**: Sobe o serviço do **Elasticsearch** (portas `9200`/`9300`) com segurança desabilitada e single-node para busca avançada local.
* **`docker-compose-redis.yaml`**: Sobe o banco de dados/cache em memória **Redis** (porta `6379`) com persistência AOF habilitada e interface visual **Redis Insight** (porta `5540`).
* **`docker-compose-mongodb.yaml`**: Sobe o banco de dados **MongoDB** (porta `27017`) e a interface visual **Mongo Express** (porta `8081`).
* **`docker-compose-kong.yml`**: Orquestra o API Gateway **Kong**, seu banco de dados PostgreSQL e a interface visual **Konga**.
* **`docker-localstack.yml`** & **`deploy-localstack.ps1`**: Configuração e script para emulação de serviços AWS (Lambda e gatilhos Kafka) no **LocalStack**.
* **`docker-compose-zabbix.yaml`**: Infraestrutura de monitoramento do **Zabbix** (Server, Web Interface, Agent e PostgreSQL).
* **`docker-compose - zabbix e prometheus.yaml`**: Monitoramento combinado do **Zabbix** e **Prometheus** com exportação de métricas.
* **`docker-compose - zabbix e prometheus e grafana.yaml`**: Stack completa de observabilidade (**Zabbix**, **Prometheus** e **Grafana**).
* **`fiap-apis-dashboard.json`**: Dashboard pré-configurado do Grafana para métricas em tempo real da `CatalogAPI` e `UserAPI`.

### ☸️ Manifestos Kubernetes (On-Premises / Cluster)
* **`kafka-infra.yaml`**: Manifesto Kubernetes para subir o Zookeeper e o broker do Apache Kafka.
* **`redis-infra.yaml`**: Deployment e Service (ClusterIP) do **Redis 7** para cache distribuído.
* **`elasticsearch-infra.yaml`**: Deployment e Service (ClusterIP) do **Elasticsearch** para busca avançada e relevância.
* **`config-and-secrets.yaml`**: ConfigMaps e Secrets para parametrização das APIs e Workers.
* **`applications-deployment.yaml`**: Deployments e Services das aplicações (`catalog-api`, `user-api` e workers).

### ☁️ Infraestrutura em Nuvem AWS (Amazon EKS - Tech Challenge Fase 4)
* **`infra-aws/cluster.yaml`**: Arquivo de definição do cluster gerenciado Amazon EKS via `eksctl` (nós `c7i-flex.large` com capacidade escalável de 1 a 3 instâncias).
* **`infra-aws/up.ps1`**: Script de automação total que provisiona o cluster EKS na AWS, ajusta credenciais de admin root no console web, configura a Secret do MongoDB Atlas e sobe os pods de apoio (**Redis** e **Elasticsearch**).
* **`infra-aws/down.ps1`**: Script para deleção dos Load Balancers, recursos e do cluster EKS, garantindo **custo zero** após a execução/apresentação.
* **`infra-aws/README.md`**: Guia passo a passo com secrets do GitHub Actions, roteiro de deploy e ciclo de vida na AWS.

---

## 🛠️ Como Executar

### 1. Execução via Docker (Desenvolvimento Local)

```bash
# Subir os containers das aplicações e serviços base (Kafka e APIs)
docker compose up -d

# Subir o Elasticsearch (Busca Avançada)
docker compose -f docker-compose-elasticsearch.yaml up -d

# Subir o Redis e Redis Insight (Cache Distribuído)
docker compose -f docker-compose-redis.yaml up -d

# Subir o banco de dados MongoDB e Mongo Express
docker compose -f docker-compose-mongodb.yaml up -d

# Subir o ambiente LocalStack (AWS local)
docker compose -f docker-localstack.yml up -d
.\deploy-localstack.ps1

# Subir o API Gateway Kong e Konga
docker compose -f docker-compose-kong.yml up -d

# Subir a infraestrutura completa de monitoramento (Zabbix, Prometheus e Grafana)
docker compose -f "docker-compose - zabbix e prometheus e grafana.yaml" up -d
```

---

### 2. Execução via Kubernetes (Local / Minikube / Docker Desktop)

```bash
# 1. Sobe a infraestrutura de mensageria (Kafka)
kubectl apply -f kafka-infra.yaml

# 2. Sobe os pods de infraestrutura de dados (Redis e Elasticsearch)
kubectl apply -f redis-infra.yaml
kubectl apply -f elasticsearch-infra.yaml

# 3. Cria todas as configurações e secrets
kubectl apply -f config-and-secrets.yaml

# 4. Sobe as APIs e os Workers consumindo os dados criados acima
kubectl apply -f applications-deployment.yaml
```

---

### 3. Execução em Nuvem: Amazon EKS (Fase 4)

Para validar a infraestrutura completa em nuvem com CI/CD automatizado via GitHub Actions e Amazon ECR:

1. **Subir o Cluster e a Infraestrutura Base:**
   ```powershell
   cd infra-aws
   .\up.ps1
   ```
   *O script provisionará o EKS, configurará a secret do MongoDB Atlas e aplicará os manifestos do Redis e Elasticsearch.*

2. **Deploy Contínuo das Aplicações:**
   - Faça push na branch `master`/`main` dos repositórios `Catalog` ou `User`.
   - As pipelines do **GitHub Actions** executarão build, testes, scan de vulnerabilidades com **Trivy**, publicação no **Amazon ECR** e deploy com **Rolling Update** no Amazon EKS.

3. **Destruir o Cluster (Garantia de Fatura Zero):**
   ```powershell
   cd infra-aws
   .\down.ps1
   ```

---

### 4. Observabilidade e Interfaces Visuais

#### Grafana (Dashboards)
* **URL**: [http://localhost:3000](http://localhost:3000) (Usuário: `admin` | Senha: `admin`)
* **Importação**: Vá em **Dashboards -> New -> Import**, selecione o arquivo [`fiap-apis-dashboard.json`](./fiap-apis-dashboard.json) e aponte para a fonte de dados do Prometheus.

#### Redis Insight
* **URL**: [http://localhost:5540](http://localhost:5540)
* **Conexão**: Host `redis` (ou `localhost`), Porta `6379`.

#### Mongo Express
* **URL**: [http://localhost:8081](http://localhost:8081) (Usuário: `admin` | Senha: `admin`)
* **MongoDB Compass**: String `mongodb://admin:adminpassword@localhost:27017`

#### Elasticsearch (Health Check)
* **URL**: [http://localhost:9200](http://localhost:9200)
* **Índice Padrão de Jogos**: `http://localhost:9200/games`

---

## 📋 Pré-requisitos

### 1. Ferramentas Necessárias
* [Docker & Docker Desktop](https://docs.docker.com/get-docker/)
* [Kubernetes CLI (kubectl)](https://kubernetes.io/docs/tasks/tools/)
* [AWS CLI v2](https://aws.amazon.com/cli/) e [eksctl](https://eksctl.io/)
* [.NET SDK 8.0 e .NET SDK 10.0](https://dotnet.microsoft.com/en-us/download)

### 2. Repositórios do Ecossistema

| Repositório | Descrição | Link para Clone |
| :--- | :--- | :--- |
| **Orchestrator** | Manifestos K8s, Docker e IaC AWS EKS | `https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.Orchestrator.git` |
| **Catalog API** | Catálogo, Redis Cache e Elasticsearch | `https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.Catalog.git` |
| **User API** | Autenticação, Usuários e Gestão | `https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.User.git` |
| **Notification Service** | Notificações via Kafka / Worker Service | `https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.Notification.git` |
| **Payments Service** | Processamento de Pagamentos | `https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.Payments.git` |

### 📂 Estrutura de Pastas Obrigatória

Para que as referências relativas dos scripts funcionem perfeitamente, organize seus repositórios no disco da seguinte forma:

```text
C:\Sistemas\FIAP\
├── FIAP.PosTech.ArqSistemas.Orchestrator/  <- (Repositório Central de Orquestração)
│   ├── infra-aws/                        <- (IaC do Amazon EKS: cluster.yaml, up.ps1, down.ps1)
│   ├── elasticsearch-infra.yaml          <- (Manifesto K8s Elasticsearch)
│   ├── redis-infra.yaml                  <- (Manifesto K8s Redis)
│   ├── docker-compose-elasticsearch.yaml <- (Compose Elasticsearch local)
│   └── ...
├── FIAP.PosTech.ArqSistemas.Catalog/
├── FIAP.PosTech.ArqSistemas.User/
├── FIAP.PosTech.ArqSistemas.Notification/
└── FIAP.PosTech.ArqSistemas.Payments/
```