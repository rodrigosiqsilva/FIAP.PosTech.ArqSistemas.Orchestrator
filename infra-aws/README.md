# Guia de Infraestrutura AWS EKS e CI/CD - FIAP Cloud Games (FCG)

Este diretório contém a automação de Infraestrutura como Código (IaC) e as instruções de provisionamento e destruição para o **Tech Challenge - Fase 4**.

---

## 1. Segredos para Configurar no GitHub (GitHub Secrets)

Para que as pipelines do **GitHub Actions** em ambos os repositórios (`Catalog` e `User`) consigam realizar o build, scan de segurança (Trivy), push no Amazon ECR e deploy no Amazon EKS, adicione as seguintes **Secrets** em cada repositório no GitHub (**Settings > Secrets and variables > Actions > New repository secret**):

| Nome da Secret | Descrição | Exemplo de Valor |
| :--- | :--- | :--- |
| `AWS_ACCESS_KEY_ID` | Chave de Acesso IAM do usuário AWS | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Segredo IAM do usuário AWS | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_REGION` | Região da AWS utilizada | `us-east-1` |
| `EKS_CLUSTER_NAME` | Nome do cluster Kubernetes | `fiap-fcg-cluster` |
| `MONGODB_CONNECTIONSTRING`| String de conexão segura do MongoDB Atlas | `mongodb+srv://rodrigosiqsilva_db_user:OEXxbVjZ2QoLSxoQ@fcg-cluster.idk7w4j.mongodb.net/?retryWrites=true&w=majority&appName=fcg-cluster` |

---

## 2. Roteiro de Provisionamento (Dia dos Testes e Gravação do Vídeo)

Para garantir **custo próximo a zero**, você provisiona o cluster apenas no momento de validar e gravar a demonstração, destruindo-o logo em seguida.

### 2.1. Subir o Cluster
No PowerShell, execute:
```powershell
cd C:\Sistemas\FIAP\FIAP.PosTech.ArqSistemas.Orchestrator\infra-aws
.\up.ps1
```
Esse script automatiza os 4 passos essenciais:
1. Cria o cluster gerenciado EKS com nós `c7i-flex.large` via `eksctl`;
2. Atualiza o `kubeconfig` local e libera visualização para o usuário root no console AWS;
3. Cria a Secret do Kubernetes `mongodb-secret` com a connection string do MongoDB Atlas (Zero Hardcoded Credentials);
4. Sobe os Pods de apoio **Redis** e **Elasticsearch** no cluster através dos manifestos `redis-infra.yaml` e `elasticsearch-infra.yaml`.

---

### 2.2. Executar o Live Deploy via GitHub Actions
1. Faça uma pequena alteração no código (ex.: na mensagem de boas-vindas do Swagger em `Program.cs`);
2. Realize o commit e envie para a branch `master`/`main`:
   ```bash
   git commit -am "feat: demonstracao live deploy"
   git push origin master
   ```
3. Abra a aba **Actions** no GitHub e mostre o workflow executando as etapas:
   - Build & Unit Tests (.NET 10)
   - Login no Amazon ECR
   - Criação da Imagem Docker taggeada
   - Security Scan via Trivy
   - Push no Amazon ECR
   - Deploy no EKS com **Rolling Update** sem downtime!

---

### 2.3. Destruir o Cluster (Garantia de Fatura Zero!)
Assim que terminar os testes e a gravação do vídeo:
```powershell
cd C:\Sistemas\FIAP\FIAP.PosTech.ArqSistemas.Orchestrator\infra-aws
.\down.ps1
```
Esse comando deleta os Load Balancers, os Worker Nodes EC2 e o plano de controle do EKS, cessando imediatamente qualquer cobrança na AWS.
