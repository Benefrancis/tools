# ==========================
# Memoria Cleaner Ultra Interativa - Smooth Version (No Flicker)
# Autor: BeneFrancis
# ==========================

# Configuracoes
$LimitPercent   = 75
$CriticalPercent = 90
$IntervalSec    = 2
$Width          = 50

Add-Type -AssemblyName System.Runtime
Add-Type -AssemblyName PresentationFramework

function Get-MemoryInfo {
    $os = Get-CimInstance Win32_OperatingSystem
    $total = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    $free  = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
    $used  = [math]::Round($total - $free, 2)
    $percent = [math]::Round(($used / $total) * 100, 2)
    return [PSCustomObject]@{Total=$total; Used=$used; Free=$free; Percent=$percent}
}

function Show-Toast($title, $msg) {
    try {
        $template = [Windows.UI.Notifications.ToastTemplateType]::ToastText02
        $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $toastXml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template)
        $xml.LoadXml($toastXml.GetXml())
        $xml.GetElementsByTagName("text")[0].AppendChild($xml.CreateTextNode($title)) | Out-Null
        $xml.GetElementsByTagName("text")[1].AppendChild($xml.CreateTextNode($msg)) | Out-Null
        $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("MemoriaCleaner").Show($toast)
    } catch {}
}

function Draw-Bar($percent) {
    $usedBars = [math]::Floor(($percent / 100) * $Width)
    $freeBars = $Width - $usedBars

    if ($percent -lt $LimitPercent) {
        $color = "Green"
    } elseif ($percent -lt $CriticalPercent) {
        $color = "Yellow"
    } else {
        $color = "Red"
    }

    Write-Host ("[" + ("#" * $usedBars) + ("-" * $freeBars) + "] $percent%") -ForegroundColor $color
}

# Ocupa posicoes fixas no console
Clear-Host
$posTop = [Console]::CursorTop
$posLeft = [Console]::CursorLeft

Write-Host "============================================="
Write-Host " MEMORIA CLEANER ULTRA INTERATIVA (Smooth UI)"
Write-Host "============================================="
Write-Host ""
Write-Host " Monitorando uso de memoria em tempo real..."
Write-Host ""

Show-Toast "Memoria Cleaner" "Monitoramento iniciado"

while ($true) {
    $mem = Get-MemoryInfo
    $usedMB = $mem.Used
    $totalMB = $mem.Total
    $percent = $mem.Percent

    # Move o cursor de volta para reescrever linhas sem piscar
    [Console]::SetCursorPosition(0, $posTop + 5)
    Write-Host (" Total: {0} MB" -f $totalMB)
    Write-Host (" Usado: {0} MB" -f $usedMB)
    Write-Host (" Livre: {0} MB" -f $mem.Free)
    Write-Host ""
    Draw-Bar $percent
    Write-Host ""

    if ($percent -ge $LimitPercent) {
        Write-Host " Executando limpeza de processos inativos..." -ForegroundColor Cyan
        $before = $mem.Free
        Get-Process | Where-Object { $_.CPU -lt 1 -and $_.ProcessName -notin "System","Idle","svchost","explorer" } | ForEach-Object {
            try { Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue } catch {}
        }
        Start-Sleep -Seconds 2
        $after = (Get-MemoryInfo).Free
        $liberado = [math]::Round($after - $before, 2)
        if ($liberado -gt 0) {
            Write-Host " Memoria liberada: $liberado MB" -ForegroundColor Green
            Show-Toast "Memoria Cleaner" "Liberado $liberado MB"
        } else {
            Write-Host " Nenhuma memoria liberada" -ForegroundColor DarkGray
        }
    } else {
        Write-Host " Sistema estavel. Nenhuma acao necessaria." -ForegroundColor DarkGray
    }

    Start-Sleep -Seconds $IntervalSec
}
