<#
===========================================
🚀 WINGET ULTRA TURBO PLUS+ (Visual Progress Edition)
Autor: Benefrancis
Versão: 2025.10
Descrição:
  Atualiza automaticamente todos os pacotes via WINGET.
  Inclui barra de progresso visual estilizada (█░),
  logs datados, limpeza automática e notificação toast.


  powershell -ExecutionPolicy Bypass -File "./opdate.ps1"

===========================================
#>

# --- CONFIGURAÇÕES ---
$ErrorActionPreference = 'SilentlyContinue'
$LogDir = "$env:ProgramData\winget\logs"
$DaysToKeepLogs = 7
$DateStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$LogFile = "$LogDir\update-$DateStamp.log"

# --- FUNÇÃO: NOTIFICAÇÃO TOAST ---
function Show-Toast {
    param([string]$Title, [string]$Message)
    try {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        $template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent(
        [Windows.UI.Notifications.ToastTemplateType]::ToastText02
        )
        $textNodes = $template.GetElementsByTagName("text")
        $textNodes.Item(0).AppendChild($template.CreateTextNode($Title)) | Out-Null
        $textNodes.Item(1).AppendChild($template.CreateTextNode($Message)) | Out-Null
        $toast = [Windows.UI.Notifications.ToastNotification]::new($template)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Winget Turbo Updater").Show($toast)
    } catch {
        Write-Host "💬 Notificação toast não suportada neste sistema." -ForegroundColor Yellow
    }
}

# --- FUNÇÃO: BARRA DE PROGRESSO ESTILIZADA ---
function Show-ProgressBar {
    param(
        [int]$Current,
        [int]$Total,
        [string]$ItemName
    )

    $Percent = [math]::Round(($Current / $Total) * 100)
    $BarLength = 30
    $FilledLength = [math]::Round(($Percent / 100) * $BarLength)
    $Bar = ('█' * $FilledLength) + ('░' * ($BarLength - $FilledLength))

    Write-Host ("`r⏳ Atualizando: {0} ({1}/{2})`n[{3}] {4}%" -f $ItemName, $Current, $Total, $Bar, $Percent) -ForegroundColor Cyan -NoNewline
    Start-Sleep -Milliseconds 300
    # Limpa linha anterior para próxima atualização
    Write-Host "`r" -NoNewline
}

# --- PREPARAÇÃO ---
if (!(Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory | Out-Null
    Write-Host "📁 Criado diretório de logs: $LogDir" -ForegroundColor DarkGray
}

# Limpeza de logs antigos
$OldLogs = Get-ChildItem -Path $LogDir -Filter "update-*.log" -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$DaysToKeepLogs) }
if ($OldLogs) {
    $OldLogs | Remove-Item -Force
    Write-Host "🧹 Logs antigos removidos (>$DaysToKeepLogs dias)" -ForegroundColor DarkGray
}

Write-Host "🚀 Escaneando pacotes disponíveis..." -ForegroundColor Cyan
Write-Host "📂 Log: $LogFile" -ForegroundColor DarkGray

# --- LISTAR PACOTES COM ATUALIZAÇÃO ---
$UpgradeList = winget upgrade --accept-source-agreements --accept-package-agreements |
        Select-String '^\S+\s+\S+\s+\S+' |
        ForEach-Object { ($_ -split '\s{2,}')[0] }

if (-not $UpgradeList -or $UpgradeList.Count -eq 0) {
    Write-Host "✅ Todos os pacotes estão atualizados!" -ForegroundColor Green
    Show-Toast -Title "Winget Turbo Updater" -Message "Nenhuma atualização disponível."
    exit
}

$Total = $UpgradeList.Count
$Current = 0
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# --- EXECUÇÃO COM BARRA DE PROGRESSO VISUAL ---
foreach ($pkg in $UpgradeList) {
    $Current++
    Show-ProgressBar -Current $Current -Total $Total -ItemName $pkg

    $cmd = "winget upgrade --id `"$pkg`" --force --silent --disable-interactivity --accept-package-agreements --accept-source-agreements"
    Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -Command `$ProgressPreference='SilentlyContinue'; $cmd" `
        -NoNewWindow -Wait -RedirectStandardOutput $LogFile -RedirectStandardError $LogFile
}

$Stopwatch.Stop()
Write-Host "`n✅ Atualização concluída!" -ForegroundColor Green

# --- ANÁLISE DE RESULTADOS ---
$Duration = "{0:N2}" -f $Stopwatch.Elapsed.TotalSeconds
$Updated = (Select-String -Path $LogFile -Pattern "Successfully" -ErrorAction SilentlyContinue | Measure-Object).Count
$Errors  = (Select-String -Path $LogFile -Pattern "Error" -ErrorAction SilentlyContinue | Measure-Object).Count

# --- RESUMO ---
Write-Host "`n===================================" -ForegroundColor Gray
Write-Host "✅ Atualização concluída em $Duration segundos" -ForegroundColor Green
Write-Host "📦 Pacotes atualizados: $Updated de $Total" -ForegroundColor Green
if ($Errors -gt 0) {
    Write-Host "⚠️  Erros detectados: $Errors (verifique o log)" -ForegroundColor Yellow
} else {
    Write-Host "🎯 Nenhum erro detectado." -ForegroundColor Green
}
Write-Host "🧾 Log salvo em: $LogFile" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Gray

# --- NOTIFICAÇÃO FINAL ---
if ($Errors -gt 0) {
    Show-Toast -Title "Winget Turbo Updater" -Message "Atualização concluída com $Errors erros. Verifique o log."
} else {
    Show-Toast -Title "Winget Turbo Updater" -Message "Todos os $Total pacotes atualizados com sucesso em $Duration s!"
}
