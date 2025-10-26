# Memoria Cleaner Ultra Interativa
# Versao 6.0
# Autor: Bene
# Funcao: Monitoramento e limpeza de memoria com grafico animado, toast notifications e alertas

# Configuracoes
$LimitPercent = 75        # Limite para disparar limpeza automatica
$CriticalPercent = 90     # Limite critico para alerta vermelho
$IntervalSec = 2          # Intervalo entre atualizacoes em segundos
$Width = 50               # Largura do grafico de memoria

# Funcoes
function Get-MemoryPercent {
    $mem = Get-CimInstance Win32_OperatingSystem
    $total = $mem.TotalVisibleMemorySize
    $free = $mem.FreePhysicalMemory
    $used = $total - $free
    $percentUsed = [math]::Round(($used/$total)*100)
    return $percentUsed
}

function Show-MemoryGraph {
    param([int]$PercentUsed)
    $usedWidth = [math]::Round($PercentUsed * $Width / 100)
    $freeWidth = $Width - $usedWidth
    $usedBar = "#" * $usedWidth
    $freeBar = "-" * $freeWidth

    if ($PercentUsed -lt 50) { $color = "Green" }
    elseif ($PercentUsed -lt $CriticalPercent) { $color = "Yellow" }
    else { $color = "Red" }

    Write-Host ("[{0}{1}] {2}%" -f $usedBar,$freeBar,$PercentUsed) -ForegroundColor $color
}

function Show-Toast {
    param([string]$Title, [string]$Message)
    [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
    $template = [Windows.UI.Notifications.ToastTemplateType]::ToastText02
    $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template)
    $texts = $xml.GetElementsByTagName("text")
    $texts.Item(0).AppendChild($xml.CreateTextNode($Title)) | Out-Null
    $texts.Item(1).AppendChild($xml.CreateTextNode($Message)) | Out-Null
    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
    $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("MemoriaCleaner")
    $notifier.Show($toast)
}

function Safe-ClearMemory {
    $percentBefore = Get-MemoryPercent
    Show-Toast -Title "Memoria Cleaner" -Message "Limpeza automatica iniciada. Uso: $percentBefore%"

    # Garbage Collection inicial
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()
    Start-Sleep -Milliseconds 200

    # Limpeza de processos seguros
    $safeProcesses = Get-Process | Where-Object {
        $_.CPU -eq 0 -and $_.Name -notin @("System","Idle","explorer","svchost","dwm")
    }
    foreach ($p in $safeProcesses) {
        try { $p.CloseMainWindow() | Out-Null; Start-Sleep -Milliseconds 10 } catch {}
    }

    # Garbage Collection final
    [System.GC]::Collect()
    Start-Sleep -Milliseconds 200

    $percentAfter = Get-MemoryPercent
    $reduction = $percentBefore - $percentAfter
    Show-Toast -Title "Memoria Cleaner" -Message "Limpeza concluida. Reducao: $reduction%"
    Write-Host ("Limpeza concluida! Reducao de memoria: {0}%" -f $reduction) -ForegroundColor Green
}

# Loop principal de monitoramento
Write-Host "Memoria Cleaner Ultra Interativa iniciado. Limite: $LimitPercent%, Critico: $CriticalPercent%" -ForegroundColor Cyan

while ($true) {
    Clear-Host
    $currentPercent = Get-MemoryPercent
    Write-Host ("Uso atual de RAM: {0}%" -f $currentPercent) -ForegroundColor Yellow
    Show-MemoryGraph -PercentUsed $currentPercent

    if ($currentPercent -ge $LimitPercent) {
        Write-Host "Uso acima do limite! Iniciando limpeza automatica..." -ForegroundColor Red
        Safe-ClearMemory
    }

    if ($currentPercent -ge $CriticalPercent) {
        Write-Host "ALERTA CRITICO: RAM acima de $CriticalPercent%!" -ForegroundColor Red
    }

    Start-Sleep -Seconds $IntervalSec
}
