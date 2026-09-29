# Toolchain MPQ — nombres y tooltips reales para El Pacto
*Luis autorizó el parche de cliente (2026-07-13). Pipeline COMPLETO y verificado en local;
falta una sola cosa: probarlo en un cliente real (5 min con Luis).*

## El pipeline
```
Spell.dbc (extraído del volumen del server — mismo que usa el cliente)
  → dbc_tool.py rename  (nombres/rangos/descripciones en español, columnas enUS)
  → mpq_pack.py crear   (patch-4.MPQ vía StormLib; 48MB → 4.5MB)
  → ElPacto-patch.mpq junto al launcher
  → ElPacto.bat lo copia a Data\patch-4.MPQ · LaTorre.bat lo BORRA
    (mismo cliente compartido, cero contaminación entre juegos)
```

## Comandos
```bash
cd tools/mpq
# ver un hechizo
python3 dbc_tool.py info Spell.dbc 78
# renombrar según un JSON  {"78": {"name": "...", "rank": "...", "desc": "...", "tooltip": "..."}}
python3 dbc_tool.py rename Spell.dbc Spell-pacto.dbc renames.json
# empaquetar y verificar
python3 mpq_pack.py crear patch-4.MPQ "DBFilesClient\\Spell.dbc=Spell-pacto.dbc"
python3 mpq_pack.py verificar patch-4.MPQ "DBFilesClient\\Spell.dbc" Spell-pacto.dbc
```

## Columnas Spell.dbc 3.3.5 (verificadas empíricamente)
ID=0 · nombre enUS=136 · rango=153 · descripción=170 · tooltip=187.
Las descripciones aceptan macros del cliente (`$s1` daño, `$d` duración, `$t1` tick...)
— el cliente sustituye los números reales solo.

## Reglas de uso
1. **Solo renombrar hechizos que usen NUESTROS kits** (sin clases base, nadie más los ve).
   Cada portador pertenece a UNA clase del Pacto — sin colisiones.
2. Cuando los kits estén finales, los renames.json se **GENERAN desde
   `pacto_class_abilities`** (una sola fuente de verdad: la descripción del `#kit`
   y la del tooltip serán la misma).
3. El demo actual (`demo-renames.json`): Golpe del Alba (78), Festín de Sangre (20577),
   Visión del Velo (2096), Sello del Cazador (1130).

## Pendiente de validar en el cliente real (5 min)
- Que `Data\patch-4.MPQ` cargue los DBC (práctica estándar de modding 3.3.5).
  **Plan B documentado**: si el cliente ignora la ruta, mover a
  `Data\enUS\patch-enUS-4.MPQ` (el launcher cambia una línea).
- Acentos en tooltips: el demo va sin acentos por prudencia; validar si la fuente del
  cliente los muestra bien (debería) y a partir de ahí escribir con acentos.

## Futuro (cuando lo pidamos)
- Iconos: re-apuntar `SpellIconID` a cualquiera de los ~1,400 iconos existentes (columna
  por confirmar empíricamente — mismo método que las de texto).
- Hechizos con ID NUEVO (no renombrar sino crear): requiere añadir la fila al DBC del
  cliente Y al del servidor (mismo archivo en el volumen) — el paso 2 del camino MPQ.
