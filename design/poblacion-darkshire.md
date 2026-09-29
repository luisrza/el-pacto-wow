# La población de Darkshire — censo de El Pacto (propuesta 2026-07-13)
*Regla: cada NPC = oficio (función mecánica) + personalidad + algo que esconde.
Entries ≥900200. Los gossips/frases son data-driven (patrón de memoria probado);
las "reacciones por clase/linaje" leen pacto_heroes — los NPCs saben QUÉ eres.*

## El corazón del pueblo

**1. Alguacil Bran Cordero** — *la ley cansada*
Función: tablón de avisos (da las quests de capítulo), la ley (reputación).
Personalidad: honesto, agotado, odia las sorpresas. **Reacciona por clase**: al Cazador
de Brujas lo trata de "matón con licencia"; al Baluarte lo respeta de inmediato.
Esconde: sabe que en el pueblo desaparece gente desde ANTES del capítulo 1... y lo calla.

**2. Coralia Cuervo, posadera del Cuervo Escarlata** — *la madre*
Función: posada (descanso, hub social oficial del pueblo).
Personalidad: matriarca de hierro, cocina legendaria. **ES LA MADRE de Ferro y Marlo** —
los del granero clandestino. No se hablan. El capítulo 1 es TAMBIÉN su drama familiar:
según el final, se reconcilia con sus hijos... o entierra a uno.

**3. Gaspar "El Mudo", herrero** — *el silencio que forja*
Función: reparaciones y mejoras de equipo (patrón Rultek: mejora armas con historia).
Personalidad: no dice UNA palabra — todo por emotes (asiente, gruñe, señala). El pueblo
entero le entiende. Esconde: su silencio es un voto; el Vidente puede leer POR QUÉ (gancho
de rango 2 del Vidente — lo que Gaspar vio en el bosque).

**4. Doña Ipe (Ipecacuana), boticaria** — *la lengua del pueblo*
Función: pociones/consumibles + **motor de rumores** (sus chismes = ganchos de quests
secundarias y recaps con sabor). Personalidad: chismosa suprema, precios "de amiga".
Rivalidad de oficio con el Penitente ("esos rezos no pagan renta, corazón").
Esconde: su mejor poción lleva un ingrediente que solo crece en Raven Hill... de noche.

**5. Salomón, el prestamista** — *el otro pacto*
Función: **préstamos de oro REALES** (mecánica: te presta ya, y la deuda la cobra el
capítulo — el eco mundano del Sepulturero). Personalidad: amabilísimo, jamás amenaza;
no le hace falta. Esconde: su libro de deudas tiene nombres que llevan décadas muertos.

## La calle (el pueblo que se siente VIVO — barato y potente)

**6. Timo "Farolillo"** — *el niño de los faroles*
Función: **al anochecer del reloj del mundo camina el pueblo encendiendo faroles**, al
amanecer los apaga (pulso + waypoints — el ciclo día/noche hecho carne). Vende chismes
a 1 plata. Esconde: nunca se le ve dormir. Nadie sabe dónde vive.

**7. "Tres Copas", el borracho profeta** — *la crónica con aliento a vino*
Función: balbucea **hechos REALES de la crónica del servidor** ("...y entonces el
grandote juró en el granero... yo lo VI..."). La memoria del mundo hecha comedia — y a
veces la pista que nadie pidió. Técnica: query a pacto_chronicle + say aleatorio.

**8. Hosk y Bosk, los guardias gemelos** — *el dúo cómico*
Función: patrulla nocturna (banter constante, patrón Rultek/Evelgreen). **Mecánica de
reputación**: si el grupo hace travesuras, los gemelos los SIGUEN por el pueblo
(vigilancia visible y vergonzosa). Esconden: uno de los dos le tiene pavor a la noche.

**9. Brunilda, la carnicera** — *brazos de herrero, corazón de oro*
Función: comida + **compra trofeos de caza** del bosque (economía de cacería entre
capítulos). Personalidad: coqueta con todo el grupo por igual, risa de trueno.
Esconde: fue mercenaria; su tajo de carnicera está... demasiado bien afilado.

## Los mayores (ganchos de rango y linaje)

**10. Padre Anselmo, el cura** — *la fe práctica*
Función: capilla (bendiciones — el flag del umbral de Q2), tensión teológica con el
Penitente (métodos opuestos, mismo bando). Gancho: rango 2 del Penitente pasa por él.
Esconde: dejó de tocar las campanas de medianoche hace un año. Nadie pregunta por qué.

**11. Viejo Osvaldo, cazador de brujas retirado** — *el mentor*
Función: gancho del rango 2 del Cazador; identifica reliquias de monstruo.
Personalidad: medio ciego, cuenta la misma cacería de tres formas distintas.
Esconde: SABE qué es el Anfitrión del capítulo 1. No lo dirá sobrio. (Tres Copas es
su único amigo — la escena de emborracharlo se escribe sola.)

**12. Doña Prudencia, la archivista** — *el horario es sagrado*
Función: biblioteca minúscula — los libros de linajes y manuales de clase (ganchos de
rango) viven ahí. **Solo abre de DÍA del mundo** (mecánica de reloj: el conocimiento
también duerme). Personalidad: estricta terminal; multa por libro doblado.
Esconde: la sección que mantiene bajo llave no está en el catálogo.

**13. Mortimer, el Sepulturero** (ya definido en M7, vive en Raven Hill)
**Visita el pueblo los días de mercado** (cada 7 días del mundo — spawn por calendario).
Los días que aparece, el pueblo entero baja la voz. Función extra: en el mercado vende
"segundas manos" — objetos de sus clientes... con historia.

## Mecánicas de pueblo que este censo habilita
- **Rumores** (Ipe + Timo): sistema de ganchos — cada capítulo siembra 2-3 rumores previos.
- **Reputación visible** (gemelos + alguacil): el pueblo REACCIONA a la conducta.
- **Reloj encarnado** (Timo + Prudencia + mercado de Mortimer): la Hora del Mundo se VE
  en la calle, no solo en el `#hora`.
- **Crónica encarnada** (Tres Copas): el mundo recuerda... y lo cuenta borracho.
- **Ganchos de rango por clase** (Gaspar/Anselmo/Osvaldo/Prudencia): subir de rango no es
  un botón, es una RELACIÓN con alguien del pueblo.
- **Economía con cara** (Salomón/Brunilda/Ipe): prestar, vender trofeos, comprar pociones
  — siempre a una persona, nunca a un mostrador.

## Técnica (nada nuevo bajo el sol)
Spawns SQL + reinicio (entre sesiones) · gossip data-driven con memoria (patrón títulos,
probado) · reacciones por clase/linaje = query a pacto_heroes · Timo/mercado/Prudencia =
pulsos sobre la Hora del Mundo (en vivo) · Tres Copas = SELECT a la crónica · banter =
patrón Evelgreen. Costo estimado: los 13 con frases v1 = 2-3 tardes, y el pueblo respira.

## Para Luis
- ¿Nombres y personalidades te gustan? Tacha/renombra a gusto (son borradores con cariño).
- ¿Alguno de tus amigos merece su NPC guiño (como Nickpala en La Torre)?
- Orden de construcción propuesto: los 5 del corazón primero (capítulo 1 los necesita),
  la calle después, los mayores al llegar los rangos.
