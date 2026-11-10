-- =====================================================================
-- Autore: Stefano Peris
-- Email: stefanoperis.github@gmail.com
-- GitHub: https://www.github.com/RetroFloppy77
-- Nome Progetto: Luiza (Lua + ELIZA)
-- Descrizione: Adattamento in Lua standard dello storico chatbot ELIZA (1966)
-- =====================================================================

-- Inizializza il generatore di numeri casuali basandosi sull'orario di sistema
math.randomseed(os.time())

-- Messaggio di benvenuto all'avvio del programma
print("------------------------------------------------------------------")
print("LUIZA: La tua terapeuta virtuale (Versione Lua 1966 - in Italiano)")
print("Digita 'esci', 'quit' o 'exit' per terminare la conversazione.")
print("------------------------------------------------------------------")
print("LUIZA: Ciao. Come ti senti oggi?")

-- =====================================================================
-- TABELLA DELLE RIFLESSIONI GRAMMATICALI
-- Inverte i pronomi e le persone dei verbi per cambiare la prospettiva
-- da prima persona (utente) a seconda persona (terapeuta).
-- =====================================================================
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
    ["sei"]        = "sono"
}

-- Funzione che prende il testo catturato dall'input dell'utente e
-- sostituisce ogni parola con il corrispettivo riflesso (se presente).
local function reflect(text)
    local words = {}
    -- %S+ seleziona ogni parola separata da spazi
    for word in text:gmatch("%S+") do
        local lower_word = word:lower()
        -- Cerca nella tabella delle riflessioni; se non esiste, mantiene la parola originale
        local reflected_word = reflections[lower_word] or word
        table.insert(words, reflected_word)
    end
    -- Riassemble le parole riflesse in un'unica stringa
    return table.concat(words, " ")
end

-- =====================================================================
-- REGOLE DI CONVERSAZIONE (Pattern Matching in Italiano)
-- Ogni regola contiene un pattern di ricerca (espressione regolare)
-- e un elenco di risposte possibili tra cui scegliere (una a caso).
-- %1 viene sostituito dinamicamente dal testo catturato da (.*)
-- =====================================================================
local rules = {
    {
        pattern = "ho bisogno di (.*)",
        responses = {
            "Perché hai bisogno di %1?",
            "Pensi che avere %1 ti aiuterebbe davvero?",
            "Sei sicuro di avere bisogno di %1?"
        }
    },
    {
        pattern = "perché non (.*)",
        responses = {
            "Pensi davvero che io non %1?",
            "Forse a tempo debito potrò %1.",
            "Vuoi davvero che io %1?"
        }
    },
    {
        pattern = "perché non posso (.*)",
        responses = {
            "Pensi che dovresti essere in grado di %1?",
            "Se potessi %1, cosa faresti?",
            "Non saprei... perché non puoi %1?"
        }
    },
    {
        pattern = "non posso (.*)",
        responses = {
            "Come fai a sapere di non poter %1?",
            "Forse potresti %1 se ci provassi.",
            "Cosa ci vorrebbe per permetterti di %1?"
        }
    },
    {
        pattern = "sono (.*)",
        responses = {
            "Sei venuto da me perché sei %1?",
            "Da quanto tempo ti senti %1?",
            "Credi sia normale essere %1?",
            "Ti fa sentire bene essere %1?"
        }
    },
    {
        pattern = "mi sento (.*)",
        responses = {
            "Ti capita spesso di sentirti %1?",
            "Cosa ti ricorda questo tuo sentirti %1?",
            "Raccontami di più sul fatto di sentirti %1."
        }
    },
    {
        pattern = "voglio (.*)",
        responses = {
            "Cosa significherebbe per te ottenere %1?",
            "Perché vuoi %1?",
            "Cosa faresti se tu ottenessi %1?"
        }
    },
    {
        pattern = "madre|padre|mamma|papà|famiglia|fratello|sorella|genitori",
        responses = {
            "Parlami di più della tua famiglia.",
            "Che rapporto hai con i tuoi familiari?",
            "Come si collega questo alla tua situazione familiare?"
        }
    },
    {
        pattern = "computer|macchina|intelligenza artificiale|robot|chatbot",
        responses = {
            "Pensi che le macchine possano davvero pensare?",
            "Perché menzioni i computer?",
            "Cosa ti fa pensare alle macchine artificiali?"
        }
    },
    {
        pattern = "ciao|salve|buongiorno|buonasera",
        responses = {
            "Ciao! Come ti senti oggi?",
            "Salve. Di cosa vorresti parlare?"
        }
    }
}

-- Risposte generiche di fallback utilizzate quando l'input dell'utente
-- non corrisponde a nessun pattern specifico nelle regole soprastanti.
local default_responses = {
    "Molto interessante. Ti prego, continua.",
    "Raccontami di più a questo proposito.",
    "Come ti fa sentire tutto questo?",
    "Puoi approfondire questo punto?",
    "Perché dici questo?",
    "Capisco. Cos'altro ti passa per la testa?"
}

-- =====================================================================
-- FUNZIONE DI ELABORAZIONE DELL'INPUT
-- Normalizza il testo dell'utente, cerca pattern corrispondenti
-- ed elabora la risposta appropriata.
-- =====================================================================
local function process_input(input)
    -- 1. Converti il testo in minuscolo
    input = input:lower()
    -- 2. Rimuovi eventuali spazi all'inizio e alla fine della frase
    input = input:gsub("^%s*(.-)%s*$", "%1")
    -- 3. Rimuovi la punteggiatura finale (punti, punti interrogativi, ecc.)
    input = input:gsub("[%.%?!;]+$", "")

    -- Controlla se l'utente ha espresso la volontà di chiudere il programma
    if input == "esci" or input == "quit" or input == "exit" or input == "ciao ciao" then
        return "Arrivederci. È stato un piacere parlare con te.", true
    end

    -- Scansione sequenziale delle regole di conversazione
    for _, rule in ipairs(rules) do
        -- Tenta la corrispondenza del pattern con l'input dell'utente
        local captured = input:match(rule.pattern)
        
        if captured then
            -- Seleziona casualmente un modello di risposta dalla regola abbinata
            local template = rule.responses[math.random(#rule.responses)]
            
            -- Applica l'inversione dei pronomi al testo catturato (se presente)
            local reflected_capture = reflect(captured)
            
            -- Sostituisce %1 nel template con la stringa espressa e riflessa
            local response = template:gsub("%%1", reflected_capture)
            return response, false
        end
    end

    -- Se nessun pattern corrisponde, restituisce una risposta casuale di default
    return default_responses[math.random(#default_responses)], false
end

-- =====================================================================
-- LOOP PRINCIPALE DEL PROGRAMMA (REPL)
-- Mantiene il programma in esecuzione continua fino al comando di uscita.
-- =====================================================================
while true do
    -- Stampa il prompt per il terminale dell'utente
    io.write("\n> ")
    io.flush()
    
    -- Legge la linea inserita da tastiera
    local user_input = io.read()
    
    -- Gestione della chiusura dello stream da terminale (es. Ctrl+D)
    if not user_input then 
        print("\nLUIZA: Arrivederci.")
        break 
    end
    
    -- Elabora la risposta tramite la funzione di processamento
    local reply, should_exit = process_input(user_input)
    
    -- Stampa la risposta di LUIZA
    print("LUIZA: " .. reply)
    
    -- Termina il ciclo se l'utente ha digitato 'esci'
    if should_exit then
        break
    end
end

return M
