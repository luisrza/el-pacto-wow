# El Pacto — Análisis técnico: qué necesita cada módulo DEL MOTOR del juego

Mapa de cada feature del PLAN a los mecanismos concretos del motor (AzerothCore 3.3.5a +
mod-ale/Eluna + SmartAI + DB). Leyenda de estado:
- ✅ **probado** — ya funciona en producción en La Torre (patrón conocido, se re-implementa aquí)
- 🧪 **por validar** — técnicamente posible, hay que probarlo antes de prometerlo
- ⚠️ **limitación** — el motor no lo da; hay plan B documentado

---

## M0 — Servidor base

| Necesidad | Mecanismo del motor | Estado |
|---|---|---|
| Segundo servidor aislado en el mismo Mac | Docker compose propio, puertos distintos (world 8086, auth 3725, MySQL 3307, SOAP 7879) | ✅ (mismo compose que La Torre, renombrado) |
| Compilar arm64 con mod-ale | Build desde fuente en el M4 (imágenes de Docker Hub son amd64) | ✅ (ya se hizo una vez; tarda ~1-2h) |
| Cliente de los amigos | MISMO cliente 3.3.5a; solo cambia `realmlist.wtf` | ✅ |
| Launcher de un clic (cambiar de juego) | Script que reescribe realmlist + borra `Cache/` | ✅ trivial — Windows confirmado (.bat) |
| ¿Aguanta el M4 dos stacks? | Medir RAM/CPU con ambos vivos | 🧪 en F0 (plan B: El Pacto solo en sesión) |

## M1 — Reglas del mundo

| Necesidad | Mecanismo | Estado |
|---|---|---|
| XP por hitos (mobs no dan nivel) | Hook `ON_GIVE_XP` → 0 + `SetLevel()` al marcar hito | ✅ (patrón xp.lua: tope de frontera) |
| Subir nivel al grupo en el hito | Comando DM / evento de capítulo → `SetLevel` a presentes | ✅ |
| **Ciclo día/noche con efectos** | ⚠️ el reloj del juego = reloj del server. Si juegan de noche real, SIEMPRE es de noche (el vampiro nunca se quema). **Plan B recomendado: "hora del mundo" propia acelerada** (ej. 1 día del Pacto = 2-3h reales), guardada en `pacto_config`, con `#hora` y anuncios de amanecer/anochecer; todos los rasgos leen ESA hora | ✅ DECIDIDO: Hora del Mundo acelerada |
| Noche peligrosa (spawns nocturnos) | Pulso Lua + `PerformIngameSpawn` al anochecer, despawn al amanecer | ✅ (patrón nightstart/spawner) |
| Clima narrativo | `Map:SetWeather` (lluvia/niebla por zona) | ✅ binding verificado en mod-ale (LuaFunctions.cpp:1328); probar efecto en vivo en F1 |
| Mundo curado (solo Duskwood cap. 1) | Cerca invisible (teleport de vuelta + mensaje temático) | ✅ (fence.lua v2) |
| Sin dungeon finder/AH | worldserver.conf | ✅ |

## M2 — Creación en texto

| Necesidad | Mecanismo | Estado |
|---|---|---|
| Formulario → linaje/dones/secreto | n8n webhook → puntuación → INSERT + cuenta por SOAP | ✅ (flujo entero probado hoy) |
| Ritual del primer login | Hook `ON_FIRST_LOGIN` + susurros + kit + aura ceremonial | ✅ (heroes.lua probado) |
| Secreto privado del personaje | Whisper solo al dueño; tabla con columna que el dashboard no muestra | ✅ |
| Palabras clave del trasfondo → micro-rasgos | Parseo en n8n (Code node) contra catálogo `pacto_keywords` | ✅ trivial |

## M3 — Linajes (el corazón mecánico)

