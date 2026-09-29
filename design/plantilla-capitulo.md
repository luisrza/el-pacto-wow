# Plantilla de Capítulo — formato de trabajo (M9)
*Cómo se escribe un capítulo entre Luis y Claude ANTES de la sesión. La historia se decide
juntos; esta página solo define el FORMATO para que el motor la pueda ejecutar.*

## Anatomía de un capítulo
```
CAPÍTULO N — "<título>"
├─ Sinopsis (3 frases: qué pasa, qué pueden cambiar los jugadores, qué se pierde si fallan)
├─ Estado del mundo al abrir (qué fase/spawns están activos)
├─ ESCENAS (5-8 por sesión de ~3h)
│   ├─ trigger: cómo se dispara (llegada a área / hora del mundo / kill / decisión / #forzar del DM)
│   ├─ acciones: narración en pantalla, spawns, POI, sonido, clima
│   ├─ decisión prevista (opcional): menú de gossip con opciones y su consecuencia
│   └─ bifurcación: qué flag escribe en la crónica según lo que hagan
├─ Encuentros (packs/elites con sus entries y posiciones — se preparan como creatures ≥900000)
├─ Loot con historia (items renombrados que suelta el capítulo)
├─ El favor del Sepulturero (si alguien muere y debe, cómo lo cobra ESTE capítulo)
└─ Cierre: hito de nivel + qué cambia en el mundo para el capítulo N+1 (phasing/spawns)
```

## Cómo lo ejecuta el motor (pacto_events, F2)
Cada escena = fila con: `capitulo, escena, trigger_tipo (area|hora|kill|flag|manual),
trigger_valor, acciones (JSON: narrar/spawn/poi/sonido/clima/decision), flag_resultado`.
El DM en sesión: `#escena N` (forzar), `#salta`, `#narra <texto>`, `#decision <id>` (abre el menú).

## Ejemplo mínimo (NO es el capítulo real — solo muestra el formato)
```
ESCENA 3 — "El velatorio interrumpido"
trigger: llegada a Raven Hill (área) DESPUÉS del anochecer (hora >= 20)
acciones: narrar "Las velas del velatorio se apagan una a una...";
          spawn pack 900101 x4 alrededor del cementerio; clima: niebla;
          sonido 8959 (aullido)
decisión: al acercarse al ataúd, menú de gossip: "¿Abrirlo / Quemarlo / Que el Vidente
          lo lea primero?" → cada opción escribe su flag (y abrir a lo bruto
          revienta la tapa: encuentro sorpresa)
bifurca:  simbolo_visto decide si la escena 6 les tiende emboscada o los evita
```

## Reglas de oro
1. Todo cambio de mundo permanente (phasing, creatures nuevas, items) se prepara ANTES
   de la sesión (requieren reinicio/repop — limitación del motor).
2. Cada escena debe poder fallar sin romper el capítulo (el fallo también avanza, solo
   que más caro — regla de mesa).
3. Los flags de bifurcación viven en la crónica: el capítulo N+1 los LEE.
4. Presupuesto por sesión: 5-8 escenas, 2-3 encuentros de combate, 2+ decisiones
   con consecuencia real, 1 que el mundo recuerde para siempre.
