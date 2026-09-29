# Las Clases del Pacto — MODELO v2 (decisión de Luis 2026-07-13)
*"Los personajes no tienen las clases base: solo 6-10 habilidades, para que no sea complicado."*

## El modelo
- **La Clase del Pacto ES la clase.** El personaje tiene una clase WoW de chasis (obligación
  del cliente) pero el motor la VACÍA: un hook al login/level quita todo hechizo fuera de la
  lista blanca. Abres tu libro y ves TUS 8 habilidades, nada más (ni grises: fuera).
- **Se elige en el test/creación** (sin clase base, la necesitas del día 1). Lo que se gana
  en capítulos son los RANGOS: mejoras de las habilidades + desbloqueo de la 7ª-10ª.
- **El linaje sigue aparte**: clase = lo que HACES, linaje = lo que ERES. Dos capas ligeras.
- Anatomía del kit: **3-4 hechizos reales** del chasis (con cadena de rangos — botón real
  con cooldown, animación y tooltip nativos) + **3 habilidades custom** (`#comandos` con
  macro de icono clásico + nombre nuestro, y animación portadora) + **2 pasivas** + **1 precio**.
- **Explicaciones** (3 capas): comando `#kit` (descripciones completas desde DB) + item
  **Grimorio** por clase (tooltip editable server-side = chuleta) + susurro al aprender.
- **Balance nuestro al 100%**: los encuentros de capítulo se tunean para kits de 8 — el
  autobalance ya está apagado y los encuentros los escribimos nosotros.

## Implementación (para que no sea problema)
Tablas `pacto_classes` + `pacto_class_abilities` (tipo hechizo_real|comando|pasiva|precio,
spell/rangos, descripción, rango de desbloqueo, animación) + UN motor genérico `classes.lua`
(lista blanca, enseñar kit, comandos, `#kit`). Añadir/tunear habilidad = INSERT/UPDATE.
Solo las custom llevan handler corto (patrón lineages.lua). ~1 tarde por clase con validación.

---

## 🛡️ EL BALUARTE — tanque *(chasis: guerrero)*
Variantes: del Alba / de Piedra
| # | Habilidad | Tipo | Qué hace |
|---|---|---|---|
| 1 | Golpe del Alba | hechizo real (rangos) | tu golpe de siempre (portador: golpe de guerrero) |
| 2 | Provocar | hechizo real | taunt de tanque, botón nativo |
| 3 | Bloqueo Alzado | hechizo real | bloqueo activo defensivo |
| 4 | `#jurar <aliado>` | comando | absorbes 25% del castigo del jurado *(se arrodilla + haz de luz)* [🧪] |
| 5 | `#aqui` | comando | provocación en área *(rugido + onda)* |
| 6 | `#muro` | comando | plantado = +armadura apilable *(piel de piedra visible)* |
| 7 | Atraer la tormenta | pasiva | amenaza multiplicada (rango 2) |
| 8 | **No puede huir** | precio | abandonar con juramento activo = deshonra + crónica |

## ⛓️ EL PENITENTE — healer *(chasis: sacerdote; entra por decisión del modelo v2 — sin clase base, el grupo necesita healer propio)*
Variantes: de la Luz / del Silencio
| # | Habilidad | Tipo | Qué hace |
|---|---|---|---|
| 1 | Plegaria Menor | hechizo real (rangos) | cura directa |
| 2 | Renuevo | hechizo real | cura periódica |
| 3 | Amparo | hechizo real | escudo absorbe-daño |
| 4 | `#cargar <aliado>` | comando | sus heridas pasan A TI (transferencia de vida) *(canaliza con cadenas de luz)* |
| 5 | `#flagelo` | comando | sacrificas tu vida por una cura enorme instantánea |
| 6 | Dolor compartido | pasiva | cuanto más herido estás TÚ, más curan tus plegarias |
| 7 | Última palabra | pasiva (rango 2) | si un aliado cae a 0 cerca de ti, 1 vez por combate lo sostiene en 1 de vida |
| 8 | **El dolor deja marca** | precio | el sufrimiento ajeno que cargas se escribe en tus cicatrices (cuentan doble en la crónica) |

## 🎵 EL BARDO — soporte *(chasis: sacerdote / pícaro en variante Canalla)*
| # | Habilidad | Tipo | Qué hace |
|---|---|---|---|
| 1 | Nota Aguda | hechizo real (rangos) | daño a distancia (portador: castigo) |
| 2 | `#cancion valor\|aliento\|sombras` | comando | aura de grupo rotativa, una a la vez *(vítores + aura visible)* |
| 3 | `#relato` | comando | narra el último hito de la crónica + micro-buff de moral |
| 4 | `#inspirar <aliado>` | comando | su próxima habilidad va POTENCIADA (+25% efecto) *(destello de luz)* |
| 5 | Eco del crítico | pasiva | críticos aliados cercanos = cargas de inspiración (tope 3) |
| 6 | Voz conocida | pasiva | mejores precios y frases propias de NPCs con memoria |
| 7 | Segunda estrofa | rango 2 | dos canciones activas a la vez |
| 8 | **Siempre en escena** | precio | emotes públicos constantes + los enemigos lo detectan de lejos |

