# EL PACTO
### Una aventura de rol con universo persistente construida sobre World of Warcraft

**Repositorio:** https://github.com/luisrza/el-pacto-wow

---

## ¿Qué es?

**El Pacto** convierte un servidor privado de World of Warcraft 3.3.5a en una experiencia
estilo *Dungeons & Dragons*: un grupo cerrado de jugadores vive una campaña por capítulos
en un mundo que **recuerda todo lo que hacen** — con la particularidad de que el personaje
no se elige de un menú: **se descubre**.

Al entrar por primera vez, el jugador encuentra al **Escribano del Pacto**, un NPC que le
hace seis preguntas dentro del juego. De sus respuestas **emerge su linaje** — vampiro,
licántropo, nigromante, pactado, tocado por la luz, hijo de la tormenta o sangre de
gigante — cada uno con una ventaja jugable y un precio real. Después elige su clase
(Baluarte, Penitente, Bardo, Cazador de Brujas o Vidente), escribe su historia y confiesa
un secreto que solo el sistema conocerá... y que la campaña usará.

> El vampiro roba vida al matar y se fortalece en la oscuridad, pero el sol le quema el
> 3% de la vida cada 30 segundos. Todo pacto tiene precio.

## Las ideas centrales

**🕐 La Hora del Mundo** — El servidor tiene su propio reloj acelerado: un día completo
del mundo transcurre cada 2.5 horas reales, con amaneceres y anocheceres anunciados y un
ciclo lunar de 28 días. Todos los sistemas leen esta hora: los linajes nocturnos despiertan,
el niño farolero enciende los faroles del pueblo, y en el primer capítulo de campaña la
condición de victoria de un asedio es literalmente **sobrevivir hasta que amanezca**.

**🎭 Clases de 9 habilidades** — Los personajes no juegan las clases de WoW con sus 40
botones: cada Clase del Pacto es un kit corto y memorable (hechizos reales + comandos con
animación como `#jurar`, `#aqui` o `#muro` + pasivas + una desventaja que la define). El
Baluarte que jura proteger a un aliado absorbe su castigo... y queda deshonrado si huye.

**🧠 Un mundo con memoria** — Todo evento notable se escribe en una crónica persistente.
Los NPCs saludan a los jugadores por sus hazañas, un borracho del pueblo balbucea hechos
reales del historial del servidor, y las decisiones de cada capítulo (¿invitaron a pasar
a los desconocidos? ¿a quién no salvaron?) bifurcan los capítulos siguientes. Los aldeanos
convertidos en la noche del asedio reaparecen semanas después, con su nombre, en el bosque.

**🎬 Campañas como quests nativas** — Los capítulos se juegan con el sistema de misiones
del propio cliente (signos de exclamación, objetivos rastreables) mientras un motor de
escenas dispara narración en pantalla, música propia, clima y encuentros según triggers:
llegar a un lugar, la hora del mundo, una decisión tomada en un menú.

## Lo técnico (resumen)

| Capa | Tecnología |
|---|---|
| Servidor | AzerothCore (C++ open source) en Docker sobre Apple Silicon, **sin modificar** |
| Lógica de juego | **9 módulos Lua** propios (mod-ale) — autocontenidos, con interruptor por módulo |
| Contenido y balance | 100% **data-driven** en MySQL (schema propio `pacto`): añadir contenido = INSERT |
| Cliente | WoW 3.3.5a sin tocar + **parche MPQ opcional** generado por herramientas propias |
| Herramientas | Editor de `Spell.dbc` (formato binario WDBC) y empaquetador MPQ en **Python** — renombran hechizos y reescriben tooltips en español con las macros nativas del cliente |
| Distribución | Launcher de un clic que alterna entre servidores, instala/quita el parche y limpia caché |

**Principios**: cero C++ custom, solo recursos que ya existen en el cliente, todo módulo
falla en silencio sin tumbar a los demás, y ningún número de balance vive en el código.

## Estado actual

✅ Servidor en producción (conviviendo con un segundo servidor en la misma máquina) ·
✅ Hora del Mundo verificada punta a punta · ✅ Motor de linajes y Festín de Sangre ·
✅ Escribano (creación in-game completa) · ✅ Primera clase jugable (Baluarte) ·
✅ Atuendos icónicos por transmog server-side · ✅ Darkshire poblado con NPCs con voz ·
✅ Primera quest de campaña · ✅ Toolchain MPQ/DBC funcionando ·
🔄 En curso: las otras 4 clases, el motor de escenas y el capítulo 1 completo
(*«La Última Noche del Cuervo Rojo»* — un asedio nocturno con deducción social, inspirado
en la estructura narrativa del cine de terror).

---

*Proyecto personal sin fines comerciales, para un grupo cerrado de amigos. No afiliado a
Blizzard Entertainment; el repositorio no distribuye ningún recurso del juego.*
