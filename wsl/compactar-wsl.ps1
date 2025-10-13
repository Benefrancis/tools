<#
.SYNOPSIS
    Compacta automaticamente todos os discos WSL (VHDX) detectados, liberando espaço no Windows.
.DESCRIPTION
    O script detecta todos os arquivos ext4.vhdx dentro do AppData do usuário e Docker Desktop,
    para qualquer distribuição WSL, exibe o tamanho antes e depois, mostra barra de progresso
    com monitoramento real do tamanho, e reinicia o WSL automaticamente.
#>

param(
    [switch]$Auto,    # Executa sem perguntar
    [switch]$Silent   # Oculta saídas visuais
)

function Write-Log {
    param([string]$msg)
    if (-not $Silent) { Write-Host $msg }
}

Write-Log "Verificando distribuicoes WSL instaladas..."

$searchPaths = @(
    "$env:LOCALAPPDATA\Packages",
    "$env:LOCALAPPDATA\Docker\wsl\data"
)

$totalSaved = 0
$allVhdx = @()

foreach ($base in $searchPaths) {
    if (Test-Path $base) {
        $vhdxFiles = Get-ChildItem -Path $base -Recurse -Filter "ext4.vhdx" -ErrorAction SilentlyContinue
        if ($vhdxFiles) { $allVhdx += $vhdxFiles }
    }
}

if ($allVhdx.Count -eq 0) {
    Write-Log "Nenhum arquivo VHDX encontrado."
    exit
}

foreach ($vhdx in $allVhdx) {
    $sizeBefore = [math]::Round(($vhdx.Length / 1GB), 2)
    Write-Log ""
    Write-Log "----------------------------------------"
    Write-Log "Distribuicao detectada: $($vhdx.FullName)"
    Write-Log "Tamanho atual: $sizeBefore GB"

    $shouldCompact = $false
    if ($Auto) { $shouldCompact = $true }
    else {
        $answer = Read-Host "Deseja compactar esta distribuicao? (S/N/T para todas)"
        switch ($answer.ToUpper()) {
            'S' { $shouldCompact = $true }
            'T' { $shouldCompact = $true; $Auto = $true }
            Default { $shouldCompact = $false }
        }
    }

    if ($shouldCompact) {
        Write-Log "Parando WSL..."
        wsl --shutdown | Out-Null

        Write-Log "Iniciando compactacao e monitoramento do tamanho real..."
        $sizeBeforeBytes = (Get-Item $vhdx.FullName).Length
        $prevSize = $sizeBeforeBytes
        $done = $false

        # Executa Optimize-VHD em background
        $job = Start-Job -ScriptBlock {
            param($path)
            Optimize-VHD -Path $path -Mode Full -ErrorAction Stop
        } -ArgumentList $vhdx.FullName

        while (-not $done) {
            Start-Sleep -Milliseconds 500
            $currentSize = (Get-Item $vhdx.FullName).Length
            $reduction = $sizeBeforeBytes - $currentSize
            $percent = [math]::Round(($reduction / $sizeBeforeBytes) * 100, 0)
            if ($percent -gt 100) { $percent = 100 }
            if ($percent -lt 0) { $percent = 0 }
            Write-Progress -Activity "Compactando $($vhdx.Name)" -Status "$percent% concluido" -PercentComplete $percent

            if ($job.State -eq 'Completed') { $done = $true }
        }

        Receive-Job $job | Out-Null
        Remove-Job $job

        Write-Progress -Activity "Compactando $($vhdx.Name)" -Completed
        Write-Log "Compactacao concluida."

        # Reinicia WSL
        Write-Log "Reiniciando WSL..."
        wsl --list | ForEach-Object { wsl -d $_ -- echo "Reiniciada" | Out-Null }

        $sizeAfter = [math]::Round((Get-Item $vhdx.FullName).Length / 1GB, 2)
        $saved = [math]::Round(($sizeBefore - $sizeAfter), 2)
        $totalSaved += $saved

        Write-Log "Novo tamanho: $sizeAfter GB"
        Write-Log "Espaco recuperado: $saved GB"
    }
}

Write-Log ""
if ($totalSaved -gt 0) {
    Write-Log "Processo concluido."
    Write-Log "Total de espaco recuperado: $([math]::Round($totalSaved, 2)) GB"
} else {
    Write-Log "Nenhum espaco recuperado (nenhuma distribuicao compactada ou sem economia)."
}
