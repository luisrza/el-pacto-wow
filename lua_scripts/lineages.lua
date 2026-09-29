-- lineages.lua — EL PACTO: MOTOR DE LINAJES (M3, F1)
-- Cada linaje es una mini-clase: pasiva + procs + su precio (spec: design/linajes.md,
-- números en pacto.pacto_traits — jamás constantes aquí).
--
-- Gate global: pacto_config.lineages_enabled (HOY: 0 — se enciende cuando Luis
-- apruebe los números). Con el gate en 0 este módulo no hace NADA.
-- Rasgos [VALIDAR F1] están además apagados por fila (pacto_traits.enabled=0).
--
-- La oscuridad (regla de Luis): PACTO.IsNight() OR mazmorra OR area en pacto_dark_areas.
-- Todo lee la Hora del Mundo — nunca el reloj real.

local function Enabled()
    return PACTO.GetConfigNum("lineages_enabled", 0) == 1
end

-- ===== cachés (se rehidratan por login/reload) =====
local heroLineage = {}   -- guidLow -> linaje (false = no es héroe)
local traitsByLineage = {}  -- linaje -> { {key, hook, p1, p2, p3}, ... }
local darkAreas = {}     -- area_id -> true
local sesion = {}        -- guidLow -> { trait_key -> procs }
local estado = {}        -- guidLow -> flags volátiles (furia, morph, avisos)

local function LoadTraits()
    traitsByLineage = {}
    local q = WorldDBQuery(
        "SELECT trait_key, linaje, hook, p1, p2, p3 FROM pacto.pacto_traits WHERE enabled = 1")
    if q then
        repeat
            local lin = q:GetString(1)
            traitsByLineage[lin] = traitsByLineage[lin] or {}
            table.insert(traitsByLineage[lin], {
                key = q:GetString(0), hook = q:GetString(2),
                p1 = q:GetFloat(3), p2 = q:GetFloat(4), p3 = q:GetFloat(5),
            })
        until not q:NextRow()
    end
    darkAreas = {}
    local qa = WorldDBQuery("SELECT area_id FROM pacto.pacto_dark_areas")
    if qa then
        repeat darkAreas[qa:GetUInt32(0)] = true until not qa:NextRow()
    end
end

local function LoadHeroLineage(p)
    local q = WorldDBQuery(string.format(
        "SELECT linaje FROM pacto.pacto_heroes WHERE nombre_personaje = '%s'",
        PACTO.Esc(p:GetName())))
    heroLineage[p:GetGUIDLow()] = q and q:GetString(0) or false
    return heroLineage[p:GetGUIDLow()]
end

local function LineageOf(p)
    local lin = heroLineage[p:GetGUIDLow()]
    if lin == nil then lin = LoadHeroLineage(p) end
    return lin
end

local function Count(p, key)
    local g = p:GetGUIDLow()
    sesion[g] = sesion[g] or {}
    sesion[g][key] = (sesion[g][key] or 0) + 1
end

local function St(p)
    local g = p:GetGUIDLow()
    estado[g] = estado[g] or {}
    return estado[g]
end

-- ===== la oscuridad según la regla de Luis =====
function PACTO.IsDarkFor(p)
    if PACTO.IsNight() then return true end
    local map = p:GetMap()
    if map and map:IsDungeon() then return true end
    return darkAreas[p:GetAreaId()] == true
end

-- ===== enemigos hostiles cercanos (para el rayo en cadena) =====
local function HostilesNear(p, range, exclude)
    local out = {}
    for _, c in ipairs(p:GetCreaturesInRange(range) or {}) do
        if not c:IsDead() and c:IsInCombat() then
            local hostile = false
            pcall(function() hostile = c:IsHostileTo(p) end)
            if hostile and c ~= exclude then table.insert(out, c) end
        end
    end
    return out
end

-- =====================================================================
-- HANDLERS — un pcall por rasgo; los [VALIDAR F1] viven apagados en DB
-- =====================================================================

local ON_KILL = {}
local PULSE = {}
local ON_LOGIN = {}

-- ---- VAMPIRO ----
-- Festín de sangre (idea de Luis): Canibalizar re-vestido — el tooltip del
-- cliente dirá "Canibalizar" (límite DBC), el teatro lo pone el emote público.
ON_LOGIN.vampiro_festin = function(p, t)
    local spell = PACTO.GetConfigNum("vamp_festin_spell", 20577)
    if not p:HasSpell(spell) then
        p:LearnSpell(spell)
        p:SendBroadcastMessage(PACTO.PREFIX ..
            "|cffc41f3bLa sangre fría también alimenta.|r Busca el Festín de sangre en tu libro (General).")
        PACTO.Chronicle("festin_aprendido", p:GetName(), "")
    end
end

