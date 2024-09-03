# Caminho da pasta principal
$baseFolder = "C:\Users\elisc_ffh6iqu\Área de Trabalho\Dataset Versions\DatasetFrames v4\Gun_Action_Recognition_Dataset"

# Função para mover os arquivos de uma pasta pra outra
function Move-Frames {
    param (
        [string]$sourceFolder,
        [string]$destinationFolder
    )

    # Move todos os arquivos .png da pasta de origem para a pasta de destino
    Get-ChildItem -Path $sourceFolder -Filter "*.png" | ForEach-Object {
        Move-Item -Path $_.FullName -Destination $destinationFolder -Force
    }
}

# Itera sobre cada subpasta e processar a movimentação e exclusão
Get-ChildItem -Path $baseFolder -Directory | ForEach-Object {
    $mainFolder = $_.FullName

    # Itera sobre subpastas dentro da pasta principal
    Get-ChildItem -Path $mainFolder -Directory | ForEach-Object {
        $subFolder = $_.FullName

        # Determina o nome da pasta vN
        $folderName = (Get-Item $subFolder).Name
        if ($folderName -match "^v(\d+)$") {
            $vNumber = $matches[1]
        } else {
            Write-Output "Nome de pasta não segue o padrão vN: $subFolder"
            return
        }

        # Caminho da pasta de frames
        $framesFolder = Join-Path -Path $subFolder -ChildPath "frames"

        # Verificar se a pasta de frames existe
        if (Test-Path $framesFolder) {
            # Mover os frames para a pasta principal correspondente
            Move-Frames -sourceFolder $framesFolder -destinationFolder $subFolder

            # Excluir a pasta de frames
            Remove-Item -Path $framesFolder -Recurse -Force

            # Mover o conteúdo da pasta vN para a pasta principal
            Get-ChildItem -Path $subFolder -Filter "*.png" | ForEach-Object {
                Move-Item -Path $_.FullName -Destination $mainFolder -Force
            }

            # Excluir a pasta vN após a movimentação dos arquivo
            Remove-Item -Path $subFolder -Recurse -Force
            Write-Output "Pasta $subFolder movida e excluída com sucesso."
        } else {
            Write-Output "Pasta de frames não encontrada em: $subFolder"
        }
    }
}
