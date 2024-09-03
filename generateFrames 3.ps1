# Caminho da pasta
$baseFolder = "C:\Users\elisc_ffh6iqu\Área de Trabalho\Dataset Versions\DatabaseVideoFrames v3\Gun_Action_Recognition_Dataset"

# Caminho do ffmpeg
$ffmpegPath = "C:\Users\elisc_ffh6iqu\Downloads\ffmpeg-master-latest-win64-gpl\bin\ffmpeg.exe"

# Função para criar pastas se não existirem
function Create-DirectoryIfNotExists {
    param (
        [string]$path
    )
    if (-not (Test-Path $path)) {
        New-Item -Path $path -ItemType Directory
    }
}

# Função para obter o número de frames do arquivo JSON
function Get-NumberOfFramesFromJson {
    param (
        [string]$jsonPath
    )

    # Ler JSON
    $jsonContent = Get-Content -Path $jsonPath | ConvertFrom-Json

    # Contar o número de entradas em 'images'
    return $jsonContent.images.Count
}

# Iterar sobre cada subpasta e processar os vídeos
Get-ChildItem -Path $baseFolder -Directory | ForEach-Object {
    $mainFolder = $_.FullName

    # Iterar sobre subpastas dentro da pasta principal
    Get-ChildItem -Path $mainFolder -Directory | ForEach-Object {
        $subFolder = $_.FullName

        # Determinar o nome da pasta vN
        $folderName = (Get-Item $subFolder).Name
        if ($folderName -match "^v(\d+)$") {
            $vNumber = $matches[1]
        } else {
            Write-Output "Nome de pasta não segue o padrão vN: $subFolder"
            return
        }

        # Verificar a existência dos arquivos JSON e de vídeo
        $jsonPath = Join-Path -Path $subFolder -ChildPath "label.json"
        $videoPath = Join-Path -Path $subFolder -ChildPath "video_h264.mp4"

        $jsonExists = Test-Path $jsonPath
        $videoExists = Test-Path $videoPath

        if ($videoExists) {
            # Criar a pasta para os frames
            $framesFolder = Join-Path -Path $subFolder -ChildPath "frames"
            Create-DirectoryIfNotExists -path $framesFolder

            if ($jsonExists) {
                # Obter o número de frames do JSON
                $numFrames = Get-NumberOfFramesFromJson -jsonPath $jsonPath

                if ($numFrames -gt 0) {
                    # Calcula o intervalo de extração para obter no máximo 50 frames
                    $fps = [math]::Max([math]::Ceiling($numFrames / 50), 1) # Garantir que fps seja pelo menos 1
                    $outputPattern = Join-Path -Path $framesFolder -ChildPath "v${vNumber}_frame_%04d.png"

                    # Definir o comando ffmpeg para extrair frames
                    $ffmpegArguments = "-i `"$videoPath`" -vf fps=$fps `"$outputPattern`""
                    Write-Output "Executando: $ffmpegPath $ffmpegArguments"
                    Start-Process -FilePath $ffmpegPath -ArgumentList $ffmpegArguments -NoNewWindow -Wait
                } else {
                    Write-Output "Número de frames inválido em: $jsonPath"
                }
            } elseif ($subFolder -match "No_Gun") {
                # Caso específico para a subpasta No_Gun, onde não há arquivo JSON
                $fps = [math]::Max([math]::Ceiling(1 / 50), 1) # Calcular FPS fixo para garantir 50 frames
                $outputPattern = Join-Path -Path $framesFolder -ChildPath "v${vNumber}_frame_%04d.png"

                # Definir o comando ffmpeg para extrair até 50 frames
                $ffmpegArguments = "-i `"$videoPath`" -vf fps=$fps -frames:v 50 `"$outputPattern`""

                # Executar o comando ffmpeg
                Write-Output "Executando: $ffmpegPath $ffmpegArguments"
                Start-Process -FilePath $ffmpegPath -ArgumentList $ffmpegArguments -NoNewWindow -Wait
            } else {
                Write-Output "Arquivo JSON não encontrado em: $subFolder"
            }
        } else {
            Write-Output "Arquivo de vídeo não encontrado em: $subFolder"
        }
    }
}