ON_KILL.vampiro_sed = function(p, t)
    local maxHp = p:GetMaxHealth()
    if p:GetHealth() < maxHp then
        local hp = p:GetHealth() + math.floor(maxHp * t.p1 / 100)
        p:SetHealth(hp > maxHp and maxHp or hp)
        Count(p, t.key)
    end
end

PULSE.vampiro_oscuridad = function(p, t)
    local aura = PACTO.GetConfigNum("vamp_dark_spell", 8599)
    if PACTO.IsDarkFor(p) then
        if not p:HasAura(aura) then
            p:AddAura(aura, p)
            p:SendBroadcastMessage("|cffc41f3bLa oscuridad te reconoce. La sed se vuelve fuerza.|r")
        end
    elseif p:HasAura(aura) then
        p:RemoveAura(aura)
    end
end

PULSE.vampiro_sol = function(p, t)
    if PACTO.IsDarkFor(p) or p:IsInCombat() then St(p).solAvisado = nil return end
    local maxHp = p:GetMaxHealth()
    local piso = math.floor(maxHp * t.p2 / 100)
    local nuevo = p:GetHealth() - math.floor(maxHp * t.p1 / 100)
    if nuevo > piso then
        p:SetHealth(nuevo)
        if not St(p).solAvisado then
            p:SendBroadcastMessage("|cffff8800El sol te quema. Busca la oscuridad... o resiste.|r")
            St(p).solAvisado = true
        end
    end
end

-- ---- LICÁNTROPO ----
PULSE.lobo_noche = function(p, t)
    local sprint = PACTO.GetConfigNum("lobo_sprint_spell", 2983)
    if PACTO.IsNight() then
        if not p:HasAura(sprint) then p:AddAura(sprint, p) end
    elseif p:HasAura(sprint) then
        p:RemoveAura(sprint)
    end
end

PULSE.lobo_luna = function(p, t)
    local st = St(p)
    if PACTO.IsFullMoon() then
        if not st.morph then
            st.morph = true
            p:SetDisplayId(PACTO.GetConfigNum("lobo_worgen_display", 729))
            p:SendBroadcastMessage("|cffc41f3bLA LUNA LLENA TE RECLAMA. No prometas nada esta noche.|r")
            PACTO.Chronicle("luna_llena", p:GetName(), "transformación")
        end
    elseif st.morph then
        st.morph = nil
        p:DeMorph()
        p:SendBroadcastMessage("La bestia te suelta... por ahora.")
    end
end

PULSE.lobo_dia = function(p, t)
    -- la parte mecánica del -daño diurno se aplica junto al aura nocturna;
    -- de momento es narrativa: el lobo diurno no recibe el sprint (lobo_noche)
end

-- ---- PACTADO ----
ON_KILL.pacto_golpe = function(p, t)
    if math.random(100) <= t.p1 then
        -- aura PROPIA (auditoría C2: ningún aura se comparte entre conceptos)
        local aura = PACTO.GetConfigNum("pacto_grace_spell", 8599)
        p:AddAura(aura, p)
        p:SendBroadcastMessage("|cff9482c9Gracia prestada. Golpea antes de que la reclamen.|r")
        Count(p, t.key)
    end
end

-- pacto_factura (on_death) lo cobra el Sepulturero (M7, F2) leyendo este trait

-- ---- TORMENTA ----
ON_KILL.tormenta_eco = function(p, t)
    if math.random(100) > t.p1 then return end
    local n = 0
    for _, c in ipairs(HostilesNear(p, 10)) do
        pcall(function() p:DealDamage(c, math.floor(p:GetLevel() * t.p2)) end)
        pcall(function() c:PlayDirectSound(6595) end)
        n = n + 1
        if n >= t.p3 then break end
    end
    if n > 0 then
        Count(p, t.key)
        p:SendBroadcastMessage("|cff69ccf0El trueno responde.|r")
    end
end

-- ---- GIGANTE ----
PULSE.gigante_furia = function(p, t)
    -- aura PROPIA (auditoría C2)
    local aura = PACTO.GetConfigNum("gigante_fury_spell", 8599)
    local st = St(p)
    local low = p:GetHealth() < p:GetMaxHealth() * t.p1 / 100
    if low and p:IsInCombat() then
        if not st.furia then
            st.furia = true
            p:AddAura(aura, p)
            p:SendBroadcastMessage("|cffc41f3bLa montaña despierta en tu sangre.|r")
        end
    elseif st.furia and not p:IsInCombat() then
        st.furia = nil
        if p:HasAura(aura) then p:RemoveAura(aura) end
    end
end

ON_KILL.gigante_desboque = function(p, t)
    if St(p).furia and math.random(100) <= t.p1 then
        p:SendBroadcastMessage("|cffff4444Estás desbocado: la furia decide cuándo parar.|r")
        Count(p, t.key)
        PACTO.Chronicle("desboque", p:GetName(), "")
    end
end

