-- Copyright 2018 Jonas Thiem

-- Data
local partyAddress = 0x0000DCD8

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
        local p = memory.readbyteunsigned(partyAddress + i - 1)
        if p ~= 255 then
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

local function update()
    readParty()

    local changeMap = didPartyChange()
    if changeMap[1] then
        for i = 1, 6, 1 do
            if changeMap[i + 1] then
                local newPNG = io.open("./sprites/" .. tostring(party[i]) .. ".png", "rb") 
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
vba.print("g2pd 1.0 loaded <3")