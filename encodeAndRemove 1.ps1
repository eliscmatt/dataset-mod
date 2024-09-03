# Caminho para o dir raiz
$basePath = "C:\Users\elisc_ffh6iqu\Área de Trabalho\Dataset Versions\DatasetEncode\Gun_Action_Recognition_Dataset"

# Caminho para o exe do ffmpeg
$ffmpegPath = "C:\Users\elisc_ffh6iqu\Downloads\ffmpeg-master-latest-win64-gpl\bin\ffmpeg.exe"

# Verificar se o ffmpeg ta la
if (-Not (Test-Path $ffmpegPath)) {
    Write-Error "ffmpeg.exe não foi encontrado em $ffmpegPath"
    exit
}

# Pegar todas as subpastas
$subfolders = Get-ChildItem -Path $basePath -Directory

foreach ($folder in $subfolders) {
    # Obter todos os arquivos de vídeo nas subpastas
    $videos = Get-ChildItem -Path $folder.FullName -Filter *.mp4 -Recurse

    foreach ($video in $videos) {
        # Define o caminho completo do arquivo de vídeo original
        $inputFile = $video.FullName

        # Define o nome do arquivo de saída (com _h264 pra diferenciar)
        $outputFile = Join-Path -Path $video.DirectoryName -ChildPath ($video.BaseName + "_h264.mp4")

        # Converter o vídeo para H.264 usando Start-Process
        Start-Process -FilePath $ffmpegPath -ArgumentList "-i `"$inputFile`" -c:v libx264 -crf 23 -preset medium -c:a aac -b:a 192k `"$outputFile`"" -NoNewWindow -Wait

        # Remover o arquivo original após a conversão
        Remove-Item -Path $inputFile -Force
    }
}
