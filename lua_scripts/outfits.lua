-- outfits.lua — EL PACTO: ATUENDOS ICÓNICOS (decisión Luis 2026-07-13)
-- Cada héroe se ve como SU clase/variante — tier sin casco, la cara visible.
-- El look es del personaje; las stats, del equipo real de abajo (transmog
-- server-side: SetUInt32Value sobre PLAYER_VISIBLE_ITEM_*, técnica validada
-- en producción). Mejora sobre el patrón original: se re-aplica también al
-- cambiar de equipo, no solo al login.
-- Gate: pacto_config.outfits_enabled. Datos: pacto_outfits (clase, variante).

local VISIBLE_ITEM_BASE = 283  -- PLAYER_VISIBLE_ITEM_1_ENTRYID (3.3.5); slot*2

local function Enabled()
    return PACTO.GetConfigNum("outfits_enabled", 0) == 1
end

local outfitCache = {}  -- "clase:variante" -> { [equip_slot]=entry } | false
local heroOutfit  = {}  -- guidLow -> clave "clase:variante" | false

local function LoadOutfit(clase, variante)
    local key = clase .. ":" .. variante
    if outfitCache[key] ~= nil then return outfitCache[key] end
    local q = WorldDBQuery(string.format(
        "SELECT equip_slot, item_entry FROM pacto.pacto_outfits WHERE clase = '%s' AND variante = '%s'",
        PACTO.Esc(clase), PACTO.Esc(variante)))
    if not q then outfitCache[key] = false; return false end
    local o = {}
    repeat o[q:GetUInt32(0)] = q:GetUInt32(1) until not q:NextRow()
    outfitCache[key] = o
    return o
end

local function HeroOutfitKey(p)
    local g = p:GetGUIDLow()
    if heroOutfit[g] ~= nil then return heroOutfit[g] end
    local q = WorldDBQuery(string.format(
        "SELECT clase, variante FROM pacto.pacto_heroes WHERE nombre_personaje = '%s' AND clase <> ''",
        PACTO.Esc(p:GetName())))
    heroOutfit[g] = q and (q:GetString(0) .. ":" .. q:GetString(1)) or false
    return heroOutfit[g]
end

local function Apply(p)
    if not Enabled() then return end
    local key = HeroOutfitKey(p)
    if not key then return end
    local clase, variante = key:match("^(.-):(.*)$")
    local outfit = LoadOutfit(clase, variante)
    if not outfit then return end
    for slot, entry in pairs(outfit) do
        pcall(function() p:SetUInt32Value(VISIBLE_ITEM_BASE + slot * 2, entry) end)
    end
end

RegisterPlayerEvent(3, function(event, p)  -- ON_LOGIN
    pcall(function()
        heroOutfit[p:GetGUIDLow()] = nil   -- rehidratar (pudo cambiar de clase)
        Apply(p)
    end)
end)

RegisterPlayerEvent(29, function(event, p) -- ON_EQUIP: el equipo nuevo no rompe el look
    pcall(Apply, p)
end)

print("[ElPacto] outfits.lua listo (atuendos icónicos, gate: outfits_enabled)")
