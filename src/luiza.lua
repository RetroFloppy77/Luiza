-- =====================================================================
-- Autore: Stefano Peris
-- Email: stefanoperis.github@gmail.com
-- GitHub: https://www.github.com/RetroFloppy77
-- Nome Progetto: Luiza (Lua + ELIZA)
-- Versione: 0.7.0 Beta
-- Descrizione: Adattamento avanzato in Lua standard dello storico chatbot
--              ELIZA (1966) ideato da Joseph Weizenbaum.
--              Interamente in italiano, dotato di memoria di contesto,
--              riflessioni grammaticali e supporto per test automatici (CI/CD).
-- Licenza: GNU General Public License v3.0 (GPL-3.0)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. STRUTTURA DEL MODULO & INIZIALIZZAZIONE
-- ---------------------------------------------------------------------
-- Tabella principale del modulo (M) usata sia per l'esportazione verso 
-- script esterni/test automatici, sia per tracciare la versione corrente.
local M = {}

-- Versione corrente del modulo (utilizzata anche dai workflow CI/CD)
M.version = "0.7.0"

-- Inizializza il generatore di numeri casuali usando il timestamp di sistema
math.randomseed(os.time())


-- ---------------------------------------------------------------------
-- 2. MEMORIA DI CONTESTO
-- ---------------------------------------------------------------------
-- Mantiene traccia dell'ultimo argomento toccato dall'utente e del numero
-- di scambi avvenuti, permettendo al chatbot di ricollegarsi ad argomenti passati.
local context = {
    last_topic = nil,   -- Memorizza la categoria dell'ultima regola attivata (es. 'ansia', 'lavoro')
    turns_count = 0     -- Contatore dei turni della conversazione
}


-- ---------------------------------------------------------------------
-- 3. TABELLA DELLE RIFLESSIONI GRAMMATICALI (Italiano)
-- ---------------------------------------------------------------------
-- Inverte i pronomi, gli aggettivi possessivi e le persone dei verbi
-- per cambiare la prospettiva dal punto di vista dell'utente (1a persona)
-- a quello del terapeuta (2a persona).
local reflections = {
    ["io"]         = "tu",
    ["mio"]        = "tuo",
    ["mia"]        = "tua",
    ["miei"]       = "tuoi",
    ["mie"]        = "tue",
    ["sono"]       = "sei",
    ["ero"]        = "eri",
    ["ho"]         = "hai",
    ["avevo"]      = "avevi",
    ["posso"]      = "puoi",
    ["voglio"]     = "vuoi",
    ["sento"]      = "senti",
    ["me"]         = "te",
    ["mi"]         = "ti",
    ["ti"]         = "mi",
    ["tuo"]        = "mio",
    ["tua"]        = "mia",
    ["tuoi"]       = "miei",
    ["tue"]        = "mie",
    ["tu"]         = "io",
    ["sei"]        = "sono",
    ["stavo"]      = "stavi"
}

--- Sostituisce le parole all'interno della stringa catturata dai pattern
-- applicando l'inversione grammaticale definita nella tabella `reflections`.
-- @param text string: Il frammento di frase catturato dall'input dell'utente.
-- @return string: La frase riconvertita con i pronomi aggiornati.
local function reflect(text)
    if not text or text == "" then return "" end
    
    local words = {}
    -- %S+ estrae ogni parola separata da spazi
    for word in text:gmatch("%S+") do
        local lower_word = word:lower()
        -- Cerca la parola nella tabella; se non presente, mantiene l'originale
        local reflected_word = reflections[lower_word] or word
        table.insert(words, reflected_word)
    end
    
    return table.concat(words, " ")
end


