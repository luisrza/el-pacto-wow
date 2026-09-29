# Auditoría de poderes y animaciones — El Pacto (2026-07-13)
*Lupa cuádruple sobre los 7 linajes y las 5 clases: ¿es divertido? ¿se ve? ¿funciona?
¿juega bien EN GRUPO? Veredicto general: **diseño sano, con 3 hallazgos críticos y una
lista de procs invisibles que necesitan visual.***

---

## 🔴 HALLAZGOS CRÍTICOS

### C1 — El ping-pong de transferencias (bug esperando a nacer)
`#jurar` del Baluarte y `#cargar` del Penitente son ambos "el daño de X pasa a Y".
Si el Baluarte jura al Penitente y el Penitente carga al Baluarte → **bucle infinito de
transferencias** (cada uno re-transfiere el daño del otro).
**Fix de regla (obligatorio en classes.lua):** el daño recibido VÍA transferencia jamás
se re-transfiere (flag "daño de pacto" en el motor). Además: un personaje solo puede ser
extremo de UNA transferencia a la vez (jurar a alguien rompe tu carga previa, con aviso).

### C2 — Tres poderes brillaban igual (misma aura 8599 para todo)
`vampiro_oscuridad`, `pacto_golpe` (gracia prestada) y `gigante_furia` usaban la MISMA
aura (Enrage 8599) — nunca coinciden en un personaje (un linaje por cabeza), pero en el
grupo se veían idénticos: tres identidades, un solo brillo rojo. Y peor: si una canción
del Bardo usara esa aura, el pulso del vampiro se la QUITARÍA al salir de la oscuridad.
**Fix APLICADO**: knob de aura propio por concepto (`vamp_dark_spell`,
`pacto_grace_spell`, `gigante_fury_spell`) — hoy comparten valor por defecto, y en la
sesión de casting de animaciones se elige un visual distinto para cada uno.
**Regla nueva**: ningún aura se comparte entre conceptos de linaje/clase distintos.

### C3 — La Desconfianza del Cazador anula al Bardo (anti-sinergia de grupo)
El precio del Cazador ("buffs ajenos duran la mitad") choca de frente con la clase cuyo
kit entero es buffear al grupo. Con las canciones re-aplicadas por pulso cada 10s el
precio queda además MUDO (no se nota) — lo peor de ambos mundos: molesta en papel, no
se siente en juego. **Opciones para Luis:**
- (a) *El manotazo*: cuando recibe un buff ajeno, 20% de rechazarlo con emote público
  ("¡Guárdate tus bendiciones!") — visible, gracioso, molesta lo justo.
- (b) *Voto de autosuficiencia*: pociones y consumibles no le hacen efecto (solo confía
  en lo que caza) — limpio, no toca al Bardo.
- (c) Dejarlo como está asumiendo que solo muerde buffs largos (bendiciones), no canciones.
**Recomendación: (a)** — es la más teatral y la única que se VE.

---

## 🟡 PROCS INVISIBLES (funcionan pero no se ven — lista para la sesión de casting)
| Poder | Hoy | Fix visual propuesto |
|---|---|---|
| Sed del vampiro (cura al matar) | invisible | destello rojo de robo de vida (visual de Drain Life instantáneo) |
| Eco del trueno (tormenta) | daño Lua + sonido | castear Chain Lightning REAL triggered (el rayo se ve encadenarse; el daño se tunea en el spell o se sustituye) |
| Cosecha del nigromante | invisible | visual verde sobre el esbirro al curarse |
| Dolor compartido (Penitente) | invisible | aura tenue que crece con su herida (glow) |
| Eco del crítico (Bardo) | invisible | nota musical/destello al ganar carga + contador en `#kit` |
| Deshonra (Baluarte que huye) | solo texto | aura de debuff VISIBLE + emote público (la vergüenza se ve) |
| Exhausto (gigante) | [VALIDAR] | aura dazed con su animación de agotamiento |

## ✅ LO QUE YA ESTÁ BIEN SERVIDO (visual + diversión)
Festín de sangre (animación nativa de devorar + emote) · Luna llena (morph worgen — el
momento más espectacular del juego; nota: el morph TAPA el atuendo esa noche, y está
bien: la bestia no viste tier) · `#sello` (Marca del Cazador: la flecha roja icónica) ·
`#vision` (rayo púrpura de Mind Vision) · `#muro` (piel de piedra) · `#jurar`
(arrodillarse + haz) · `#aqui` (rugido) · canciones del Bardo (aura visible por canción)
· el sol quemando al vampiro (mensaje + vida bajando: se SIENTE).

## 🤝 AUDITORÍA DE SINERGIA (el grupo de 5 como máquina)
**Roles**: tanque (Baluarte) ✓ · healer (Penitente) ✓ · daño único (Cazador) ✓ · daño
en área + control (Vidente: Velo Helado) ✓ · amplificador (Bardo) ✓. Trinidad completa
más dos multiplicadores — composición sana.

**Sinergias emergentes BUENAS (promoverlas, no caparlas):**
- Penitente `#flagelo` (se hiere para curar) + linaje **Sangre de Gigante** (más fuerte
  herido) = el healer berserker. Combo legal y glorioso.
- Baluarte `#jurar` + Penitente "Dolor compartido" = el tanque transfiere, el healer
  se hiere cargando, sus curas crecen. Círculo virtuoso CON el fix C1 (sin loops).
- Bardo `#inspirar` + `#flagelo` del Penitente potenciado = la gran salvada del grupo.
- Cazador `#sello` + Canción de Valor = ejecución de amenazas prioritarias.
- Vidente ve la emboscada → el Baluarte se planta ANTES (`#muro`) → la escena se
  gira. La sinergia exploración→combate es el sello de la casa.

**Fricciones detectadas (además de C3):**
- Esbirro del nigromante vs `#aqui` del Baluarte: el esqueleto debe RESPETAR el tanque
  (su IA escolta no debe robar aggro — regla: ataca al objetivo del dueño, nunca taunt).
- `#inspirar` definido como "próxima habilidad": acotar a habilidades de COMBATE (que
  no se gaste en un `#hora`). Regla: solo consume con hechizos/comandos de efecto.
- Vampiro de día en viajes de grupo: knob `vamp_sun_pct` ya existe; si en juego real
  frena al grupo, se baja a 2% sin tocar código.

## 🎬 REGLA DE ORO DE ANIMACIÓN (adoptada)
**Todo poder debe ser VISIBLE por un tercero**: si un amigo no puede señalar la pantalla
y decir "¡mira, eso fue su poder!", le falta capa visual. Es el criterio de aceptación
de la sesión de casting — ningún poder se da por terminado sin su animación.

## Cambios aplicados en esta auditoría
1. Knobs de aura separados por concepto + lineages.lua actualizado (C2).
2. Reglas C1 (no re-transferir) y del esbirro anotadas como requisitos de classes.lua.
3. Esta lista de visuales pendientes queda como checklist de la sesión de casting.
