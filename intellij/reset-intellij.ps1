# ===========================================================
# Script: reset-intellij-definitivo.ps1
# Funcao: Reset ultra completo do IntelliJ IDEA com dashboard, estatisticas e log
# ===========================================================

# Caminho do log
$logPath = "$env:USERPROFILE\intellij-reset-log.txt"

function Write-Log($text) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $text" | Out-File -FilePath $logPath -Append -Encoding UTF8
}

function Remove-Acentos($text) {
    $map = @{
        'á'='a'; 'à'='a'; 'ã'='a'; 'â'='a';
        'é'='e'; 'ê'='e';
        'í'='i';
        'ó'='o'; 'ô'='o'; 'õ'='o';
        'ú'='u';
        'ç'='c';
    }
    foreach ($k in $map.Keys) { $text = $text -replace $k, $map[$k] }
    return $text
}

function Ask-Option($message) {
    $message = Remove-Acentos $message
    do { $answer = Read-Host "$message (S/N/T/B)" }
    while ($answer -notmatch '^[SsNnTtBb]$')
    return $answer.ToUpper()
}

function Show-ProgressBar($percent) {
    $blocks = [int]($percent / 2)
    $bar = ("█" * $blocks) + ("-" * (50 - $blocks))
    Write-Host -NoNewline ("[$bar] $percent`%`r")
}

Write-Host "===== IntelliJ IDEA RESET DEFINITIVO =====`n"
Write-Log "===== INICIO DO RESET ====="

# Perguntas por tipo
$configChoice   = Ask-Option "Deseja apagar Configuracoes globais?"
$cacheChoice    = Ask-Option "Deseja apagar Cache e Sistema?"
$pluginsChoice  = Ask-Option "Deseja apagar Plugins instalados?"
$logsChoice     = Ask-Option "Deseja apagar Logs do IntelliJ?"
$projectsChoice = Ask-Option "Deseja apagar Configuracoes dos Projetos?"

# Detecta todas as versoes do IntelliJ IDEA
$ideaDirs = Get-ChildItem -Path "$env:USERPROFILE" -Directory -Filter ".IntelliJIdea*" -ErrorAction SilentlyContinue

# Inicializa estatisticas
$stats = @{
    "Configuracoes globais" = 0
    "Cache e Sistema"       = 0
    "Plugins"               = 0
    "Logs"                  = 0
    "Projetos"              = 0
}

# Funcao auxiliar para processar cada tipo com barra, tempo e log
function Process-Type($dirs, $choice, $name, $subDirFunc) {
    if ($choice -eq "N") { return }
    $total = $dirs.Count
    $count = 0
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    foreach ($dir in $dirs) {
        $count++
        $percent = [int](($count/$total)*100)
        Show-ProgressBar $percent
        $subDir = & $subDirFunc $dir
        if ($subDir -and (Test-Path $subDir)) {
            Rename-Item $subDir "$subDir-backup"
            $stats[$name]++
            Write-Log "$name - $($dir.Name) renomeado para backup"
        }
    }
    $sw.Stop()
    $time = [math]::Round($sw.Elapsed.TotalSeconds,2)
    Write-Host "`n$name concluido em $time segundos. Pastas processadas: $($stats[$name])`n"
    Write-Log "$name concluido em $time segundos. Pastas processadas: $($stats[$name])"
}

# Funcoes que retornam os caminhos
$configFunc  = { param($d) Join-Path $d.FullName "config" }
$cacheFunc   = { param($d) Join-Path $d.FullName "system" }
$pluginsFunc = { param($d) Join-Path $d.FullName "config\plugins" }
$logsFunc    = { param($d) Join-Path $d.FullName "system\log" }

# Processando cada tipo
Process-Type $ideaDirs $configChoice "Configuracoes globais" $configFunc
Process-Type $ideaDirs $cacheChoice "Cache e Sistema" $cacheFunc
Process-Type $ideaDirs $pluginsChoice "Plugins" $pluginsFunc
Process-Type $ideaDirs $logsChoice "Logs" $logsFunc

# Projetos
if ($projectsChoice -eq "T" -or $projectsChoice -eq "S") {
    $ideaProjects = Get-ChildItem -Path "$env:USERPROFILE" -Recurse -Directory -Force -ErrorAction SilentlyContinue | Where-Object { Test-Path "$($_.FullName)\.idea" }
    $totalProj = $ideaProjects.Count
    $countProj = 0
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    foreach ($proj in $ideaProjects) {
        $countProj++
        $percent = [int](($countProj/$totalProj)*100)
        Show-ProgressBar $percent
        $ideaConfig = Join-Path $proj.FullName ".idea"
        if (Test-Path $ideaConfig) {
            Rename-Item $ideaConfig "$ideaConfig-backup"
            $stats["Projetos"]++
            Write-Log "Projetos - $($proj.FullName) renomeado para backup"
        }
    }
    $sw.Stop()
    $time = [math]::Round($sw.Elapsed.TotalSeconds,2)
    Write-Host "`nProjetos concluido em $time segundos. Pastas processadas: $($stats['Projetos'])`n"
    Write-Log "Projetos concluido em $time segundos. Pastas processadas: $($stats['Projetos'])"
}

# Finalizar barra
Write-Progress -Activity "Reset do IntelliJ IDEA" -Completed

# Alertas sonoros
[console]::beep(1000,500)
[console]::beep(1500,500)

# Estatisticas finais resumidas
Write-Host "===== RESET CONCLUIDO! Estatisticas =====" -ForegroundColor Green
Write-Log "===== RESET CONCLUIDO ====="
foreach ($key in $stats.Keys) {
    Write-Host "$key : $($stats[$key]) pastas renomeadas/backups"
    Write-Log "$key : $($stats[$key]) pastas renomeadas/backups"
}
Write-Host "`nIntelliJ IDEA esta pronto para uso com configuracoes limpas!" -ForegroundColor Green
Write-Log "IntelliJ IDEA pronto para uso com configuracoes limpas"