-- ---------------------------------------------------------------------
-- 4. REGOLE CONVERSAZIONALI E PATTERN ESPANSI
-- ---------------------------------------------------------------------
-- Ogni regola contiene:
-- - `pattern`: Espressione regolare usata per identificare l'intento dell'utente.
-- - `topic`: Argomento chiave associato (salvato nel contesto per i turni successivi).
-- - `responses`: Elenco di risposte dinamiche; %1 viene sostituito dalla parte catturata.
local rules = {
    -- Categoria: Bisogni espressi dall'utente
    {
        pattern = "ho bisogno di (.*)",
        topic = "bisogno",
        responses = {
            "Perché senti di avere bisogno di %1?",
            "Pensi che avere %1 ti aiuterebbe davvero a stare meglio?",
            "Sei sicuro di avere proprio bisogno di %1?",
            "Cosa cambierebbe nella tua vita se ottenessi %1?"
        }
    },
    -- Categoria: Domande dirette al chatbot
    {
        pattern = "perché non (.*)",
        topic = "domanda_perche",
        responses = {
            "Pensi davvero che io non %1?",
            "Forse a tempo debito potrò %1, ma parlami di te.",
            "Vuoi davvero che io %1?",
            "Credi che la soluzione stia nel fatto che io %1?"
        }
    },
    -- Categoria: Sensazione di blocco / Impossibilità
    {
        pattern = "perché non posso (.*)",
        topic = "limite",
        responses = {
            "Pensi che dovresti essere in grado di %1?",
            "Se potessi %1, cosa faresti subito dopo?",
            "Non saprei... secondo te perché non puoi %1?"
        }
    },
    {
        pattern = "non posso (.*)",
        topic = "limite",
        responses = {
            "Come fai a sapere con certezza di non poter %1?",
            "Forse potresti %1 se provassi a guardare la cosa da un'altra prospettiva.",
            "Cosa ci vorrebbe per permetterti di %1?"
        }
    },
    -- Categoria: Identità e Autosvalutazione
    {
        pattern = "sono (.*)",
        topic = "identita",
        responses = {
            "Sei venuto da me perché ti senti %1?",
            "Da quanto tempo avverti di essere %1?",
            "Credi sia normale sentirti così %1?",
            "Essere %1 ti fa soffrire o ti dà sicurezza?"
        }
    },
    -- Categoria: Emozioni generiche
    {
        pattern = "mi sento (.*)",
        topic = "emozione",
        responses = {
            "Ti capita spesso di sentirti %1?",
            "Cosa ti ricorda questo tuo sentirti %1?",
            "Raccontami di più sul fatto di sentirti %1. Quando è iniziato?",
            "Accogliere il fatto di sentirti %1 è il primo passo per capirlo."
        }
    },
    -- Categoria: Desideri
    {
        pattern = "voglio (.*)",
        topic = "desiderio",
        responses = {
            "Cosa significherebbe per te riuscire ad ottenere %1?",
            "Perché desideri così tanto %1?",
            "Cosa faresti se tu ottenessi %1 oggi stesso?"
        }
    },
    -- Categoria: Ansia e Stress
    {
        pattern = "ansioso|ansia|preoccupato|agitato|stressato|paura",
        topic = "ansia",
        responses = {
            "L'ansia spesso ci segnala che stiamo cercando di controllare qualcosa che sfugge al nostro controllo. Cosa ti preoccupa di più?",
            "Quando avverti questa forte agitazione, quali pensieri ti passano per la testa?",
            "Fai un respiro profondo. Da dove credi che nasca questa tensione?"
        }
    },
    -- Categoria: Tristezza e Solitudine
    {
        pattern = "triste|depresso|giù|sconfortato|male|sol[oa]",
        topic = "tristezza",
        responses = {
            "Mi dispiace che tu provi questa tristezza. C'è un episodio specifico che ha scatenato questa sensazione?",
            "Quando ti senti così giù, cosa ti aiuta solitamente a trovare un minimo di conforto?",
            "La tristezza merita di essere ascoltata. Ti va di parlarne?"
        }
    },
    -- Categoria: Lavoro e Studio
    {
        pattern = "lavoro|ufficio|capo|colleghi|università|studio|scuola|carriera",
        topic = "lavoro",
        responses = {
            "Il lavoro e lo studio occupano gran parte delle nostre giornate. Come descriveresti il clima in cui ti trovi?",
            "Ti senti valorizzato per l'impegno che metti in quello che fai?",
            "In che modo questa situazione lavorativa sta influenzando il tuo equilibrio personale?"
        }
    },
    -- Categoria: Famiglia
    {
        pattern = "madre|padre|mamma|papà|famiglia|fratello|sorella|genitori",
        topic = "famiglia",
        responses = {
            "I legami familiari sono profondi e complessi. Che impatto ha la tua famiglia sul tuo stato d'animo?",
            "Ti va di approfondire il rapporto con i tuoi familiari?",
            "Spesso le dinamiche familiari ci accompagnano a lungo. Ti recognized in questo?"
        }
    },
    -- Categoria: Relazioni interpersonali
    {
        pattern = "partner|fidanzat[oa]|moglie|marito|ragazz[oa]|amico|amica|amici",
        topic = "relazioni",
        responses = {
            "Le relazioni con gli altri sono un importante specchio interiore. Come ti senti all'interno di questo rapporto?",
            "Riesci a esprimere apertamente i tuoi bisogni con questa persona?",
            "Pensi che questa relazione ti stia facendo crescere o ti stia prosciugando energie?"
        }
    },
    -- Categoria: Domande sulla natura del Bot
    {
        pattern = "computer|macchina|intelligenza artificiale|robot|chatbot|luiza",
        topic = "tecnologia",
        responses = {
            "Sono Luiza, una terapeuta virtuale basata sul modello del 1966. Ma in questo momento, l'attenzione è tutta focalizzata su di te.",
            "Più che sulla mia natura artificiale, ti chiederei: come ti fa sentire parlare con un programma di ciò che vivi?",
            "Posso offrirti uno spazio di ascolto neutro. Credi che questo ti aiuti a riflettere?"
        }
    },
    -- Categoria: Saluti
    {
        pattern = "ciao|salve|buongiorno|buonasera",
        topic = "saluto",
        responses = {
            "Ciao! Sono qui per ascoltarti. Di cosa vorresti parlare oggi?",
            "Salve. Mettiti comodo: come ti senti in questo momento?"
        }
    }
}


