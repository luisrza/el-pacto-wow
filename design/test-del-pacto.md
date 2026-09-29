# El Test del Pacto — borrador para revisar con Luis
*M2/F1. El formulario que firma tu pacto: 8 preguntas + trasfondo + secreto.
Cada respuesta suma puntos a linajes (v/l/n/p/t/h/g) y modela tus atributos D&D.*

## Estructura
- **P1-P6**: personalidad → puntúan linaje (una opción por linaje sería un menú de 7 —
  demasiado; cada pregunta ofrece 4-5 opciones que puntúan a linajes distintos).
- **P7**: el DESEO (qué buscas en El Pacto) y **P8**: el MIEDO — puntúan linaje Y fijan
  atributos (+2 al atributo asociado).
- **Texto libre 1**: tu TRASFONDO (Medivh… no, el DM del Pacto te lo susurrará de vuelta).
- **Texto libre 2**: tu SECRETO (nadie más lo verá; el capítulo lo usará en tu contra o a tu favor).

Linajes: **v**ampiro · **l**icántropo · **n**igromante · **p**actado · **t**ocado ·
**h**ijo de la tormenta · **g**igante

## Preguntas (borrador)

**P1 — Es medianoche en el bosque y algo te observa. ¿Qué haces?**
- a) Le devuelvo la mirada. Que sepa que también lo veo. (v)
- b) Me quedo quieto y huelo el aire. El bosque me habla. (l)
- c) Susurro a mis muertos que lo rodeen. (n)
- d) Enciendo una luz. La oscuridad no manda aquí. (t)
- e) Que ataque. Necesito calentar. (g)

**P2 — Te ofrecen poder a cambio de algo que no nombran. ¿Firmas?**
- a) Firmo. Ya negociaré la letra pequeña. (p)
- b) Firmo con sangre ajena. (n)
- c) No firmo nada: lo que soy me lo dio la luna sin pedir permiso. (l)
- d) Rechazo. Mi poder viene de algo más limpio. (t)
- e) ¿Poder? Yo YA soy la tormenta. (h)

**P3 — Tu grupo duerme. Tú haces guardia. ¿Qué piensas?**
- a) En lo que haría si uno de ellos no despertara. (v)
- b) En el cielo: huele a lluvia, y la lluvia me pone... eléctrico. (h)
- c) En la deuda que aún no me cobran. (p)
- d) En nada. Golpeo mejor cuando no pienso. (g)
- e) En que dormidos parecen tan frágiles... yo los cuidaré. (t)

**P4 — ¿Cuál herida te marcó?**
- a) La mordida. (l)  b) La sed. (v)  c) La tumba de quien no debí perder. (n)
- d) El contrato. (p)  e) El rayo que me partió y me dejó vivo. (h)

**P5 — El pueblo te cierra las puertas. ¿Por qué?**
- a) Vieron lo que hago con los muertos. (n)  b) Vieron mis ojos de noche. (l)
- c) Alguien contó a quién le debo. (p)  d) Les da vergüenza necesitarme. (t)
- e) Rompí la puerta la última vez. (g)

**P6 — Elige la hora del día:**
- a) Medianoche. (v)  b) Luna llena. (l)  c) El velatorio. (n)
- d) El amanecer. (t)  e) La tormenta, sea la hora que sea. (h)

**P7 — ¿Qué buscas en El Pacto?** *(fija atributo +2)*
- a) Poder que nadie me pueda quitar. (p / +CAR)
- b) Volverme imposible de matar. (g / +CON)
- c) Respuestas que los vivos no tienen. (n / +INT)
- d) Proteger a los míos de lo que viene. (t / +SAB)
- e) La cacería perfecta. (l / +FUE)
- f) Sentirlo TODO más fuerte. (h / +DES)

**P8 — ¿Qué te da más miedo?** *(fija atributo +2, puntúa al linaje OPUESTO — el miedo delata)*
- a) El espejo. (v / +CAR)  b) Perder el control. (l / +FUE)  c) El silencio de los muertos. (n / +INT)
- d) La oscuridad total. (t / +SAB)  e) El día que llegue la factura. (p / +CAR)
- f) La calma. (h / +DES)  g) Ser débil. (g / +CON)

**Trasfondo (libre)**: ¿quién eras antes de firmar? 2-4 frases.
**Secreto (libre)**: algo que tu personaje no le ha contado a nadie. 1-2 frases.

## Puntuación
- Mayor puntaje gana. Empate: manda P8 (el miedo no miente — regla heredada del test de
  La Torre, que funcionó bien).
- Atributos: base 10 en todo; +2 por P7, +2 por P8, +1 al atributo de ventaja del linaje
  ganador (`pacto_lineages.ventaja_tiradas`).
- El trasfondo pasa por `pacto_keywords` (micro-rasgos por palabras clave, F1.5).

## Flujo n8n (adaptación del patrón ya probado)
Webhook → puntuar → INSERT `pacto_heroes` (linaje, atributos, secreto) → SOAP `account create`
(puerto **7879**, credencial dashboard del Pacto) → responder. Los rasgos los aplica el
módulo de linajes al primer login (no hace falta insertar poderes por guid: en El Pacto el
linaje vive en `pacto_heroes.linaje`, cero problema de personaje-aún-no-existe).

## Para Luis
- ¿Tono de las preguntas ok? (oscuro-juguetón)
- ¿P8 puntuando al linaje del miedo te convence, o mejor que el miedo reste?
- ¿Añadimos pregunta de "¿cómo conociste al grupo?" para amarrar la campaña? (recomendado)
