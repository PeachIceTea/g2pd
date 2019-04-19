-- Data
local partyAddress = 0xDCDF
local numberedSprites

local numberPNG = io.open("./sprites/1.png", "rb+")
if numberPNG ~= nil then
    vba.print("Using numbered sprites.")
    numberedSprites = true
    numberPNG:flush()
else
    vba.print("Using named sprites.")
    numberedSprites = false
end

local pkmNameDb = {"Bulbasaur", "Ivysaur", "Venusaur", "Charmander", "Charmeleon", "Charizard",
    "Squirtle", "Wartortle", "Blastoise", "Caterpie", "Metapod", "Butterfree",
    "Weedle", "Kakuna", "Beedrill", "Pidgey", "Pidgeotto", "Pidgeot", "Rattata", "Raticate",
    "Spearow", "Fearow", "Ekans", "Arbok", "Pikachu", "Raichu", "Sandshrew", "Sandslash",
    "NidoranF", "Nidorina", "Nidoqueen", "NidoranM", "Nidorino", "Nidoking",
    "Clefairy", "Clefable", "Vulpix", "Ninetales", "Jigglypuff", "Wigglytuff",
    "Zubat", "Golbat", "Oddish", "Gloom", "Vileplume", "Paras", "Parasect", "Venonat", "Venomoth",
    "Diglett", "Dugtrio", "Meowth", "Persian", "Psyduck", "Golduck", "Mankey", "Primeape",
    "Growlithe", "Arcanine", "Poliwag", "Poliwhirl", "Poliwrath", "Abra", "Kadabra", "Alakazam",
    "Machop", "Machoke", "Machamp", "Bellsprout", "Weepinbell", "Victreebel", "Tentacool", "Tentacruel",
    "Geodude", "Graveler", "Golem", "Ponyta", "Rapidash", "Slowpoke", "Slowbro",
    "Magnemite", "Magneton", "Farfetch'd", "Doduo", "Dodrio", "Seel", "Dewgong", "Grimer", "Muk",
    "Shellder", "Cloyster", "Gastly", "Haunter", "Gengar", "Onix", "Drowzee", "Hypno",
    "Krabby", "Kingler", "Voltorb", "Electrode", "Exeggcute", "Exeggutor", "Cubone", "Marowak",
    "Hitmonlee", "Hitmonchan", "Lickitung", "Koffing", "Weezing", "Rhyhorn", "Rhydon", "Chansey",
    "Tangela", "Kangaskhan", "Horsea", "Seadra", "Goldeen", "Seaking", "Staryu", "Starmie",
    "Mr. Mime", "Scyther", "Jynx", "Electabuzz", "Magmar", "Pinsir", "Tauros", "Magikarp", "Gyarados",
    "Lapras", "Ditto", "Eevee", "Vaporeon", "Jolteon", "Flareon", "Porygon", "Omanyte", "Omastar",
    "Kabuto", "Kabutops", "Aerodactyl", "Snorlax", "Articuno", "Zapdos", "Moltres",
    "Dratini", "Dragonair", "Dragonite", "Mewtwo", "Mew",
    
    "Chikorita", "Bayleef", "Meganium", "Cyndaquil", "Quilava", "Typhlosion",
    "Totodile", "Croconaw", "Feraligatr", "Sentret", "Furret", "Hoothoot", "Noctowl",
    "Ledyba", "Ledian", "Spinarak", "Ariados", "Crobat", "Chinchou", "Lanturn", "Pichu", "Cleffa",
    "Igglybuff", "Togepi", "Togetic", "Natu", "Xatu", "Mareep", "Flaaffy", "Ampharos", "Bellossom",
    "Marill", "Azumarill", "Sudowoodo", "Politoed", "Hoppip", "Skiploom", "Jumpluff", "Aipom",
    "Sunkern", "Sunflora", "Yanma", "Wooper", "Quagsire", "Espeon", "Umbreon", "Murkrow", "Slowking",
    "Misdreavus", "Unown", "Wobbuffet", "Girafarig", "Pineco", "Forretress", "Dunsparce", "Gligar",
    "Steelix", "Snubbull", "Granbull", "Qwilfish", "Scizor", "Shuckle", "Heracross", "Sneasel",
    "Teddiursa", "Ursaring", "Slugma", "Magcargo", "Swinub", "Piloswine", "Corsola", "Remoraid", "Octillery",
    "Delibird", "Mantine", "Skarmory", "Houndour", "Houndoom", "Kingdra", "Phanpy", "Donphan",
    "Porygon2", "Stantler", "Smeargle", "Tyrogue", "Hitmontop", "Smoochum", "Elekid", "Magby", "Miltank",
    "Blissey", "Raikou", "Entei", "Suicune", "Larvitar", "Pupitar", "Tyranitar", "Lugia", "Ho-Oh", "Celebi"
}