-- ---------------------------------------------------------------------
-- 5. RISPOSTE CONTESTUALI E DI FALLBACK
-- ---------------------------------------------------------------------
-- Domande di approfondimento agganciate al topic precedente
local context_responses = {
    lavoro = "Prima hai accennato al tuo lavoro o studio. Pensi che c'entri con quello che stai dicendo ora?",
    famiglia = "Ripensando a ciò che dicevi sulla tua famiglia, vedi un collegamento con questo argomento?",
    ansia = "Dato che prima avvertivi molta ansia, credi che questo pensiero stia alimentando la tua agitazione?",
    tristezza = "Questo discorso si collega in qualche modo alla tristezza di cui parlavi prima?",
    relazioni = "Ha a che fare con le relazioni di cui discutevamo poco fa?"
}

-- Risposte generiche di ascolto attivo (usate quando nessun pattern corrisponde)
local default_responses = {
    "Molto interessante. Ti prego, continua a sviluppare questo pensiero.",
    "Raccontami qualcosa di più a questo proposito.",
    "Come ti fa sentire tutto questo mentre lo racconti ad alta voce?",
    "Puoi approfondire questo punto specifico?",
    "Perché ritieni che questo sia così importante per te?",
    "Capisco. Cos'altro ti passa per la mente adesso?"
}


-- ---------------------------------------------------------------------
-- 6. FUNZIONE DI ELABORAZIONE DELL'INPUT (M.reply)
-- ---------------------------------------------------------------------
--- Elabora la frase inviata dall'utente e restituisce la risposta di Luiza.
-- @param input string: La frase dell'utente.
-- @return string: La risposta generata da Luiza.
-- @return boolean: Flag che indica true se l'utente ha chiesto di uscire.
function M.reply(input)
    -- Controlla se l'input è vuoto o assente
    if not input or input == "" then
        return "Ti ascolto, dimmi pure.", false
    end

    -- Incrementa il contatore dei turni
    context.turns_count = context.turns_count + 1

    -- Normalizzazione: minuscolo, rimozione spazi iniziali/finali e punteggiatura
    local clean_input = input:lower()
    clean_input = clean_input:gsub("^%s*(.-)%s*$", "%1")
    clean_input = clean_input:gsub("[%.%?!;]+$", "")

    -- Controllo comandi di uscita della conversazione
    if clean_input == "esci" or clean_input == "quit" or clean_input == "exit" or clean_input == "ciao ciao" then
        return "Arrivederci. Spero che questa chiacchierata ti sia stata utile per fare un po' di chiarezza. A presto!", true
    end

    -- PASSAGGIO 1: Scansione delle regole di conversazione (Pattern Matching)
    for _, rule in ipairs(rules) do
        local captured = clean_input:match(rule.pattern)
        if captured then
            -- Se la regola definisce un topic, aggiorna la memoria di contesto
            if rule.topic then
                context.last_topic = rule.topic
            end

            -- Seleziona una risposta casuale dalla lista della regola
            local template = rule.responses[math.random(#rule.responses)]
            -- Riflette i pronomi nella parte di testo catturata
            local reflected_capture = reflect(captured)
            -- Sostituisce il segnaposto %1 con il testo riflesso
            local response = template:gsub("%%1", reflected_capture)
            return response, false
        end
    end

    -- PASSAGGIO 2: Richiamo casuale del contesto precedente (se disponibile)
    if context.last_topic and context_responses[context.last_topic] and math.random(1, 100) > 60 then
        local resp = context_responses[context.last_topic]
        context.last_topic = nil -- Consuma il contesto per evitare ripetizioni immediate
        return resp, false
    end

    -- PASSAGGIO 3: Risposta generica di ascolto attivo (fallback)
    return default_responses[math.random(#default_responses)], false
end


-- ---------------------------------------------------------------------
-- 7. CICLO PRINCIPALE REPL (Esecuzione da Terminale)
-- ---------------------------------------------------------------------
-- Verifica se il file è eseguito direttamente (es. `lua src/luiza.lua`)
-- oppure se è stato caricato come modulo tramite `require("luiza")`.
local is_main_script = debug.getinfo(3) == nil

if is_main_script then
    print("------------------------------------------------------------------")
    print("LUIZA (Versione " .. M.version .. "-beta): La tua terapeuta virtuale in Italiano")
    print("Digita 'esci', 'quit' o 'exit' per terminare la conversazione.")
    print("------------------------------------------------------------------")
    print("LUIZA: Ciao. Sono qui per ascoltarti. Come ti senti in questo momento?")

    -- Loop interattivo continuo
    while true do
        io.write("\n> ")
        io.flush()

        local user_input = io.read()
        -- Gestisce la disconnessione o la chiusura dello stream (es. Ctrl+D)
        if not user_input then
            print("\nLUIZA: Arrivederci.")
            break
        end

        local reply, should_exit = M.reply(user_input)
        print("\nLUIZA: " .. reply)

        -- Esce dal ciclo se l'utente ha inserito un comando di chiusura
        if should_exit then
            break
        end
    end
end

-- Restituisce la tabella del modulo Luiza
return M