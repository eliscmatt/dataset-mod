# Caminho da pasta principal
$baseFolder = "C:\Users\elisc_ffh6iqu\Área de Trabalho\Dataset Versions\DatasetFrames v4\Gun_Action_Recognition_Dataset"

# Função pra contar frames em uma pasta
function Count-FramesInFolder {
    param (
        [string]$folder
    )

    # Contar o número de arquivos PNG na pasta
    $frameCount = (Get-ChildItem -Path $folder -Filter "*.png").Count
    return $frameCount
}

# Iterar sobre cada subpasta e contar os frames
$frameCounts = @{}

Get-ChildItem -Path $baseFolder -Directory | ForEach-Object {
    $mainFolder = $_.FullName

    # Contar frames na pasta principal (após a mov dos arquivos)
    $mainFolderFrameCount = Count-FramesInFolder -folder $mainFolder
    $frameCounts[$mainFolder] = $mainFolderFrameCount
    Write-Output "Pasta: $mainFolder - Frames gerados: $mainFolderFrameCount"

    # Iterar sobre subpastas dentro da pasta principal
    Get-ChildItem -Path $mainFolder -Directory | ForEach-Object {
        $subFolder = $_.FullName

        # Verificar se a pasta segue o padrão vN ou se restou alguma outra subpasta
        if ($subFolder -match "^v(\d+)$") {
            # Contar os frames restantes, se houver, na subpasta vN
            $subFolderFrameCount = Count-FramesInFolder -folder $subFolder
            $frameCounts[$subFolder] = $subFolderFrameCount
            Write-Output "Subpasta (vN): $subFolder - Frames gerados: $subFolderFrameCount"
        } else {
            # Contar frames em outras subpastas que não foram excluídas
            $subFolderFrameCount = Count-FramesInFolder -folder $subFolder
            $frameCounts[$subFolder] = $subFolderFrameCount
            Write-Output "Subpasta: $subFolder - Frames gerados: $subFolderFrameCount"
        }
    }
}

# Exibir o total de frames gerados
$totalFrames = ($frameCounts.Values | Measure-Object -Sum).Sum
Write-Output "Total de frames gerados em todas as subpastas: $totalFrames"
