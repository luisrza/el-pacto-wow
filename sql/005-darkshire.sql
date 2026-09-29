-- 005-darkshire.sql — EL PACTO: LA CAMPAÑA EMPIEZA EN DARKSHIRE
-- Spawn de personajes nuevos en el pueblo + los 7 NPCs del corazón + la quest 900001.
-- ⚠️ REQUIERE REINICIO del worldserver (creatures/quests/spawn no cargan en caliente).
-- ⚠️ Aplicar con --default-character-set=utf8mb4

-- ============ 1. LOS PERSONAJES NUEVOS NACEN EN DARKSHIRE ============
UPDATE acore_world.playercreateinfo
SET map = 0, zone = 10, position_x = -10573, position_y = -1182.5, position_z = 28.5, orientation = 0.31;

-- ============ 2. LOS 7 DEL CORAZÓN (entries 900201+, clonados de templates sanos) ============
DELETE FROM acore_world.creature_template WHERE entry BETWEEN 900201 AND 900220;
DELETE FROM acore_world.creature_template_model WHERE CreatureID BETWEEN 900201 AND 900220;
DELETE FROM acore_world.creature WHERE id BETWEEN 900201 AND 900220;

-- clon del posadero de Darkshire (template civil sano) con overrides por NPC
INSERT INTO acore_world.creature_template
  (entry, name, subname, minlevel, maxlevel, faction, npcflag, unit_class, AIName, ScriptName)
SELECT 900201, 'Alguacil Bran Cordero', 'La Ley de Darkshire', 30, 30, faction, 3, unit_class, '', ''
FROM acore_world.creature_template WHERE entry = 6790;
INSERT INTO acore_world.creature_template (entry, name, subname, minlevel, maxlevel, faction, npcflag, unit_class, AIName, ScriptName)
SELECT 900202, 'Coralia Cuervo', 'Posadera del Cuervo Escarlata', 30, 30, faction, 1, unit_class, '', ''
FROM acore_world.creature_template WHERE entry = 6790;
INSERT INTO acore_world.creature_template (entry, name, subname, minlevel, maxlevel, faction, npcflag, unit_class, AIName, ScriptName)
SELECT 900203, 'Gaspar', 'El Herrero Mudo', 30, 30, faction, 1, unit_class, '', ''
FROM acore_world.creature_template WHERE entry = 6790;
INSERT INTO acore_world.creature_template (entry, name, subname, minlevel, maxlevel, faction, npcflag, unit_class, AIName, ScriptName)
SELECT 900204, 'Doña Ipe', 'Boticaria y Enterada', 30, 30, faction, 1, unit_class, '', ''
FROM acore_world.creature_template WHERE entry = 6790;
INSERT INTO acore_world.creature_template (entry, name, subname, minlevel, maxlevel, faction, npcflag, unit_class, AIName, ScriptName)
SELECT 900205, 'Salomón', 'Préstamos y Favores', 30, 30, faction, 1, unit_class, '', ''
FROM acore_world.creature_template WHERE entry = 6790;
INSERT INTO acore_world.creature_template (entry, name, subname, minlevel, maxlevel, faction, npcflag, unit_class, AIName, ScriptName)
SELECT 900206, 'Ferro Cuervo', 'El Cuervo Rojo', 30, 30, faction, 3, unit_class, 'SmartAI', ''
FROM acore_world.creature_template WHERE entry = 6790;
INSERT INTO acore_world.creature_template (entry, name, subname, minlevel, maxlevel, faction, npcflag, unit_class, AIName, ScriptName)
SELECT 900207, 'Marlo Cuervo', 'El Cuervo Rojo', 30, 30, faction, 1, unit_class, '', ''
FROM acore_world.creature_template WHERE entry = 6790;

-- modelos (displays de humanos EXISTENTES del cliente, vistos en el propio pueblo)
INSERT INTO acore_world.creature_template_model (CreatureID, Idx, CreatureDisplayID, DisplayScale, Probability) VALUES
 (900201, 0, 4320, 1, 1),  -- alguacil: humano de guardia
 (900202, 0, 4334, 1, 1),  -- Coralia: mujer de pueblo
 (900203, 0, 4331, 1, 1),  -- Gaspar: herrero
 (900204, 0, 5129, 1, 1),  -- Ipe: mujer mayor
 (900205, 0, 1724, 1, 1),  -- Salomón: señor de traje
 (900206, 0, 4338, 1, 1),  -- Ferro
 (900207, 0, 2027, 1, 1);  -- Marlo

