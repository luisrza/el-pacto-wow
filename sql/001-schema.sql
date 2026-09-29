-- 001-schema.sql — EL PACTO: schema base (F0/F1)
-- ⚠️ Aplicar SIEMPRE con: mysql --default-character-set=utf8mb4 (lección de La Torre)
-- docker exec -i pacto-database mysql -uroot -ppassword --default-character-set=utf8mb4 < sql/001-schema.sql

CREATE DATABASE IF NOT EXISTS pacto CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- ============ CONFIG (todo knob vive aquí, nunca constantes en Lua) ============
CREATE TABLE IF NOT EXISTS pacto.pacto_config (
    `key`   VARCHAR(64)  NOT NULL,
    `value` VARCHAR(255) NOT NULL,
    PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============ LA CRÓNICA (telemetría + memoria del mundo; M6 la leerá) ============
CREATE TABLE IF NOT EXISTS pacto.pacto_chronicle (
    id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
    event_type VARCHAR(32)  NOT NULL,
    actor      VARCHAR(24)  NOT NULL DEFAULT '',   -- personaje (si aplica)
    detail     VARCHAR(255) NOT NULL DEFAULT '',
    world_day  INT UNSIGNED NOT NULL DEFAULT 0,    -- día del mundo (Hora del Mundo)
    world_hour TINYINT UNSIGNED NOT NULL DEFAULT 0,
    ts         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    KEY idx_type_ts (event_type, ts),
    KEY idx_actor (actor)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============ HÉROES (los llena n8n con el test; heroes.lua los despierta) ============
CREATE TABLE IF NOT EXISTS pacto.pacto_heroes (
    id               INT UNSIGNED NOT NULL AUTO_INCREMENT,
    account_name     VARCHAR(32)  NOT NULL DEFAULT '',
    nombre_personaje VARCHAR(24)  NOT NULL,
    linaje           VARCHAR(32)  NOT NULL,            -- FK lógica a pacto_lineages
    trasfondo        TEXT,
    secreto          VARCHAR(255) NOT NULL DEFAULT '', -- solo su dueño lo ve
    -- atributos D&D para tiradas (no tocan stats WoW)
    fue TINYINT NOT NULL DEFAULT 10, des TINYINT NOT NULL DEFAULT 10,
    con TINYINT NOT NULL DEFAULT 10, intel TINYINT NOT NULL DEFAULT 10,
    sab TINYINT NOT NULL DEFAULT 10, car TINYINT NOT NULL DEFAULT 10,
    respuestas       TEXT,
    kit_aplicado     TINYINT UNSIGNED NOT NULL DEFAULT 0,
    created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_nombre (nombre_personaje)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============ LINAJES (mini-clases; los 7 del catálogo aprobado) ============
CREATE TABLE IF NOT EXISTS pacto.pacto_lineages (
    linaje     VARCHAR(32)  NOT NULL,
    nombre     VARCHAR(60)  NOT NULL,
    lema       VARCHAR(160) NOT NULL DEFAULT '',  -- la ventaja y el precio, en una frase
    kit_items  VARCHAR(200) NOT NULL DEFAULT '',  -- "entry:cantidad,..."
    kit_copper INT UNSIGNED NOT NULL DEFAULT 0,
    ventaja_tiradas VARCHAR(32) NOT NULL DEFAULT '', -- atributo con ventaja en dados (M4)
    bienvenida TEXT,
    enabled    TINYINT UNSIGNED NOT NULL DEFAULT 1,
    PRIMARY KEY (linaje)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Los números de cada linaje (p1..p3 tuneables por SQL, cero Lua)
CREATE TABLE IF NOT EXISTS pacto.pacto_traits (
    trait_key  VARCHAR(40) NOT NULL,   -- ej. 'vampiro_sol', 'lobo_noche'
    linaje     VARCHAR(32) NOT NULL,
    hook       ENUM('pulse','on_kill','on_death','on_login') NOT NULL,
    p1 FLOAT NOT NULL DEFAULT 0, p2 FLOAT NOT NULL DEFAULT 0, p3 FLOAT NOT NULL DEFAULT 0,
    descripcion VARCHAR(200) NOT NULL DEFAULT '',
    enabled    TINYINT UNSIGNED NOT NULL DEFAULT 1,
    PRIMARY KEY (trait_key),
    KEY idx_linaje (linaje)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============ OSCURIDAD EN MUNDO ABIERTO (decisión: lista curada de áreas) ============
CREATE TABLE IF NOT EXISTS pacto.pacto_dark_areas (
    area_id INT UNSIGNED NOT NULL,     -- area/zone id que cuenta como oscuridad
    nombre  VARCHAR(80) NOT NULL DEFAULT '',
    PRIMARY KEY (area_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============ PALABRAS CLAVE DEL TRASFONDO (micro-rasgos, M2) ============
CREATE TABLE IF NOT EXISTS pacto.pacto_keywords (
    palabra    VARCHAR(32) NOT NULL,
    micro_don  VARCHAR(120) NOT NULL,
    PRIMARY KEY (palabra)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============ KNOBS INICIALES ============
REPLACE INTO pacto.pacto_config (`key`, `value`) VALUES
    -- Hora del Mundo (decisión: acelerada). 9000s reales = 1 día del mundo (2.5h)
    ('clock_epoch',        '0'),      -- lo fija worldclock.lua al primer arranque
    ('clock_day_seconds',  '9000'),
    ('clock_day_from',     '6'),      -- amanece a las 6
    ('clock_day_to',       '20'),     -- anochece a las 20
    ('clock_moon_cycle',   '28'),     -- días del mundo por ciclo lunar (luna llena = día 14)
    ('clock_announce',     '1'),      -- anunciar amanecer/anochecer
    -- gates de módulos
    ('worldclock_enabled', '1'),
    ('lineages_enabled',   '0'),      -- F1: se enciende cuando los linajes estén listos
    ('dice_enabled',       '0');      -- F2
