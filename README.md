# FIAP.PosTech.ArqSistemas.Orchestrator
Armazena todos os arquivos para orquestração das aplicações

🚀 Começando
Temos os seguintes arquivos nesse repositório para orquestrar as aplicações:

docker-compose.yml
kafka-infra.yaml
apis-deployment.yaml
workers-deployment.yaml

O arquivo docker-compose.yml é usado para orquestrar os containers localmente, 
enquanto os arquivos kafka-infra.yaml, apis-deployment.yaml e workers-deployment.yaml 
são usados para orquestrar os containers em um cluster Kubernetes.

📋 Pré-requisitos

Para executar esses arquivos, você precisará ter o Docker, o Kubernetes e .NET Core 8 e superiores.
Além disso, baixar os repósitórios listados abaixo e instalados em sua máquina.

Consulte essa URL na documentação oficial do Docker para obter instruções de instalação: https://docs.docker.com/get-docker/
Consulte essa URL na documentação oficial do Kubernetes para obter instruções de instalação: https://kubernetes.io/docs/setup/
Consulte essa URL na documentação oficial do .NET para obter instruções de instalação: https://dotnet.microsoft.com/en-us/download

Baixar os seguintes repositórios:

FIAP.PosTech.ArqSistemas.Orchestrator - https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.Orchestrator.git
FIAP.PosTech.ArqSistemas.Catalog - https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.Catalog.git
FIAP.PosTech.ArqSistemas.User - https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.User.git
FIAP.PosTech.ArqSistemas.Notification - https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.Notification.git
FIAP.PosTech.ArqSistemas.Payments - https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.Payments.git

Importante respeitar essa estrutura de pastas para que os arquivos de orquestração funcionem corretamente:

FIAP.PosTech.ArqSistemas.Catalog - C:\Sistemas\FIAP\FIAP.PosTech.ArqSistemas.Catalog
FIAP.PosTech.ArqSistemas.User - C:\Sistemas\FIAP\FIAP.PosTech.ArqSistemas.User
FIAP.PosTech.ArqSistemas.Notification - C:\Sistemas\FIAP\FIAP.PosTech.ArqSistemas.Notification
FIAP.PosTech.ArqSistemas.Payments - C:\Sistemas\FIAP\FIAP.PosTech.ArqSistemas.Payments
FIAP.PosTech.ArqSistemas.Orchestrator - C:\Sistemas\FIAP

Veja uma imagem de exemplo da estrutura de pastas:

https://github.com/rodrigosiqsilva/FIAP.PosTech.ArqSistemas.Orchestrator/blob/main/Estrututa%20pastas.png

🔧 Instalação

# Local
Navegue até a pasta (C:\Sistemas\FIAP) onde o arquivo docker-compose.yml está localizado 
e execute o seguinte comando: 

docker-compose up -d

Use o prompt do powershell para executar o comando acima.

#Cluster Kubernetes

O comando para aplicar as aplicações no cluster Kubernetes e fazer o Kafka, as APIs e Workers rodarem são:

kubectl apply -f kafka-infra.yaml
kubectl apply -f apis-deployment.yaml
kubectl apply -f workers-deployment.yaml

IMPORTANTE: 
- Certifique-se de que o cluster Kubernetes esteja configurado corretamente e que você tenha acesso a 
  ele antes de executar os comandos acima.
- Seguir a ordem de execução mencionada acima é importante para garantir que as dependências 
  sejam atendidas corretamente.