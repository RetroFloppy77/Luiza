-- =====================================================================
-- Autore: Stefano Peris
-- Email: stefanoperis.github@gmail.com
-- GitHub: https://www.github.com/RetroFloppy77
-- Nome Progetto: Luiza (Lua + ELIZA)
-- Versione: 0.9.2 Beta
-- Descrizione: Adattamento avanzato in Lua standard dello storico chatbot
--              ELIZA (1966) ideato da Joseph Weizenbaum.
--              Interamente in italiano, dotato di memoria di contesto estesa,
--              parser basato su scoring di specificità, riflessioni grammaticali
--              avanzate per contrazioni e supporto per test automatici (CI/CD).
-- Licenza: GNU General Public License v3.0 (GPL-3.0)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. STRUTTURA DEL MODULO & INIZIALIZZAZIONE
-- ---------------------------------------------------------------------
-- Tabella principale del modulo (M) usata sia per l'esportazione verso 
-- script esterni/test automatici, sia per tracciare la versione corrente.
local M = {}

-- Versione corrente del modulo (utilizzata anche dai workflow CI/CD)
M.version = "0.9.2"

-- Inizializza il generatore di numeri casuali usando il timestamp di sistema
math.randomseed(os.time())


-- ---------------------------------------------------------------------
-- 2. MEMORIA DI CONTESTO ESTESA
-- ---------------------------------------------------------------------
-- Mantiene traccia dell'ultimo argomento, dello storico recente dei topic
-- e del numero di scambi avvenuti per garantire coerenza conversazionale.
local context = {
    last_topic = nil,       -- Memorizza la categoria dell'ultima regola attivata
    topic_history = {},     -- Storico limitato degli ultimi topic trattati
    turns_count = 0         -- Contatore dei turni della conversazione
}

--- Registra un nuovo topic nella memoria di contesto e nello storico.
-- @param topic string: L'etichetta del topic identificato.
local function push_topic(topic)
    if not topic then return end
    context.last_topic = topic
    table.insert(context.topic_history, 1, topic)
    if #context.topic_history > 5 then
        table.remove(context.topic_history)
    end
end


-- ---------------------------------------------------------------------
-- 3. TABELLA DELLE RIFLESSIONI GRAMMATICALI (Italiano)
-- ---------------------------------------------------------------------
-- Inverte i pronomi, gli aggettivi possessivi e le persone dei verbi
-- per cambiare la prospettiva dall'utente (1a persona) al terapeuta (2a persona).
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
    ["stavo"]      = "stavi",
    ["ci"]         = "vi",
    ["vi"]         = "ci",
    ["nostro"]     = "vostro",
    ["nostra"]     = "vostra",
    ["nostri"]     = "vostri",
    ["nostre"]     = "vostre"
}

