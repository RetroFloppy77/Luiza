# 🤖 Luiza (Lua + ELIZA) - v0.7.0 Beta

<p align="center">
  <img src="https://img.shields.io/badge/Language-Lua-blue.svg?style=flat-square&logo=lua" alt="Lua">
  <img src="https://img.shields.io/badge/License-GPL3-green.svg?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/Version-0.7.0--beta-brightgreen.svg?style=flat-square" alt="Version">
  <img src="https://img.shields.io/badge/Author-Stefano%20Peris-orange.svg?style=flat-square" alt="Author">
</p>

> **Luiza** è un gioco di parole tra **Lua** ed **ELIZA**. Rappresenta un'evoluzione moderna, modulare e pulita in **Lua standard** dello storico chatbot ideato nel 1966 da **Joseph Weizenbaum** al MIT, interamente tradotto in lingua italiana e potenziato con capacità conversazionali avanzate e memoria di contesto.

> ⚠️ **Nota sullo stato di sviluppo (v0.7.0 Beta):**
> 
> Questa release di **Luiza è attualmente alla versione v0.7.0 Beta**. Il codice sorgente è organizzato come modulo riutilizzabile (`src/luiza.lua`), supportando sia l'esecuzione interattiva da terminale (REPL) sia i test automatici unitari (`test/test_luiza.lua`). Segnalazioni di bug e suggerimenti per nuovi pattern sono i benvenuti!

---

## ⚡ Caratteristiche Principali

- 🧠 **Memoria di Contesto Intelligente:** Luiza tiene traccia dell'argomento principale trattato (ansia, lavoro, famiglia, relazioni, tristezza) e vi si ricollega in modo naturale durante il dialogo.
- 💬 **Risposte Articolate & Empatiche:** Superata la semplice ripetizione speculare: Luiza pone domande di approfondimento psicologico sulle cause profonde degli stati d'animo.
- 🇮🇹 **Adattamento Italiano Avanzato:** Tabella di riflessione grammaticale estesa per pronomi, aggettivi possessivi e forme verbali.
- 🧩 **Pattern Matching Ampliato:** Regole strutturate e suddivise per aree tematiche (bisogni, desideri, identità, limiti, solitudine e quesiti tecnologici).
- 🪶 **Zero Dipendenze & Modulare:** Sviluppato in Lua puro (compatibile con Lua 5.1+), strutturato come modulo esportabile tramite tabella `M` per garantire la massima portabilità e compatibilità CI/CD.

---

## 💬 Esempio di Conversazione

```text
------------------------------------------------------------------
LUIZA (v0.7.0 Beta): La tua terapeuta virtuale in Italiano
Digita 'esci', 'quit' o 'exit' per terminare la conversazione.
------------------------------------------------------------------
LUIZA: Ciao. Sono qui per ascoltarti. Come ti senti in questo momento?

> Mi sento molto in ansia per il lavoro
LUIZA: L'ansia spesso ci segnala che stiamo cercando di controllare qualcosa che sfugge al nostro controllo. Cosa ti preoccupa di più?

> Il mio capo pretende troppo da me
LUIZA: Il lavoro e lo studio occupano gran parte delle nostre giornate. Come descriveresti il clima in cui ti trovi?

> Non so cosa fare per uscire da questa situazione
LUIZA: Prima hai accennato al tuo lavoro o studio. Pensi che c'entri con quello che stai dicendo ora?

> esci
LUIZA: Arrivederci. Spero che questa chiacchierata ti sia stata utile per fare un po' di chiarezza. A presto!
```

---

## 🛠️ Ambiente di Sviluppo & Installazione

### 1. Installazione di Lua
Per eseguire **Luiza** è necessario l'interprete **Lua**.

- 🔗 **Sito Ufficiale Lua:** [lua.org](https://www.lua.org/)

#### Comandi di installazione:
- **Linux (Ubuntu/Debian):**
  ```bash
  sudo apt update
  sudo apt install lua5.4
  ```
- **macOS (Homebrew):**
  ```bash
  brew install lua
  ```
- **Windows:** Scarica i binari da [LuaBinaries](http://luabinaries.sourceforge.net/) oppure usa un package manager (`choco install lua` o `scoop install lua`).

Verifica la corretta installazione:
```bash
lua -v
```

---

### 2. Installazione di VSCodium (IDE Consigliato)
**VSCodium** è la versione *free/libre* di Visual Studio Code, priva di telemetria e tracciamento.

- 🔗 **Sito Ufficiale VSCodium:** [vscodium.com](https://vscodium.com/)

---

### 3. Plugin consigliato per Lua in VSCodium
Per l'autocompletamento, l'analisi statica e l'evidenziamento della sintassi:

- 🔗 **Estensione consigliata:** [Lua (Lua Language Server by sumneko)](https://open-vsx.org/extension/sumneko/lua)

---

## 🚀 Esecuzione di Luiza

1. Clona il repository:
   ```bash
   git clone https://github.com/RetroFloppy77/luiza.git
   cd luiza
   ```
2. Avvia lo script principale situato nella cartella `src`:
   ```bash
   lua src/luiza.lua
   ```
3. Per uscire digita `esci`, `quit` o `exit`.

---

## 🧪 Esecuzione dei Test Automatici

Il progetto include una suite di test unitari nella cartella `test/`, eseguita automaticamente ad ogni push tramite GitHub Actions (CI/CD).

Per eseguire i test manualmente dal terminale:
```bash
lua test/test_luiza.lua
```

---

## 🐛 Segnalazione Bug e Contributi (Beta)

Essendo una versione **v0.7.0 Beta**, il tuo contributo è prezioso:
1. Apri una **Issue** sul repository GitHub specificando l'input utente e la risposta ricevuta.
2. Invia una **Pull Request** proponendo nuovi pattern o risposte nella tabella delle regole all'interno di `src/luiza.lua`.

---

## 🧠 Note Storiche: L'Effetto ELIZA

Sviluppato da **Joseph Weizenbaum** al MIT tra il 1964 e il 1966, il programma originale *ELIZA* (con lo script *DOCTOR*) dimostrò come una serie di semplici regole sintattiche e risposte speculari potesse indurre gli utenti a proiettare empatia e intelligenza reale sulla macchina. Questo fenomeno è noto nell'ambito dell'intelligenza artificiale come **Effetto ELIZA**.

---

## 📁 Struttura del Repository

```text
luiza/
├── .github/
│   └── workflows/
│       ├── test.yml        # CI/CD automatizzato per eseguire i test ad ogni push
│       └── release.yml     # Workflow automatizzato per la gestione dei rilasci
├── LICENSE                 # Licenza GNU General Public License v3.0
├── README.md               # Documentazione ufficiale del progetto (v0.7.0 Beta)
├── src/
│   └── luiza.lua           # Modulo sorgente principale del chatbot in Lua
└── test/
    └── test_luiza.lua      # Script per l'esecuzione dei test automatici
```

---

## 👤 Autore e Contatti

- **Autore:** Stefano Peris
- **Email:** [stefanoperis.github@gmail.com](mailto:stefanoperis.github@gmail.com)
- **GitHub:** [@RetroFloppy77](https://www.github.com/RetroFloppy77)

---

## 📄 Licenza

Questo progetto è distribuito sotto licenza **GNU General Public License v3.0 (GPL-3.0)**. Consultare il file [LICENSE](LICENSE) per i dettagli completi.