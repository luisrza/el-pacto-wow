-- classes.lua — EL PACTO: MOTOR DE CLASES DEL PACTO v1 (modelo v2 de Luis)
-- La Clase del Pacto ES la clase: kit corto de habilidades sobre un chasis vaciado.
-- v1: enseña los hechizos del kit por rango + comandos del BALUARTE (#jurar/#aqui/#muro)
-- + pasiva de amenaza + #kit con descripciones. Datos: pacto_class_abilities.
-- (Nota v1: el "vaciado" de la clase base es innecesario aún — sin trainers ni
--  autolearn, el chasis nivel 1 no crece solo. El removedor llega con los niveles.)
-- Gate: pacto_config.classes_enabled. Todo en pcall.
-- REGLA DE AUDITORÍA C1: el daño absorbido por juramento JAMÁS se re-transfiere.

local function Enabled()
    return PACTO.GetConfigNum("classes_enabled", 0) == 1
end

-- ===== cachés =====
local heroClass = {}    -- guidLow -> {clase, rango} | false
local kit = {}          -- clase -> { {orden, tipo, nombre, spell, rango, desc}, ... }
local juramentos = {}   -- guidLow baluarte -> { jurado = guidLow, hp = última vida vista }
local jurados = {}      -- guidLow jurado -> guidLow baluarte (índice inverso; 1 a 1)
local muro = {}         -- guidLow -> {x, y, z} donde se plantó
local aquiCd = {}       -- guidLow -> os.time del último #aqui

local function LoadKit(clase)
    if kit[clase] ~= nil then return kit[clase] end
    local list = {}
    local q = WorldDBQuery(string.format(
        "SELECT orden, tipo, nombre, spell_id, rango, descripcion FROM pacto.pacto_class_abilities WHERE clase = '%s' ORDER BY orden",
        PACTO.Esc(clase)))
    if q then
        repeat
            table.insert(list, { orden = q:GetUInt32(0), tipo = q:GetString(1),
                nombre = q:GetString(2), spell = q:GetUInt32(3),
                rango = q:GetUInt32(4), desc = q:GetString(5) })
        until not q:NextRow()
    end
    kit[clase] = list
    return list
end

local function HeroClass(p)
    local g = p:GetGUIDLow()
    if heroClass[g] ~= nil then return heroClass[g] end
    local q = WorldDBQuery(string.format(
        "SELECT clase, rango FROM pacto.pacto_heroes WHERE nombre_personaje = '%s' AND clase <> ''",
        PACTO.Esc(p:GetName())))
    heroClass[g] = q and { clase = q:GetString(0), rango = q:GetUInt32(1) } or false
    return heroClass[g]
end

-- ===== al login: enseñar el kit del rango =====
local function TeachKit(p)
    local hc = HeroClass(p)
    if not hc then return end
    local nuevos = 0
    for _, ab in ipairs(LoadKit(hc.clase)) do
        if ab.tipo == "hechizo" and ab.spell > 0 and ab.rango <= hc.rango
                and not p:HasSpell(ab.spell) then
            p:LearnSpell(ab.spell)
            p:SendBroadcastMessage(string.format(
                "|cffffd700Aprendes: %s|r — %s", ab.nombre, ab.desc))
            nuevos = nuevos + 1
        end
    end
    if nuevos > 0 then
        p:SendBroadcastMessage(PACTO.PREFIX .. "Tu kit está en el libro. Escribe #kit para verlo completo.")
        PACTO.Chronicle("kit_aprendido", p:GetName(), hc.clase)
    end
end

RegisterPlayerEvent(3, function(event, p)
    pcall(function()
        heroClass[p:GetGUIDLow()] = nil
        if Enabled() then TeachKit(p) end
    end)
end)

-- ===== BALUARTE: #jurar =====
local function CmdJurar(p, args)
    local hc = HeroClass(p)
    if not hc or hc.clase ~= "baluarte" then return end
    local g = p:GetGUIDLow()
    if args == "" then
        if juramentos[g] then
            jurados[juramentos[g].jurado] = nil
            juramentos[g] = nil
            p:SendBroadcastMessage(PACTO.PREFIX .. "Tu juramento queda liberado.")
        end
        return
    end
    local objetivo = nil
    for _, v in ipairs(p:GetPlayersInRange(PACTO.GetConfigNum("baluarte_jurar_range", 30)) or {}) do
        if v:GetName():lower() == args:lower() then objetivo = v break end
    end
    if not objetivo then
        p:SendBroadcastMessage(PACTO.PREFIX .. "No veo a '" .. args .. "' cerca de ti.")
        return
    end
    if jurados[g] then
        p:SendBroadcastMessage(PACTO.PREFIX .. "Alguien ya te juró a TI — un escudo no se esconde tras otro.")
        return
    end
    -- C1: una transferencia por extremo, jamás en cadena
    if juramentos[objetivo:GetGUIDLow()] then
        p:SendBroadcastMessage(PACTO.PREFIX .. "Ese aliado ya cargó su propio juramento.")
        return
    end
    if juramentos[g] then jurados[juramentos[g].jurado] = nil end
    juramentos[g] = { jurado = objetivo:GetGUIDLow(), hp = objetivo:GetHealth() }
    jurados[objetivo:GetGUIDLow()] = g
    p:PerformEmote(68)  -- arrodillarse
    local emote = string.format("%s hinca la rodilla ante %s. El juramento está hecho.",
        p:GetName(), objetivo:GetName())
    for _, v in ipairs(p:GetPlayersInRange(30) or {}) do
        v:SendBroadcastMessage("|cffff8040" .. emote .. "|r")
    end
    p:SendBroadcastMessage("|cffffd700Su castigo es tu castigo. No puedes huir.|r")
    objetivo:SendBroadcastMessage(PACTO.PREFIX .. p:GetName() .. " ha jurado protegerte.")
    PACTO.Chronicle("juramento", p:GetName(), "protege a " .. objetivo:GetName())
end

-- pulso del juramento: absorbe el % del daño que recibió el jurado
local function FindPlayerByGuid(guidLow)
    for _, v in ipairs(GetPlayersInWorld()) do
        if v:GetGUIDLow() == guidLow then return v end
    end
    return nil
end

CreateLuaEvent(function()
    if not Enabled() then return end
    pcall(function()
        for g, j in pairs(juramentos) do
            local baluarte = FindPlayerByGuid(g)
            local jurado = FindPlayerByGuid(j.jurado)
            if not baluarte or not jurado or baluarte:IsDead() or jurado:IsDead() then
                if jurado then jurados[j.jurado] = nil end
                juramentos[g] = nil
            else
                local perdido = j.hp - jurado:GetHealth()
                if perdido > 0 and baluarte:GetDistance(jurado) <= PACTO.GetConfigNum("baluarte_jurar_range", 30) then
                    local absorbe = math.floor(perdido * PACTO.GetConfigNum("baluarte_jurar_pct", 25) / 100)
                    if absorbe > 0 then
                        -- devolver al jurado, cobrar al baluarte (piso 10% — el juramento no mata)
                        local maxJ = jurado:GetMaxHealth()
                        local nJ = jurado:GetHealth() + absorbe
                        jurado:SetHealth(nJ > maxJ and maxJ or nJ)
                        local piso = math.floor(baluarte:GetMaxHealth() * 0.10)
                        local nB = baluarte:GetHealth() - absorbe
                        if nB > piso then baluarte:SetHealth(nB) end
                    end
                end
                j.hp = jurado:GetHealth()
            end
        end
    end)
end, 3000, 0)

-- ===== BALUARTE: #aqui =====
local function CmdAqui(p)
    local hc = HeroClass(p)
    if not hc or hc.clase ~= "baluarte" then return end
    local g = p:GetGUIDLow()
    local cd = PACTO.GetConfigNum("baluarte_aqui_cd", 60)
    if aquiCd[g] and os.time() - aquiCd[g] < cd then
        p:SendBroadcastMessage(PACTO.PREFIX .. string.format(
            "Tu voz aún no se recupera (%ds).", cd - (os.time() - aquiCd[g])))
        return
    end
    aquiCd[g] = os.time()
    p:PerformEmote(53)  -- rugido de batalla
    local threat = PACTO.GetConfigNum("baluarte_aqui_threat", 5000)
    local n = 0
    for _, c in ipairs(p:GetCreaturesInRange(15) or {}) do
        if not c:IsDead() and c:IsInCombat() then
            local hostile = false
            pcall(function() hostile = c:IsHostileTo(p) end)
            if hostile then
                pcall(function() c:AddThreat(p, threat) end)
                n = n + 1
            end
        end
    end
    local emote = string.format("¡%s RUGE: \"¡AQUÍ! ¡El muro soy yo!\"", p:GetName())
    for _, v in ipairs(p:GetPlayersInRange(30) or {}) do
        v:SendBroadcastMessage("|cffff8040" .. emote .. "|r")
    end
    p:SendBroadcastMessage(PACTO.PREFIX .. (n > 0
        and string.format("%d enemigos vienen por ti. Eso querías.", n)
        or "Tu rugido se pierde en la noche... nadie vino."))
end

-- ===== BALUARTE: #muro =====
local function CmdMuro(p)
    local hc = HeroClass(p)
    if not hc or hc.clase ~= "baluarte" then return end
    local g = p:GetGUIDLow()
    if muro[g] then
        muro[g] = nil
        p:SendBroadcastMessage(PACTO.PREFIX .. "Dejas de ser muro.")
        return
    end
    muro[g] = { x = p:GetX(), y = p:GetY(), z = p:GetZ() }
    p:SendBroadcastMessage(PACTO.PREFIX .. "|cffa0a0a0Te plantas. Mientras no te muevas, eres piedra.|r")
end

-- pulso del muro: si no se movió, piedra (aura visible); si se movió, se rompe
CreateLuaEvent(function()
    if not Enabled() then return end
    pcall(function()
        local spell = PACTO.GetConfigNum("baluarte_muro_spell", 20594)
        for g, pos in pairs(muro) do
            local p = FindPlayerByGuid(g)
            if not p or p:IsDead() then muro[g] = nil
            else
                local dx, dy = p:GetX() - pos.x, p:GetY() - pos.y
                if dx * dx + dy * dy > 2 then
                    muro[g] = nil
                    if p:HasAura(spell) then p:RemoveAura(spell) end
                    p:SendBroadcastMessage(PACTO.PREFIX .. "Te moviste: el muro se rompe.")
                elseif not p:HasAura(spell) then
                    p:AddAura(spell, p)
                end
            end
        end
    end)
end, 4000, 0)

-- ===== pasiva del Baluarte: atraer la tormenta (amenaza por pulso) =====
CreateLuaEvent(function()
    if not Enabled() then return end
    pcall(function()
        local bonus = PACTO.GetConfigNum("baluarte_threat_mult", 2000)
        for _, p in ipairs(GetPlayersInWorld()) do
            local hc = heroClass[p:GetGUIDLow()]
            if hc and hc.clase == "baluarte" and p:IsInCombat() and not p:IsDead() then
                for _, c in ipairs(p:GetCreaturesInRange(10) or {}) do
                    if c:IsInCombat() and not c:IsDead() then
                        pcall(function() if c:IsHostileTo(p) then c:AddThreat(p, bonus) end end)
                    end
                end
            end
        end
    end)
end, 3000, 0)

-- ===== #kit (todas las clases) =====
local function CmdKit(p)
    local hc = HeroClass(p)
    if not hc then
        p:SendBroadcastMessage(PACTO.PREFIX .. "Aún no llevas una Clase del Pacto.")
        return
    end
    p:SendBroadcastMessage(PACTO.PREFIX .. string.format(
        "|cffa335eeTu kit de %s (rango %d):|r", hc.clase:upper(), hc.rango))
    for _, ab in ipairs(LoadKit(hc.clase)) do
        if ab.rango <= hc.rango then
            local color = ab.tipo == "precio" and "|cffff4444" or "|cff69ccf0"
            p:SendBroadcastMessage(string.format("%s[%s] %s|r — %s",
                color, ab.tipo, ab.nombre, ab.desc))
        else
            p:SendBroadcastMessage(string.format(
                "|cff808080[rango %d] ???|r — la campaña lo desbloqueará.", ab.rango))
        end
    end
end

-- ===== router de comandos =====
local function OnChat(event, p, msg)
    if msg:sub(1, 1) ~= "#" then return end
    if not Enabled() then return end
    local cmd, args = msg:match("^#(%S+)%s*(.*)$")
    if not cmd then return end
    cmd = cmd:lower()
    if cmd == "kit" then pcall(CmdKit, p) return false
    elseif cmd == "jurar" then pcall(CmdJurar, p, args or "") return false
    elseif cmd == "aqui" or cmd == "aquí" then pcall(CmdAqui, p) return false
    elseif cmd == "muro" then pcall(CmdMuro, p) return false
    end
end

for _, ev in ipairs({18, 19, 20, 21, 22}) do
    RegisterPlayerEvent(ev, OnChat)
end

print("[ElPacto] classes.lua listo (motor de clases v1 — Baluarte operativo, gate: classes_enabled)")
