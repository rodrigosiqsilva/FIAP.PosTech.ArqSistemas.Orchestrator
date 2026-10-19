# Script para Subir a Infraestrutura EKS na AWS
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Provisionando Cluster Amazon EKS: fiap-fcg-cluster" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Provisiona o cluster EKS (ou apenas o NodeGroup se o Control Plane já estiver ativo)
$eksctlCmd = if (Test-Path "$PSScriptRoot\eksctl.exe") { 
    "$PSScriptRoot\eksctl.exe" 
} elseif (Test-Path "$PSScriptRoot\..\..\infra-aws\eksctl.exe") {
    "$PSScriptRoot\..\..\infra-aws\eksctl.exe"
} else { 
    "eksctl" 
}

$clusterStatus = aws eks describe-cluster --name fiap-fcg-cluster --region us-east-1 --query "cluster.status" --output text 2>$null

if ($clusterStatus -eq "ACTIVE") {
    Write-Host "Control Plane 'fiap-fcg-cluster' já ATIVO! Verificando/criando NodeGroup com instância (c7i-flex.large)..." -ForegroundColor Yellow
    aws cloudformation wait stack-delete-complete --stack-name eksctl-fiap-fcg-cluster-nodegroup-fcg-workers --region us-east-1 2>$null
    & $eksctlCmd create nodegroup -f "$PSScriptRoot\cluster.yaml"
} else {
    & $eksctlCmd create cluster -f "$PSScriptRoot\cluster.yaml"
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro ao criar o cluster/nodegroup EKS. Verifique as mensagens acima." -ForegroundColor Red
    exit $LASTEXITCODE
}

# 2. Atualiza o kubeconfig local e libera visualizacao no Console Web da AWS (usuario Root)
Write-Host "Configurando acesso ao cluster..." -ForegroundColor Cyan
aws eks update-kubeconfig --name fiap-fcg-cluster --region us-east-1
$accountId = aws sts get-caller-identity --query "Account" --output text
aws eks create-access-entry --cluster-name fiap-fcg-cluster --principal-arn "arn:aws:iam::${accountId}:root" --region us-east-1 2>$null
aws eks associate-access-policy --cluster-name fiap-fcg-cluster --principal-arn "arn:aws:iam::${accountId}:root" --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy --access-scope type=cluster --region us-east-1 2>$null

# 3. Cria o segredo do MongoDB Atlas no Kubernetes
Write-Host "Criando secret do MongoDB Atlas..." -ForegroundColor Cyan
$mongoConn = "mongodb+srv://rodrigosiqsilva_db_user:OEXxbVjZ2QoLSxoQ@fcg-cluster.idk7w4j.mongodb.net/?retryWrites=true&w=majority&appName=fcg-cluster"
kubectl create secret generic mongodb-secret --from-literal=connection-string="$mongoConn" --dry-run=client -o yaml | kubectl apply -f -

# 4. Sobe os pods de infraestrutura (Redis e Elasticsearch)
Write-Host "Aplicando manifestos de Redis e Elasticsearch..." -ForegroundColor Cyan
$orchestratorDir = Split-Path -Parent $PSScriptRoot

if (Test-Path "$orchestratorDir\redis-infra.yaml") {
    kubectl apply -f "$orchestratorDir\redis-infra.yaml"
} else {
    kubectl apply -f "$orchestratorDir\..\FIAP.PosTech.ArqSistemas.Catalog\FIAP.PosTech.ArqSistemas.CatalogAPI\K8S\redis.yml"
}

if (Test-Path "$orchestratorDir\elasticsearch-infra.yaml") {
    kubectl apply -f "$orchestratorDir\elasticsearch-infra.yaml"
} else {
    kubectl apply -f "$orchestratorDir\..\FIAP.PosTech.ArqSistemas.Catalog\FIAP.PosTech.ArqSistemas.CatalogAPI\K8S\elasticsearch.yml"
}

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Cluster EKS e infraestrutura de apoio implantados com sucesso!" -ForegroundColor Green
Write-Host "Execute 'kubectl get pods' para checar o status dos pods." -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Green
