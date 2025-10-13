# ===========================================================
# Script: reset-intellij-dashboard-ladoa-lado.ps1
# Funcao: Reset IntelliJ IDEA com dashboard visual LADO A LADO
# ===========================================================

$logPath = "$env:USERPROFILE\intellij-reset-dashboard.log"

function Write-Log($text) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $text" | Out-File -FilePath $logPath -Append -Encoding UTF8
}

function Remove-Acentos($text) {
    $map = @{ 'á'='a';'à'='a';'ã'='a';'â'='a';'é'='e';'ê'='e';'í'='i';'ó'='o';'ô'='o';'õ'='o';'ú'='u';'ç'='c' }
    foreach ($k in $map.Keys) { $text = $text -replace $k, $map[$k] }
    return $text
}

function Ask-Option($message) {
    $message = Remove-Acentos $message
    do { $answer = Read-Host "$message (S/N/T/B)" }
    while ($answer -notmatch '^[SsNnTtBb]$')
    return $answer.ToUpper()
}

function Show-ProgressBars($stats,$totals) {
    $barWidth = 20
    $line = ""
    foreach ($key in $stats.Keys) {
        $percent = if ($totals[$key] -eq 0) {0} else { [int](($stats[$key]/$totals[$key])*100) }
        $blocks = [int]($percent/5)
        $bar = ("█" * $blocks) + ("-" * ($barWidth - $blocks))
        $line += "$key [$bar] $percent`%  "
    }
    Write-Host -NoNewline "$line`r"
}

Write-Host "===== IntelliJ IDEA RESET DASHBOARD LADO A LADO =====`n"
Write-Log "===== INICIO DO RESET ====="

# Perguntas
$configChoice   = Ask-Option "Deseja apagar Configuracoes globais?"
$cacheChoice    = Ask-Option "Deseja apagar Cache e Sistema?"
$pluginsChoice  = Ask-Option "Deseja apagar Plugins instalados?"
$logsChoice     = Ask-Option "Deseja apagar Logs do IntelliJ?"
$projectsChoice = Ask-Option "Deseja apagar Configuracoes dos Projetos?"

# Detectar pastas IntelliJ
$ideaDirs = Get-ChildItem -Path "$env:USERPROFILE" -Directory -Filter ".IntelliJIdea*" -ErrorAction SilentlyContinue

# Inicializar estatisticas
$stats = @{
    "Configs" = 0
    "Cache"   = 0
    "Plugins" = 0
    "Logs"    = 0
    "Projetos"= 0
}
$totals = @{
    "Configs" = $ideaDirs.Count
    "Cache"   = $ideaDirs.Count
    "Plugins" = $ideaDirs.Count
    "Logs"    = $ideaDirs.Count
    "Projetos"= 0
}

# Funcoes de caminhos
$configFunc  = { param($d) Join-Path $d.FullName "config" }
$cacheFunc   = { param($d) Join-Path $d.FullName "system" }
$pluginsFunc = { param($d) Join-Path $d.FullName "config\plugins" }
$logsFunc    = { param($d) Join-Path $d.FullName "system\log" }

# Projetos
if ($projectsChoice -eq "T" -or $projectsChoice -eq "S") {
    $ideaProjects = Get-ChildItem -Path "$env:USERPROFILE" -Recurse -Directory -Force -ErrorAction SilentlyContinue | Where-Object { Test-Path "$($_.FullName)\.idea" }
    $totals["Projetos"] = $ideaProjects.Count
}

# Processar tipos
$types = @(
    @{ Name="Configs"; Choice=$configChoice; Func=$configFunc; Dirs=$ideaDirs },
    @{ Name="Cache"; Choice=$cacheChoice; Func=$cacheFunc; Dirs=$ideaDirs },
    @{ Name="Plugins"; Choice=$pluginsChoice; Func=$pluginsFunc; Dirs=$ideaDirs },
    @{ Name="Logs"; Choice=$logsChoice; Func=$logsFunc; Dirs=$ideaDirs },
    @{ Name="Projetos"; Choice=$projectsChoice; Func={ param($d) Join-Path $d.FullName ".idea"}; Dirs=$ideaProjects }
)

foreach ($type in $types) {
    $dirs = $type.Dirs
    if ($type.Choice -eq "N" -or $dirs.Count -eq 0) { continue }
    foreach ($dir in $dirs) {
        $subDir = & $type.Func $dir
        if ($subDir -and (Test-Path $subDir)) {
            Rename-Item $subDir "$subDir-backup"
            $stats[$type.Name]++
            Write-Log "$($type.Name) - $($dir.FullName) renomeado para backup"
        }
        Show-ProgressBars $stats $totals
        Start-Sleep -Milliseconds 50
    }
    Write-Host ""
}

# Concluir
[console]::beep(1000,500)
[console]::beep(1500,500)
Write-Host "`n===== RESET CONCLUIDO! Estatisticas =====" -ForegroundColor Green
Write-Log "===== RESET CONCLUIDO ====="
foreach ($key in $stats.Keys) {
    Write-Host "$key : $($stats[$key]) pastas renomeadas/backups"
    Write-Log "$key : $($stats[$key]) pastas renomeadas/backups"
}
Write-Host "`nIntelliJ IDEA pronto para uso com configuracoes limpas!" -ForegroundColor Green
Write-Log "IntelliJ IDEA pronto para uso com configuracoes limpas"
