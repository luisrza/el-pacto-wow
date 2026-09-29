# PROYECTO: EL PACTO — Aventura D&D en WoW 3.3.5a

Servidor privado de WoW **independiente de La Torre** (otro AzerothCore, otra DB, otro realm,
este repo). Una aventura estilo Dungeons & Dragons con **universo persistente**: los amigos
crean su personaje **escribiendo en texto** (test + trasfondo), y de ese texto nace un
**linaje** que funciona como mini-clase — identidad jugable con ventaja Y precio. Todo pacto
tiene precio: el vampiro roba vida y domina la oscuridad, pero el sol lo quema. El mundo
recuerda lo que haces y las campañas se escriben ANTES, entre Luis y Claude.

**Regla de oro heredada (probada en La Torre):** todo data-driven (contenido = INSERT, nunca
editar código), cero C++ custom, solo spells/efectos del cliente 3.3.5, módulos Lua con
interruptor en config, SQL siempre `utf8mb4`.
**Regla de este repo:** NO tocar `~/latorre/wowero` — proyectos hermanos, archivos aparte.

Análisis motor-por-módulo (qué mecanismo del juego usa cada cosa): **MODULOS-TECNICOS.md**.

---

## DECISIONES TOMADAS (2026-07-12, Luis)

| Tema | Decisión |
|---|---|
| Nombre | **El Pacto** |
| Infraestructura | Stack 100% separado + **launcher Windows** (.bat: realmlist + borrar Cache) |
| Zona inicial | **Duskwood** (capítulo 1); hub: Darkshire; resurrección en Raven Hill |
| DM | **Híbrido**: campañas predefinidas con **triggers automáticos + override de Luis** por comandos in-game; panel web después (F3-F4). La IA mueve el mundo entre sesiones |
| Personaje | **MODELO v2 (2026-07-13): SIN clase base de WoW.** El motor vacía la clase chasis (lista blanca) y el personaje juega SOLO su **Clase del Pacto** (8-10 habilidades: hechizos reales con rangos + comandos con animación + pasivas + precio) elegida en el test, + su **linaje** (lo que ERES). Lineup temporada 1: Baluarte, Penitente, Bardo, Cazador de Brujas, Vidente. Rangos y habilidades 7-10 se ganan por capítulos. Atuendo icónico fijo (transmog; stats en el equipo real). Spec: design/clases-del-pacto.md |
| Linajes F1 | **Los 7 de una vez**: Vampiro, Licántropo, Nigromante menor, Pactado, Tocado por la Luz, Hijo de la Tormenta, Sangre de Gigante |
| Día/noche | **Hora del mundo acelerada** propia (≈1 día del Pacto por 2-3h reales), `#hora`, anuncios de amanecer/anochecer; todos los rasgos leen ESTA hora |
| Interiores/cuevas | **Lista de area-ids curada** por config (cero C++; mod-ale no expone IsOutdoors) |
| Muerte | Cicatrices **narrativas** (nombre + historia, sin malus mecánico) + **resurrección cara con el Sepulturero de Raven Hill** (oro creciente y a veces un "favor" que el capítulo cobra) |
| Progresión | Por **hitos de capítulo** (el DM/campaña nivela al grupo) |
| La Torre | Lo desplegado allá el 2026-07-12 se queda vivo allá |

## Preguntas aún abiertas (PREGUNTAS.md)
Ritmo de sesiones (asumo noches programadas) · ¿los 8 de siempre con personajes nuevos? ·
n8n se levanta al llegar a F1 · hardware 24/7 vs solo-sesión (medir en F0).

---

## MÓDULOS

### M0 — Servidor base independiente 🏗️ *(bloquea todo)*
- Docker compose propio (`pacto-*`), build arm64 desde fuente + mod-ale (~1-2h de compilación).
- Puertos: world **8086**, auth **3725**, MySQL **3307**, SOAP **7879** (La Torre: 8085/3724/3306/7878).
- Schema `pacto_*`, backups diarios propios + restore probado, Tailscale, PlayerLimit 50.
- **Launcher Windows**: .bat que reescribe `realmlist.wtf` (La Torre ⇄ El Pacto) y borra `Cache/`.
- Medir RAM/CPU con ambos stacks vivos → decide 24/7 vs encendido por sesión.
- *Criterio: 2 amigos jugando vanilla en El Pacto.*