-- ---- TOCADO (solo el precio, lo demás [VALIDAR F1]) ----
PULSE.tocado_sombra = function(p, t)
    -- narrativo por ahora: aviso al entrar en oscuridad (el -daño llega con la validación)
    local st = St(p)
    if PACTO.IsDarkFor(p) and not st.sombraAviso then
        st.sombraAviso = true
        p:SendBroadcastMessage("|cff9482c9La sombra pesa sobre tu luz.|r")
    elseif not PACTO.IsDarkFor(p) then
        st.sombraAviso = nil
    end
end

-- =====================================================================
-- HOOKS del módulo
-- =====================================================================

RegisterPlayerEvent(7, function(event, killer, killed) -- ON_KILL_CREATURE
    if not Enabled() or not killer or not killer.GetGUIDLow then return end
    local lin = LineageOf(killer)
    if not lin then return end
    for _, t in ipairs(traitsByLineage[lin] or {}) do
        if t.hook == "on_kill" then
            local h = ON_KILL[t.key]
            if h then pcall(h, killer, t) end
        end
    end
end)

CreateLuaEvent(function()
    if not Enabled() then return end
    for _, p in ipairs(GetPlayersInWorld()) do
        if not p:IsDead() then
            local lin = LineageOf(p)
            if lin then
                for _, t in ipairs(traitsByLineage[lin] or {}) do
                    if t.hook == "pulse" then
                        local h = PULSE[t.key]
                        if h then pcall(h, p, t) end
                    end
                end
            end
        end
    end
end, PACTO.GetConfigNum("lineage_pulse_s", 30) * 1000, 0)

RegisterPlayerEvent(3, function(event, p) -- ON_LOGIN: rehidratar + rasgos de login
    pcall(function()
        heroLineage[p:GetGUIDLow()] = nil
        estado[p:GetGUIDLow()] = nil
        if not Enabled() then return end
        local lin = LineageOf(p)
        if not lin then return end
        for _, t in ipairs(traitsByLineage[lin] or {}) do
            if t.hook == "on_login" then
                local h = ON_LOGIN[t.key]
                if h then pcall(h, p, t) end
            end
        end
    end)
end)

-- ===== Festín de sangre: el teatro público al canalizar =====
local festinCd = {}   -- guidLow -> os.time (el canal dispara el evento varias veces)

RegisterPlayerEvent(5, function(event, p, spell) -- ON_SPELL_CAST
    if not Enabled() then return end
    pcall(function()
        local id = spell and spell.GetEntry and spell:GetEntry() or 0
        if id ~= PACTO.GetConfigNum("vamp_festin_spell", 20577) then return end
        if LineageOf(p) ~= "vampiro" then return end
        local g = p:GetGUIDLow()
        if festinCd[g] and os.time() - festinCd[g] < 8 then return end
        festinCd[g] = os.time()
        local emote = string.format("%s se inclina sobre el cadáver... y bebe.", p:GetName())
        for _, v in ipairs(p:GetPlayersInRange(30) or {}) do
            v:SendBroadcastMessage("|cffff8040" .. emote .. "|r")
        end
        p:SendBroadcastMessage("|cffc41f3bBebes. El frío de los caídos se vuelve tu calor.|r")
        Count(p, "vampiro_festin")
    end)
end)

-- ===== #milinaje — tu linaje y los procs de la sesión =====
local function OnChatLinaje(event, player, msg)
    if msg:sub(1, 1) == "#" then msg = "!" .. msg:sub(2) end
    if msg ~= "!milinaje" and msg ~= "!linaje" then return end
    if not Enabled() then
        player:SendBroadcastMessage(PACTO.PREFIX .. "Los linajes aún duermen.")
        return false
    end
    local lin = LineageOf(player)
    if not lin then
        player:SendBroadcastMessage(PACTO.PREFIX ..
            "No has firmado ningún pacto. El test te espera.")
        return false
    end
    local q = WorldDBQuery(string.format(
        "SELECT nombre, lema FROM pacto.pacto_lineages WHERE linaje = '%s'", PACTO.Esc(lin)))
    if q then
        player:SendBroadcastMessage(PACTO.PREFIX .. string.format(
            "Eres |cffa335ee%s|r — \"%s\"", q:GetString(0), q:GetString(1)))
    end
    local g = player:GetGUIDLow()
    for _, t in ipairs(traitsByLineage[lin] or {}) do
        local procs = (sesion[g] and sesion[g][t.key]) or 0
        local qd = WorldDBQuery(string.format(
            "SELECT descripcion FROM pacto.pacto_traits WHERE trait_key = '%s'", t.key))
        player:SendBroadcastMessage(string.format("|cff69ccf0- %s|r (procs: %d)",
            qd and qd:GetString(0) or t.key, procs))
    end
    return false
end

for _, ev in ipairs({18, 19, 20, 21, 22}) do
    RegisterPlayerEvent(ev, OnChatLinaje)
end

LoadTraits()
print("[ElPacto] lineages.lua listo (motor de linajes, gate: lineages_enabled)")
