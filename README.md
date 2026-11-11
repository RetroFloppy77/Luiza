🤖 Luiza (Lua + ELIZA) — v0.9.3 Beta
<p align="center"> <img src="https://img.shields.io/badge/Language-Lua-blue.svg?style=flat-square&logo=lua" alt="Language: Lua"> <img src="https://img.shields.io/badge/License-GPL--3.0-green.svg?style=flat-square" alt="License: GPL-3.0"> <img src="https://img.shields.io/badge/Version-0.9.3--beta-brightgreen.svg?style=flat-square" alt="Version: 0.9.3 Beta"> <img src="https://img.shields.io/badge/Author-Stefano%20Peris-orange.svg?style=flat-square" alt="Author: Stefano Peris"> </p>

<p align="center"> **Autore:** Stefano Peris · **Email:** [stefanoperis.github@gmail.com](mailto:stefanoperis.github@gmail.com) · **GitHub:** (https://github.com/RetroFloppy77) </p>

🕰️ La storia di ELIZA
La storia di Luiza nasce dall'esperienza di ELIZA, uno dei programmi più importanti nella storia delle interfacce conversazionali. ELIZA fu sviluppato da Joseph Weizenbaum al Massachusetts Institute of Technology (MIT) tra il 1964 e il 1966. Il programma venne presentato nell'articolo “ELIZA—A Computer Program for the Study of Natural Language Communication Between Man and Machine”, pubblicato nel gennaio 1966 sulla rivista Communications of the ACM.

ELIZA non era un'intelligenza artificiale nel significato contemporaneo del termine: il suo funzionamento si basava su parole chiave, regole di scomposizione delle frasi e modelli di risposta. Quando individuava un termine significativo nell'input, applicava trasformazioni al testo e costruiva una risposta utilizzando regole associate. In assenza di una corrispondenza adeguata, poteva ricorrere a risposte generiche o a meccanismi di ripiego. Questo approccio permetteva di sostenere una conversazione apparentemente naturale senza comprendere davvero il significato delle frasi.

Lo script più celebre di ELIZA era DOCTOR, progettato per imitare lo stile di una conversazione con uno psicoterapeuta ispirato all'approccio non direttivo di Carl Rogers. Il programma tendeva a riformulare le parole dell'interlocutore e a porre domande aperte, lasciando a quest'ultimo gran parte dell'iniziativa. Proprio questa semplicità rese evidente quanto le persone potessero attribuire comprensione, intenzioni ed empatia a un sistema che applicava soltanto regole linguistiche: il fenomeno è oggi conosciuto come Effetto ELIZA.

Il progetto Luiza — nome nato dall'unione delle parole Lua ed ELIZA — riprende questo modello storico e lo reinterpreta in italiano, utilizzando Lua standard. L'obiettivo è didattico e sperimentale: mostrare come un insieme di pattern, risposte alternative, trasformazioni grammaticali e memoria contestuale possa produrre dialoghi più vari e collegati tra loro, mantenendo il codice semplice, leggibile e procedurale.

ℹ️ Nota importante: Luiza è un chatbot dimostrativo basato su regole. Non comprende realmente le esperienze dell'utente e non è un terapeuta, uno strumento diagnostico o un servizio di assistenza professionale.

Riferimenti storici:

Joseph Weizenbaum, ELIZA—A Computer Program for the Study of Natural Language Communication Between Man and Machine, Communications of the ACM, vol. 9, n. 1, gennaio 1966, pp. 36–45.
Weizenbaum Institute — ELIZA: A program for simulating understanding and intelligence.
✨ Novità della versione 0.9.3
La versione v0.9.3 Beta si concentra sulla qualità delle corrispondenze, sulla varietà delle risposte e sulla continuità della conversazione.

1. 🎯 Correzione e miglioramento del riconoscimento dei pattern
Corretto un errore fondamentale: Lua non supporta l'operatore di alternativa | nei propri pattern. Le vecchie regole che lo utilizzavano sono state riscritte separando le parole chiave e le frasi da riconoscere.
Riconoscimento delle parole complete: le parole chiave vengono cercate rispettando i confini delle parole, riducendo le corrispondenze accidentali all'interno di termini più lunghi.
Valutazione di tutte le regole: il motore confronta le corrispondenze disponibili e seleziona quella con la priorità e la specificità maggiori.
Pattern con catture: le frasi variabili, come ho bisogno di ... o mi sento ..., possono trasferire parte del testo dell'utente nella risposta.
2. 💬 Risposte più varie e meno ripetitive
Ogni argomento dispone di più risposte alternative.
Il programma ricorda l'ultima risposta scelta per ciascuna categoria e, quando possibile, evita di riproporla immediatamente.
Le risposte che includono una frase catturata dispongono di modelli dedicati, separati da quelli utilizzati per le semplici parole chiave.
3. 🧠 Continuità e memoria contestuale
Luiza conserva temporaneamente l'ultimo argomento riconosciuto e uno storico limitato dei topic.
Le risposte brevi — ad esempio sì, no, forse o non lo so — possono richiamare l'argomento precedente invece di ricevere una risposta generica.
Anche gli input non riconosciuti possono generare, occasionalmente, una domanda collegata al contesto.
La memoria rimane in RAM e viene azzerata quando termina il processo. Non viene scritto alcun dato su disco.
4. 🇮🇹 Normalizzazione e riflessione grammaticale
Gestione più uniforme di spazi, ritorni a capo, apostrofi e alcune lettere accentate maiuscole.
Estensione delle trasformazioni per pronomi, possessivi e forme verbali comuni.
La riflessione grammaticale resta volutamente semplice: non è un analizzatore morfosintattico completo della lingua italiana.
5. 🧩 Modulo e ciclo REPL
Aggiunta della funzione pubblica M.reset() per iniziare una nuova conversazione senza ricaricare il modulo.
Migliorato il controllo che distingue l'esecuzione diretta del file dal caricamento tramite require().
Conservata l'organizzazione procedurale e la compatibilità con Lua standard, senza dipendenze esterne.
⚡ Caratteristiche principali
🧠 Memoria contestuale temporanea: conserva l'ultimo argomento e uno storico breve per collegare i turni della conversazione.
🎯 Selezione per priorità e specificità: le regole più pertinenti prevalgono su quelle generiche.
💬 Risposte alternative: più formulazioni per categoria e protezione dalle ripetizioni immediate.
🔎 Riconoscimento più preciso: parole chiave complete e pattern Lua con gruppi di cattura.
🇮🇹 Riflessione grammaticale italiana: trasformazione di alcuni pronomi, possessivi e verbi.
🪶 Procedurale e senza dipendenze: nessuna classe, nessun framework e nessuna libreria esterna.
🔌 Modulo riutilizzabile: le funzioni M.reply() e M.reset() possono essere richiamate da altri programmi Lua.
💬 Esempio di conversazione
Le risposte effettive possono variare perché vengono selezionate casualmente tra più alternative.

------------------------------------------------------------------
LUIZA (Versione 0.9.3 Beta): Chatbot conversazionale in italiano
Digita 'esci', 'quit' o 'exit' per terminare la conversazione.
------------------------------------------------------------------
LUIZA: Ciao! Sono qui per conversare. Di che cosa vorresti parlare?

> Sono molto in ansia per il mio lavoro
LUIZA: Qual è la preoccupazione che occupa più spazio nei tuoi pensieri?

> Sì
LUIZA: Questa sensazione è cambiata mentre ne parlavi?

> C'entra anche il mio capo: non mi ascolta
LUIZA: Ti senti ascoltato e valorizzato nell'ambiente in cui ti trovi?

> esci
LUIZA: Arrivederci! Grazie per la conversazione. A presto!
🛠️ Ambiente di sviluppo e installazione
1. Installazione di Lua
Per eseguire Luiza è necessario un interprete Lua. Il codice utilizza funzionalità disponibili in Lua 5.1 o versioni successive.

🔗 Sito ufficiale: lua.org
Comandi di installazione
Linux (Ubuntu/Debian):
sudo apt update
sudo apt install lua5.4
macOS (Homebrew):
brew install lua
Windows: è possibile utilizzare una distribuzione Lua per Windows o un gestore di pacchetti disponibile nel proprio ambiente.
Verifica l'installazione:

lua -v
2. Installazione di VSCodium (IDE consigliato)
VSCodium è una distribuzione libera e open source basata sul codice di Visual Studio Code.

🔗 Sito ufficiale: vscodium.com
3. Estensione Lua consigliata
Per ottenere evidenziazione della sintassi, completamento automatico e analisi del codice:

🔗 Lua Language Server: estensione su Open VSX
🚀 Esecuzione di Luiza
Se il file sorgente si trova nella directory principale del progetto:

lua luiza.lua
Se invece è conservato nella directory src/:

lua src/luiza.lua
Per terminare la conversazione, digita esci, quit oppure exit. È possibile anche terminare con Ctrl+C o chiudendo l'input del terminale.

🔌 Utilizzo come modulo
Il file può essere caricato da un altro programma Lua senza avviare il ciclo interattivo.

-- Se luiza.lua si trova nella directory corrente:
local luiza = require("luiza")

local risposta, deve_uscire = luiza.reply("Mi sento preoccupato per il lavoro")
print(risposta)

-- Azzera memoria e storico per una nuova conversazione.
luiza.reset()
Se il modulo si trova in src/, aggiungi la directory al percorso di ricerca prima di chiamare require():

package.path = package.path .. ";./src/?.lua"
local luiza = require("luiza")
API pubblica
Funzione / campo	Descrizione
M.version	Stringa contenente la versione del modulo (0.9.3).
M.reply(input)	Elabora un messaggio e restituisce risposta, deve_uscire.
M.reset()	Azzera la memoria contestuale e gli indici delle risposte già selezionate.
🧪 Test e controlli
Per una verifica manuale rapida, avvia il programma e prova messaggi appartenenti a categorie differenti: ansia, lavoro, famiglia, relazioni, desideri, stanchezza e saluti. Prova anche una risposta breve (sì, no, forse) dopo aver introdotto un argomento: Luiza dovrebbe provare a riprendere il contesto.

Se nel repository è presente la suite di test in test/, eseguila con:

lua test/test_luiza.lua
La suite di test non era inclusa tra i file forniti per questa revisione; di conseguenza non è stata modificata né dichiarata superata. I controlli svolti su questa versione sono descritti nella consegna insieme ai file aggiornati.

🐛 Segnalazione di bug e contributi
Per contribuire al progetto:

Apri una Issue indicando la versione di Lua, il messaggio inserito e la risposta ottenuta.
Descrivi il comportamento atteso e quello effettivo.
Per proporre nuove conversazioni, aggiungi parole chiave, pattern o risposte alla tabella rules, mantenendo le regole di sintassi dei pattern Lua.
Prima di inviare una Pull Request, verifica che il codice venga caricato correttamente e che i casi già esistenti continuino a funzionare.
📁 Struttura del repository
luiza/
├── .github/
│   └── workflows/
│       ├── test.yml        # CI/CD per i test automatici
│       └── release.yml     # Workflow per la gestione dei rilasci
├── LICENSE                # Licenza GNU General Public License v3.0
├── README.md              # Documentazione del progetto
├── luiza.lua              # Modulo sorgente principale
└── test/
    └── test_luiza.lua     # Test automatici (se presenti nel repository)
📄 Licenza
Questo progetto è distribuito secondo i termini della GNU General Public License v3.0 (GPL-3.0). Per informazioni complete, consulta il file LICENSE.