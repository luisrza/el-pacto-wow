# PROYECTO: EL PACTO

Servidor privado de WoW 3.3.5a **independiente de La Torre**: una aventura estilo D&D con
universo persistente para el grupo de amigos de Luis. Visión, módulos y fases: **PLAN.md**.
Mecanismos del motor por feature: **MODULOS-TECNICOS.md**. Decisiones y pendientes:
**PREGUNTAS.md**. Spec de linajes: **design/linajes.md**.

## Reglas duras (no negociables)
1. **NO tocar `~/latorre/wowero` ni sus contenedores `ac-*`** — proyecto hermano, archivos
   y datos 100% aparte. Este repo es autocontenido.
2. **Todo data-driven**: contenido/balance = INSERT/UPDATE en el schema `pacto`, nunca
   constantes en Lua ni ediciones de código para tunear.
3. **Cero C++ custom** y solo spells/displays/efectos que EXISTAN en el cliente 3.3.5.
4. Módulos Lua autocontenidos: gate en `pacto_config` (`*_enabled`), todo en pcall, cada
   script imprime `[ElPacto] <archivo> listo` al cargar.
5. **SQL siempre con `--default-character-set=utf8mb4`** (sin eso, mojibake en acentos).
6. Cuentas de juego SIEMPRE por SOAP/consola (`account create`) — jamás INSERT en DB (SRP6).
7. La hora del juego es la **Hora del Mundo** (`PACTO.WorldHour()`, worldclock.lua) — ningún
   rasgo/evento debe leer el reloj real.

## Stack (F0, en vivo desde 2026-07-12)
- Contenedores: `pacto-database`, `pacto-authserver`, `pacto-worldserver` (compose en
  `azerothcore-wotlk/` con `.env` + override propios; imágenes congeladas tag `:pacto`).
- Puertos: world **8086** y auth **3725** (solo IP Tailscale <TAILSCALE_IP>); MySQL **3307**
  y SOAP **7879** (solo localhost). La Torre usa 8085/3724/3306/7878 — no chocan.
- MySQL: `docker exec pacto-database mysql -uroot -ppassword` (schema propio: `pacto`).
- SOAP: `curl -u dashboard:<SOAP_PASS> http://127.0.0.1:7879/` (credencial real en NOTAS-LOCALES.md, no versionado).
- Lua: `lua_scripts/` de este repo, montado al vuelo; recargar con `reload ale` por SOAP.
- Logs: `docker logs pacto-worldserver`. Tras cada reload: cero "lua error" + los "listo".
- Backups: `tools/backup-pacto.sh` (probado; cron diario pendiente de que Luis lo instale).
- Launcher amigos (Windows): `launcher/ElPacto.bat` y `launcher/LaTorre.bat` (van en la
  carpeta del WoW).

## Convenciones
- Entries custom (creatures/objetos) ≥ **900000**. Items custom = reciclar entries
  existentes (registro en `pacto_item_overrides` cuando exista).
- Telemetría y memoria del mundo: TODO evento notable a `pacto_chronicle`
  (`PACTO.Chronicle(tipo, actor, detalle)`) — la crónica es la fuente de los NPCs con
  memoria y los recaps.
- Español en textos de juego; los NPCs hablan con personalidad propia.
- Trampas conocidas (heredadas de la experiencia La Torre): `item_template` no recarga en
  caliente · **`npc_text` TAMPOCO recarga en caliente** (cazada 2026-07-15: el comando reload no existe en el core, solo el de locales) · creatures nuevas requieren reinicio · no retener userdata entre ticks ·
  `RegisterCreatureGossipEvent` apila handlers (no toques menús ajenos desde otro archivo).

## El usuario
Luis (in-game: por definir en El Pacto) orquesta y diseña; Claude genera Lua/SQL y explica
las decisiones técnicas sin asumir conocimiento de C++/emulación. Los capítulos de campaña
se escriben ENTRE Luis y Claude antes de cada sesión.
