-- =====================================================================
-- Autore: Stefano Peris
-- Email: stefanoperis.github@gmail.com
-- GitHub: https://www.github.com/RetroFloppy77
-- Nome Progetto: Luiza (Lua + ELIZA)
-- Versione: 0.9.3 Beta
-- Descrizione: Adattamento conversazionale in Lua standard dello storico
--              chatbot ELIZA (1966), ideato da Joseph Weizenbaum.
--              Include regole in italiano, selezione per specificita',
--              riflessioni grammaticali, memoria contestuale e risposte
--              variate. Il progetto usa esclusivamente il paradigma
--              procedurale e le librerie standard di Lua.
-- Licenza: GNU General Public License v3.0 (GPL-3.0)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. STRUTTURA DEL MODULO E INIZIALIZZAZIONE
-- ---------------------------------------------------------------------
-- La tabella M espone le funzioni pubbliche del programma. Il motore e le
-- sue strutture interne restano locali a questo file, così da evitare
-- modifiche accidentali allo stato della conversazione da parte di altri
-- moduli.
local M = {}

M.version = "0.9.3"

-- Il generatore casuale viene inizializzato una volta sola al caricamento
-- del modulo. La scelta casuale serve a variare le risposte, non a simulare
-- una comprensione linguistica o un'intelligenza artificiale generativa.
math.randomseed(os.time())


-- ---------------------------------------------------------------------
-- 2. MEMORIA CONVERSAZIONALE
-- ---------------------------------------------------------------------
-- La memoria conserva soltanto informazioni temporanee e non viene salvata
-- su disco. Lo storico dei topic consente al bot di riprendere un argomento
-- quando l'utente risponde con una frase breve o poco specifica.
local context = {
    last_topic = nil,
    topic_history = {},
    last_user_input = nil,
    turns_count = 0
}

-- Memorizza l'indice dell'ultima risposta scelta per ciascuna categoria.
-- In questo modo una stessa regola non ripete immediatamente la medesima
-- frase, purché disponga di almeno due risposte.
local last_response_index = {}

--- Registra un argomento nella memoria e mantiene uno storico limitato.
-- @param topic string Etichetta dell'argomento riconosciuto.
local function push_topic(topic)
    if not topic then
        return
    end

    context.last_topic = topic

    -- Evita di riempire lo storico con copie consecutive dello stesso topic.
    if context.topic_history[1] ~= topic then
        table.insert(context.topic_history, 1, topic)
    end

    -- Conserva soltanto gli ultimi sei argomenti distinti/consecutivi.
    while #context.topic_history > 6 do
        table.remove(context.topic_history)
    end
end

--- Sceglie una risposta evitando, quando possibile, la ripetizione immediata.
-- @param responses table Elenco delle risposte disponibili.
-- @param response_key string Chiave usata per ricordare la scelta precedente.
-- @return string Risposta selezionata.
local function choose_response(responses, response_key)
    local count = #responses
    if count == 0 then
        return "Puoi raccontarmi qualcosa di più?"
    end

    local selected = math.random(count)
    local previous = last_response_index[response_key]

    if count > 1 and selected == previous then
        -- Sposta l'indice di una posizione: evita un secondo sorteggio
        -- e garantisce che la risposta sia diversa dalla precedente.
        selected = (selected % count) + 1
    end

    last_response_index[response_key] = selected
    return responses[selected]
end


