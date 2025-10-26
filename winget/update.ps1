<#
===========================================
🚀 WINGET ULTRA TURBO PLUS+ (Visual Progress Edition)
Autor: Benefrancis
Versão: 2025.15
Descrição:
  Atualiza automaticamente todos os pacotes via WINGET.
  Inclui barra de progresso visual estilizada (█░),
  logs datados, limpeza automática e notificação toast.


  powershell -ExecutionPolicy Bypass -File "./update.ps1"

===========================================
#>

# Defina a codificação de saída para UTF-8 para exibir os caracteres corretamente
[System.Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

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
        # Silencia o erro de notificação se não for suportado
    }
}

# --- FUNÇÃO: BARRA DE PROGRESSO ESTILIZADA (LINHA ÚNICA) ---
function Show-ProgressBar {
    param(
        [int]$Current,
        [int]$Total,
        [string]$ItemName
    )

    $Percent = [math]::Round(($Current / $Total) * 100)
    $BarLength = 20
    $FilledLength = [math]::Round(($Percent / 100) * $BarLength)
    $Bar = ('█' * $FilledLength) + ('░' * ($BarLength - $FilledLength))

    $line = "⏳ [{0}] {1}% ({2}/{3}) Atualizando: {4}" -f $Bar, $Percent, $Current, $Total, $ItemName
    
    $maxWidth = $Host.UI.RawUI.BufferSize.Width - 1
    if ($line.Length -gt $maxWidth) {
        $line = $line.Substring(0, $maxWidth)
    }
    $line = $line.PadRight($maxWidth)

    Write-Host "`r$line" -ForegroundColor Cyan -NoNewline
}

# --- PREPARAÇÃO ---
if (!(Test-Path $LogDir)) {
    New-Item -Path $LogDir -ItemType Directory | Out-Null
    Write-Host "📁 Criado diretório de logs: $LogDir" -ForegroundColor DarkGray
}

# Limpeza de logs antigos
Get-ChildItem -Path $LogDir -Filter "update-*.log" -ErrorAction SilentlyContinue |
    Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-$DaysToKeepLogs) } |
    Remove-Item -Force -ErrorAction SilentlyContinue

Write-Host "🚀 Escaneando pacotes disponíveis..." -ForegroundColor Cyan

# --- LISTAR PACOTES COM ATUALIZAÇÃO ---
$tempFile = [System.IO.Path]::GetTempFileName()
try {
    cmd /c "chcp 65001 >nul && winget upgrade --accept-source-agreements --accept-package-agreements" | Set-Content -Path $tempFile -Encoding Utf8
    $wingetOutput = Get-Content -Path $tempFile -Encoding Utf8
} finally {
    if (Test-Path $tempFile) { Remove-Item $tempFile -Force }
}

# Análise robusta da saída do winget para extrair os IDs dos pacotes
$UpgradeList = $wingetOutput |
    # Pula linhas até o cabeçalho (em português), que é um marcador mais confiável
    Select-Object -SkipWhile { $_ -notmatch 'Nome\s+Id\s+Versão' } |
    # Pula a linha do cabeçalho e a linha separadora '---' para chegar aos dados
    Select-Object -Skip 2 |
    # Processa as linhas de dados
    ForEach-Object {
        # Para de processar ao encontrar uma linha vazia (fim da tabela)
        if ([string]::IsNullOrWhiteSpace($_)) { return }

        $parts = $_.Trim() -split '\s{2,}'
        if ($parts.Count -ge 2) {
            $parts[1] # Retorna o ID do pacote
        }
    } |
    # Filtra quaisquer resultados nulos ou vazios que possam ter passado
    Where-Object { -not [string]::IsNullOrWhiteSpace($_) }


if (-not $UpgradeList -or $UpgradeList.Count -eq 0) {
    $clearLine = ' '.PadRight($Host.UI.RawUI.BufferSize.Width - 1)
    Write-Host "`r$clearLine`r" -NoNewline
    Write-Host "✅ Todos os pacotes estão atualizados!" -ForegroundColor Green
    Show-Toast -Title "Winget Turbo Updater" -Message "Nenhuma atualização disponível."
    exit
}

$Total = $UpgradeList.Count
$Current = 0
$Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

# --- EXECUÇÃO COM BARRA DE PROGRESSO VISUAL ---
foreach ($pkgId in $UpgradeList) {
    $Current++
    Show-ProgressBar -Current $Current -Total $Total -ItemName $pkgId

    $cmd = "winget upgrade --id `"$pkgId`" --force --silent --disable-interactivity --accept-package-agreements --accept-source-agreements"
    Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -Command `$ProgressPreference='SilentlyContinue'; $cmd" `
        -NoNewWindow -Wait -RedirectStandardOutput $LogFile -Append -RedirectStandardError $LogFile -Append
}

$Stopwatch.Stop()
$clearLine = ' '.PadRight($Host.UI.RawUI.BufferSize.Width - 1)
Write-Host "`r$clearLine`r" -NoNewline
Write-Host "`n✅ Atualização concluída!" -ForegroundColor Green

# --- ANÁLISE DE RESULTADOS ---
# Procura por padrões em português no arquivo de log para contar sucessos e falhas.
$Duration = "{0:N2}" -f $Stopwatch.Elapsed.TotalSeconds
$Updated = (Select-String -Path $LogFile -Pattern "instalado com êxito" -ErrorAction SilentlyContinue | Measure-Object).Count
$Errors  = (Select-String -Path $LogFile -Pattern "falhou" -ErrorAction SilentlyContinue | Measure-Object).Count

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
