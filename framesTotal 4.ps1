# Caminho da pasta
$baseFolder = "C:\Users\elisc_ffh6iqu\Área de Trabalho\Dataset Versions\DatabaseVideoFrames v3\Gun_Action_Recognition_Dataset"

# Função para contar frames em uma subpasta
function Count-FramesInFolder {
    param (
        [string]$framesFolder
    )

    # Contar o número de arquivos PNG na pasta de frames
    $frameCount = (Get-ChildItem -Path $framesFolder -Filter "*.png").Count
    return $frameCount
}

# Iterar sobre cada subpasta e conta os frames
$frameCounts = @{}

Get-ChildItem -Path $baseFolder -Directory | ForEach-Object {
    $mainFolder = $_.FullName

    # Iterar sobre subpastas dentro da pasta principal
    Get-ChildItem -Path $mainFolder -Directory | ForEach-Object {
        $subFolder = $_.FullName

        # Caminho da pasta de frames
        $framesFolder = Join-Path -Path $subFolder -ChildPath "frames"

        # Verificar se a pasta de frames existe
        if (Test-Path $framesFolder) {
            # Contar o número de frames
            $frameCount = Count-FramesInFolder -framesFolder $framesFolder

            # Armazenar o resultado no hash table
            $frameCounts[$subFolder] = $frameCount

            # Exibir o resultado
            Write-Output "Subpasta: $subFolder - Frames gerados: $frameCount"
        } else {
            Write-Output "Pasta de frames não encontrada em: $subFolder"
        }
    }
}

# Exibir o total de frames gerados
$totalFrames = ($frameCounts.Values | Measure-Object -Sum).Sum
Write-Output "Total de frames gerados em todas as subpastas: $totalFrames"