-- ---------------------------------------------------------------------
-- 3. NORMALIZZAZIONE E RIFLESSIONE GRAMMATICALE
-- ---------------------------------------------------------------------
-- La riflessione grammaticale ribalta alcune forme dalla prima alla seconda
-- persona e viceversa. È una tecnica tipica dei chatbot della famiglia
-- ELIZA: non equivale a un'analisi grammaticale completa della lingua.
local reflections = {
    ["io"] = "tu",
    ["me"] = "te",
    ["mio"] = "tuo",
    ["mia"] = "tua",
    ["miei"] = "tuoi",
    ["mie"] = "tue",
    ["sono"] = "sei",
    ["sei"] = "sono",
    ["ero"] = "eri",
    ["eri"] = "ero",
    ["ho"] = "hai",
    ["hai"] = "ho",
    ["avevo"] = "avevi",
    ["avevi"] = "avevo",
    ["posso"] = "puoi",
    ["puoi"] = "posso",
    ["voglio"] = "vuoi",
    ["vuoi"] = "voglio",
    ["sento"] = "senti",
    ["senti"] = "sento",
    ["stavo"] = "stavi",
    ["stavi"] = "stavo",
    ["mi"] = "ti",
    ["ti"] = "mi",
    ["tu"] = "io",
    ["tuo"] = "mio",
    ["tua"] = "mia",
    ["tuoi"] = "miei",
    ["tue"] = "mie",
    ["ci"] = "vi",
    ["vi"] = "ci",
    ["nostro"] = "vostro",
    ["nostra"] = "vostra",
    ["nostri"] = "vostri",
    ["nostre"] = "vostre",
    ["vostro"] = "nostro",
    ["vostra"] = "nostra",
    ["vostri"] = "nostri",
    ["vostre"] = "nostre"
}

--- Rimuove spazi esterni e uniforma alcune forme di punteggiatura.
-- @param input string Testo originale dell'utente.
-- @return string Testo normalizzato e convertito in minuscolo.
local function normalize_input(input)
    local text = input:lower()

    -- Uniforma apostrofi tipografici e ritorni a capo.
    text = text:gsub("’", "'"):gsub("‘", "'")
    text = text:gsub("`", "'"):gsub("´", "'")
    text = text:gsub("À", "à"):gsub("È", "è"):gsub("É", "é")
    text = text:gsub("Ì", "ì"):gsub("Ò", "ò"):gsub("Ù", "ù")
    text = text:gsub("[\r\n\t]", " ")

    -- La punteggiatura finale non deve impedire il riconoscimento di una
    -- frase. Quella interna viene conservata per non alterare le parole.
    text = text:gsub("[%.,%!%?%;:]+$", "")
    text = text:gsub("%s+", " ")
    text = text:gsub("^%s*(.-)%s*$", "%1")

    return text
end