### M1 — Reglas del mundo ⚖️
- **Hora del Mundo**: reloj propio acelerado en `pacto_config` (motor central: TODOS los
  rasgos, spawns nocturnos y triggers la leen). `#hora`, anuncios de amanecer/anochecer,
  luna llena calculada sobre el calendario del mundo.
- XP de mobs → 0 (hook probado); **nivelar por hito**: comando/evento sube al grupo.
- Duskwood curado: cerca suave (patrón fence), Darkshire como hub, spawns nocturnos que
  hacen la noche PELIGROSA (knobs en config).
- Sin dungeon finder/AH; una facción; kit inicial humilde.

### M2 — Creación de personaje en texto 📜
- Test (personalidad + trasfondo libre + deseo/miedo/secreto) → n8n → linaje + dones +
  defecto + secreto → cuenta por SOAP → `pacto_heroes`.
- Primer login = **ritual del Pacto**: susurro del trasfondo, firma del pacto (ceremonia),
  kit de linaje, y el secreto (privado — otros jugadores no lo ven).
- Palabras clave del trasfondo → micro-rasgos (`pacto_keywords`, data-driven).

### M3 — Linajes = mini-clases 🧛 *(el corazón; los 7 en F1)*
Cada linaje: **pasiva de identidad + 1-2 poderes activos/procs + su precio**, montado
sobre la clase WoW del jugador. Tablas `pacto_lineages` + `pacto_traits` (params tuneables).

| Linaje | Ventaja jugable | El precio |
|---|---|---|
| **Vampiro** | robo de vida; en oscuridad/cuevas +daño | el sol lo quema (−% vida por pulso, nunca mata) |
| **Licántropo** | de noche +velocidad/+daño; luna llena: transformación (morph worgen) | de día frágil; no elige cuándo cambiar |
| **Nigromante menor** | esbirro esqueleto que pelea por él | los aldeanos desconfían (precios peores, frases frías) |
| **Pactado** | críticos brutales prestados | cada muerte cobra doble (el favor del pacto pesa en la resurrección) |
| **Tocado por la Luz** | cura más; los no-muertos le temen | la oscuridad lo debilita (espejo del vampiro) |
| **Hijo de la Tormenta** | rayos en cadena al matar | las tormentas lo sobrecargan (poder y riesgo a la vez) |
| **Sangre de Gigante** | +daño cuanto menos vida | frenesí que no siempre controla |

- ⚠️ Riesgo técnico F1: el **esbirro del Nigromante** (pet custom con follow/defend) es lo
  único no probado — se valida PRIMERO (si el charm no coopera, plan B: esbirro "escolta"
  por IA propia, mismo resultado visible).
- Verificación por linaje antes de darlo por hecho: su pasiva se siente, su precio duele,
  y ambos leen la Hora del Mundo cuando aplique.

### M4 — Decisiones y atributos ⚖️ *(SIN DADOS — decisión de Luis 2026-07-13: el combate
del motor con las habilidades ES la resolución)*
- **Decisiones de escena por menús de gossip**: el objeto/NPC de la escena ofrece opciones
  ("¿Abren el ataúd / lo queman / llaman al Vidente?"), el grupo elige, el capítulo bifurca
  (flag en la crónica). Cero fricción, mecánica nativa de WoW.
- **Atributos del test = bonos reales pequeños** al crear el personaje (+CON vida, +FUE
  daño físico, etc.) — el test importa mecánicamente dentro del combate del motor.
- Las habilidades que referenciaban "tiradas" quedaron re-especificadas en
  design/clases-del-pacto.md (inspiración = potenciar la próxima habilidad; "ojo abierto" =
  detección real de sigilo/invisibilidad).

### M5 — El Dungeon Master 🎭
- **Motor de escenas con triggers** (VIABLE con mecanismos probados): condición → escena
  (llegada a área por distancia, hora del mundo, kill por poller, flag de decisión) →
  acciones (spawn, narración, POI, sonido, menú de decisión). Tabla `pacto_events`.
- **Comandos de override de Luis** (in-game, prefijo `#`): forzar/saltar escena, narrar,
  spawnear, dar loot, abrir un menú de decisión, mover la escena, `#amanecer`/`#anochecer`.
- Entre sesiones: la IA ejecuta los eventos programados del capítulo y siembra rumores.
- Panel web para preparar capítulos y leer la crónica: F3-F4.

### M6 — Universo persistente 🌍
- `pacto_chronicle`: todo acto notable escrito (kills, decisiones, hazañas, muertes).
- NPCs con memoria (gossip apilado + frases data-driven — patrón probado hoy).
- Reputación por lugar (precios y frases; hostilidad selectiva es limitada en el motor —
  se expresa narrativamente).
