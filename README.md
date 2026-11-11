# 🤖 Luiza (Lua + ELIZA) - v0.9.2 Beta

<p align="center">
  <img src="https://img.shields.io/badge/Language-Lua-blue.svg?style=flat-square&logo=lua" alt="Lua">
  <img src="https://img.shields.io/badge/License-GPL3-green.svg?style=flat-square" alt="License">
  <img src="https://img.shields.io/badge/Version-0.9.2--beta-brightgreen.svg?style=flat-square" alt="Version">
  <img src="https://img.shields.io/badge/Author-Stefano%20Peris-orange.svg?style=flat-square" alt="Author">
</p>

> **Luiza** è un gioco di parole tra **Lua** ed **ELIZA**. Rappresenta un'evoluzione moderna, modulare e pulita in **Lua standard** dello storico chatbot ideato nel 1966 da **Joseph Weizenbaum** al MIT, interamente tradotto in lingua italiana e potenziato con capacità conversazionali avanzate e memoria di contesto.

> ⚠️ **Nota sullo stato di sviluppo (v0.9.2 Beta):**
> 
> Questa release di **Luiza è alla versione v0.9.2 Beta**. Il codice sorgente è organizzato come modulo riutilizzabile (`luiza.lua`), supportando sia l'esecuzione interattiva da terminale (REPL) sia i test automatici unitari (`test/test_luiza.lua`). Segnalazioni di bug e suggerimenti per nuovi pattern sono i benvenuti!

---

## ✨ Novità della Versione 0.9.2

La versione **v0.9.2** rappresenta un salto di qualità decisivo nell'architettura di comprensione e risposta del chatbot:

### 1. 🎯 Parser a Punteggio di Specificità (Scoring System)
Nelle versioni precedenti, il chatbot esaminava le regole conversazionali in ordine sequenziale, fermandosi al primo pattern corrispondente. Questo causava spesso la selezione di risposte troppo generiche quando l'utente pronunciava frasi composte o articolate.
* **Come funziona ora:** Ad ogni turno, Luiza analizza l'input dell'utente confrontandolo con *tutte* le regole attive e calcola per ciascun pattern un **punteggio di specificità** basato sulla lunghezza e sul grado di dettaglio della sintassi (escludendo i metacaratteri regex).
* **Risultato:** Viene selezionata ed eseguita esclusivamente la regola con il punteggio più alto, garantendo che le espressioni più specifiche abbiano sempre la precedenza rispetto a quelle generali.

### 2. 🧩 Insieme di Pattern e Risposte Notevolmente Ampliato
* **Nuove Aree Tematiche:** Introdotte nuove categorie di intenzione tra cui *rabbia e frustrazione*, *stanchezza e burnout*, *incertezza sul futuro*, *senso di colpa* e *sogni/progetti personali*.
* **Varietà nelle Risposte:** Aumentato significativamente il pool di risposte per ciascuna regola, minimizzando la sensazione di ripetitività anche durante sessioni di dialogo prolungate.

### 3. 🧠 Memoria di Contesto Estesa e Storico Topic
* Implementata la funzione `push_topic(topic)` che mantiene un buffer circolare degli ultimi argomenti toccati dall'utente.
* I richiami contestuali e le domande di collegamento ("*Questo si ricollega a quello che dicevi sulla tua famiglia?*") avvengono ora con tempistiche più coerenti e probabilistiche.

### 4. 🇮🇹 Riflessione Grammaticale Ottimizzata e Gestione Apostrofi
* Pulizia dei simboli di punteggiatura e normalizzazione automatica degli apostrofi (`'`, `` ` ``, `´`).
* Estensione della tabella di riflessione sintattica per pronomi e aggettivi possessivi della prima e seconda persona plurale (*ci/vi*, *nostro/vostro*).

---

## ⚡ Caratteristiche Principali

- 🧠 **Memoria di Contesto Estesa:** Luiza tiene traccia dell'argomento principale trattato e gestisce uno storico dei topic recenti per ricollegarvisi fluidamente.
- 🎯 **Parser a Punteggio di Specificità:** Selezione intelligente delle regole conversazionali basata sul livello di dettaglio della frase dell'utente.
- 💬 **Risposte Articolate & Empatiche:** Superata la semplice ripetizione speculare: Luiza pone domande di approfondimento psicologico sulle cause profonde degli stati d'animo.
- 🇮🇹 **Adattamento Italiano Avanzato:** Gestione ottimizzata di pronomi, aggettivi possessivi, forme verbali e particelle apostrofate.
- 🪶 **Zero Dipendenze & Modulare:** Sviluppato in Lua puro (compatibile con Lua 5.1+), strutturato come modulo esportabile tramite tabella `M` per garantire la massima portabilità e compatibilità CI/CD.

---

## 💬 Esempio di Conversazione

```text
------------------------------------------------------------------
LUIZA (v0.9.2 Beta): La tua terapeuta virtuale in Italiano
Digita 'esci', 'quit' o 'exit' per terminare la conversazione.
------------------------------------------------------------------
LUIZA: Ciao. Sono qui per ascoltarti. Come ti senti in questo momento?

> Mi sento molto in ansia per il mio lavoro
LUIZA: L'ansia spesso ci segnala che stiamo cercando di controllare qualcosa che sfugge al nostro controllo. Cosa ti preoccupa di più?

> Sento una grande stanchezza e non so cosa fare per il futuro
LUIZA: Quando il corpo e la mente dicono basta, spesso c'è bisogno di fermarsi. Ti stai concedendo il permesso di farlo?

> Ripensando a prima, mi fa arrabbiare il comportamento dei colleghi
LUIZA: La rabbia spesso protegge qualcos'altro, come una delusione o una ferita. Cosa ha scatenato questa furia?

> esci
LUIZA: Arrivederci. Spero che questa chiacchierata ti sia stata utile per fare un po' di chiarezza. A presto!
```

---

## 🛠️ Ambiente di Sviluppo & Installazione

### 1. Installazione di Lua
Per eseguire **Luiza** è necessario l'interprete **Lua** (compatibile con versioni 5.1, 5.2, 5.3 e 5.4).

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
2. Avvia lo script principale situato nella cartella `Luiza`:
   ```bash
   lua luiza.lua
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

Essendo una versione **v0.9.2 Beta**, il tuo contributo è prezioso:
1. Apri una **Issue** sul repository GitHub specificando l'input utente e la risposta ricevuta.
2. Invia una **Pull Request** proponendo nuovi pattern o risposte nella tabella delle regole all'interno di `luiza.lua`.

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
├── README.md               # Documentazione ufficiale del progetto (v0.9.2 Beta)
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