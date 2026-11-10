-- test/test_luiza.lua

-- Dice a Lua di cercare anche nella cartella src/
package.path = package.path .. ";./src/?.lua"

local luiza = require("luiza") -- Ora basta chiamare require("luiza")

print("Avvio dei test per Luiza...")

local risposta = luiza.reply("Hello")
assert(type(risposta) == "string", "Errore: la risposta di Luiza deve essere una stringa")

print("Tutti i test sono passati correttamente! ✅")