- Mundo que cambia entre capítulos vía **phasing** (dos versiones de la zona en DB);
  los swaps SIEMPRE entre sesiones (pueden pedir repop/reinicio).

### M7 — Muerte, cicatrices y el Sepulturero 💀
- Morir deja **cicatriz narrativa** con nombre e historia ("La garra de Raven Hill") en la
  crónica y en `#cicatrices` — sin malus mecánico (decisión de Luis).
- **El Sepulturero de Raven Hill**: único resucitador; cobra oro creciente por muerte y a
  veces un **favor** — una deuda que el capítulo cobrará después (gancho narrativo directo).
  El Pactado paga doble (su precio de linaje).
- Viaje fantasma largo si mueres lejos: morir en Duskwood tiene geografía.

### M8 — Botín con historia 🗡️
- Objetos notables únicos y nombrados (reciclaje de entries + `pacto_item_overrides`;
  recordar: item_template solo entra con reinicio → items nuevos se preparan entre sesiones).
- El loot lo dan las escenas/DM, no el grind. Comercio libre entre jugadores.

### M9 — Campañas por capítulos 📖 *(central: aquí vive "la aventura se trabaja antes")*
- `pacto_campaigns`: capítulos → escenas → triggers/encuentros/decisiones → bifurcaciones.
- Flujo: Luis + Claude escriben el capítulo (doc narrativo + INSERTs de escenas) → sesión
  con triggers corriendo y Luis encima → la crónica registra decisiones → el siguiente
  capítulo las hereda.
- Recap automático al abrir sesión ("En el capítulo anterior...").
- **Capítulo 1 (Duskwood)** — primer entregable narrativo, a escribir juntos.

### M10 — Herramientas 🧰
- Launcher Windows (M0) · Dashboard (F3-F4: cuentas, crónica, editor de capítulos) ·
  backups + restore probado ANTES de progreso real.

---

## FASES

- **F0 — Cimientos** ✅ **HECHO (2026-07-12)**: stack `pacto-*` EN VIVO (imágenes :pacto
  congeladas, DB propia, realm "El Pacto" en <TAILSCALE_IP>:8086/auth 3725, SOAP probado,
  mod-ale cargando Lua, autobalance apagado). Backups probados (cron pendiente de Luis).
  Launcher Windows listo. **Mediciones: ambos servidores conviven — RAM total ~5.4/7.6GB
  Docker, ~½ core por worldserver en idle → pueden correr 24/7.**
  Falta el criterio humano: 2 amigos conectados (primer login real pendiente).
  BONUS adelantado de F1: Hora del Mundo (worldclock.lua) EN VIVO + schema pacto_* creado.
- **F1 — El ritual**: Hora del Mundo + M2 (test) + M3 (**los 7 linajes**, empezando por
  validar el esbirro del Nigromante) + Duskwood curado.
  *Criterio: cada amigo entra con su linaje y lo SIENTE (el sol quema, la noche aúlla).*
- **F2 — La mesa**: M4 (dados) + M5 (motor de escenas + comandos DM) + M7 (Sepulturero).
  *Criterio: primera sesión dirigida con triggers, decisiones con consecuencia y una resurrección que dolió.*
- **F3 — El mundo vivo**: M6 (crónica + memoria + phasing) + M8 + **capítulo 1 completo**.
- **F4 — Profundidad**: IA entre sesiones, dashboard, capítulo 2+, linajes nuevos que
  "despiertan" por eventos.

## Qué reutilizamos de La Torre (conocimiento, NO archivos)
Módulos Lua autocontenidos con gate en config · poller de log · gossip apilado · n8n→SOAP
(cuentas NUNCA por DB, SRP6) · rasgos por pulso · morph/transmog server-side · reciclaje de
items · trampas: utf8mb4, item_template no recarga en caliente, creatures nuevas = reinicio,
no retener userdata entre ticks.

## Riesgos
1. **Esbirro del Nigromante** (pets custom) — único linaje con técnica no probada; se
   valida al inicio de F1 con plan B listo.
2. **Recursos del M4** con dos stacks — medición en F0 decide 24/7 vs por-sesión.
3. **7 linajes de una** — F1 más largo; mitigación: motor de rasgos común primero, los
   linajes son datos + handlers cortos encima (patrón hero_powers probado).
4. Los dados viven FUERA del combate — no convertir el combate WoW en turnos.
