# CAPÍTULO 1 — "La Última Noche del Cuervo Rojo"
*Inspirado en la estructura de Sinners (transformado: nombres, diálogos y mundo nuestros).
Diseñado como CADENA DE QUESTS interactiva (petición de Luis 2026-07-13): registro de
misiones real del cliente + escenas/decisiones del motor encima. BORRADOR para trabajar
juntos — los diálogos finales los escribimos entre los dos.*

## Sinopsis
Los hermanos Cuervo reabren una taberna clandestina en el granero de Addle's Stead —
la hermana bastarda del Cuervo Escarlata de Darkshire. Contratan al grupo como seguridad
para la noche de apertura. La música del Bardo se oirá más lejos de lo que nadie quiere.
Lo que toca la puerta al anochecer no puede entrar... sin invitación.

## Ubicaciones (IDs verificados contra el cliente)
- **El Cuervo Rojo** = granero de **Addle's Stead (área 536)**, suroeste de Duskwood — aislado, indefendible a medias, perfecto.
- Darkshire (42): tablón de anuncios + alguacil (breadcrumb y epílogo).
- Camino del suministro: Darkshire → Addle's Stead (escolta de la carreta).
- Refugios oscuros cercanos ya sembrados en `pacto_dark_areas` (Vul'Gol 93 al este).

---

## CADENA PRINCIPAL (quests reales, IDs ≥900001)

### Q1 — «Se buscan manos (y espadas)» — el gancho
- **Da**: tablón de anuncios de Darkshire (GO custom) o el alguacil. **Entrega**: Ferro Cuervo, en Addle's Stead.
- **Objetivo rastreable**: hablar con Ferro Cuervo (talk-to).
- Ferro presenta el trabajo con su hermano Marlo discutiendo de fondo (banter tipo Rultek/Evelgreen). El grupo ve el granero de DÍA — el vampiro del grupo ya está sufriendo 😈.

### Q2 — «Preparar la casa» — preparación con decisiones
- **Da/entrega**: Ferro Cuervo. **Objetivos**: 3 tareas rastreables:
  1. Escoltar la carreta de suministros desde Darkshire (evento de escolta clásico, 1 emboscada suave de práctica).
  2. Colocar 4 barriles/tablones (usar GO en 4 puntos del granero — objetivo "usar objeto").
  3. Hablar con la cocinera Abuela Zeta (talk-to; ella suelta el PRIMER presagio gratis al Vidente).
- **Decisiones embebidas (gossip en Ferro, opcionales — escriben flags)**:
  · ¿Reforzar las puertas? (−oro del grupo, +tiempo de resistencia en E5)
  · ¿Bendecir el umbral? (el Penitente/Tocado lo hace gratis; sin él cuesta reputación)
  · ¿Avisar al alguacil? (llega ayuda al amanecer en el asedio… pero el Cuervo Rojo queda fichado — consecuencia en cap. 2)
- **Recompensa**: oro + acceso a la fiesta + "Llave del granero" (item con historia).

### Q3 — «La prueba de sonido» — la quest del Bardo (grupal)
- **Da**: Marlo Cuervo. **Objetivo**: que el Bardo toque al atardecer (usar su `#cancion`
  dentro del granero cuando la Hora del Mundo marque 18:00 → script credit para TODO el grupo presente).
- **AQUÍ SUENA LA PRIMERA CANCIÓN NUESTRA** (MP3 del parche): la fiesta arranca de verdad
  — NPCs aldeanos bailando (waypoints+emotes), luces, la escena más viva del capítulo.
- Al completarse: la música "se corta" (fade + sonido de viento) → trigger de E3. El
  Vidente recibe susurro automático: *"Se oyó demasiado lejos."*

### Q4 — «El convite» — la decisión central (sin objetivo de matar)
- **Trigger**: anochecer (Hora del Mundo 20:00) tras Q3. Tres viajeros "amables" tocan
  la puerta del granero (spawn + knock sound + narración en pantalla).
- **Objetivo**: "Decide el destino del Cuervo Rojo" — se completa al elegir en el menú
  de gossip de la puerta (GO custom):
  · **"Que pasen — la casa invita"** → flag `invitados=1` → rama Q5b
  · **"La puerta se queda cerrada"** → flag `invitados=0` → rama Q5a
  · **"Que el Vidente los mire primero"** → `#escrutar` revela lo que son → vuelve al menú con la opción extra "Échalos Y atranca todo" (+preparación)
- Los tres viajeros CONVERSAN antes de la decisión (gossip individual): cada uno miente
  distinto — material para `#escrutar`/`#olfatear`. La socarronería del líder se escribe con Luis.

### ⭐ ESTRUCTURA ELEGIDA DE LA NOCHE (2026-07-13): el ritmo alternado
*Los amigos YA dominan asedios de oleadas (La Torre); la diversión nueva es la paranoia.
Pase lo que pase en la puerta hay presión AFUERA y veneno ADENTRO (Milo, el mozo nuevo,
llegó esa mañana... ya mordido).*
- **OLEADA → CALMA → OLEADA**: combate 5-8 min, calma 5 min (investigar aldeanos,
  acusar, el ritual del Penitente, el Anfitrión conversando desde la oscuridad), escalada.
- **Oleadas ancladas a las horas del mundo** (22:00, 00:00, 02:00, 04:00 + final), con
  anuncio de cada hora como beat: "03:00 — el fuego se está apagando." La noche completa
  = ~62 min reales con el reloj actual. `#hora` es la barra de tensión de todos.
- La decisión del convite cambia el SABOR, no la cantidad: puerta cerrada = oleadas más
  duras, menos conversos; invitados = oleadas suaves, conversión acelerada adentro.
- **Regla anti-frustración**: caer esa noche = "malherido" 30s y la Abuela Zeta te
  levanta (cicatriz + deuda con el Sepulturero después). Muerte real solo en wipe de
  los 5 (derrota del capítulo — final válido). NADIE deja de jugar la noche.
- Evitar: maratón de 25+ oleadas (5 gordas > 25 flacas) y deducción sin combate.

### Q5a — «Hasta el amanecer» (rama: puerta cerrada — asedio desde afuera)
- **Objetivos rastreables**: "Sobrevive hasta el amanecer" (script credit cuando la Hora
  del Mundo marque 6:00 — la quest se completa SOLA al amanecer si sigues vivo) +
  contador "Asaltantes rechazados: X/25" (kill credit por oleada).
- Oleadas nocturnas por pulso (patrón asedio, probado en producción): presión creciente,
  minijefe a mitad de noche (la conversa del líder mientras pelean — SendUnitYell).
- **La ventana rota** (evento a mitad): un NPC aldeano ES arrastrado afuera si nadie lo
  protege (objetivo opcional oculto) → si se lo llevan, VUELVE convertido en la última oleada.
- El amanecer REAL del `#hora` es la victoria: los que queden afuera arden huyendo (visual).

### Q5b — «El infierno adentro» (rama: los invitaste)
- Sin oleadas: **deducción + caos en interiores**. Los tres se dispersan entre los NPCs de
  la fiesta y empiezan a convertir en silencio (cada N min del mundo, un aldeano cambia de flag).
- **Objetivos**: "Descubre a los conversos" (usar `#escrutar`/`#olfatear` sobre NPCs — cada
  acierto = credit; acusar MAL: el inocente huye a la noche y vuelve convertido) +
  "Derriba al Anfitrión" (el líder solo se vuelve atacable cuando sus conversos caen).
- Más corto pero más letal que Q5a — invitar tenía que doler.

### Q6 — «Lo que dejó la noche» — epílogo
- **Da**: quien sobreviva de los hermanos Cuervo. **Objetivos**: enterrar a los caídos
  (usar GO tumbas — cada una con nombre del NPC muerto ESA noche), reportar al alguacil.
- **Recompensas**: HITO DE CAPÍTULO (nivel del grupo sube con anuncio) + 1 item con
  historia por cabeza (nombrados según lo que CADA UNO hizo — el que protegió la ventana
  recibe distinto que el que acusó mal) + la crónica escribe el resumen.
- El mundo queda cambiado para el cap. 2 (phasing entre sesiones): el Cuervo Rojo
  reabierto/quemado/“bajo nueva administración” según flags.

## QUESTS PERSONALES (susurradas, invisibles para el resto)
- **«La Oferta»** (solo el linaje vampiro o Pactado): durante el asedio, el Anfitrión le
  susurra una propuesta. Quest oculta con DOS cierres (aceptar algo pequeño / rechazar) —
  ninguno rompe el grupo, ambos tienen eco en el cap. 2. Su secreto del test puede aparecer aquí.
- **«El olor conocido»** (Cazador de Brujas): reconoce el "modus" de los viajeros —
  mini-investigación paralela (3 pistas por el granero) que si completa ANTES del convite,
  desbloquea la opción de gossip "Sé lo que son" (ventaja en ambas ramas).
- **«Los susurros no mienten»** (Vidente): su precio se vuelve quest — 3 susurros del don
  durante la noche; interpretar el correcto evita la ventana rota.

## LOS ALDEANOS DEL CUERVO ROJO (y sí — algunos NO amanecen humanos)
*Regla de diseño: solo duele perder a quien conociste. Por eso Q2/Q3 obligan a convivir
con ellos ANTES de la noche: cada aldeano tiene nombre, oficio y 1-2 líneas de gossip
con personalidad durante la fiesta.*

**Roster de la fiesta (borrador — 10 con nombre, pool 900120+):** la Abuela Zeta
(cocinera, sabe más de lo que dice), Tomasín (el borracho alegre que invita rondas que
no puede pagar), los mellizos Odara y Bruno (bailan toda la noche, nunca separados),
Renata (la viuda que vino "solo a mirar"), el Viejo Copo (cuenta la misma historia tres
veces), Lupe y Chano (pareja que discute y se reconcilia por horas), Milo (el mozo
nuevo, primer día), y Salomón (el prestamista que TODOS saludan de mala gana).

**Vectores de conversión (cómo se pierden):**
1. **Q5b (los invitaste)**: cada N min del mundo, un aldeano al azar es convertido EN
   SILENCIO — sigue bailando, con el gossip sutilmente mal ("Tomasín ya no arrastra las
   palabras..."). Detectarlo: `#escrutar` / `#olfatear` / pura atención al detalle.
2. **Q5a (la ventana rota)**: a mitad del asedio arrastran a un aldeano si nadie cubre
   ese flanco (objetivo opcional oculto) → vuelve convertido en la última oleada,
   LLAMANDO POR SU NOMBRE a quien más le habló en la fiesta (la crónica sabe quién fue).
3. **La acusación falsa**: acusar a un inocente en la prueba del ajo → huye a la noche
   → convertido. La paranoia también cobra.

**La ventana de salvación (el momento del Penitente):** un mordido RECIENTE (menos de
una hora del mundo) aún puede salvarse — ritual del Penitente (`#cargar` sostenido +
un costo real). Después de esa hora, ya no hay a quién salvar. Decisión bajo presión
en medio del caos: ¿gastas al healer en el aldeano o lo guardas para el grupo?

**Cómo se ve un converso:** ojos rojos (aura visual), el gossip cambia a frases nuevas
(escritas por converso — el Tomasín converso sigue siendo gracioso, y eso es lo peor),
y NO ataca hasta ser descubierto o hasta que el Anfitrión lo ordene.

**La permanencia (esto es El Pacto):** los convertidos no mueren esa noche a menos que
el grupo los mate. Los que escapan quedan REGISTRADOS en la crónica y pasan al mundo
del capítulo 2 como spawns nocturnos de Duskwood, con su nombre y sus frases — la
Abuela Zeta convertida te reconoce en el camino semanas después. En el epílogo (Q6),
las tumbas son solo de los MUERTOS; los convertidos tienen **tumba vacía con su nombre**
— cada tumba vacía es un gancho del capítulo siguiente.

## Música (slots para tus MP3)
1. Tema de la fiesta (Q3 — el momento juke joint) · 2. Tema del Anfitrión (Q4, cuando
habla) · 3. Tema del asedio (Q5, loop tenso) · 4. Amanecer (victoria). Carpeta `musica/`
del repo → el empaquetador los mete al parche con sus SoundEntries.

## Implementación técnica (todo data-driven)
- `quest_template` + relaciones en NPCs custom (IDs ≥900001): Ferro (900101), Marlo
  (900102), Abuela Zeta (900103), el Anfitrión (900110) y sus 2 acompañantes, aldeanos
  de la fiesta (pool 900120+). **Creatures nuevas = reinicio del server ANTES de la
  sesión** (regla conocida — todo el capítulo se instala entre sesiones).
- Objetivos "script credit" (amanecer, canción, decisiones) = `KilledMonsterCredit` con
  entries fantasma otorgados por el motor de escenas — técnica estándar, cero C++.
- Las escenas del motor (`pacto_events`) llevan narración/música/clima/spawns SOBRE las
  quests; las quests llevan el rastreo visible. Dos capas, cada una en lo suyo.
- El asedio de Q5a reusa el patrón de oleadas ya probado en producción (waves de La Torre).

## Para trabajar CON Luis antes de construir
1. Nombres/diálogos de los hermanos, la Abuela Zeta y el Anfitrión (te propongo borradores y los tuneamos).
2. La playlist (4 slots).
3. ¿La rama Q5b (invitarlos) puede acabar en derrota total del grupo? (mi voto: sí — que
   invitar mal PUEDA costar el Cuervo Rojo entero; la derrota también es capítulo).
4. Dificultad del asedio: número de oleadas y si la ayuda del alguacil (flag de Q2) debe
   sentirse decisiva o solo cosmética.