-- code

local prevParty = {0, 0, 0, 0, 0, 0}
local party = {0, 0, 0, 0, 0, 0}

local function copyArray(a, b)
    for i, v in pairs(a) do
        b[i] = v
    end
end

local function readParty()
    copyArray(party, prevParty)
    for  i = 1, 6, 1 do
        local p = memory.readbyteunsigned(partyAddress + 48 * (i - 1))
        local l = memory.readbyteunsigned(partyAddress + 31 + 48 * (i - 1))
        if p > 0 and p < table.getn(pkmNameDb) and l > 0 and l <= 100 then
            party[i] = p
        else
            party[i] = 0
        end
    end
end

local function didPartyChange()
    if party[1] == 0 then return {false} end
    
    local r = {false, false, false, false, false, false, false}
    
    for i = 1, 6, 1 do
        if prevParty[i] ~= party[i] then
            r[1] = true
            r[i + 1] = true
        end
    end

    return r
end

local function getPNGPath(id)
    if id > 0 and id <= table.getn(pkmNameDb) then
        if numberedSprites then
            return "./sprites/" .. id .. ".png"
        else
            return "./sprites/" .. pkmNameDb[id] .. ".png"
        end
    end
end

local function update()
    readParty()

    local changeMap = didPartyChange()
    local partySize = memory.readbyteunsigned(0xDCD7)
    if changeMap[1] and partySize >= 1 and partySize <= 6 then
        for i = 1, 6, 1 do
            if changeMap[i + 1] then
                local id = party[i]
                local pngPath
                if id == 0xfd then
                    pngPath = "./sprites/egg.png"
                else
                    pngPath = getPNGPath(id)
                end
                if pngPath then
                    local newPNG = io.open(pngPath, "rb")
                    if newPNG == nil then
                        vba.print(getPNGPath(party[i]) .. " is missing.")
                    else
                        local newData = newPNG:read("*a")
                        newPNG:flush()
                        
                        local oldPNG = io.open("./party/p" .. tostring(i) .. ".png", "wb")
                        oldPNG:write(newData)
                        oldPNG:flush()
                    end
                end
            end
        end
        for i = partySize + 1, 6, 1 do
            local newPNG = io.open("./sprites/0.png", "rb")
            if newPNG == nil then
                vba.print("0.png is missing in the sprites folder.")
            else
                local newData = newPNG:read("*a")
                newPNG:flush()
                        
                local oldPNG = io.open("./party/p" .. tostring(i) .. ".png", "wb")
                oldPNG:write(newData)
                oldPNG:flush()
            end
        end
    end
end

local function clearPartyDisplay()
    local newPNG = io.open("./sprites/0.png", "rb+")
    if newPNG == nil then vba.print("0.png is missing in the sprites folder.") end
    local newData = newPNG:read("*a")
    newPNG:flush()

    for i = 1, 6, 1 do
        local oldPNG = io.open("./party/p" .. tostring(i) .. ".png", "wb+")
        oldPNG:write(newData)
        oldPNG:flush()
    end
end

clearPartyDisplay()
gui.register(update)
vba.print("g2pd 1.5 loaded <3")