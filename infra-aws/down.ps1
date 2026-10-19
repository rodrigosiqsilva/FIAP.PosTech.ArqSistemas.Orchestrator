# Script para Destruir o Cluster e Zerar Custos na AWS
Write-Host "==========================================================" -ForegroundColor Red
Write-Host "ATENÇÃO: Destruindo Cluster Amazon EKS: fiap-fcg-cluster" -ForegroundColor Red
Write-Host "==========================================================" -ForegroundColor Red

# 1. Remove os serviços tipo LoadBalancer e pods para liberar recursos de rede na AWS
$orchestratorDir = Split-Path -Parent $PSScriptRoot
$catalogDir = "$orchestratorDir\..\FIAP.PosTech.ArqSistemas.Catalog\FIAP.PosTech.ArqSistemas.CatalogAPI\K8S"
$userDir = "$orchestratorDir\..\FIAP.PosTech.ArqSistemas.User\FIAP.PosTech.ArqSistemas.UserAPI\K8S"

Write-Host "Deletando deployments e services das aplicações..." -ForegroundColor Yellow
if (Test-Path "$catalogDir\deployment.yml") {
    kubectl delete -f "$catalogDir\deployment.yml" --ignore-not-found
}
if (Test-Path "$userDir\deployment.yml") {
    kubectl delete -f "$userDir\deployment.yml" --ignore-not-found
}

if (Test-Path "$orchestratorDir\redis-infra.yaml") {
    kubectl delete -f "$orchestratorDir\redis-infra.yaml" --ignore-not-found
} elseif (Test-Path "$catalogDir\redis.yml") {
    kubectl delete -f "$catalogDir\redis.yml" --ignore-not-found
}

if (Test-Path "$orchestratorDir\elasticsearch-infra.yaml") {
    kubectl delete -f "$orchestratorDir\elasticsearch-infra.yaml" --ignore-not-found
} elseif (Test-Path "$catalogDir\elasticsearch.yml") {
    kubectl delete -f "$catalogDir\elasticsearch.yml" --ignore-not-found
}

# 2. Destrói o cluster EKS e os Worker Nodes EC2 completamente
$eksctlCmd = if (Test-Path "$PSScriptRoot\eksctl.exe") { 
    "$PSScriptRoot\eksctl.exe" 
} elseif (Test-Path "$PSScriptRoot\..\..\infra-aws\eksctl.exe") {
    "$PSScriptRoot\..\..\infra-aws\eksctl.exe"
} else { 
    "eksctl" 
}

Write-Host "Deletando cluster EKS via eksctl..." -ForegroundColor Yellow
& $eksctlCmd delete cluster -f "$PSScriptRoot\cluster.yaml" --wait

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "Cluster destruído com sucesso. Custos de EKS/EC2 paralisados!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
