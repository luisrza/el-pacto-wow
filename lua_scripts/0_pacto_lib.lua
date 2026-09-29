-- 0_pacto_lib.lua — EL PACTO: librería común (F0)
-- El prefijo "0_" garantiza que carga antes que el resto.
-- Todo knob vive en pacto.pacto_config — nunca constantes en Lua.

PACTO = PACTO or {}

PACTO.PREFIX = "|cff8788ee[El Pacto]|r "

-- ========== config cacheada ==========
local configCache = {}

function PACTO.ReloadConfig()
    configCache = {}
    local q = WorldDBQuery("SELECT `key`, `value` FROM pacto.pacto_config")
    if q then
        repeat
            configCache[q:GetString(0)] = q:GetString(1)
        until not q:NextRow()
    end
    local n = 0
    for _ in pairs(configCache) do n = n + 1 end
    print(string.format("[ElPacto] config cargada (%d claves)", n))
end

function PACTO.GetConfig(key, default)
    local v = configCache[key]
    if v == nil then return default end
    return v
end

function PACTO.GetConfigNum(key, default)
    return tonumber(PACTO.GetConfig(key, default)) or default
end

function PACTO.SetConfig(key, value)
    WorldDBExecute(string.format(
        "REPLACE INTO pacto.pacto_config (`key`, `value`) VALUES ('%s', '%s')",
        tostring(key):gsub("'", "''"), tostring(value):gsub("'", "''")))
    configCache[key] = tostring(value)
end

-- ========== la Crónica (telemetría + memoria del mundo) ==========
-- world_day/world_hour los aporta worldclock.lua (0 si aún no cargó)
function PACTO.Chronicle(eventType, actor, detail)
    local wd, wh = 0, 0
    if PACTO.WorldDay then wd, wh = PACTO.WorldDay(), PACTO.WorldHour() end
    WorldDBExecute(string.format(
        "INSERT INTO pacto.pacto_chronicle (event_type, actor, detail, world_day, world_hour) VALUES ('%s', '%s', '%s', %d, %d)",
        tostring(eventType):gsub("'", "''"),
        tostring(actor or ""):gsub("'", "''"):sub(1, 24),
        tostring(detail or ""):gsub("'", "''"):sub(1, 250), wd, wh))
end

-- ========== anuncios ==========
function PACTO.Announce(msg)
    SendWorldMessage(PACTO.PREFIX .. msg)
    PACTO.Chronicle("announce", "", msg)
end

-- ========== util ==========
function PACTO.Esc(s)
    return tostring(s or ""):gsub("'", "''")
end

-- carga inicial
PACTO.ReloadConfig()
print("[ElPacto] 0_pacto_lib.lua listo")
