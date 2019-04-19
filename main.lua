-- Copyright 2018 Jonas Thiem

-- Data
local partyAddress = 0x0000DCD8
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
local currParty = {0, 0, 0, 0, 0, 0}    -- CURRENT frame party
local printedParty = {0, 0, 0, 0, 0, 0} -- Currently drawn party

local function copyArray(a, b)
    for i, v in pairs(a) do
        b[i] = v
    end
end

local function readParty()
    for  i = 1, 6, 1 do
        local p = memory.readbyteunsigned(partyAddress + i - 1)
        if p > 0 and p <= table.getn(pkmNameDb) then
            currParty[i] = p
        else
            currParty[i] = -1
        end
    end
end

local function didPartyChange()
    -- Having no pokemon in the first slot is an invalid read
    for i = 1, 6, 1 do
        if currParty[i] == -1 then 
            return false 
        end 
    end
    
    for i = 1, 6, 1 do
        if printedParty[i] ~= currParty[i] then
            return true
        end
    end

    return false
end

local function getPNGPath(id)
    if id ~= -1 then
        if numberedSprites then
            return "./sprites/" .. id .. ".png"
        else
            return "./sprites/" .. pkmNameDb[id] .. ".png"
        end
    end
end

local timesChanged = 300
local function update()
    readParty()

    local didChange = didPartyChange()
    if didChange then
        timesChanged = timesChanged + 1
    else
        timesChanged = 0
    end

    if timesChanged >= 300 or currParty[1] == 0 then
        timesChanged = 0
        for i = 1, 6, 1 do
            local id = currParty[i]
            if id ~= -1 and id ~= printedParty[i] then
                local pngPath
                if id == 0xfd then
                    pngPath = "./sprites/egg.png"
                else
                    pngPath = getPNGPath(id)
                end
                if pngPath then
                    local newPNG = io.open(pngPath, "rb")
                    if newPNG == nil then
                        vba.print(getPNGPath(readParty[i]) .. " is missing.")
                    else
                        local newData = newPNG:read("*a")
                        newPNG:flush()
                        
                        local oldPNG = io.open("./party/p" .. tostring(i) .. ".png", "wb")
                        oldPNG:write(newData)
                        oldPNG:flush()
                    end
                    printedParty[i] = id
                end
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
vba.print("g2pd 1.4 loaded <3")