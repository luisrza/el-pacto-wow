# Auditoría F0 — El Pacto (2026-07-13, madrugada)
*Auditoría completa de infraestructura, seguridad, datos, módulos y convivencia con La
Torre, al cierre del primer día del proyecto. Veredicto: **F0 sano — verde para seguir**.*

## ✅ Infraestructura
- Contenedores `pacto-database` (healthy) / `pacto-worldserver` / `pacto-authserver`: **Up 3h**,
  restart `unless-stopped` los tres. `pacto-db-import` y `pacto-client-data-init` Exited(0) (one-shot, normal).
- Imágenes congeladas `:pacto` (snapshot inmutable — rebuilds de La Torre NO afectan a El Pacto).
- Volúmenes propios `pacto-database` / `pacto-client-data` (3.2GB copiados, verificados por el init).
- **Exposición de puertos correcta** (verificado con netstat):
  world 8086 y auth 3725 SOLO en <TAILSCALE_IP> (Tailscale); MySQL 3307 y SOAP 7879 SOLO
  en 127.0.0.1. **Nada escucha en 0.0.0.0.**
- Realm: `El Pacto @ <TAILSCALE_IP>:8086`, gamebuild 12340 ✓.
- Recursos con AMBOS servidores vivos: ~5.5/7.6GB RAM Docker, ~½ core por worldserver.
  ⚠️ Observación: la RAM del pacto-worldserver creció 1.56→1.97GB en sus primeras 3h
  (warmup de caches, esperable) — **vigilar tendencia mañana**.

## ✅ Cuentas y seguridad
- Una sola cuenta: `DASHBOARD` (gm 3, realm -1), creada por consola (regla SRP6 respetada).
- SOAP probado en caliente (reload ale por SOAP funciona).
- Sin datos sensibles fuera del repo; el repo es local y privado.

## ✅ Datos (schema `pacto`)
- 8 tablas, **todas utf8mb4** (verificado también byte a byte: `á` = C3A1, sin mojibake).
- Config: 13 claves. **Gates seguros**: `lineages_enabled=0`, `dice_enabled=0`,
  `worldclock_enabled=1` — solo el reloj está activo, como debe ser.
- Semillas: 7 linajes ✓ · 18 rasgos (12 activos, 6 `[VALIDAR F1]` apagados por fila) ✓ ·
  0 héroes (esperado) · **`pacto_dark_areas` VACÍA** → llenar en F1 caminando Duskwood
  (propuesta: comando `#zona` que te diga el area_id donde estás parado).

## ✅ Módulos Lua (reload en caliente durante la auditoría)
- `0_pacto_lib.lua`, `worldclock.lua`, `lineages.lua`: **3/3 "listo", 0 errores Lua**.
- **Hora del Mundo verificada punta a punta con datos reales**: nacimiento (04:04:42) →
  amanecer EXACTO a la hora 6 del mundo (04:42:12, +2250s) → anochecer EXACTO a la hora
  20 (06:09:43, +5250s = 14 horas del mundo). Crónica registrando con world_day/world_hour.

## ✅ Backups
- 2 dumps íntegros (gzip verificado; contenido revisado: 137 tablas y los INSERTs de
  `pacto` presentes — el segundo dump, post-linajes, es el vigente).
- Retención 14 días en el script. **CRON AÚN NO INSTALADO** (bloqueado al asistente por
  seguridad, correcto): Luis debe correr la línea que está en PREGUNTAS.md.

## ✅ Repo
- `.env` y `docker-compose.override.yml` con copia maestra en `config/` (verificado diff).
- `.gitignore` upstream cubre los archivos locales del clon (working tree limpio).
- 🔧 **CORREGIDO EN LA AUDITORÍA**: el clon traía el `CLAUDE.md` de La Torre dentro de
  `azerothcore-wotlk/` (habría confundido a futuras sesiones) → reemplazado por una nota
  que apunta al CLAUDE.md de El Pacto.

## ✅ La Torre (proyecto hermano — solo verificación)
- 0 errores Lua en 4h, contenedores sanos, 28 títulos intactos, cursor del poller
  consistente. Nadie jugó esta noche. **Nada de El Pacto la tocó.**

## 📋 Para mañana (en orden sugerido)
1. **Luis instala el cron** de backups (línea en PREGUNTAS.md).
2. **Primer login real** (criterio humano de F0): launcher → `account create` → entrar →
   `#hora` → confirmar el MOTD y el anuncio de amanecer/anochecer en vivo.
3. **Aprobar números de `design/linajes.md`** → encender `lineages_enabled=1` con un
   personaje de prueba y validar los 6 rasgos `[VALIDAR]`: morph worgen (729), esbirro
   del nigromante (el riesgo técnico real), aura de +curación, fear de no-muertos,
   clima/SetWeather, aura de exhausto.
4. Llenar `pacto_dark_areas` (comando `#zona` + paseo por Duskwood).
5. Revisar `design/test-del-pacto.md` (3 preguntas al final) → montar n8n si va.
6. Tras el primer reinicio del Mac que toque: verificar que los 3 contenedores se
   levantan solos en orden (unless-stopped reintenta; comprobar una vez).
7. Cuando arranque el diseño narrativo: capítulo 1 de Duskwood con `design/plantilla-capitulo.md`.
