Write-Host "##############################################"
Write-Host "1. Deploying frontend-teste-docker2 in Docker"
Write-Host "##############################################"

$projectRoot = "C:\Projetos\TESTE\Docker\frontend-teste-docker2" # Define o caminho raiz onde esta o projeto Angular.
$dockerfile = Join-Path $projectRoot "Dockerfile" # Monta o caminho completo do arquivo Dockerfile.
$imageName = "frontend-teste-docker2:local" # Define o nome e a tag da imagem Docker que sera criada.
$containerName = "frontend-teste-docker2" # Define o nome do container que aparecera no Docker Desktop.
$hostPort = "4201" # Define a porta do Windows/localhost que sera usada para acessar o frontend.
$containerPort = "80" # Define a porta interna do container onde o Nginx servira o Angular.

Set-Location $projectRoot # Altera o diretorio atual do PowerShell para a pasta do projeto Angular.

if (-not (Test-Path $dockerfile)) { # Verifica se o arquivo Dockerfile nao existe no caminho esperado.
    throw "Dockerfile not found: $dockerfile" # Interrompe o script com erro caso o Dockerfile nao seja encontrado.
} # Finaliza o bloco de validacao do Dockerfile.

Write-Host ""
Write-Host "##############################################"
Write-Host "2. Building Docker image"
Write-Host "##############################################"

docker build -t $imageName -f $dockerfile $projectRoot # Cria a imagem Docker usando o Dockerfile e o diretorio do projeto como contexto.
if ($LASTEXITCODE -ne 0) { throw "docker build failed (exit code $LASTEXITCODE)" } # Interrompe o script se o docker build falhar.

Write-Host ""
Write-Host "##############################################"
Write-Host "3. Deploying container"
Write-Host "##############################################"

$existingContainer = docker ps -a --filter "name=^/$containerName$" --format "{{.Names}}" # Procura um container existente com exatamente o mesmo nome definido em $containerName.
if ($existingContainer -eq $containerName) { # Verifica se ja existe um container com o nome desejado.
    docker rm -f $containerName # Remove o container antigo para permitir criar outro com o mesmo nome.
    if ($LASTEXITCODE -ne 0) { throw "docker rm failed (exit code $LASTEXITCODE)" } # Interrompe o script se a remocao do container falhar.
} # Finaliza o bloco de remocao do container existente.

$dockerArgs = @( # Inicia um array com os argumentos que serao enviados ao comando docker run.
    "run", "-d", # Define que o Docker deve criar e iniciar o container em segundo plano.
    "-p", "127.0.0.1:${hostPort}:${containerPort}", # Mapeia http://localhost:$hostPort no Windows para a porta $containerPort dentro do container.
    "--name", $containerName, # Define o nome do container no Docker Desktop.
    $imageName # Informa qual imagem Docker sera usada para criar o container.
) # Finaliza o array de argumentos do docker run.

& docker @dockerArgs # Executa docker run usando o array de argumentos montado acima.
if ($LASTEXITCODE -ne 0) { throw "docker run failed (exit code $LASTEXITCODE)" } # Interrompe o script se a criacao ou inicializacao do container falhar.

Write-Host "" # Exibe uma linha em branco para melhorar a leitura no console.
Write-Host "Frontend available at http://localhost:$hostPort" # Exibe a URL onde o frontend Angular pode ser acessado no browser.

# Comando para executar: powershell -ExecutionPolicy Bypass -File "C:\Projetos\TESTE\Docker\frontend-teste-docker2\deploy-docker.ps1"