# Defina o caminho para a Gun_Action_Recognition_Dataset
$datasetBasePath = "C:\Users\elisc_ffh6iqu\Área de Trabalho\Dataset Versions\DatasetVN v2\Gun_Action_Recognition_Dataset"

# Obter todas as pastas principais  dentro de Gun_Action_Recognition_Dataset
$mainFolders = Get-ChildItem -Path $datasetBasePath -Directory

foreach ($mainFolder in $mainFolders) {
    Write-Host "Processando a pasta principal:" $mainFolder.FullName
    
    # Defina o caminho base para a pasta principal atual
    $basePath = $mainFolder.FullName
    
    # Cria um contador para nomear as pastas vN
    $counter = 1

    # Obtem todas as subpastas dentro da pasta principal atual
    $subfolders = Get-ChildItem -Path $basePath -Directory

    foreach ($subfolder in $subfolders) {
        Write-Host "  Processando a subpasta:" $subfolder.FullName
        
        # todos os arquivos dentro da subpasta
        $files = Get-ChildItem -Path $subfolder.FullName -File
        
        if ($files.Count -gt 0) {
            # Defina o novo nome da pasta vN
            $newFolderName = "v" + $counter
            $newFolderPath = Join-Path -Path $basePath -ChildPath $newFolderName
            
            # Cria a nova pasta vN
            Write-Host "  Criando a pasta:" $newFolderPath
            New-Item -Path $newFolderPath -ItemType Directory -Force
            
            # Move os arquivos para a nova pasta vN
            foreach ($file in $files) {
                Write-Host "    Movendo o arquivo:" $file.Name "para" $newFolderPath
                Move-Item -Path $file.FullName -Destination $newFolderPath
            }
            
            # Incrementar o contador para o próximo nome de pasta
            $counter++
            
            # Excluir a subpasta vazia
            Write-Host "  Excluindo a subpasta vazia:" $subfolder.FullName
            Remove-Item -Path $subfolder.FullName -Recurse -Force
        } else {
            Write-Host "    Nenhum arquivo encontrado em" $subfolder.FullName
        }
    }
}

Write-Host "Processamento concluído!"
