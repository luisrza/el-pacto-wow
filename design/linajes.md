# Los 7 Linajes de El Pacto — spec de números (para aprobar antes de codificar)
*F1. Todo número de esta página vive en `pacto_traits`/`pacto_config` (tuneable por SQL).
Regla del catálogo: **cada linaje es una mini-clase con ventaja jugable Y precio**, montada
sobre la clase WoW del jugador. Los rasgos leen la Hora del Mundo (worldclock.lua, ya en vivo).*

Leyenda: ✅ mecanismo probado · 🧪 spell/ID a validar en el cliente durante F1

---

## 🧛 Vampiro — "La noche te alimenta; el día te cobra"
| Rasgo | Efecto | Números propuestos |
|---|---|---|
| **Sed** (on_kill) ✅ | al matar, recuperas % de tu vida máxima | p1 = 5% |
| **Festín de sangre** (on_login) ✅ **IMPLEMENTADO 2026-07-13** | aprende Canibalizar (spell 20577, racial renegado): canaliza sobre cadáveres humanoides/no-muertos y recupera 35% de vida en 10s. Al usarlo, emote público a 30m: *"{nombre} se inclina sobre el cadáver... y bebe."* (idea de Luis; el tooltip dirá "Canibalizar" — límite del cliente; si molesta, se envuelve en un item renombrado). Falta SOLO la validación en vivo con el primer login | — |
| **Abrazo de la oscuridad** (pulse) ✅ | de NOCHE o en zona oscura (mazmorra / `pacto_dark_areas`): +daño | aura 8599 (+daño) 🧪 número exacto del aura |
| **El precio del sol** (pulse) ✅ | de DÍA a la intemperie: −% vida por pulso (30s), nunca te baja del piso | p1 = 3% por pulso, piso 20% |
| Ventaja en tiradas | **Carisma** (el encanto del depredador) | — |
| Kit | capa oscura — SIN pociones: el vampiro no bebe pociones, se alimenta de sus enemigos | — |

## 🐺 Licántropo — "La luna decide, no tú"
| Rasgo | Efecto | Números |
|---|---|---|
| **Sangre de la manada** (pulse) ✅ | de NOCHE: +velocidad de movimiento y +daño físico | +20% vel (aura Sprint suave 🧪), +10% daño |
| **Luna llena** (pulse) ✅ | la noche del día 14 del ciclo (28 días del mundo ≈ 3 días reales): TRANSFORMACIÓN — morph a worgen + ambos bonos doblados; no puedes quitártela | displayid worgen 🧪 (validar en cliente), bonos ×2 |
| **Resaca lunar** (pulse) ✅ | de DÍA: −10% daño (la bestia duerme) | p1 = 10% |
| Ventaja en tiradas | **Fuerza** | — |
| Kit | 3× carne cruda + 5× poción menor | — |

## 💀 Nigromante menor — "Nunca caminas solo... y eso incomoda"
| Rasgo | Efecto | Números |
|---|---|---|
| **Esbirro** (on_login/pulse) 🧪 | un esqueleto (entry custom ≥900000) te sigue y pelea contigo; si muere, se re-alza a los N min | re-alzarse: 5 min del mundo. ⚠️ PRIMERA validación de F1 (charm/escort; plan B: IA escolta Lua) |
| **Cosecha** (on_kill) ✅ | al matar humanoides/no-muertos, p1% de que tu esbirro se cure por completo | p1 = 30% |
| **Mala fama** (social) ✅ | los vendedores te cobran +15% y los NPCs con memoria te hablan frío (frases propias) | multiplicador de precios 🧪 (validar hook de vendor; plan B: solo narrativo) |
| Ventaja en tiradas | **Inteligencia** | — |
| Kit | 1 daga ritual (item renombrado) + 5× poción menor | — |

