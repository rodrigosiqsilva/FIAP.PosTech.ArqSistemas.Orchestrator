# Script de Deploy e Configuração do LocalStack para a Lambda de Notificações
# Requisitos: LocalStack CLI, AWS CLI, .NET 8 SDK

$ErrorActionPreference = "Stop"

Write-Host "=== 1. Configurando Autenticação e Variáveis do LocalStack ===" -ForegroundColor Cyan
localstack auth set-token ls-MeME8033-liKi-fOsA-zODI-JaXIGOruc4a7
$env:LOCALSTACK_ACKNOWLEDGE_ACCOUNT_REQUIREMENT="1"

Write-Host "=== 2. Iniciando o Daemon do LocalStack ===" -ForegroundColor Cyan
localstack start -d

Write-Host "=== 3. Conectando a rede Docker do Kafka ===" -ForegroundColor Cyan
$ErrorActionPreference = "SilentlyContinue"
docker network connect fiap_default localstack-main 2>$null
$kafkaIp = docker inspect kafka -f "{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" 2>$null
if ($kafkaIp) {
    docker exec localstack-main sh -c "grep -q 'kafka' /etc/hosts || echo '$kafkaIp kafka' >> /etc/hosts" 2>$null
}
$ErrorActionPreference = "Stop"

Write-Host "=== 4. Configurando Profile AWS CLI 'localstack' ===" -ForegroundColor Cyan
aws configure set aws_access_key_id test --profile localstack
aws configure set aws_secret_access_key test --profile localstack
aws configure set region us-east-1 --profile localstack
aws configure set output json --profile localstack

Write-Host "=== 5. Publicando o Projeto .NET 8 Lambda ===" -ForegroundColor Cyan
$publishPath = ".\bin\Release\net8.0\publish"
if (Test-Path $publishPath) { Remove-Item -Recurse -Force $publishPath }
dotnet publish -c Release -o $publishPath

Write-Host "=== 6. Empacotando Lambda em Arquivo ZIP ===" -ForegroundColor Cyan
$zipPath = ".\function.zip"
if (Test-Path $zipPath) { Remove-Item -Force $zipPath }
Compress-Archive -Path "$publishPath\*" -DestinationPath $zipPath -Force

Write-Host "=== 7. Deploy da Função Lambda no LocalStack ===" -ForegroundColor Cyan
$functionName = "NotificationLambda"
$endpointUrl = "http://localhost.localstack.cloud:4566"

$existingFunction = $null
$prevErrorAction = $ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
try {
    $existingFunction = aws lambda get-function --function-name $functionName --endpoint-url $endpointUrl --profile localstack 2>$null
} catch {
    $existingFunction = $null
}
$ErrorActionPreference = $prevErrorAction

$envVars = 'Variables={SMTP_SERVER=smtp.gmail.com,SMTP_PORT=587,SMTP_USERNAME=fiapcloudgames5@gmail.com,SMTP_PASSWORD="hfoo hama dssx fezu"}'

if ($existingFunction -and $LASTEXITCODE -eq 0) {
    Write-Host "Atualizando código e configurações da função Lambda existente..." -ForegroundColor Yellow
    aws lambda update-function-code `
        --function-name $functionName `
        --zip-file "fileb://$zipPath" `
        --endpoint-url $endpointUrl `
        --profile localstack

    aws lambda update-function-configuration `
        --function-name $functionName `
        --environment $envVars `
        --endpoint-url $endpointUrl `
        --profile localstack
} else {
    Write-Host "Criando nova função Lambda..." -ForegroundColor Green
    aws lambda create-function `
        --function-name $functionName `
        --runtime dotnet8 `
        --role arn:aws:iam::000000000000:role/lambda-role `
        --handler "FIAP.PosTech.ArqSistemas.Notification.Lambda::FIAP.PosTech.ArqSistemas.Notification.Lambda.Function::FunctionHandler" `
        --environment $envVars `
        --zip-file "fileb://$zipPath" `
        --timeout 30 `
        --endpoint-url $endpointUrl `
        --profile localstack
}

Write-Host "=== 8. Mapeando Triggers do Kafka (Event Source Mapping) ===" -ForegroundColor Cyan
# Tópicos do Kafka na rede interna do Docker (kafka:29092)
$kafkaBootstrap = "kafka:29092"
$topics = @("user-created-topic", "payment-processed-topic")

foreach ($topic in $topics) {
    Write-Host "Configurando Event Source Mapping para o tópico '$topic'..." -ForegroundColor Yellow
    $ErrorActionPreference = "SilentlyContinue"
    aws lambda create-event-source-mapping `
        --function-name $functionName `
        --topics $topic `
        --self-managed-event-source '{\"Endpoints\":{\"KAFKA_BOOTSTRAP_SERVERS\":[\"kafka:29092\"]}}' `
        --source-access-configurations 'Type=BASIC_AUTH,URI=arn:aws:secretsmanager:us-east-1:000000000000:secret:dummy' `
        --endpoint-url $endpointUrl `
        --profile localstack 2>$null
    $ErrorActionPreference = "Stop"
}

Write-Host "=== Deploy Concluído com Sucesso! ===" -ForegroundColor Green
Write-Host "A Lambda '$functionName' está pronta e conectada aos tópicos do Kafka no LocalStack." -ForegroundColor Green
