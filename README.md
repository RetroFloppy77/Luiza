# 🤖 Luiza (Lua + ELIZA) - v0.6.0 (Beta)

<p align="center">
  <img src="https://img.shields.io/badge/Language-Lua-blue.svg?style=flat-square&logo=lua" alt="Lua">
  <img src="https://img.shields.io/badge/License-GPL3-green.svg?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/Version-0.6.0--beta-brightgreen.svg?style=flat-square" alt="Version">
  <img src="https://img.shields.io/badge/Author-Stefano%20Peris-orange.svg?style=flat-square" alt="Author">
</p>

> **Luiza** è un gioco di parole tra **Lua** ed **ELIZA**. Rappresenta un'evoluzione moderna e pulita in **Lua standard** dello storico chatbot ideato nel 1966 da Joseph Weizenbaum al MIT, interamente tradotto in lingua italiana e potenziato con capacità conversazionali avanzate.

> ⚠️ **Nota sullo stato di sviluppo (v0.6.0 Beta):**
> 
> Questa release di **Luiza è attualmente alla versione 0.6.0 Beta**. Le funzionalità di tracciamento del contesto e i nuovi pattern conversazionali sono in fase di test ed espansione. Segnalazioni di bug e suggerimenti per nuovi pattern sono i benvenuti!

---

## ⚡ Novità della Versione 0.6.0 (Beta)

- 🧠 **Memoria di Contesto:** Luiza è in grado di tracciare l'argomento principale della conversazione (lavoro, famiglia, ansia, relazioni) e ricollegarsi ad esso durante il dialogo.
- 💬 **Risposte Articolate & Empatiche:** Superata la semplice ripetizione speculare: Luiza pone domande di approfondimento psicologico sulle cause profonde degli stati d'animo.
- 🇮🇹 **Adattamento Italiano Avanzato:** Sistema di riflessione dei pronomi e della grammatica italiana ampiamente esteso.
- 🪶 **Zero Dipendenze:** Realizzato interamente in Lua standard puro (compatibile con Lua 5.1+), senza richiedere librerie esterne.
- 🧩 **Pattern Matching Ampliato:** Regole suddivise per aree tematiche (stati d'animo, bisogni, relazioni, blocchi emotivi e quesiti esistenziali).

---

## 💬 Esempio di Conversazione

```text
------------------------------------------------------------------
LUIZA (v0.6.0 Beta): La tua terapeuta virtuale (in Italiano)
Digita 'esci', 'quit' o 'exit' per terminare la conversazione.
------------------------------------------------------------------
LUIZA: Ciao. Sono qui per ascoltarti. Come ti senti in questo momento?

> Mi sento molto in ansia per il lavoro
LUIZA: L'ansia spesso ci indica che c'è qualcosa che stiamo cercando di controllare senza riuscirci. Cosa ti preoccupa di più in questo momento?

> Il mio capo pretende troppo da me
LUIZA: Il lavoro e lo studio occupano una gran parte della nostra vita. Ti senti valorizzato per quello che fai o avverti del peso e dell'incomprensione?

> Non so cosa fare per uscire da questa situazione
LUIZA: Prima hai menzionato il tuo ambiente di lavoro o studio. Pensi che sia collegato a quello che stai dicendo ora?

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
- **Windows:** Scarica i binari pronti da [LuaBinaries](http://luabinaries.sourceforge.net/) oppure usa un package manager (`choco install lua` o `scoop install lua`).

Verifica la corretta installazione:
```bash
lua -v
```

---

### 2. Installazione di VSCodium (IDE Consigliato)
**VSCodium** è la versione *free/libre* di Visual Studio Code, libera da tracciamenti e telemetria Microsoft.

- 🔗 **Sito Ufficiale VSCodium:** [vscodium.com](https://vscodium.com/)

---

### 3. Plugin consigliato per Lua in VSCodium
Per l'autocompletamento, l'analisi statica e l'evidenziamento della sintassi in VSCodium:

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

Il progetto include una suite di test unitari automatici nella cartella `test/` eseguita automaticamente su GitHub tramite CI/CD (GitHub Actions).

Per eseguire i test manualmente dal tuo terminale:
```bash
lua test/test_luiza.lua
```

---

## 🐛 Segnalazione Bug e Contributi (Beta)

Essendo una versione **v0.6.0 Beta**, il tuo contributo è prezioso!

Se riscontri risposte incoerenti, errori di punteggiatura o hai idee per migliorare il riconoscimento grammaticale in italiano:
1. Apri una **Issue** sul repository GitHub specificando l'input utente e la risposta ricevuta.
2. Invia una **Pull Request** proponendo nuovi pattern o risposte nella tabella `rules`.

---

## 🧠 Note Storiche: L'Effetto ELIZA

Sviluppato da **Joseph Weizenbaum** al MIT tra il 1964 e il 1966, il programma originale *ELIZA* (con lo script *DOCTOR*) dimostrò come una serie di semplici regole sintattiche e risposte speculari potesse indurre gli utenti a proiettare empatia e intelligenza reale sulla macchina. Questo fenomeno è noto nell'ambito dell'IA come **Effetto ELIZA**.

---

## 📁 Struttura del Repository

```text
luiza/
├── .github/
│   └── workflows/
│       └── test.yml        # CI/CD automatizzato per eseguire i test ad ogni push
├── LICENSE                 # Licenza GNU General Public License v3.0
├── README.md               # Documentazione ufficiale del progetto (v0.6.0 Beta)
├── src/
│   └── luiza.lua           # Codice sorgente del chatbot in Lua
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