--- Sostituisce le parole all'interno della stringa catturata dai pattern
-- applicando l'inversione grammaticale e gestendo correttamente le contrazioni.
-- @param text string: Il frammento di frase catturato dall'input dell'utente.
-- @return string: La frase riconvertita con i pronomi aggiornati.
local function reflect(text)
    if not text or text == "" then return "" end
    
    -- Pulizia preliminare del testo catturato
    text = text:gsub("^%s*(.-)%s*$", "%1")
    
    local words = {}
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
-- - `topic`: Argomento chiave associato (salvato nel contesto).
-- - `responses`: Elenco di risposte dinamiche; %1, %2 vengono sostituiti dalle parti catturate.
local rules = {
    -- Categoria: Bisogni espressi dall'utente
    {
        pattern = "ho bisogno di (.*)",
        topic = "bisogno",
        responses = {
            "Perché senti di avere bisogno di %1?",
            "Pensi che avere %1 ti aiuterebbe davvero a stare meglio?",
            "Sei sicuro di avere proprio bisogno di %1?",
            "Cosa cambierebbe nella tua vita se ottenessi %1?",
            "Credi che dipenda tutto da %1 in questo momento?"
        }
    },
    -- Categoria: Incertezza e dubbi sul futuro
    {
        pattern = "non so (.*)",
        topic = "incertezza",
        responses = {
            "Cosa ti spaventa di più del non sapere %1?",
            "Se tu sapessi già la risposta riguardo %1, cosa faresti?",
            "A volte l'incertezza su %1 blocca ogni azione. Come ti fa sentire?",
            "Ti capita spesso di sentirti così smarrito quando pensi a %1?"
        }
    },
    -- Categoria: Rabbia e frustrazione
    {
        pattern = "arrabbiat[oa]|rabbia|furia|infastidit[oa]|odio",
        topic = "rabbia",
        responses = {
            "La rabbia spesso protegge qualcos'altro, come una delusione o una ferita. Cosa ha scatenato questa furia?",
            "Quando provi questa rabbia intensa, dove la avverti di più nel corpo?",
            "Pensi che esprimere questa rabbia possa aiutarti a chiarire la situazione o finisce per logorarti?"
        }
    },
    -- Categoria: Stanchezza ed esaurimento
    {
        pattern = "stanchezza|stanc[oa]|esaurit[oa]|sfinito|forze|energia",
        topic = "stanchezza",
        responses = {
            "Hai accumulato troppi pesi ultimamente? Raccontami di cosa ti senti svuotato.",
            "Quando il corpo e la mente dicono basta, spesso c'è bisogno di fermarsi. Ti stai concedendo il permesso di farlo?",
            "Cosa sta prosciugando tutte le tue energie in questo periodo?"
        }
    },
    -- Categoria: Senso di colpa
    {
        pattern = "colpa|sbagliat[oa]|fallito|fallimento",
        topic = "colpa",
        responses = {
            "Ti stai giudicando troppo severamente?",
            "Se un amico si trovasse nella tua stessa identica situazione, gli faresti le stesse critiche?",
            "Credi che commettere errori tolga valore a chi sei?"
        }
    },
    -- Categoria: Sogni e Progetti
    {
        pattern = "sogno|sognare|passione|vorrei tanto (.*)|desiderio",
        topic = "sogni",
        responses = {
            "Coltivare i propri desideri è fondamentale. Cosa ti impedisce di realizzare %1?",
            "Parlami di più di questo sogno. Che emozione ti dà solo a pensarci?",
            "Se non ci fossero ostacoli esterni, come cambierebbe la tua strada verso %1?"
        }
    },
    -- Categoria: Domande dirette al chatbot
    {
        pattern = "perché non (.*)",
        topic = "domanda_perche",
        responses = {
            "Pensi davvero che io non %1?",
            "Forse a tempo debito potrò %1, ma adesso concentriamoci su di te.",
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
            "Essere %1 ti fa soffrire o ti dà una sorta di sicurezza?"
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
            "Fai un respiro profondo. Da dove credi che nasca questa tensione?",
            "L'ansia sa essere molto logorante. C'è un pensiero ricorrente che l'alimenta?"
        }
    },
    -- Categoria: Tristezza e Solitudine
    {
        pattern = "triste|depresso|giù|sconfortato|male|sol[oa]",
        topic = "tristezza",
        responses = {
            "Mi dispiace che tu provi questa tristezza. C'è un episodio specifico che ha scatenato questa sensazione?",
            "Quando ti senti così giù, cosa ti aiuta solitamente a trovare un minimo di conforto?",
            "La tristezza merita di essere ascoltata. Ti va di parlarne?",
            "Sentirsi soli o giù di morale toglie ogni colore alla giornata. Ti va di raccontarmi cosa provi?"
        }
    },
    -- Categoria: Lavoro e Studio
    {
        pattern = "lavoro|ufficio|capo|colleghi|università|studio|scuola|carriera",
        topic = "lavoro",
        responses = {
            "Il lavoro e lo studio occupano gran parte delle nostre giornate. Come descriveresti il clima in cui ti trovi?",
            "Ti senti valorizzato per l'impegno che metti in quello che fai?",
            "In che modo questa situazione lavorativa sta influenzando il tuo equilibrio personale?",
            "Ci sono tensioni specifiche con qualcuno nell'ambiente lavorativo o di studio?"
        }
    },
    -- Categoria: Famiglia
    {
        pattern = "madre|padre|mamma|papà|famiglia|fratello|sorella|genitori",
        topic = "famiglia",
        responses = {
            "I legami familiari sono profondi e complessi. Che impatto ha la tua famiglia sul tuo stato d'animo?",
            "Ti va di approfondire il rapporto con i tuoi familiari?",
            "Spesso le dinamiche familiari ci accompagnano a lungo. Ti recognized in questo?",
            "Qual è il ricordo o la dinamica familiare che ti pesa di più adesso?"
        }
    },
    -- Categoria: Relazioni interpersonali
    {
        pattern = "partner|fidanzat[oa]|moglie|marito|ragazz[oa]|amico|amica|amici",
        topic = "relazioni",
        responses = {
            "Le relazioni con gli altri sono un importante specchio interiore. Come ti senti all'interno di questo rapporto?",
            "Riesci a esprimere apertamente i tuoi bisogni con questa persona?",
            "Pensi che questa relazione ti stia facendo crescere o ti stia prosciugando energie?",
            "C'è qualcosa che vorresti dire a questa persona ma che finora hai trattenuto?"
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
            "Salve. Mettiti comodo: come ti senti in questo momento?",
            "Benvenuto. Prenditi tutto il tempo di cui hai bisogno."
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
    relazioni = "Ha a che fare con le relazioni di cui discutevamo poco fa?",
    rabbia = "Questo risentimento si collega alla rabbia di cui parlavamo prima?",
    stanchezza = "Senti che la stanchezza di cui accennavi stia aggravando questo stato d'animo?"
}

-- Risposte generiche di ascolto attivo (usate quando nessun pattern corrisponde)
local default_responses = {
    "Molto interessante. Ti prego, continua a sviluppare questo pensiero.",
    "Raccontami qualcosa di più a questo proposito.",
    "Come ti fa sentire tutto questo mentre lo racconti ad alta voce?",
    "Puoi approfondire questo punto specifico?",
    "Perché ritieni che questo sia così importante per te?",
    "Capisco. Cos'altro ti passa per la mente adesso?",
    "C'è un dettaglio in particolare di questa storia che vorresti mettere a fuoco?",
    "Ascoltandoti, mi chiedo cosa ti aspetti che accada adesso."
}


-- ---------------------------------------------------------------------
-- 6. FUNZIONE DI ELABORAZIONE DELL'INPUT (M.reply)
-- ---------------------------------------------------------------------
--- Elabora la frase inviata dall'utente e restituisce la risposta di Luiza
-- utilizzando un parser basato su scoring di specificità e gestione delle contrazioni.
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

    -- Normalizzazione avanzata: minuscolo, rimozione spazi e punteggiatura superflua
    local clean_input = input:lower()
    clean_input = clean_input:gsub("^%s*(.-)%s*$", "%1")
    clean_input = clean_input:gsub("[%.,%?!;]+$", "")
    clean_input = clean_input:gsub("[''`]", "'")

    -- Controllo comandi di uscita della conversazione
    if clean_input == "esci" or clean_input == "quit" or clean_input == "exit" or clean_input == "ciao ciao" then
        return "Arrivederci. Spero che questa chiacchierata ti sia stata utile per fare un po' di chiarezza. A presto!", true
    end

    -- PASSAGGIO 1: Scoring e Pattern Matching Avanzato
    -- Valuta tutte le regole assegnando un punteggio basato sulla specificità del pattern
    local best_match = nil
    local best_score = -1
    local best_captured = nil

    for _, rule in ipairs(rules) do
        local captured = { clean_input:match(rule.pattern) }
        if #captured > 0 then
            -- Calcola la specificità del pattern escludendo i caratteri speciali regex
            local literal_pattern = rule.pattern:gsub("%%.", ""):gsub("%(.-%)", ""):gsub("[%[%]%*%+%?%%]", "")
            local score = #literal_pattern + (#rule.pattern > 12 and 5 or 0)

            if score > best_score then
                best_score = score
                best_match = rule
                best_captured = captured
            end
        end
    end

    if best_match then
        if best_match.topic then
            push_topic(best_match.topic)
        end

        local template = best_match.responses[math.random(#best_match.responses)]
        local response = template

        -- Sostituzione dinamica dei gruppi catturati con riflessione grammaticale
        for i, cap in ipairs(best_captured) do
            local reflected_capture = reflect(cap)
            response = response:gsub("%%" .. i, reflected_capture)
        end

        return response, false
    end

    -- PASSAGGIO 2: Richiamo contestuale intelligente basato sullo storico recente
    if context.last_topic and context_responses[context.last_topic] and math.random(1, 100) > 50 then
        local resp = context_responses[context.last_topic]
        context.last_topic = nil -- Consuma il topic per evitare ripetizioni immediate
        return resp, false
    end

    -- PASSAGGIO 3: Risposta generica di ascolto attivo (fallback)
    return default_responses[math.random(#default_responses)], false
end


-- ---------------------------------------------------------------------
-- 7. CICLO PRINCIPALE REPL (Esecuzione da Terminale)
-- ---------------------------------------------------------------------
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
        if not user_input then
            print("\nLUIZA: Arrivederci.")
            break
        end

        local reply, should_exit = M.reply(user_input)
        print("\nLUIZA: " .. reply)

        if should_exit then
            break
        end
    end
end

-- Restituisce la tabella del modulo Luiza
return M