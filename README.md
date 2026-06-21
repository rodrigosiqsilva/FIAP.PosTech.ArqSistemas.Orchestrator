# FIAP.PosTech.ArqSistemas.Orchestrator

Centraliza e armazena todos os manifestos e arquivos de configuração necessários para a orquestração das aplicações do ecossistema.

---

## 🚀 Começando

Este repositório contém os seguintes arquivos de configuração:

* **`docker-compose.yaml`**: Utilizado para orquestrar e rodar os containers em ambiente de desenvolvimento **local**.
* **`kafka-infra.yaml`**: Manifesto Kubernetes para subir a infraestrutura do Kafka.
* **`config-and-secrets.yaml`**: Manifesto Kubernetes para deploy das configurações e segredos das APIs (`catalog-api` e `user-api`) e dos serviços de background (Workers).
* **`applications-deployment.yaml`**: Manifesto Kubernetes para deploy das APIs (`catalog-api` e `user-api`) e dos serviços de background (Workers).

# 1. Cria todas as configurações e secrets primeiro
kubectl apply -f config-and-secrets.yaml

# 2. Sobe as APIs e os Workers consumindo os dados criados acima
kubectl apply -f applications-deployment.yaml

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
C:\Sistemas\FIAP\     <- (Arquivos de orquestração os 4 yamls mencionados aqui)
├── FIAP.PosTech.ArqSistemas.Catalog/
├── FIAP.PosTech.ArqSistemas.User/
├── FIAP.PosTech.ArqSistemas.Notification/
└── FIAP.PosTech.ArqSistemas.Payments/