## 🏹 EL CAZADOR DE BRUJAS — daño *(chasis: cazador)*
| # | Habilidad | Tipo | Qué hace |
|---|---|---|---|
| 1 | Saeta Bendita | hechizo real (rangos) | disparo principal |
| 2 | Disparo Certero | hechizo real | daño fuerte con casteo |
| 3 | `#olfatear` | comando | marca lanzadores cercanos en el mapa |
| 4 | `#sello <objetivo>` | comando | tu presa: +daño contra ella, −daño al resto *(Marca del Cazador: flecha roja)* |
| 5 | `#interrogar` | comando | sobre cadáver de caster: pista de la escena |
| 6 | Golpe silenciador | pasiva | % de silenciar casters al golpear [🧪] |
| 7 | Nariz para lo oculto | pasiva | detecta enemigos furtivos/ocultos a más distancia |
| 8 | **Desconfianza** | precio | los buffs ajenos le duran la mitad [🧪] |

## 👁️ EL VIDENTE — secretos *(chasis: mago)*
Variantes: Oráculo / Médium (su `#vision` funciona sobre cadáveres y tumbas)
| # | Habilidad | Tipo | Qué hace |
|---|---|---|---|
| 1 | Lanza del Velo | hechizo real (rangos) | daño a distancia (portador: descarga de mago) |
| 2 | Velo Helado | hechizo real | ralentiza/controla |
| 3 | `#vision` | comando (1/escena) | el secreto oculto de la escena; cuesta 5% de vida *(rayo púrpura de los ojos)* |
| 4 | `#presagio` | comando (1/hora del mundo) | augurio críptico del capítulo |
| 5 | `#escrutar <objetivo>` | comando | debilidad del enemigo / si el NPC miente |
| 6 | Ojo abierto | pasiva | ve sigilo e invisibilidad a gran distancia (detección real) |
| 7 | Ve lo que otros no | pasiva | banderitas de secretos que nadie más ve |
| 8 | **El don no se calla** | precio | susurros no pedidos (peor de noche; en luna llena, no para) |

---

## Atuendos icónicos (EN VIVO 2026-07-13 — sql/004 + outfits.lua)
Tier **sin casco** (la cara siempre visible — "esto es una aventura", Luis) por
clase/variante; el look se re-aplica al login Y al cambiar equipo; stats en el equipo real:
| Clase/variante | Set | Silueta |
|---|---|---|
| Baluarte del Alba | Judgement (T2 paladín) | oro y púrpura, EL set icónico |
| Baluarte de Piedra | Might (T1 guerrero) | bronce y acero oscuro |
| Penitente de la Luz | Transcendence (T2 sacerdote) | blanco y dorado |
| Penitente del Silencio | Nemesis (T2 brujo) | negro sobrio |
| Bardo de la Corte | Netherwind (T2 mago) | púrpura elegante |
| Bardo Canalla | Shadowcraft (T0 pícaro) | cuero de viajero |
| Cazador Inquisidor | Beaststalker (T0 cazador) | cuero oscuro de cacería |
| Cazador Rastreador | Giantstalker (T1 cazador) | montaraz curtido |
| Vidente Oráculo | Arcanist (T1 mago) | azul y dorado místico |
| Vidente Médium | Plagueheart (T3 brujo) | verde sepulcral |

⚠️ Nota de sabor conocida: al re-equipar un slot el visual real parpadea hasta el
próximo evento de equipo/login (limitación heredada; el hook ON_EQUIP lo minimiza).

## Grupo de prueba de 5
Uno por clase — la party completa: Baluarte + Penitente + Bardo + Cazador + Vidente,
cada uno con linaje distinto. Cuentas y héroes de prueba: los preparo en un minuto.

## Los 🧪 pendientes de validación en vivo
Juramento (tracking de vida) · silencio proc en creatures · acortar buffs ajenos ·
y el hook de lista blanca (vaciar clase base) que es el corazón del modelo — se valida
PRIMERO con el personaje de prueba.

## Banco de ideas (fuera de la temporada 1)
Boticario · Duelista · Guardabosques de Duskwood · Caballero Arcano · Nigromante-clase
(el linaje ya lo cubre) · Monje.
