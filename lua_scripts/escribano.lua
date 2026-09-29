-- escribano.lua — EL PACTO: EL ESCRIBANO DEL PACTO (creación in-game, decisión Luis)
-- El test como ritual jugado: 6 preguntas por gossip → el linaje EMERGE de las
-- respuestas → eliges clase y variante → dictas tu trasfondo y tu secreto por
-- chat (patrón dictado probado) → firma → "sal del mundo y vuelve a entrar"
-- (el relog despierta linaje/kit/atuendo por los hooks de login existentes).
-- Datos: pacto_test_questions/options, pacto_classes. Gate: escribano_enabled.

local ESCRIBANO = 900208

local function Enabled()
    return PACTO.GetConfigNum("escribano_enabled", 0) == 1
end

-- estado de cada aspirante (volátil; el ritual se completa en una sentada)
local ritual = {}   -- guidLow -> {paso, puntos={linaje=n}, clase, variante, trasfondo, secreto, dictando}

local preguntas = {}  -- orden -> {texto, opciones={ {texto, linaje}, ... }}
local clases = {}     -- idx -> {clase, nombre, desc, va, vb}

local function LoadTest()
    preguntas, clases = {}, {}
    local q = WorldDBQuery("SELECT orden, texto FROM pacto.pacto_test_questions ORDER BY orden")
    if q then
        repeat preguntas[q:GetUInt32(0)] = { texto = q:GetString(1), opciones = {} } until not q:NextRow()
    end
    local o = WorldDBQuery("SELECT orden, opcion, texto, linaje FROM pacto.pacto_test_options ORDER BY orden, opcion")
    if o then
        repeat
            local pq = preguntas[o:GetUInt32(0)]
            if pq then pq.opciones[o:GetUInt32(1)] = { texto = o:GetString(2), linaje = o:GetString(3) } end
        until not o:NextRow()
    end
    local c = WorldDBQuery("SELECT clase, nombre, descripcion, variante_a, variante_b FROM pacto.pacto_classes ORDER BY clase")
    if c then
        repeat
            table.insert(clases, { clase = c:GetString(0), nombre = c:GetString(1),
                desc = c:GetString(2), va = c:GetString(3), vb = c:GetString(4) })
        until not c:NextRow()
    end
end

local function YaFirmo(p)
    local q = WorldDBQuery(string.format(
        "SELECT linaje FROM pacto.pacto_heroes WHERE nombre_personaje = '%s' AND linaje <> ''",
        PACTO.Esc(p:GetName())))
    return q and q:GetString(0) or nil
end

local function MenuPregunta(p, c, n)
    local pq = preguntas[n]
    if not pq then return end
    p:GossipClearMenu()
    for i, op in pairs(pq.opciones) do
        p:GossipMenuAddItem(0, op.texto, 0, n * 100 + i)
    end
    p:GossipSendMenu(900000 + n, c)  -- la pregunta vive SOLO en la hoja
end

local function MenuClase(p, c)
    p:GossipClearMenu()
    for i, cl in ipairs(clases) do
        p:GossipMenuAddItem(0, cl.nombre .. " — " .. cl.desc, 0, 9000 + i)
    end
    p:GossipSendMenu(900007, c)
end

local function MenuVariante(p, c, idx)
    local cl = clases[idx]
    p:GossipClearMenu()
    p:GossipMenuAddItem(0, cl.nombre .. " " .. cl.va, 0, 9100 + idx * 2)
    p:GossipMenuAddItem(0, cl.nombre .. " " .. cl.vb, 0, 9101 + idx * 2)
    p:GossipSendMenu(900008, c)
end

local function Linaje(st)
    local mejor, pts = "vampiro", -1
    for lin, n in pairs(st.puntos) do
        if n > pts then mejor, pts = lin, n end
    end
    return mejor
end

local function Firmar(p, st)
    local lin = Linaje(st)
    WorldDBExecute(string.format([[
        INSERT INTO pacto.pacto_heroes (account_name, nombre_personaje, linaje, clase, variante, trasfondo, secreto)
        VALUES ('%s', '%s', '%s', '%s', '%s', '%s', '%s')
        ON DUPLICATE KEY UPDATE linaje=VALUES(linaje), clase=VALUES(clase),
          variante=VALUES(variante), trasfondo=VALUES(trasfondo), secreto=VALUES(secreto)]],
        PACTO.Esc(tostring(p:GetAccountId())), PACTO.Esc(p:GetName()), PACTO.Esc(lin),
        PACTO.Esc(st.clase), PACTO.Esc(st.variante),
        PACTO.Esc(st.trasfondo or ""), PACTO.Esc(st.secreto or "")))
    ritual[p:GetGUIDLow()] = nil
    p:SendBroadcastMessage("|cff9482c9[El Escribano]|r La pluma se detiene. Está hecho.")
    p:SendBroadcastMessage(string.format(
        "|cffa335eeEres %s, del linaje %s.|r Tu historia y tu secreto están en el libro.",
        st.clase:upper(), lin:upper()))
    p:SendBroadcastMessage("|cffffd700\"Ahora VE. Sal del mundo... y vuelve a entrar en él. Despertarás distinto.\"|r")
    PACTO.Chronicle("firma", p:GetName(), string.format("%s / %s %s", lin, st.clase, st.variante))
    PACTO.Announce(string.format("%s ha firmado El Pacto.", p:GetName()))
