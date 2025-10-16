<#
    memoria_cleaner_universal.ps1
    Autor: BeneFrancis + GPT-5
    Descricao: Monitoramento e limpeza automatica de memoria RAM, com logging avancado e suporte multiplataforma.
#>

param(
    [ValidateSet("DEBUG", "INFO", "WARN")]
    [string]$LogLevel = "INFO",
    [int]$Interval = 5
)

# ================================
# CONFIGURACOES GERAIS
# ================================
$LogFile = Join-Path $PSScriptRoot "memoria_cleaner.log"
$Version = $PSVersionTable.PSVersion.Major
$Threshold = 80
$HostName = $env:COMPUTERNAME
$KeepRunning = $true

# ================================
# FUNCOES DE LOG
# ================================
function Write-Log {
    param([string]$Level, [string]$Message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logEntry = "[${timestamp}] [$Level] $Message"
    Add-Content -Path $LogFile -Value $logEntry

    switch ($Level) {
        "DEBUG" { if ($LogLevel -eq "DEBUG") { Write-Host $logEntry -ForegroundColor DarkGray } }
        "INFO"  { if ($LogLevel -in @("DEBUG", "INFO")) { Write-Host $logEntry -ForegroundColor Cyan } }
        "WARN"  { Write-Host $logEntry -ForegroundColor Yellow }
        "ERROR" { Write-Host $logEntry -ForegroundColor Red }
    }
}

# ================================
# DETECCAO E PREPARACAO
# ================================
Write-Host "`n===============================" -ForegroundColor Magenta
Write-Host "🧠 MEMORIA CLEANER UNIVERSAL" -ForegroundColor Green
Write-Host "===============================`n" -ForegroundColor Magenta

Write-Log "INFO" "PowerShell detectado: v$Version"
Write-Log "INFO" "Monitoramento iniciado (LogLevel=$LogLevel, Interval=$Interval seg.)"

# ================================
# FUNCAO DE LIMPEZA
# ================================
function Clear-Memory {
    $uso = Get-MemoryUsage
    Write-Log "INFO" "Limpeza iniciada (uso: ${uso}%)"
    Start-Sleep -Milliseconds 300
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    if ($Version -ge 7) { [System.GC]::Collect(2, [System.GCCollectionMode]::Forced, $true, $true) }
}

# ================================
# OBTEM USO DE MEMORIA
# ================================
function Get-MemoryUsage {
    $os = Get-CimInstance Win32_OperatingSystem
    [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 2)
}

# ================================
# TRATAMENTO DE ENCERRAMENTO
# ================================
$global:ScriptRunning = $true
$eventHandler = {
    Write-Log "INFO" "Encerrando monitoramento manualmente..."
    $global:ScriptRunning = $false
}
Register-EngineEvent PowerShell.Exiting -Action $eventHandler | Out-Null

# ================================
# LOOP PRINCIPAL
# ================================
try {
    while ($global:ScriptRunning) {
        $usage = Get-MemoryUsage
        $barLen = 30
        $filled = [math]::Round(($usage / 100) * $barLen)
        $empty = $barLen - $filled
        $bar = ("█" * $filled) + ("░" * $empty)

        # Define cor dinamica da barra
        if ($usage -gt $Threshold) { $color = "Yellow" } else { $color = "Green" }

        Write-Host ("`rMemoria: [{0}] {1}% " -f $bar, $usage) -ForegroundColor $color -NoNewline

        if ($usage -gt $Threshold) {
            Write-Log "WARN" "Uso de memoria alto ($usage%). Executando limpeza..."
            Clear-Memory
        }

        Start-Sleep -Seconds $Interval
    }
}
catch {
    Write-Log "ERROR" "Erro durante a execucao: $_"
}
finally {
    Write-Log "INFO" "Script finalizado em $(Get-Date)"
    Write-Host "`n🧩 Monitoramento encerrado. Log salvo em: $LogFile`n" -ForegroundColor Magenta
}