| Necesidad | Mecanismo | Estado |
|---|---|---|
| Rasgos por pulso (vampiro sol/oscuridad) | `CreateLuaEvent` + `SetHealth`/`AddAura`/`RemoveAura` | ✅ (probado hoy en La Torre) |
| **Detectar "interior/cueva" en mundo abierto** | ⚠️ mod-ale NO expone `IsOutdoors` (verificado en el código del módulo). Opciones: (a) **lista de area-ids de cuevas/edificios** en config — data-driven, cero C++, suficiente para Duskwood curado; (b) micro-patch a mod-ale añadiendo el binding (~10 líneas C++, estilo la excepción maxplayers de La Torre, pero obliga a recompilar en cada update) | ✅ DECIDIDO: lista de áreas curada (a) |
| Transformación del licántropo | `SetDisplayId` (morph a worgen, displayid existente en el cliente) | ✅ (patrón conocido; La Torre morphea trolls) |
| Luna llena real | Cálculo de fase lunar por fecha en Lua (aritmética pura) | ✅ trivial |
| +daño / robo de vida / miedo de no-muertos | Auras de spells EXISTENTES del cliente (Enrage 8599, lifesteal de forja, Fear ai) | ✅ catálogo por armar |
| Ventaja/desventaja en tiradas por linaje | Columna en `pacto_lineages`, la lee el módulo de dados | ✅ |

## M3b — Herramientas de mini-clase (fusionado en M3: linaje = mini-clase, decisión de Luis)

| Necesidad | Mecanismo | Estado |
|---|---|---|
| Enseñar hechizos de otra clase | `LearnSpell` selectivo al login/nivel | ✅ (autolearn.lua) — ⚠️ solo cruza bien entre clases de MANÁ (a un guerrero con rabia no le castean spells de maná) |
| Pasivas/procs de clase custom | Handlers Lua on_kill/on_damage (agnósticos al recurso) | ✅ (hero_powers.lua) |
| Visual propio de clase | Transmog server-side (sobrescribir campos visuales de slots) | ✅ (wardrobe.lua) |
| Barra de acción/talentos custom | ⚠️ IMPOSIBLE — UI del cliente cerrada. Los talentos siguen siendo los del chasis | — |
| **Ejército del Nigromante (pets custom)** | `PerformIngameSpawn` + control (follow/defend del dueño): hay que validar si el charm/ownership se comporta o si se simula con IA "escolta" | 🧪 validar al INICIO de F1 (Nigromante confirmado en el catálogo; plan B: esbirro-escolta por IA) |

## M4 — Dados y pruebas

