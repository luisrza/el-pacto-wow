-- pueblo.lua — EL PACTO: DARKSHIRE RESPIRA (banter de los NPCs del corazón)
-- Cada ~3 min, un NPC del Pacto cercano a algún jugador suelta una de sus
-- frases (pacto_npc_lines, data-driven — añadir frase = INSERT).
-- Patrón banter probado (Rultek/Evelgreen). Gate: pueblo_enabled.

local function Enabled()
    return PACTO.GetConfigNum("pueblo_enabled", 1) == 1
end

local lineas = {}      -- npc_entry -> { "frase", ... }
local entries = {}     -- lista de entries con frases
local lastSaid = {}    -- npc_entry -> os.time (throttle por NPC)

local function LoadLineas()
    lineas, entries = {}, {}
    local q = WorldDBQuery("SELECT npc_entry, linea FROM pacto.pacto_npc_lines")
    if q then
        repeat
            local e = q:GetUInt32(0)
            if not lineas[e] then lineas[e] = {}; table.insert(entries, e) end
            table.insert(lineas[e], q:GetString(1))
        until not q:NextRow()
    end
end

local function Banter()
    if not Enabled() or #entries == 0 then return end
    -- busca un NPC del censo cerca de algún jugador (sin retener userdata)
    for _, p in ipairs(GetPlayersInWorld()) do
        if p:GetMapId() == 0 and not p:IsInCombat() then
            for _, c in ipairs(p:GetCreaturesInRange(40) or {}) do
                local e = c.GetEntry and c:GetEntry() or 0
                if lineas[e] and not c:IsDead()
                        and (not lastSaid[e] or os.time() - lastSaid[e] > 120) then
                    lastSaid[e] = os.time()
                    local frase = lineas[e][math.random(#lineas[e])]
                    pcall(function() c:SendUnitSay(frase, 0) end)
                    return  -- una frase por pulso: pueblo, no mercado de gritos
                end
            end
        end
    end
end

CreateLuaEvent(function() pcall(Banter) end, 45000, 0)

LoadLineas()
print(string.format("[ElPacto] pueblo.lua listo (%d NPCs con voz)", #entries))
