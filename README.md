# FIAP.PosTech.ArqSistemas.Orchestrator

Centraliza e armazena todos os manifestos e arquivos de configuração necessários para a orquestração das aplicações do ecossistema.

---

## 🚀 Começando

Este repositório contém os seguintes arquivos de configuração e scripts:

* **`docker-compose.yaml`**: Utilizado para orquestrar e rodar os containers em ambiente de desenvolvimento **local**.
* **`docker-localstack.yml`**: Arquivo de configuração Docker Compose para subir o container do **LocalStack** (emulação de serviços AWS).
* **`deploy-localstack.ps1`**: Script PowerShell para automatizar a compilação, o deploy e a configuração da função Lambda de notificações e o mapeamento de gatilhos do Kafka no LocalStack.
* **`docker-compose-kong.yml`**: Arquivo Docker Compose para orquestração da infraestrutura do API Gateway **Kong**, seu banco de dados PostgreSQL e a interface visual **Konga**.
* **`docker-compose-mongodb.yaml`**: Arquivo Docker Compose para orquestração do banco de dados **MongoDB** e da interface visual **Mongo Express** (com suporte à conexão via **MongoDB Compass**).
* **`docker-compose-zabbix.yaml`**: Arquivo Docker Compose para subir a infraestrutura de monitoramento do **Zabbix** (Server, Web Interface, Agent e banco PostgreSQL).
* **`docker-compose - zabbix e prometheus.yaml`**: Arquivo Docker Compose para subir a infraestrutura de monitoramento combinada do **Zabbix** e **Prometheus** (incluindo aplicação .NET para exportação de métricas).
* **`docker-compose - zabbix e prometheus e grafana.yaml`**: Arquivo Docker Compose para subir a infraestrutura completa de monitoramento combinando **Zabbix**, **Prometheus** e **Grafana** (incluindo visualizações e dashboards em tempo real).
* **`fiap-apis-dashboard.json`**: Arquivo JSON contendo o Dashboard pré-configurado do Grafana para monitoramento em tempo real da `CatalogAPI` e `UserAPI` (latência, contagem de requisições e taxa de erros).
* **`kafka-infra.yaml`**: Manifesto Kubernetes para subir a infraestrutura do Kafka.
* **`config-and-secrets.yaml`**: Manifesto Kubernetes para deploy das configurações e segredos das APIs (`catalog-api` e `user-api`) e dos serviços de background (Workers).
* **`applications-deployment.yaml`**: Manifesto Kubernetes para deploy das APIs (`catalog-api` e `user-api`) e dos serviços de background (Workers).

### 🛠️ Como Executar

#### 1. Execução via Docker (Desenvolvimento Local)

```bash
# Subir os containers das aplicações e serviços base
docker compose up -d

# Subir o ambiente LocalStack (AWS local)
docker compose -f docker-localstack.yml up -d

# Executar o deploy da função Lambda e integração com Kafka no LocalStack (PowerShell)
.\deploy-localstack.ps1

# Subir o API Gateway Kong, Banco de Dados e Konga
docker compose -f docker-compose-kong.yml up -d

# Subir o banco de dados MongoDB e Mongo Express
docker compose -f docker-compose-mongodb.yaml up -d

# Subir a infraestrutura de monitoramento do Zabbix
docker compose -f docker-compose-zabbix.yaml up -d

# Subir a infraestrutura de monitoramento do Zabbix e Prometheus
docker compose -f "docker-compose - zabbix e prometheus.yaml" up -d

# Subir a infraestrutura completa de monitoramento (Zabbix, Prometheus e Grafana)
docker compose -f "docker-compose - zabbix e prometheus e grafana.yaml" up -d
```

#### 2. Execução via Kubernetes

```bash
# 1. Sobe a infraestrutura do Kafka
kubectl apply -f kafka-infra.yaml

# 2. Cria todas as configurações e secrets
kubectl apply -f config-and-secrets.yaml

# 3. Sobe as APIs e os Workers consumindo os dados criados acima
kubectl apply -f applications-deployment.yaml
```

#### 3. Importação do Dashboard no Grafana

1. Acesse o Grafana em **[http://localhost:3000](http://localhost:3000)** (Usuário: `admin` | Senha: `admin`).
2. Caso ainda não tenha a fonte de dados configurada, acesse **Connections -> Data sources -> Add data source**, selecione **Prometheus**, informe a URL `http://host.docker.internal:9090` (ou `http://prometheus:9090`) e clique em **Save & test**.
3. No menu lateral, acesse **Dashboards -> New -> Import**.
4. Clique em **Upload dashboard JSON file** e selecione o arquivo:
   `C:\Sistemas\FIAP\FIAP.PosTech.ArqSistemas.Orchestrator\fiap-apis-dashboard.json`
5. Selecione a fonte de dados **Prometheus** e clique no botão **Import**.

#### 4. Conexão ao MongoDB (MongoDB Compass / Mongo Express)

1. **MongoDB Compass (Desktop App)**:
   - Abra o **MongoDB Compass** no Windows.
   - Na tela inicial, cole a string de conexão:
     `mongodb://admin:adminpassword@localhost:27017`
   - Clique em **Connect**.

2. **Mongo Express (Interface Web)**:
   - Acesse **[http://localhost:8081](http://localhost:8081)** no navegador.
   - Utilize as credenciais de Acesso Básico: Usuário `admin` | Senha `admin`.

---

## 📋 Pré-requisitos

### 1. Ferramentas Necessárias
Certifique-se de ter instalado em sua máquina:
* [Docker](https://docs.docker.com/get-docker/)
* [Kubernetes (kubectl / Minikube / Docker Desktop)](https://kubernetes.io/docs/setup/)
* [.NET SDK 8.0 e .NET SDK 10.0](https://dotnet.microsoft.com/en-us/download)

### 2. Repositórios do Ecossistema
Você precisará clonar os seguintes repositórios do projeto:

| Repositório | Link para Clone |
| :--- | :--- |
| **Orchestrator** (Este repositório) | `https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.Orchestrator.git` |
| **Catalog API** | `https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.Catalog.git` |
| **User API** | `https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.User.git` |
| **Notification Service** | `https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.Notification.git` |
| **Payments Service** | `https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.Payments.git` |

### 📂 Estrutura de Pastas Obrigatória
Para que os arquivos de orquestração local (Docker Compose) referenciem os projetos corretamente, você **deve** respeitar a seguinte estrutura de diretórios no seu disco:

Veja um exemplo através da imagem: https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.Orchestrator/blob/main/Estrututa%20pastas.png

```text
C:\Sistemas\FIAP\     <- (Arquivos de orquestração e scripts mencionados aqui)
├── FIAP.PosTech.ArqSistemas.Catalog/
├── FIAP.PosTech.ArqSistemas.User/
├── FIAP.PosTech.ArqSistemas.Notification/
└── FIAP.PosTech.ArqSistemas.Payments/