end

-- ===== gossip del Escribano =====
local function OnHello(event, p, c)
    if not Enabled() then return end
    local firmado = YaFirmo(p)
    if firmado then
        p:GossipClearMenu()
        p:GossipMenuAddItem(0, "(Tu firma ya está en el libro.)", 0, 9999)
        p:GossipSendMenu(900009, c)
        return
    end
    local g = p:GetGUIDLow()
    local st = ritual[g]
    if st then  -- ritual a medias: retomar, no reiniciar
        if st.dictando then
            p:SendBroadcastMessage("|cff9482c9[El Escribano]|r \"Te espero. Escribe tu " .. st.dictando .. " en el chat.\"")
        elseif st.clase then MenuVariante(p, c, 1)
        else MenuPregunta(p, c, st.paso or 1) end
        return
    end
    ritual[g] = { paso = 1, puntos = {} }
    PACTO.Chronicle("test_paso", p:GetName(), "ritual iniciado")
    MenuPregunta(p, c, 1)
end

local function OnSelect(event, p, c, sender, intid, code)
    if not Enabled() then return end
    local g = p:GetGUIDLow()
    local st = ritual[g]
    p:GossipComplete()
    if intid == 9999 or not st then return end

    if intid >= 100 and intid < 9000 then           -- respuesta de pregunta
        local n, op = math.floor(intid / 100), intid % 100
        local pq = preguntas[n]
        local elegida = pq and pq.opciones[op]
        if not elegida then return end
        st.puntos[elegida.linaje] = (st.puntos[elegida.linaje] or 0) + 1
        PACTO.Chronicle("test_paso", p:GetName(), string.format("pregunta %d -> %s", n, elegida.linaje))
        if preguntas[n + 1] then
            st.paso = n + 1
            MenuPregunta(p, c, n + 1)
        else
            MenuClase(p, c)
        end

    elseif intid >= 9000 and intid < 9100 then      -- clase elegida
        local cl = clases[intid - 9000]
        if not cl then return end
        st.clase = cl.clase
        PACTO.Chronicle("test_paso", p:GetName(), "clase " .. cl.clase)
        MenuVariante(p, c, intid - 9000)

    elseif intid >= 9100 then                        -- variante elegida
        local idx = math.floor((intid - 9100) / 2)
        local cl = clases[idx]
        if not cl then return end
        st.variante = (intid % 2 == 0) and cl.va or cl.vb
        PACTO.Chronicle("test_paso", p:GetName(), "variante " .. st.variante)
        st.dictando = "trasfondo"
        p:SendBroadcastMessage("|cff9482c9[El Escribano]|r \"Ahora cuéntame quién eras antes de esta noche. ESCRÍBELO en el chat — una o dos frases.\"")
    end
end

-- ===== dictado: trasfondo y secreto por chat =====
local function OnChat(event, p, msg)
    local st = ritual[p:GetGUIDLow()]
    if not st or not st.dictando then return end
    if msg:sub(1, 1) == "#" or msg:sub(1, 1) == "!" then return end  -- comandos no se tragan
    if st.dictando == "trasfondo" then
        st.trasfondo = msg:sub(1, 500)
        PACTO.Chronicle("test_paso", p:GetName(), "trasfondo recibido")
        st.dictando = "secreto"
        p:SendBroadcastMessage("|cff9482c9[El Escribano]|r \"Bien... Y ahora, en voz baja: tu SECRETO. Lo que nadie sabe. Solo el libro lo verá.\"")
        return false
    elseif st.dictando == "secreto" then
        st.secreto = msg:sub(1, 250)
        st.dictando = nil
        Firmar(p, st)
        return false  -- el secreto JAMÁS se muestra en el chat
    end
end

pcall(RegisterCreatureGossipEvent, ESCRIBANO, 1, OnHello)
pcall(RegisterCreatureGossipEvent, ESCRIBANO, 2, OnSelect)
for _, ev in ipairs({18, 19, 20, 21, 22}) do
    RegisterPlayerEvent(ev, OnChat)
end

LoadTest()
print(string.format("[ElPacto] escribano.lua listo (%d preguntas, %d clases)",
    (function() local n = 0 for _ in pairs(preguntas) do n = n + 1 end return n end)(), #clases))