--- Riflette i pronomi e i verbi contenuti in una frase catturata.
-- La funzione separa la punteggiatura ASCII iniziale/finale, sostituisce
-- soltanto la parola e poi ricompone il token.
-- @param text string Frase da trasformare.
-- @return string Frase con le riflessioni applicate.
local function reflect(text)
    if not text or text == "" then
        return ""
    end

    local words = {}

    for token in text:gmatch("%S+") do
        local prefix = token:match("^(%p*)") or ""
        local remaining = token:sub(#prefix + 1)
        local suffix = remaining:match("(%p*)$") or ""
        local word = remaining:sub(1, #remaining - #suffix)

        local reflected_word = reflections[word] or word
        table.insert(words, prefix .. reflected_word .. suffix)
    end

    return table.concat(words, " ")
end


-- ---------------------------------------------------------------------
-- 4. FUNZIONI DI RICONOSCIMENTO DEI PATTERN
-- ---------------------------------------------------------------------
-- Lua usa i propri pattern (string patterns), che non sono espressioni
-- regolari complete: in particolare NON supportano l'alternativa "|".
-- Per questo motivo le parole chiave sono elencate separatamente e cercate
-- come testo semplice; i pattern con catture sono usati solo per le frasi
-- che devono fornire una parte variabile (%1, %2, ...).

--- Indica se un byte appartiene a una parola, incluse le lettere UTF-8.
-- Considerare come lettere anche i byte >= 128 evita di spezzare parole
-- accentate durante il controllo dei confini.
-- @param value number|nil Byte da controllare.
-- @return boolean True se il byte fa parte di una parola.
local function is_word_byte(value)
    if not value then
        return false
    end

    return (value >= 48 and value <= 57)
        or (value >= 65 and value <= 90)
        or (value >= 97 and value <= 122)
        or value >= 128
        or value == 95
end

--- Cerca una parola o una frase completa, senza corrispondenze parziali.
-- @param text string Testo normalizzato.
-- @param phrase string Parola o sequenza da cercare.
-- @return boolean True quando la frase è presente come unità completa.
local function contains_phrase(text, phrase)
    local start_at = 1

    while true do
        local first, last = text:find(phrase, start_at, true)
        if not first then
            return false
        end

        local before_is_boundary = first == 1 or not is_word_byte(text:byte(first - 1))
        local after_is_boundary = last == #text or not is_word_byte(text:byte(last + 1))

        if before_is_boundary and after_is_boundary then
            return true
        end

        start_at = last + 1
    end
end

--- Calcola un punteggio per una regola: le priorità esplicite prevalgono,
-- mentre la lunghezza del testo riconosciuto risolve i casi a pari priorità.
-- @param priority number Priorità assegnata alla regola.
-- @param matched_text string Pattern o parola che ha prodotto il match.
-- @return number Punteggio complessivo.
local function calculate_score(priority, specificity)
    -- La lunghezza della parte letterale pesa più della priorità: in una
    -- frase come "voglio cambiare lavoro", il pattern specifico "voglio"
    -- deve prevalere sulla semplice parola chiave "lavoro". La priorità
    -- risolve poi i casi con specificità equivalente.
    return (specificity or 0) * 100 + (priority or 0)
end


-- ---------------------------------------------------------------------
-- 5. REGOLE CONVERSAZIONALI
-- ---------------------------------------------------------------------
-- Ogni regola contiene:
--   topic     : argomento da salvare nella memoria;
--   priority  : precedenza rispetto alle regole più generiche;
--   keywords  : parole/frasi cercate come testo semplice;
--   patterns  : pattern Lua con eventuali gruppi di cattura;
--   responses : risposte tra cui il motore sceglie senza ripetizioni immediate.
--
-- Le regole più specifiche hanno priorità maggiore. Il motore valuta tutte
-- le regole e non si ferma al primo risultato trovato.
local rules = {
    {
        topic = "bisogno",
        priority = 95,
        keywords = {},
        patterns = { "ho bisogno di (.+)", "avrei bisogno di (.+)" },
        responses = {
            "Che cosa rappresenta per te %1 in questo momento?",
            "Come pensi che %1 potrebbe aiutarti?",
            "Da quanto tempo senti il bisogno di %1?",
            "C'è qualcosa che ti impedisce, al momento, di %1?",
            "Che cosa speri possa cambiare quando riuscirai a %1?"
        }
    },
    {
        topic = "limite",
        priority = 110,
        keywords = {},
        patterns = { "perché non posso (.+)", "perche non posso (.+)" },
        responses = {
            "Che cosa ti fa pensare che questa possibilità sia fuori portata?",
            "Qual è l'ostacolo più importante che incontri?",
            "Se questa possibilità diventasse concreta, quale sarebbe il tuo primo passo?"
        },
        capture_responses = {
            "Che cosa ti fa pensare che non puoi %1?",
            "Qual è l'ostacolo più importante che incontri quando provi a %1?",
            "Se riuscissi a %1, quale sarebbe il tuo primo passo?"
        }
    },
    {
        topic = "domanda_perche",
        priority = 100,
        keywords = {},
        patterns = { "perché non (.+)", "perche non (.+)" },
        responses = {
            "Che cosa ti aspetteresti che accadesse se fosse possibile %1?",
            "Perché è importante per te che io %1?",
            "Che cosa ti porta a formulare proprio questa domanda?"
        }
    },
    {
        topic = "incertezza",
        priority = 98,
        keywords = { "non so cosa fare", "non ne ho idea", "sono indeciso", "sono indecisa" },
        patterns = { "non so se (.+)", "non so (.+)" },
        responses = {
            "Che cosa ti crea più incertezza in questo momento?",
            "Quali possibilità hai già preso in considerazione?",
            "Quale parte della situazione ti sembra più difficile da valutare?",
            "Che cosa potrebbe aiutarti a chiarire i tuoi dubbi?"
        }
    },
    {
        topic = "emozione",
        priority = 105,
        keywords = {},
        patterns = { "mi sento (.+)", "mi sono sentito (.+)", "mi sono sentita (.+)" },
        responses = {
            "Da quanto tempo ti senti %1?",
            "C'è stato un episodio che ha fatto emergere il sentirti %1?",
            "In quali momenti questa sensazione diventa più evidente?",
            "Che cosa vorresti che gli altri capissero del tuo sentirti %1?",
            "Quando dici che ti senti %1, qual è la prima cosa che ti viene in mente?"
        }
    },
    {
        topic = "rabbia",
        priority = 90,
        keywords = {
            "rabbia", "arrabbiato", "arrabbiata", "arrabbiare", "arrabbiarsi",
            "mi fa rabbia", "furioso", "furiosa", "infastidito", "infastidita",
            "irritato", "irritata", "odio"
        },
        patterns = {},
        responses = {
            "Che cosa è successo poco prima che provassi questa rabbia?",
            "Quale aspetto della situazione ti sembra più ingiusto?",
            "C'è qualcosa che avresti voluto dire, ma hai preferito trattenere?",
            "Oltre alla rabbia, riconosci anche un'altra emozione in questa situazione?",
            "Che cosa vorresti cambiasse nel modo in cui viene affrontato il problema?"
        }
    },
    {
        topic = "stanchezza",
        priority = 90,
        keywords = {
            "stanchezza", "stanco", "stanca", "esausto", "esausta",
            "sfinito", "sfinita", "senza energie", "senza forze", "burnout"
        },
        patterns = {},
        responses = {
            "Qual è la cosa che in questo periodo ti sta richiedendo più energie?",
            "Questa stanchezza è legata a qualcosa di preciso o si è accumulata nel tempo?",
            "C'è un impegno che vorresti riuscire a ridimensionare?",
            "Quali momenti della giornata ti risultano più pesanti?",
            "Che cosa potrebbe rendere un po' più sostenibile la tua giornata?"
        }
    },
    {
        topic = "colpa",
        priority = 88,
        keywords = { "colpa", "sbagliato", "sbagliata", "fallito", "fallita", "fallimento" },
        patterns = {},
        responses = {
            "Che cosa ti porta a giudicare così severamente quello che è successo?",
            "Quale parte della situazione dipendeva davvero da te?",
            "Che cosa hai imparato da questa esperienza, anche se è stata difficile?",
            "Riusciresti a guardare l'accaduto con un po' più di distanza?"
        }
    },
    {
        topic = "sogni",
        priority = 88,
        keywords = { "sogno", "sognare", "passione", "desiderio", "progetto" },
        patterns = { "vorrei tanto (.+)", "il mio sogno è (.+)" },
        responses = {
            "Che cosa ti attrae maggiormente di questo sogno o progetto?",
            "Quale sarebbe un piccolo passo realistico per avvicinarti a questo progetto?",
            "Da quanto tempo coltivi questo desiderio?",
            "Che cosa ti piacerebbe imparare o scoprire lungo questo percorso?"
        },
        capture_responses = {
            "Che cosa ti attrae maggiormente di %1?",
            "Quale sarebbe un piccolo passo realistico per avvicinarti a %1?",
            "Da quanto tempo coltivi il desiderio di %1?"
        }
    },
    {
        topic = "limite",
        priority = 86,
        keywords = { "non riesco", "non posso", "mi è impossibile", "mi sembra impossibile" },
        patterns = { "non posso (.+)", "non riesco a (.+)" },
        responses = {
            "Qual è la difficoltà più concreta che incontri quando provi a %1?",
            "Hai già provato un modo diverso per affrontare %1?",
            "Che tipo di aiuto o risorsa potrebbe rendere più semplice %1?",
            "Cosa ti fa sentire che questa possibilità sia fuori dalla tua portata?"
        }
    },
    {
        topic = "desiderio",
        priority = 82,
        keywords = {},
        patterns = { "voglio (.+)", "vorrei (.+)" },
        responses = {
            "Che cosa significherebbe per te riuscire a %1?",
            "Qual è il motivo più importante per cui desideri %1?",
            "Che cosa hai già fatto per provare a %1?",
            "Come immagini che cambierebbero le cose se riuscissi a %1?"
        }
    },
    {
        topic = "ansia",
        priority = 91,
        keywords = {
            "ansia", "ansioso", "ansiosa", "preoccupato", "preoccupata",
            "agitato", "agitata", "stressato", "stressata", "paura", "spaventato",
            "spaventata", "in apprensione"
        },
        patterns = { "mi preoccupa (.+)", "ho paura di (.+)" },
        responses = {
            "Qual è la preoccupazione che occupa più spazio nei tuoi pensieri?",
            "C'è qualcosa di concreto che temi possa accadere?",
            "Quando questa agitazione aumenta, che cosa sta succedendo intorno a te?",
            "Quale parte della situazione senti di poter affrontare per prima?",
            "Ti capita di provare questa preoccupazione anche in altri contesti?"
        }
    },
    {
        topic = "tristezza",
        priority = 91,
        keywords = {
            "triste", "tristezza", "depresso", "depressa", "giù", "giù di morale",
            "male", "sconfortato", "sconfortata", "solo", "sola", "solitudine",
            "demoralizzato", "demoralizzata"
        },
        patterns = {},
        responses = {
            "Ti va di raccontarmi che cosa ha contribuito a farti sentire così?",
            "Da quanto tempo questa sensazione accompagna le tue giornate?",
            "C'è qualcosa che, anche solo per poco, rende la situazione più leggera?",
            "Ti senti compreso dalle persone con cui ne parli?",
            "Qual è la cosa che vorresti riuscire a esprimere in questo momento?"
        }
    },
    {
        topic = "lavoro",
        priority = 94,
        keywords = {
            "lavoro", "ufficio", "capo", "collega", "colleghi", "università",
            "studio", "studiare", "scuola", "carriera", "esame", "insegnante"
        },
        patterns = {},
        responses = {
            "Qual è l'aspetto del lavoro o dello studio che ti pesa maggiormente?",
            "Ti senti ascoltato e valorizzato nell'ambiente in cui ti trovi?",
            "Come sta influenzando il resto della tua giornata questa situazione?",
            "C'è una persona o un episodio preciso che vorresti approfondire?",
            "Che cosa dovrebbe cambiare per rendere questo contesto più sereno?"
        }
    },
    {
        topic = "famiglia",
        priority = 94,
        keywords = {
            "madre", "padre", "mamma", "papà", "famiglia", "fratello",
            "sorella", "genitori", "figlio", "figlia", "parente", "parenti"
        },
        patterns = {},
        responses = {
            "Che effetto ha questa situazione sul rapporto con la tua famiglia?",
            "C'è un aspetto del rapporto con i tuoi familiari che vorresti cambiare?",
            "Quando si presenta questa dinamica, come reagisci di solito?",
            "Qual è la cosa che vorresti riuscire a comunicare ai tuoi familiari?",
            "Ti sembra che gli altri comprendano il tuo punto di vista?"
        }
    },
    {
        topic = "relazioni",
        priority = 94,
        keywords = {
            "partner", "fidanzato", "fidanzata", "moglie", "marito", "ragazzo",
            "ragazza", "amico", "amica", "amici", "amicizia", "relazione"
        },
        patterns = {},
        responses = {
            "Come ti senti quando sei insieme a questa persona?",
            "Riesci a comunicare apertamente quello di cui hai bisogno?",
            "Qual è l'aspetto più positivo di questo rapporto? E quello più difficile?",
            "C'è qualcosa che vorresti chiarire con questa persona?",
            "Secondo te, che cosa potrebbe migliorare il vostro modo di comunicare?"
        }
    },
    {
        topic = "tecnologia",
        priority = 89,
        keywords = { "computer", "macchina", "intelligenza artificiale", "robot", "chatbot", "luiza", "eliza" },
        patterns = {},
        responses = {
            "Sono Luiza, un programma conversazionale ispirato al progetto ELIZA. Come mai ti interessa questo argomento?",
            "Funziono attraverso regole e trasformazioni del testo: quale aspetto dei chatbot vorresti conoscere?",
            "La mia capacità di rispondere dipende dai pattern programmati. Che cosa ti incuriosisce del mio funzionamento?"
        }
    },
    {
        topic = "gratitudine",
        priority = 85,
        keywords = { "grazie", "ti ringrazio", "molto gentile" },
        patterns = {},
        responses = {
            "Prego! C'è qualcos'altro su cui vorresti riflettere?",
            "Sono qui per proseguire la conversazione. Vuoi aggiungere qualcosa?",
            "Di nulla. Quale aspetto vorresti approfondire adesso?"
        }
    },
    {
        topic = "saluto",
        priority = 80,
        keywords = { "ciao", "salve", "buongiorno", "buonasera", "buon pomeriggio" },
        patterns = {},
        responses = {
            "Ciao! Di che cosa ti piacerebbe parlare?",
            "Salve! Da dove vuoi iniziare oggi?",
            "Ciao, bentornato. Che cosa ti passa per la mente?"
        }
    },
    {
        topic = "identita",
        priority = 60,
        keywords = {},
        patterns = { "sono (.+)" },
        responses = {
            "Quando dici di essere %1, a che cosa ti riferisci esattamente?",
            "Da quanto tempo ti descriveresti come %1?",
            "In quali situazioni ti capita soprattutto di sentirti %1?",
            "Che significato ha per te definirti %1?"
        }
    }
}


-- ---------------------------------------------------------------------
-- 6. RISPOSTE CONTESTUALI E RISPOSTE GENERICHE
-- ---------------------------------------------------------------------
-- Le risposte contestuali sono organizzate per argomento. Vengono usate
-- soprattutto quando l'utente invia una risposta breve, come "sì", "no"
-- o "non lo so", oppure quando una nuova frase non attiva alcuna regola.
local context_responses = {
    bisogno = {
        "Prima parlavi di qualcosa di cui senti il bisogno. È cambiato qualcosa da allora?",
        "Vuoi approfondire che cosa renderebbe importante per te quel bisogno?"
    },
    incertezza = {
        "Riprendendo i dubbi di cui parlavi, qual è la domanda a cui vorresti trovare una risposta?",
        "C'è qualche elemento nuovo che ti aiuta a valutare meglio le possibilità?"
    },
    rabbia = {
        "Torniamo a ciò che ti ha fatto arrabbiare: quale aspetto senti di non aver ancora chiarito?",
        "La situazione di cui parlavi è cambiata oppure ti pesa ancora allo stesso modo?"
    },
    stanchezza = {
        "Ripensando alla stanchezza che descrivevi, c'è qualcosa che potresti alleggerire?",
        "Quale impegno continua a richiederti più energie?"
    },
    colpa = {
        "Riguardo a ciò che ti faceva sentire in colpa, c'è un elemento che ora vedi diversamente?",
        "Quale parte di quella situazione vorresti comprendere meglio?"
    },
    sogni = {
        "Vuoi tornare al progetto di cui parlavi? Quale sarebbe il prossimo piccolo passo?",
        "Quel desiderio è ancora importante per te? Che cosa lo rende tale?"
    },
    limite = {
        "Riprendendo la difficoltà che descrivevi, qual è l'ostacolo più concreto?",
        "È cambiato qualcosa nel modo in cui guardi a quella possibilità?"
    },
    emozione = {
        "Prima descrivevi come ti senti. Questa sensazione è cambiata mentre ne parlavi?",
        "C'è un dettaglio in più che può aiutarmi a capire meglio ciò che intendi?"
    },
    desiderio = {
        "Vuoi tornare a ciò che desideri ottenere? Quale aspetto conta di più per te?",
        "Hai individuato un modo per avvicinarti a quello che vorresti?"
    },
    ansia = {
        "Ripensando alla preoccupazione di prima, è cambiato qualcosa nella situazione?",
        "Quale pensiero continua a tornarti in mente quando ci ripensi?"
    },
    tristezza = {
        "La sensazione di cui parlavi è ancora presente o qualcosa è cambiato?",
        "C'è qualcosa che vorresti aggiungere su quello che ti ha fatto stare male?"
    },
    lavoro = {
        "Torniamo al lavoro o allo studio: qual è l'aspetto che vorresti affrontare per primo?",
        "È successo qualcosa di nuovo nell'ambiente di lavoro o di studio?"
    },
    famiglia = {
        "Riprendendo il discorso sulla tua famiglia, c'è un episodio preciso che vuoi raccontare?",
        "Il rapporto di cui parlavi è cambiato in qualche modo?"
    },
    relazioni = {
        "Vuoi approfondire il rapporto di cui parlavi? Che cosa è successo nel frattempo?",
        "Quale aspetto di questa relazione vorresti fosse compreso meglio?"
    },
    tecnologia = {
        "Vuoi continuare a parlare di come funzionano i chatbot?",
        "C'è un'altra curiosità su Luiza o su ELIZA che vorresti approfondire?"
    },
    identita = {
        "Prima ti descrivevi in un certo modo. È una sensazione che riconosci da tempo?",
        "Vuoi spiegarmi meglio che cosa intendi con quella descrizione?"
    },
    gratitudine = {
        "Possiamo continuare: quale argomento vorresti affrontare?",
        "C'è qualcos'altro che ti piacerebbe raccontare?"
    },
    saluto = {
        "Da quale argomento vorresti iniziare?",
        "C'è qualcosa che ti è successo oggi e di cui vuoi parlare?"
    }
}

local default_responses = {
    "Puoi raccontarmi qualcosa di più su questo?",
    "Qual è l'aspetto che consideri più importante?",
    "Che cosa ti fa vedere la situazione in questo modo?",
    "C'è un esempio concreto che potrebbe aiutarmi a capire meglio?",
    "Come si collega questo a ciò che è successo negli ultimi giorni?",
    "Che cosa vorresti riuscire a chiarire parlando di questo argomento?",
    "Mi sembra un punto interessante. Da dove vorresti cominciare ad approfondirlo?",
    "Quale parte di quello che hai raccontato senti più vicina ai tuoi pensieri attuali?"
}

local short_replies = {
    ["si"] = true,
    ["sì"] = true,
    ["no"] = true,
    ["forse"] = true,
    ["boh"] = true,
    ["non lo so"] = true,
    ["non so"] = true,
    ["non saprei"] = true,
    ["esatto"] = true,
    ["davvero"] = true,
    ["non proprio"] = true,
    ["può darsi"] = true,
    ["e quindi"] = true,
    ["perché"] = true,
    ["perche"] = true,
    ["in che senso"] = true
}


-- ---------------------------------------------------------------------
-- 7. SELEZIONE DELLA REGOLA PIÙ ADATTA
-- ---------------------------------------------------------------------
--- Cerca la regola più specifica confrontando tutte le parole chiave e i
-- pattern con catture. Restituisce la regola e i valori catturati.
-- @param text string Input normalizzato.
-- @return table|nil Regola selezionata.
-- @return table Catture da inserire nel testo della risposta.
local function find_best_rule(text)
    local best_rule = nil
    local best_captures = {}
    local best_score = -1

    for _, rule in ipairs(rules) do
        -- Le parole chiave sono cercate come testo semplice, con confini
        -- di parola: "ansia" non deve corrispondere, per esempio, a "fantasia".
        for _, keyword in ipairs(rule.keywords or {}) do
            if contains_phrase(text, keyword) then
                local score = calculate_score(rule.priority, #keyword)
                if score > best_score then
                    best_score = score
                    best_rule = rule
                    best_captures = {}
                end
            end
        end

        -- I pattern Lua vengono usati soltanto quando servono catture.
        for _, pattern in ipairs(rule.patterns or {}) do
            local found = { text:find(pattern) }
            if found[1] then
                local captures = {}
                for index = 3, #found do
                    if found[index] ~= nil then
                        table.insert(captures, found[index])
                    end
                end

                local capture_start = pattern:find("(", 1, true)
                local specificity = capture_start and (capture_start - 1) or #pattern
                local score = calculate_score(rule.priority, specificity)
                if score > best_score then
                    best_score = score
                    best_rule = rule
                    best_captures = captures
                end
            end
        end
    end

    return best_rule, best_captures
end

--- Inserisce i gruppi catturati nella risposta, dopo la riflessione.
-- @param template string Modello della risposta.
-- @param captures table Valori catturati dal pattern.
-- @return string Risposta completa.
local function fill_response(template, captures)
    return (template:gsub("%%(%d+)", function(index)
        local captured = captures[tonumber(index)]
        return reflect(captured or "")
    end))
end

--- Restituisce una risposta collegata all'ultimo argomento riconosciuto.
-- @return string|nil Risposta contestuale, oppure nil se non disponibile.
local function get_context_response()
    local topic = context.last_topic
    local responses = topic and context_responses[topic]

    if not responses then
        return nil
    end

    return choose_response(responses, "context_" .. topic)
end


-- ---------------------------------------------------------------------
-- 8. FUNZIONE PUBBLICA DI ELABORAZIONE (M.reply)
-- ---------------------------------------------------------------------
--- Elabora il testo dell'utente e genera una risposta.
-- @param input string Messaggio scritto dall'utente.
-- @return string Risposta generata.
-- @return boolean True se l'utente ha richiesto di terminare la sessione.
function M.reply(input)
    if type(input) ~= "string" then
        return "Puoi scrivere un messaggio così posso risponderti.", false
    end

    local clean_input = normalize_input(input)
    if clean_input == "" then
        return "Ti ascolto: quando vuoi, continua pure.", false
    end

    -- I comandi di uscita vengono controllati prima delle regole generiche.
    if clean_input == "esci"
        or clean_input == "quit"
        or clean_input == "exit"
        or clean_input == "ciao ciao" then
        return "Arrivederci! Grazie per la conversazione. A presto!", true
    end

    context.turns_count = context.turns_count + 1

    local best_rule, captures = find_best_rule(clean_input)

    if best_rule then
        push_topic(best_rule.topic)

        -- Se il pattern ha catturato una frase e la regola dispone di
        -- risposte dinamiche, usa quelle; altrimenti resta sul pool generico.
        local response_pool = best_rule.responses
        if #captures > 0 and best_rule.capture_responses then
            response_pool = best_rule.capture_responses
        end

        local template = choose_response(
            response_pool,
            "rule_" .. best_rule.topic
        )

        local response = fill_response(template, captures)
        context.last_user_input = clean_input
        return response, false
    end

    -- Per risposte brevi o riferimenti poco specifici, è preferibile
    -- riprendere l'ultimo argomento invece di proporre una domanda casuale.
    if context.last_topic and short_replies[clean_input] then
        local response = get_context_response()
        if response then
            context.last_user_input = clean_input
            return response, false
        end
    end

    -- Per messaggi non riconosciuti ma non brevi, il richiamo contestuale
    -- viene usato con probabilità moderata, lasciando spazio al fallback.
    if context.last_topic and math.random(1, 100) <= 35 then
        local response = get_context_response()
        if response then
            context.last_user_input = clean_input
            return response, false
        end
    end

    context.last_user_input = clean_input
    return choose_response(default_responses, "default"), false
end

--- Azzera lo stato della conversazione e gli indici delle risposte.
-- Utile per avviare una nuova sessione o per isolare i test automatici.
function M.reset()
    context.last_topic = nil
    context.topic_history = {}
    context.last_user_input = nil
    context.turns_count = 0

    for key in pairs(last_response_index) do
        last_response_index[key] = nil
    end
end


-- ---------------------------------------------------------------------
-- 9. CICLO PRINCIPALE REPL (ESECUZIONE DA TERMINALE)
-- ---------------------------------------------------------------------
-- Il controllo confronta il percorso del file corrente con arg[0]. In
-- questo modo il REPL parte quando il file viene eseguito direttamente,
-- ma non quando viene caricato con require() da un altro programma.
local source_info = debug and debug.getinfo and debug.getinfo(1, "S")
local is_main_script = source_info
    and arg
    and arg[0]
    and source_info.source == "@" .. arg[0]

if is_main_script then
    print("------------------------------------------------------------------")
    print("LUIZA (Versione " .. M.version .. " Beta): Chatbot conversazionale in italiano")
    print("Digita 'esci', 'quit' o 'exit' per terminare la conversazione.")
    print("------------------------------------------------------------------")
    print("LUIZA: Ciao! Sono qui per conversare. Di che cosa vorresti parlare?")

    while true do
        io.write("\n> ")
        io.flush()

        local user_input = io.read()
        if not user_input then
            print("\nLUIZA: Arrivederci!")
            break
        end

        local reply, should_exit = M.reply(user_input)
        print("\nLUIZA: " .. reply)

        if should_exit then
            break
        end
    end
end

-- L'esportazione di M rende disponibili M.reply(), M.reset() e M.version
-- quando Luiza viene caricato da un altro script tramite require().
return M
