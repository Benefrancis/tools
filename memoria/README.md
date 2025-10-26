# 🖥️ Memoria Cleaner Interativa

![Windows](https://img.shields.io/badge/OS-Windows-blue) ![PowerShell](https://img.shields.io/badge/Language-PowerShell-purple) ![Version](https://img.shields.io/badge/Version-6.0-green)

---

## 🎬 Demo Animada

![Grafico de Memoria](https://user-images.githubusercontent.com/SEU_USUARIO/SEU_GIF_RAM.gif)  
*📊 Gráfico de RAM usado/livre animado no console*

![Toast Notification](https://user-images.githubusercontent.com/SEU_USUARIO/SEU_GIF_TOAST.gif)  
*🔔 Notificação toast do Windows ao iniciar e concluir a limpeza*

---

## 📝 Descrição

**Memoria Cleaner Interativa** é uma ferramenta avançada para **monitoramento e limpeza de memória** no Windows.  
Oferece monitoramento em tempo real, alertas visuais, gráficos animados no console e notificações do Windows (toast).  
Ideal para manter sistemas rápidos, responsivos e otimizados. 🚀

---

## ✨ Vantagens

- 📊 Gráfico de RAM usada/livre animado com cores intuitivas:
    - 🟢 Verde: RAM ok
    - 🟡 Amarelo: uso moderado
    - 🔴 Vermelho: uso crítico
- 📈 Barra de progresso e percentual de uso atualizados dinamicamente
- ⚡ Limpeza automática segura de processos inativos
- 🔔 Notificações toast no início e fim da limpeza
- ⚠️ Alertas críticos quando RAM ultrapassa o limite definido
- ⏱️ Monitoramento contínuo com feedback imediato da memória liberada

---

## 🛠️ Requisitos

- 🖥️ Windows 10 ou superior
- 💻 PowerShell 7 ou superior
- 🔑 Permissões de Administrador recomendadas
- 🪟 Windows Runtime para notificações toast

---

## ▶️ Como Rodar

1. Abra PowerShell como **Administrador**
2. Navegue até a pasta do script:

```powershell
cd C:\caminho\para\script
````

3. Execute o script:

```powershell
.\memoria.ps1
```

4. Para rodar em segundo plano minimizado:

```powershell
Start-Process powershell -ArgumentList "-NoExit -File 'C:\caminho\para\memoria.ps1'" -WindowStyle Minimized
```

---

## ⚙️ Parâmetros Configuráveis

| Parâmetro          | Descrição                                                          |
|--------------------|--------------------------------------------------------------------|
| `$LimitPercent`    | Limite de RAM (%) para disparar limpeza automática (padrão: 75) 🔹 |
| `$CriticalPercent` | Limite crítico (%) para alerta vermelho (padrão: 90) ⚠️            |
| `$IntervalSec`     | Intervalo entre verificações (segundos, padrão: 2) ⏱️              |
| `$Width`           | Largura do gráfico de memória no console (padrão: 50) 📏           |

> Para alterar parâmetros, edite diretamente no início do script.

---

## 👨‍💻 Créditos

* **Autor:** BeneFrancis
* Desenvolvido em **PowerShell 7+** usando APIs do **Windows Runtime**
* Inspirado em ferramentas nativas de monitoramento do Windows

---

## 🏷️ Selos de Tecnologia

* ![PowerShell](https://img.shields.io/badge/PowerShell-7.5.3-blueviolet)
* ![Windows Runtime](https://img.shields.io/badge/Windows-ToastNotifications-lightgrey)
* ![Console UI](https://img.shields.io/badge/Console-Interactive-green)

---

## 📂 Compatibilidade

* Testado em Windows 10 e Windows 11
* Funciona em desktops e notebooks Windows 💻
* Full HD ou superior recomendado para melhor visualização do gráfico 🖥️

---

## 🔒 Observações de Segurança

* Fecha apenas processos inativos e não essenciais 🛡️
* Execute como **Administrador** para garantir que todas as operações sejam executadas 🔑
* Personalize `$safeProcesses` para filtrar processos específicos se necessário 📝

---

## 🚀 Futuras Atualizações

* 📊 Histórico de uso de RAM e gráfico de tendência
* 📧 Alertas via e-mail ou Telegram
* 📝 Exportação de relatórios de performance do sistema
 
 
