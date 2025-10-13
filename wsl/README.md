# 🧹 compactar-wsl.ps1

> **Reduza o tamanho dos discos do WSL automaticamente e libere espaço no seu Windows.**

```

---

/ **|**_ _ __  _ __  __ _ _ _  **| |**_ _ _     \ \      / / |_   *|  _ | |
| (__/ _ \ '  | '* / *` | ' \/ _` / -*) '*|_____\ \ /\ / /    | | | |*) | |__
_**_**/*|*|*| .__/_*,*|*||*_*,*___|*|__**(*) _/  _/     |*| |****/|****|
|_|

````

<p align="center">
  <img src="https://img.shields.io/badge/PowerShell-7+-blue?logo=powershell" alt="PowerShell">
  <img src="https://img.shields.io/badge/Windows-10%20%7C%2011-lightgrey?logo=windows" alt="Windows">
  <img src="https://img.shields.io/badge/WSL-2-success?logo=linux" alt="WSL 2">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="MIT License">
</p>

---

## 📘 Sobre o projeto

**compactar-wsl.ps1** é um script em PowerShell que **detecta, analisa e compacta automaticamente os discos virtuais (
VHDX)** usados pelo WSL 2.  
O objetivo é **recuperar espaço em disco** sem afetar os dados das distribuições Linux instaladas.

Ideal para quem desenvolve com **Docker, Node.js, Python, Java, etc.** dentro do WSL e percebe que o arquivo `ext4.vhdx`
cresce rapidamente com o tempo.

---

## 🚀 Principais Benefícios

| 💡 Função                                | Descrição                                                                 |
|------------------------------------------|---------------------------------------------------------------------------|
| 🔍 **Verificação automática**            | Detecta todas as distribuições WSL e mostra o tamanho atual de cada VHDX. |
| ⚙️ **Compactação segura**                | Usa o comando nativo `Optimize-VHD`, sem riscos de perda de dados.        |
| 📊 **Relatório de economia**             | Exibe o tamanho antes e depois da compactação, além do total economizado. |
| 🤖 **Execução interativa ou automática** | Permite confirmar manualmente ou rodar em modo 100% automático.           |
| 🧩 **Compatibilidade total**             | Suporta WSL 2 em Windows 10 e 11, PowerShell 5.1+ e 7+.                   |

---

## 🧩 Requisitos

- **Windows 10** (build 2004+) ou **Windows 11**
- **PowerShell 5.1** ou superior
- **Hyper-V** habilitado (`Optimize-VHD` depende desse recurso)
- **WSL 2** instalado

Para verificar se o Hyper-V está ativo:

```powershell
Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
````

---

## 🛠️ Instalação

1. Baixe o script [`compactar-wsl.ps1`](./compactar-wsl.ps1).
2. Salve-o em um diretório fixo, como:

   ```powershell
   C:\Scripts\WSL\
   ```
3. (Opcional) Desbloqueie o arquivo se o Windows o marcar como externo:

   ```powershell
   Unblock-File -Path "C:\Scripts\WSL\compactar-wsl.ps1"
   ```

---

## ▶️ Como usar

Abra o **PowerShell como administrador** e execute:

```powershell
cd C:\Scripts\WSL
.\compactar-wsl.ps1
```

### Fluxo do script:

1. Lista todas as distribuições WSL detectadas.
2. Mostra o tamanho atual do arquivo `ext4.vhdx`.
3. Pergunta se deseja compactar (S/N/T para todas).
4. Executa automaticamente:

    * `wsl --terminate <distro>`
    * `Optimize-VHD -Path <caminho> -Mode Full`
    * Reinicia o WSL 2 se necessário.
5. Exibe:

    * 💿 **Tamanho antes/depois**
    * 💠 **Espaço recuperado**

---

## 🧭 Exemplo de saída

```powershell
🔍 Verificando distribuições WSL instaladas...

Ubuntu-22.04
Kali-Linux

💾 Tamanho atual: 15.8 GB
Deseja compactar esta distribuição? (S/N/T): S

🛑 Parando WSL...
🧩 Compactando VHDX...
✅ Compactação concluída!

💿 Novo tamanho: 9.3 GB
💠 Espaço recuperado: 6.5 GB
```

---

## ⚡ Modos de execução

| Modo                | Descrição                                     | Exemplo                       |
|---------------------|-----------------------------------------------|-------------------------------|
| Interativo (padrão) | Pergunta antes de compactar cada distro       | `.\compactar-wsl.ps1`         |
| Automático          | Compacta todas as distribuições sem perguntar | `.\compactar-wsl.ps1 -Auto`   |
| Silencioso          | Nenhuma saída visual (para agendamentos)      | `.\compactar-wsl.ps1 -Silent` |

---

## 🗓️ Agendamento automático

Você pode agendar o script para rodar **periodicamente** via **Agendador de Tarefas**.

### Passos:

1. Abra **Agendador de Tarefas** → “Criar Tarefa”.
2. Aba **Geral**:

    * Nome: `Compactar WSL Automaticamente`
    * Marque “Executar com privilégios mais altos”.
3. Aba **Disparadores**:

    * “Novo…” → Repetir **toda semana** ou **mensalmente**.
4. Aba **Ações**:

    * Programa/script:

      ```
      powershell.exe
      ```
    * Argumentos:

      ```
      -ExecutionPolicy Bypass -File "C:\Scripts\WSL\compactar-wsl.ps1" -Auto
      ```
5. Salve e pronto. O Windows executará automaticamente a manutenção do WSL.

---

## 🧰 Manutenção preventiva recomendada

| Frequência | Ação                                    | Benefício                            |
|------------|-----------------------------------------|--------------------------------------|
| Semanal    | Executar `compactar-wsl.ps1`            | Evita crescimento exagerado de disco |
| Mensal     | `sudo apt clean && sudo apt autoremove` | Limpa cache interno do Linux         |
| Trimestral | `wsl --update`                          | Atualiza kernel e componentes        |

---

## 🧑‍💻 Autor

**Benefrancis**

> Analista de Sistemas | Engenheiro de Software | Otimizador de Ambientes de Desenvolvimento

💬 Ferramenta criada para quem trabalha diariamente com WSL e quer manter o sistema leve e eficiente.

---

## 📜 Licença

Este projeto é distribuído sob a **Licença MIT**.
Você pode usá-lo, modificá-lo e redistribuí-lo livremente, desde que mantenha os créditos originais.

---

## ⭐ Dica

Se este utilitário te ajudou, considere marcar com uma ⭐ no GitHub e compartilhar com outros desenvolvedores que usam
WSL.

---

🧠 *“Automatizar é o primeiro passo para liberar tempo para o que realmente importa: pensar.”*
— Benefrancis

