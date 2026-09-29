-- worldclock.lua — EL PACTO: LA HORA DEL MUNDO (F1, decisión de Luis 2026-07-12)
-- El Pacto tiene su propio reloj acelerado: 1 día del mundo = clock_day_seconds
-- reales (default 9000s = 2.5h). En una sesión se viven día Y noche — el
-- vampiro planea su ruta, el licántropo espera la suya.
--
-- TODOS los rasgos, spawns y triggers deben leer ESTA hora, nunca el reloj real:
--   PACTO.WorldHour()  -> 0..23        PACTO.WorldDay()   -> día del mundo
--   PACTO.IsNight()    -> bool         PACTO.MoonPhase()  -> 0..cycle-1
--   PACTO.IsFullMoon() -> bool (la noche del día central del ciclo)
-- Comando: #hora — la hora del mundo, fase lunar y cuánto falta para el cambio.
-- Gate: pacto_config.worldclock_enabled. Anuncios de amanecer/anochecer con gate propio.

local function Enabled()
    return PACTO.GetConfigNum("worldclock_enabled", 0) == 1
end

-- epoch del mundo: fijado UNA vez al primer arranque (persistente en DB)
local function Epoch()
    local e = PACTO.GetConfigNum("clock_epoch", 0)
    if e == 0 then
        e = os.time()
        PACTO.SetConfig("clock_epoch", e)
        PACTO.Chronicle("clock_birth", "", "El tiempo de El Pacto comienza a correr")
    end
    return e
end

local function DaySeconds() return math.max(600, PACTO.GetConfigNum("clock_day_seconds", 9000)) end

function PACTO.WorldDay()
    return math.floor((os.time() - Epoch()) / DaySeconds())
end

function PACTO.WorldHour()
    local intoDay = (os.time() - Epoch()) % DaySeconds()
    return math.floor(intoDay / DaySeconds() * 24)
end

function PACTO.IsNight()
    local h = PACTO.WorldHour()
    return h < PACTO.GetConfigNum("clock_day_from", 6)
        or h >= PACTO.GetConfigNum("clock_day_to", 20)
end

function PACTO.MoonPhase()
    return PACTO.WorldDay() % PACTO.GetConfigNum("clock_moon_cycle", 28)
end

function PACTO.IsFullMoon()
    return PACTO.IsNight()
        and PACTO.MoonPhase() == math.floor(PACTO.GetConfigNum("clock_moon_cycle", 28) / 2)
end

-- ===== pulso: detectar amanecer/anochecer y anunciarlos =====
local lastWasNight = nil

local function ClockPulse()
    if not Enabled() then return end
    local night = PACTO.IsNight()
    if lastWasNight == nil then lastWasNight = night return end
    if night == lastWasNight then return end
    lastWasNight = night
    if PACTO.GetConfigNum("clock_announce", 1) ~= 1 then return end
    if night then
        local msg = PACTO.IsFullMoon()
            and "La noche cae sobre El Pacto... y la LUNA LLENA se alza. Algo aúlla a lo lejos."
            or "La noche cae sobre El Pacto. Lo que duerme de día, despierta."
        PACTO.Announce(msg)
        PACTO.Chronicle("dusk", "", string.format("día %d", PACTO.WorldDay()))
    else
        PACTO.Announce("Amanece en El Pacto. Los hijos de la noche buscan refugio.")
        PACTO.Chronicle("dawn", "", string.format("día %d", PACTO.WorldDay()))
    end
end

CreateLuaEvent(function() pcall(ClockPulse) end, 10000, 0)

-- ===== #hora — la hora del mundo para cualquier jugador =====
local function OnChatHora(event, player, msg)
    if msg:sub(1, 1) == "#" then msg = "!" .. msg:sub(2) end
    if msg ~= "!hora" and msg ~= "!tiempo" then return end
    if not Enabled() then
        player:SendBroadcastMessage(PACTO.PREFIX .. "El tiempo del mundo está detenido.")
        return false
    end
    local h = PACTO.WorldHour()
    local dayFrom = PACTO.GetConfigNum("clock_day_from", 6)
    local dayTo = PACTO.GetConfigNum("clock_day_to", 20)
    local estado = PACTO.IsNight() and "|cff9482c9NOCHE|r" or "|cffffd700DÍA|r"
    -- horas del mundo que faltan para el próximo cambio
    local target = PACTO.IsNight() and dayFrom or dayTo
    local faltanH = (target - h) % 24
    local realMin = math.floor(faltanH * (DaySeconds() / 24) / 60)
    local luna = PACTO.IsFullMoon() and " |cffff4444LUNA LLENA|r" or
        (PACTO.MoonPhase() == math.floor(PACTO.GetConfigNum("clock_moon_cycle", 28) / 2)
            and " (luna llena esta noche)" or "")
    player:SendBroadcastMessage(PACTO.PREFIX .. string.format(
        "Día %d del mundo, %02d:00 — %s%s. %s en ~%d min reales.",
        PACTO.WorldDay(), h, estado, luna,
        PACTO.IsNight() and "Amanece" or "Anochece", realMin))
    return false
end

for _, ev in ipairs({18, 19, 20, 21, 22}) do
    RegisterPlayerEvent(ev, OnChatHora)
end

print(string.format("[ElPacto] worldclock.lua listo (día %d, %02d:00, %s)",
    PACTO.WorldDay(), PACTO.WorldHour(), PACTO.IsNight() and "noche" or "día"))