| Necesidad | Mecanismo | Estado |
|---|---|---|
| `#d20`, `#tirar XdY+Z` visibles al grupo | Hook de chat (eventos 18-22) + mensaje a grupo/say | ✅ (patrón #mipoder/#titulos) |
| Atributos D&D del personaje | Columnas en `pacto_heroes` (no tocan stats WoW: son para tiradas) | ✅ |
| Prueba pedida por el DM ("Carisma dif. 15") | Comando DM → whisper al jugador → su tirada resuelve con ventaja/desventaja de sus rasgos → resultado anunciado | ✅ solo Lua+DB |
| Crítico/pifia con drama | `SendAreaTriggerMessage` (texto grande en pantalla) + `PlayDirectSound` | ✅ (narrator de La Torre usa ambos) |

## M5 — Dungeon Master

| Necesidad | Mecanismo | Estado |
|---|---|---|
| Narrar en pantalla de todos | `SendAreaTriggerMessage`/emote raid + `SendWorldMessage` | ✅ |
| Voz de NPCs ("el posadero dice...") | `SendUnitSay` sobre el NPC objetivo | ✅ |
| Spawnear encuentro preparado | `PerformIngameSpawn` de packs definidos en `pacto_encounters` | ✅ (spawner.lua) |
| Dar loot con historia | `AddItem` + item overrides | ✅ |
| Mover la escena / teleport grupo | `Teleport` grupal | ✅ (gates.lua) |
| Eventos entre sesiones (IA ejecuta el capítulo) | Pulso que lee `pacto_events` (hora del mundo, condiciones, acciones) | ✅ motor por escribir, mecanismos probados |
| Sonido/música de momento | `PlayDirectSound` (sonidos del cliente) | ✅ |
| **Interfaz del DM** | (a) in-game: cuenta GM + comandos `#` — inmediato; (b) panel web (dashboard) — cómodo para leer la crónica y preparar; (c) ambos | ✅ DECIDIDO: (a) in-game primero, panel en F3-F4 |

## M6 — Universo persistente

| Necesidad | Mecanismo | Estado |
|---|---|---|
| Crónica de actos | Tabla `pacto_chronicle` + poller (hitos → memoria) | ✅ (patrón titles.lua probado hoy) |
| NPCs con memoria que saludan | Gossip apilado sin romper menús + frases data-driven | ✅ (probado hoy) |
| Reputación por lugar | Tabla + reacciones (frases, precios, guardias hostiles vía FactionTemplate por jugador ⚠️ — la hostilidad selectiva por jugador es limitada; plan B: consecuencias narrativas y de precios) | 🧪 |
| **El pueblo quemado (mundo que cambia)** | **Phasing**: `creature.phaseMask` en DB — dos versiones de la misma zona; el capítulo activa una u otra (repop). Cambio GLOBAL (verdad única del server), no por jugador | 🧪 validar flujo de swap en vivo (puede requerir repop/reinicio) |
| Decisiones que bifurcan | Flags en `pacto_campaigns`/`pacto_chronicle`, los eventos las consultan | ✅ |

## M7 — Muerte y cicatrices

| Necesidad | Mecanismo | Estado |
|---|---|---|
| Detectar muerte + contexto | Hook de muerte (killer, zona, hora del mundo) | ✅ (death.lua) |
| Cicatriz = micro-malus permanente | Al login re-aplicar el malus: (a) `SetMaxHealth` −X% (universal, simple) o (b) catálogo variado por causa (velocidad, espíritu, oro…) vía auras existentes | ✅ DECIDIDO: cicatrices narrativas SIN malus |
| Resurrección cara | Anular resurrección normal en el punto elegido + NPC resucitador que cobra (oro/atributo/favor) | ✅ DECIDIDO: solo el Sepulturero de Raven Hill |
| Registro narrativo | Cicatrices con nombre en `pacto_scars` + `#cicatrices` | ✅ |

## M8 — Botín · M9 — Campañas · M10 — Herramientas

| Necesidad | Mecanismo | Estado |
|---|---|---|
| Items únicos nombrados | Reciclaje de entries existentes + `pacto_item_overrides` (⚠️ recordar: item_template NO recarga en caliente — los items nuevos entran con reinicio) | ✅ |
| Capítulos data-driven | `pacto_campaigns` (escenas/encuentros/tiradas/bifurcaciones) leídos por el motor de eventos | ✅ diseño, motor por escribir |
| Recap "en el capítulo anterior..." | Query a la crónica al abrir sesión | ✅ |
| Dashboard | Next.js + MySQL read-only + SOAP (patrón de La Torre) | ✅ |
| Backups | cron + mysqldump, restore probado | ✅ |

---

## Las 4 limitaciones duras del motor (para no chocar con ellas)
1. **Nada de UI custom en el cliente**: ni barras, ni ventanas, ni clases reales nuevas.
   Todo pasa por chat, gossip, emotes de pantalla y sonidos existentes.
2. **`IsOutdoors` no está expuesto** en mod-ale → interior/cueva se resuelve por listas de
   áreas (data-driven) o micro-patch C++ (decisión pendiente).
3. **Cross-class solo entre clases de maná**; guerrero/pícaro reciben pasivas y procs Lua.
4. **Los cambios de mundo (phasing/creatures nuevas/items) pueden pedir repop o reinicio**
   — los capítulos deben cambiar el mundo ENTRE sesiones, no en mitad de una.
