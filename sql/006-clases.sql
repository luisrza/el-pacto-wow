-- 006-clases.sql — EL PACTO: motor de Clases del Pacto v1 + kit del BALUARTE
-- (modelo v2: la clase del Pacto ES la clase — spec design/clases-del-pacto.md)
-- ⚠️ Aplicar con --default-character-set=utf8mb4

-- el héroe lleva rango de clase (los capítulos lo suben)
ALTER TABLE pacto.pacto_heroes ADD COLUMN rango TINYINT UNSIGNED NOT NULL DEFAULT 1 AFTER variante;

CREATE TABLE IF NOT EXISTS pacto.pacto_class_abilities (
    clase     VARCHAR(32) NOT NULL,
    orden     TINYINT UNSIGNED NOT NULL,
    tipo      ENUM('hechizo','comando','pasiva','precio') NOT NULL,
    nombre    VARCHAR(60) NOT NULL,
    spell_id  INT UNSIGNED NOT NULL DEFAULT 0,   -- para tipo hechizo (se enseña al login)
    rango     TINYINT UNSIGNED NOT NULL DEFAULT 1, -- desde qué rango se tiene
    descripcion VARCHAR(250) NOT NULL DEFAULT '',
    PRIMARY KEY (clase, orden)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============ EL BALUARTE v1 (chasis guerrero) ============
DELETE FROM pacto.pacto_class_abilities WHERE clase = 'baluarte';
INSERT INTO pacto.pacto_class_abilities (clase, orden, tipo, nombre, spell_id, rango, descripcion) VALUES
 ('baluarte', 1, 'hechizo', 'Golpe del Alba', 78, 1,
  'Tu golpe de juramento (ya lo conoces: es tu golpe básico, renombrado por el parche).'),
 ('baluarte', 2, 'hechizo', 'Postura del Muro', 71, 1,
  'La postura defensiva del Baluarte. Necesaria para Provocar.'),
 ('baluarte', 3, 'hechizo', 'Provocar', 355, 1,
  'Obliga a un enemigo a atacarte. El pan del tanque.'),
 ('baluarte', 4, 'hechizo', 'Bloqueo Alzado', 2565, 1,
  'Alza el escudo: bloqueas el próximo golpe.'),
 ('baluarte', 5, 'comando', '#jurar <aliado>', 0, 1,
  'Juras proteger a un aliado: absorbes parte de su castigo (te arrodillas ante él). #jurar sin nombre lo cancela.'),
 ('baluarte', 6, 'comando', '#aqui', 0, 1,
  'Provocación de honor: rugido que obliga a los enemigos cercanos a venir por ti (60s de recarga).'),
 ('baluarte', 7, 'comando', '#muro', 0, 1,
  'Te plantas: mientras no te muevas, tu piel se vuelve piedra (+defensa). Moverte lo rompe.'),
 ('baluarte', 8, 'pasiva', 'Atraer la tormenta', 0, 1,
  'Tu presencia multiplica tu amenaza: los enemigos te prefieren a ti.'),
 ('baluarte', 9, 'precio', 'No puede huir', 0, 1,
  'Abandonar un combate con tu juramento activo mancha tu nombre — y la crónica lo escribe.');

-- knobs del Baluarte
REPLACE INTO pacto.pacto_config (`key`, `value`) VALUES
 ('classes_enabled',      '1'),
 ('baluarte_jurar_pct',   '25'),   -- % del daño del jurado que absorbes
 ('baluarte_jurar_range', '30'),   -- distancia máxima del juramento
 ('baluarte_aqui_cd',     '60'),   -- cooldown de #aqui (s reales)
 ('baluarte_aqui_threat', '5000'), -- amenaza extra de #aqui
 ('baluarte_muro_spell',  '20594'),-- Forma de Piedra (piel de piedra visible)
 ('baluarte_threat_mult', '2000'); -- amenaza extra por pulso de combate