-- spawns sobre coordenadas VERIFICADAS (junto a NPCs vanilla existentes)
INSERT INTO acore_world.creature (id, map, zoneId, areaId, position_x, position_y, position_z, orientation, spawntimesecs, wander_distance, MovementType) VALUES
 (900201, 0, 10, 42, -10563.0, -1150.0, 28.1, 2.00, 300, 0, 0),  -- junto al ayuntamiento
 (900202, 0, 10, 42, -10513.0, -1164.0, 28.1, 4.03, 300, 0, 0),  -- dentro de la posada
 (900203, 0, 10, 42, -10614.0, -1157.0, 27.2, 3.00, 300, 0, 0),  -- la herrería
 (900204, 0, 10, 42, -10556.0, -1128.0, 30.1, 1.30, 300, 0, 0),  -- calle principal
 (900205, 0, 10, 42, -10580.0, -1121.0, 30.1, 0.10, 300, 0, 0),  -- su "oficina"
 (900206, 0, 10, 42, -10575.0, -1215.0, 26.2, 1.50, 300, 0, 0),  -- la plaza (reclutando)
 (900207, 0, 10, 42, -10572.0, -1217.5, 26.2, 1.80, 300, 0, 0);  -- junto a su hermano

-- ============ 3. QUEST 900001 — «Se buscan manos (y espadas)» ============
DELETE FROM acore_world.quest_template WHERE ID = 900001;
INSERT INTO acore_world.quest_template
  (ID, QuestType, QuestLevel, MinLevel, QuestSortID, LogTitle, LogDescription, QuestDescription, QuestCompletionLog,
   RequiredNpcOrGo1, RequiredNpcOrGoCount1, ObjectiveText1, RewardMoney)
VALUES
  (900001, 2, 1, 1, 10,
   'Se buscan manos (y espadas)',
   'Habla con Ferro Cuervo en la plaza de Darkshire.',
   'El alguacil resopla y señala la plaza con la barbilla.$B$B"Los hermanos Cuervo andan reclutando gente para su... negocio. Un granero en Addle''s Stead, dicen que taberna. A MÍ no me han pedido permiso, pero mientras no haya muertos, no es asunto mío.$B$BSi buscas trabajo, ve con ellos. Y si ves algo raro ahí afuera... eso SÍ es asunto mío."',
   'Ferro te mira de arriba a abajo, y sonríe como quien encuentra una moneda en el barro.',
   900206, 1, 'Habla con Ferro Cuervo', 5000);

DELETE FROM acore_world.quest_template_addon WHERE ID = 900001;
INSERT INTO acore_world.quest_template_addon (ID) VALUES (900001);

DELETE FROM acore_world.creature_queststarter WHERE quest = 900001;
INSERT INTO acore_world.creature_queststarter (id, quest) VALUES (900201, 900001);
DELETE FROM acore_world.creature_questender WHERE quest = 900001;
INSERT INTO acore_world.creature_questender (id, quest) VALUES (900206, 900001);

-- Ferro da el crédito de "hablar con él" al abrir su gossip (SmartAI puro SQL)
DELETE FROM acore_world.smart_scripts WHERE entryorguid = 900206 AND source_type = 0;
INSERT INTO acore_world.smart_scripts
 (entryorguid, source_type, id, link, event_type, event_phase_mask, event_chance, event_flags,
  action_type, action_param1, target_type, comment)
VALUES (900206, 0, 0, 0, 64, 0, 100, 0, 33, 900206, 7, 'Ferro Cuervo - gossip hello - credito de quest 900001');

-- ============ 4. FRASES DEL PUEBLO (banter data-driven, pueblo.lua) ============
CREATE TABLE IF NOT EXISTS pacto.pacto_npc_lines (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    npc_entry INT UNSIGNED NOT NULL,
    linea VARCHAR(250) NOT NULL,
    PRIMARY KEY (id), KEY idx_npc (npc_entry)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DELETE FROM pacto.pacto_npc_lines WHERE npc_entry BETWEEN 900201 AND 900220;
INSERT INTO pacto.pacto_npc_lines (npc_entry, linea) VALUES
 (900201, 'Otra noche sin muertos, por favor. Es lo único que pido.'),
 (900201, 'Desde antes del granero ese ya desaparecía gente. Pero eso no lo digo en voz alta.'),
 (900202, 'Mis hijos abren su cantina en un GRANERO. Que no me hablen. Que ni me nombren.'),
 (900202, 'La sopa de hoy lleva lo mismo que la de ayer: paciencia.'),
 (900204, '¿Ya supiste lo del granero? Yo no digo nada... pero digo TODO, corazón.'),
 (900204, 'Esos rezos no pagan renta. Mis pociones sí funcionan, y cobro menos que la iglesia.'),
 (900205, '¿Un préstamo? Firma aquí. Sin prisa. Yo nunca tengo prisa.'),
 (900205, 'Todos me pagan. Tarde o temprano, todos.'),
 (900206, '¡Esta noche abre el Cuervo Rojo! Corre la voz... pero no muy fuerte.'),
 (900206, '¡Marlo! ¿Contaste los barriles? ¡MARLO!'),
 (900207, 'Sí los conté, Ferro. Dos veces. Como ayer. Como siempre.'),
 (900207, 'Mamá va a matarnos. Y lo del bosque también, pero primero mamá.');
