-- 007-escribano.sql — EL PACTO: EL ESCRIBANO DEL PACTO (creación de personaje in-game)
-- El test completo como ritual jugado: preguntas por gossip, linaje emergente,
-- clase a elección, trasfondo/secreto dictados por chat. ⚠️ NPC nuevo = REINICIO.
-- ⚠️ Aplicar con --default-character-set=utf8mb4

-- ============ el NPC (rincón de la posada de Darkshire) ============
DELETE FROM acore_world.creature_template WHERE entry = 900208;
DELETE FROM acore_world.creature_template_model WHERE CreatureID = 900208;
DELETE FROM acore_world.creature WHERE id = 900208;
INSERT INTO acore_world.creature_template (entry, name, subname, minlevel, maxlevel, faction, npcflag, unit_class, AIName, ScriptName)
SELECT 900208, 'El Escribano', 'Del Pacto', 60, 60, faction, 1, unit_class, '', ''
FROM acore_world.creature_template WHERE entry = 6790;
INSERT INTO acore_world.creature_template_model (CreatureID, Idx, CreatureDisplayID, DisplayScale, Probability)
VALUES (900208, 0, 2027, 1, 1);  -- figura humana encapuchada v1 (elegir display final en el casting)
INSERT INTO acore_world.creature (id, map, zoneId, areaId, position_x, position_y, position_z, orientation, spawntimesecs, wander_distance, MovementType)
VALUES (900208, 0, 10, 42, -10520.0, -1167.0, 28.1, 2.20, 300, 0, 0);  -- rincón de la posada

-- ============ el test (data-driven: cambiar preguntas = SQL) ============
CREATE TABLE IF NOT EXISTS pacto.pacto_test_questions (
    orden TINYINT UNSIGNED NOT NULL,
    texto VARCHAR(250) NOT NULL,
    PRIMARY KEY (orden)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pacto.pacto_test_options (
    orden  TINYINT UNSIGNED NOT NULL,
    opcion TINYINT UNSIGNED NOT NULL,
    texto  VARCHAR(200) NOT NULL,
    linaje VARCHAR(32) NOT NULL,
    PRIMARY KEY (orden, opcion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS pacto.pacto_classes (
    clase VARCHAR(32) NOT NULL,
    nombre VARCHAR(60) NOT NULL,
    descripcion VARCHAR(200) NOT NULL,
    variante_a VARCHAR(32) NOT NULL,
    variante_b VARCHAR(32) NOT NULL,
    PRIMARY KEY (clase)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

DELETE FROM pacto.pacto_test_questions;
INSERT INTO pacto.pacto_test_questions (orden, texto) VALUES
 (1, 'Es medianoche en el bosque y algo te observa. ¿Qué haces?'),
 (2, 'Te ofrecen poder a cambio de algo que no nombran. ¿Firmas?'),
 (3, 'Tu grupo duerme y tú haces guardia. ¿En qué piensas?'),
 (4, '¿Cuál herida te marcó?'),
 (5, 'El pueblo te cierra las puertas. ¿Por qué?'),
 (6, 'Elige la hora del día.');

DELETE FROM pacto.pacto_test_options;
INSERT INTO pacto.pacto_test_options (orden, opcion, texto, linaje) VALUES
 (1,1,'Le devuelvo la mirada. Que sepa que también lo veo.','vampiro'),
 (1,2,'Me quedo quieto y huelo el aire. El bosque me habla.','licantropo'),
 (1,3,'Susurro a mis muertos que lo rodeen.','nigromante'),
 (1,4,'Enciendo una luz. La oscuridad no manda aquí.','tocado'),
 (1,5,'Que ataque. Necesito calentar.','gigante'),
 (2,1,'Firmo. Ya negociaré la letra pequeña.','pactado'),
 (2,2,'Firmo con sangre ajena.','nigromante'),
 (2,3,'No firmo: lo que soy me lo dio la luna sin pedir permiso.','licantropo'),
 (2,4,'Rechazo. Mi poder viene de algo más limpio.','tocado'),
 (2,5,'¿Poder? Yo YA soy la tormenta.','tormenta'),
 (3,1,'En lo que haría si uno de ellos no despertara.','vampiro'),
 (3,2,'En el cielo: huele a lluvia, y la lluvia me pone eléctrico.','tormenta'),
 (3,3,'En la deuda que aún no me cobran.','pactado'),
 (3,4,'En nada. Golpeo mejor cuando no pienso.','gigante'),
 (3,5,'En que dormidos parecen frágiles... yo los cuidaré.','tocado'),
 (4,1,'La mordida.','licantropo'),
 (4,2,'La sed.','vampiro'),
 (4,3,'La tumba de quien no debí perder.','nigromante'),
 (4,4,'El contrato.','pactado'),
 (4,5,'El rayo que me partió y me dejó vivo.','tormenta'),
 (5,1,'Vieron lo que hago con los muertos.','nigromante'),
 (5,2,'Vieron mis ojos de noche.','licantropo'),
 (5,3,'Alguien contó a quién le debo.','pactado'),
 (5,4,'Les da vergüenza necesitarme.','tocado'),
 (5,5,'Rompí la puerta la última vez.','gigante'),
 (6,1,'Medianoche.','vampiro'),
 (6,2,'Luna llena.','licantropo'),
 (6,3,'El velatorio.','nigromante'),
 (6,4,'El amanecer.','tocado'),
 (6,5,'La tormenta, sea la hora que sea.','tormenta');

DELETE FROM pacto.pacto_classes;
INSERT INTO pacto.pacto_classes (clase, nombre, descripcion, variante_a, variante_b) VALUES
 ('baluarte',  'El Baluarte',          'El muro. Juras proteger y tu palabra pesa. (tanque)', 'alba', 'piedra'),
 ('penitente', 'El Penitente',         'Curas cargando el dolor ajeno sobre ti. (sanador)', 'luz', 'silencio'),
 ('bardo',     'El Bardo',             'Tus canciones sostienen al grupo. Siempre en escena. (soporte)', 'corte', 'canalla'),
 ('cazador',   'El Cazador de Brujas', 'Marcas presas y las cobras. Desconfías de todo. (daño)', 'inquisidor', 'rastreador'),
 ('vidente',   'El Vidente',           'Ves lo oculto... y lo oculto te ve a ti. (secretos)', 'oraculo', 'medium');

REPLACE INTO pacto.pacto_config (`key`, `value`) VALUES ('escribano_enabled', '1');
