# Preguntas de diseño — El Pacto

## ✅ Respondidas (2026-07-12, Luis)
- **Nombre**: El Pacto.
- **Realms**: stack 100% separado + launcher **Windows** (.bat: realmlist + Cache).
- **Zona inicial**: Duskwood; hub Darkshire.
- **DM**: híbrido — campañas predefinidas con **triggers automáticos + override de Luis**
  (comandos in-game primero, panel web en F3-F4); la IA mueve el mundo entre sesiones;
  **la aventura se escribe ANTES entre Luis y Claude**.
- **Personaje**: clase WoW + **linaje como única capa extra** (linaje = mini-clase;
  las "Clases del Pacto" se fundieron en los linajes).
- **Linajes**: catálogo de **7, todos en F1** — Vampiro, Licántropo, Nigromante menor,
  Pactado, Tocado por la Luz, Hijo de la Tormenta, Sangre de Gigante.
- **Día/noche**: Hora del Mundo acelerada propia (≈1 día del Pacto / 2-3h reales).
- **Interiores/cuevas**: lista de area-ids curada por config (cero C++).
- **Muerte**: cicatrices narrativas SIN malus + resurrección cara con el **Sepulturero de
  Raven Hill** (oro creciente + a veces un "favor" que el capítulo cobra).
- **Progresión**: por hitos de capítulo.
- **La Torre**: lo desplegado allá se queda vivo allá.

## ⏳ Abiertas (F0 ya está EN VIVO — ver PLAN.md)
- **Cron de backups**: el clasificador de seguridad me bloqueó (bien) instalar el cron.
  El script ya está probado; instálalo tú con:
  `(crontab -l; echo '0 6 * * * /Users/brumbrum/Desktop/torre/tools/backup-pacto.sh >> /Users/brumbrum/Desktop/torre/backups/backup.log 2>&1') | crontab -`
- **Linajes**: aprobar los números de `design/linajes.md` (3 preguntas al final del doc).
- **Ritmo**: ¿sesiones programadas (una noche = un capítulo) con el mundo persistente
  entre medio? (asumo que sí por el flujo de capítulos pre-escritos)
- **Jugadores**: ¿los 8 de La Torre con personajes nuevos desde cero? (asumo que sí)
- **n8n**: levantar el contenedor al llegar a F1 (un comando docker en el Mac Mini).
- **Hardware**: ¿ambos servidores 24/7 o El Pacto solo en sesión? → lo deciden las
  mediciones de F0.
- **Kit de poderes por linaje**: al diseñar F1 te propongo los spells/números concretos
  de cada linaje (p.ej. cuánto roba el vampiro, cadencia del rayo) para que los apruebes
  antes de codificar.
- **Capítulo 1**: sesión de diseño narrativo Luis+Claude (escenas, villano, secretos de
  Duskwood, qué favor cobra el Sepulturero).
