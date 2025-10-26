# IntelliJ IDEA Reset Dashboard Colorido

![PowerShell](https://img.shields.io/badge/PowerShell-7.5.3-blue) ![Windows](https://img.shields.io/badge/Windows-10%2F11-green) ![License](https://img.shields.io/badge/License-MIT-lightgrey)

## 🛠️ Descrição

**IntelliJ IDEA Reset Dashboard Colorido** é uma ferramenta **PowerShell 7+** avançada para **reset completo do IntelliJ
IDEA** em ambientes Windows.
Ela permite limpar configurações, caches, plugins, logs e arquivos de projetos, garantindo que o IntelliJ retorne ao
estado **original**, com **backups automáticos e dashboard animado em tempo real**.

Com recursos de **visualização animada colorida**, **estatísticas detalhadas**, **logs por execução** e **alertas
sonoros**, esta ferramenta facilita o gerenciamento de múltiplas instalações do IntelliJ IDEA.

---

## 🚀 Vantagens

* Reset **completo** ou **parcial** (Configurações, Cache, Plugins, Logs, Projetos).
* Dashboard **animado e colorido** exibindo progresso **lado a lado**.
* **Backups únicos com timestamp**, evitando conflitos de arquivos.
* Logs detalhados de cada execução, mantendo histórico.
* **Interativo**: S/N/T/B para cada tipo de limpeza.
* **Compatível com pastas com caracteres especiais** (ex.: colchetes, espaços, acentos).
* Alertas sonoros no final para indicar conclusão.
* Mensagens sem acento para máxima compatibilidade em terminais Windows.

---

## ⚡ Requisitos

* **Windows 10 / 11**
* **PowerShell 7.0 ou superior**
* Permissão de execução de scripts:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

---

## 📂 Estrutura do Script

* `reset-intellij.ps1` → script principal
* **Logs** → salvos em `C:\Users\<Usuario>\intellij-reset-dashboard-YYYYMMDD_HHMMSS.log`
* **Backups** → renomeados com `-backup-YYYYMMDD_HHMMSS`

---

## 🏃 Como Rodar

1. Abra **PowerShell 7** como administrador (ou usuário com permissões).
2. Navegue até a pasta onde o script está:

```powershell
cd C:\Users\Francis\tools\intellij
```

3. Execute o script:

```powershell
.\reset-intellij.ps1
```

4. Responda às perguntas:

* **S** → Sim, apagar este tipo de dados
* **N** → Não, manter este tipo de dados
* **T** → Todos, apagar tudo
* **B** → Limpeza básica (configurações mínimas)

---

## 🧩 Parâmetros

> Atualmente, o script é **interativo**. Futuramente, será possível rodar com parâmetros para automação.

| Parâmetro | Função                                                   |
|-----------|----------------------------------------------------------|
| S         | Apagar o tipo de dado selecionado                        |
| N         | Manter o tipo de dado selecionado                        |
| T         | Apagar todos os tipos de dados                           |
| B         | Limpeza básica, apagando apenas configurações essenciais |

---

## 🎨 Dashboard

* Cada tipo de limpeza possui **barra colorida própria**:

    * **Configs** → Ciano
    * **Cache** → Amarelo
    * **Plugins** → Magenta
    * **Logs** → Verde
    * **Projetos** → Azul

* Progresso é exibido **simultaneamente**, lado a lado, em tempo real.

---

## 📊 Estatísticas

* Exibe o número de **pastas processadas/renomeadas** por tipo.
* Tempo gasto por tipo.
* Histórico completo gravado em log.

---

## 💾 Backup

* Cada pasta apagada recebe **nome único com timestamp**:

```
<nome_da_pasta>-backup-YYYYMMDD_HHMMSS
```

* Evita **conflitos** em múltiplas execuções.

---

## 🔔 Alertas

* Alertas sonoros quando o processo termina.
* Mensagens coloridas indicando **sucesso** ou **estatísticas finais**.

---

## ✅ Compatibilidade

| Tecnologia    | Suporte                                        |
|---------------|------------------------------------------------|
| PowerShell    | 7.0+                                           |
| Windows       | 10 / 11                                        |
| IntelliJ IDEA | Todas as versões instaladas em `%USERPROFILE%` |
| Terminais     | PowerShell, Windows Terminal, VSCode Terminal  |

---

## 📜 Créditos

* Desenvolvedor: **Benefrancis**
* Base: Scripts PowerShell personalizados para gerenciamento de ambientes IntelliJ IDEA.

---

## 🏅 Selos de Tecnologia

![PowerShell](https://img.shields.io/badge/PowerShell-7.5.3-blue)
![Dashboard](https://img.shields.io/badge/Dashboard-Animado-green)
![Backup](https://img.shields.io/badge/Backup-Timestamp-yellow)
![Logs](https://img.shields.io/badge/Logs-Detalhados-orange)

---

## ⚠️ Aviso

* Use **com cuidado**.
* **Backups automáticos** permitem restaurar arquivos, mas sempre confirme antes de apagar dados críticos.
* **Não testa** caminhos de rede ou unidades externas.

 