## 😈 Pactado — "El poder es prestado. El cobrador existe"
| Rasgo | Efecto | Números |
|---|---|---|
| **Golpe del pacto** (on_kill) ✅ | al matar, p1% de entrar en "gracia prestada": tus siguientes golpes hacen +25% daño por 10s | p1 = 25%, aura 🧪 |
| **La factura** (on_death) ✅ | tu resurrección con el Sepulturero SIEMPRE cuesta doble, y tu cicatriz se escribe con tinta del pacto (frases propias en la crónica) | ×2 costo |
| Ventaja en tiradas | **Carisma** (sabe negociar... lo aprendió por las malas) | — |
| Kit | contrato sellado (item de sabor) + 5× poción menor | — |

## ✨ Tocado por la Luz — "La luz te sostiene; la oscuridad te apaga"
| Rasgo | Efecto | Números |
|---|---|---|
| **Manos benditas** (pulse) ✅ | tus curaciones (dadas Y recibidas) +15% de DÍA | p1 = 15% 🧪 (validar aura de +healing; plan B: heal extra por Lua) |
| **Terror sagrado** (on_damaged) 🧪 | cuando un NO-MUERTO te golpea, p1% de que huya despavorido | p1 = 20%, fear 🧪 validar aura en creature |
| **La sombra pesa** (pulse) ✅ | de NOCHE o en zona oscura: −10% daño y curación | p1 = 10% |
| Ventaja en tiradas | **Sabiduría** | — |
| Kit | símbolo sagrado + 5× poción menor | — |

## ⚡ Hijo de la Tormenta — "El trueno responde... a veces de más"
| Rasgo | Efecto | Números |
|---|---|---|
| **Eco del trueno** (on_kill) ✅ | al matar, p1% de desatar un rayo en cadena sobre enemigos cercanos (daño = nivel × p2, hasta p3 objetivos) | p1 = 30%, p2 = 2, p3 = 3 (patrón nova probado, visual de rayo 🧪) |
| **Sobrecarga** (pulse) 🧪 | si LLUEVE/tormenta en la zona: tus rayos pegan doble... y cada eco te cuesta 2% de vida | validar lectura de clima; plan B: "noches de tormenta" narradas por el DM activan el estado |
| Ventaja en tiradas | **Destreza** | — |
| Kit | vara de cobre (item de sabor) + 5× poción menor | — |

## 🩸 Sangre de Gigante — "Cuanto más te duele, más fuerte golpeas"
| Rasgo | Efecto | Números |
|---|---|---|
| **Furia del gigante** (pulse) ✅ | con menos del p1% de vida: +daño (aura 8599) y +10% velocidad de ataque | p1 = 40%, se evalúa cada pulso de combate |
| **Perder el control** (on_kill) ✅ | si matas ESTANDO en furia, p2% de quedar "desbocado": no puedes salir de combate 10s (sigue la furia, la decide ella) | p2 = 25% |
| **Exhausto** (pulse) ✅ | al salir de la furia: −20% velocidad 15s (aura dazed 🧪) | — |
| Ventaja en tiradas | **Constitución** | — |
| Kit | cinturón de cuero de mamut (item renombrado) + 5× poción menor | — |

---

## Reglas transversales
- **Todos los rasgos con pcall** y gate `lineages_enabled` (0 = módulo muerto, patrón probado).
- Los % y auras: knobs `pacto_traits.p1..p3` — cambiar balance = UPDATE, jamás editar Lua.
- La oscuridad = `PACTO.IsNight()` OR mazmorra OR area_id ∈ `pacto_dark_areas` (decisión de Luis).
- El "🧪 validar" de F1 se hace ANTES de anunciar el linaje a los amigos: cada linaje se
  prueba con un personaje de prueba y se marca ✅ en esta página con el spell/display final.
- Orden de construcción propuesto: Vampiro (base probada) → Licántropo → Sangre de Gigante →
  Pactado → Tocado → Tormenta → **Nigromante al final** (el único con riesgo técnico real).

## Para aprobar por Luis
1. ¿Los números de cada tabla te cuadran como arranque? (todo tuneable después)
2. Nigromante: si el esbirro-mascota se resiste, ¿te vale el plan B (esqueleto escolta que
   pelea a tu lado por IA propia — visualmente idéntico, no es "mascota" de verdad)?
3. ¿Kits de sabor con items renombrados (daga ritual, contrato sellado...) — los preparo?
