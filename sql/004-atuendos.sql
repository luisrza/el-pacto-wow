-- 004-atuendos.sql — EL PACTO: atuendos icónicos por clase/variante (decisión Luis
-- 2026-07-13: "tier SIN casco según la subclase, que se vean únicos — esto es una aventura")
-- La cara siempre visible; el look es del personaje, las stats del equipo real de abajo.
-- ⚠️ Aplicar con --default-character-set=utf8mb4

-- el héroe ahora lleva clase y variante (modelo v2)
-- (MySQL 8 no tiene ADD COLUMN IF NOT EXISTS; este ALTER es de una sola vez —
--  si se re-aplica el archivo, ignorar el error de columna duplicada)
ALTER TABLE pacto.pacto_heroes
    ADD COLUMN clase    VARCHAR(32) NOT NULL DEFAULT '' AFTER linaje,
    ADD COLUMN variante VARCHAR(32) NOT NULL DEFAULT '' AFTER clase;

CREATE TABLE IF NOT EXISTS pacto.pacto_outfits (
    clase      VARCHAR(32) NOT NULL,
    variante   VARCHAR(32) NOT NULL,
    equip_slot TINYINT UNSIGNED NOT NULL,  -- 2=hombros 4=pecho 5=cintura 6=piernas 7=pies 8=muñecas 9=manos (SIN 0=cabeza)
    item_entry INT UNSIGNED NOT NULL,
    PRIMARY KEY (clase, variante, equip_slot)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ===== poblar desde los sets del cliente (verificados en item_template) =====
-- InventoryType -> equip_slot: 3->2, 5/20->4, 6->5, 7->6, 8->7, 9->8, 10->9 (1=cabeza EXCLUIDA)
-- baluarte/alba: Judgement (217) · baluarte/piedra: Might (209)
-- penitente/luz: Transcendence (211) · penitente/silencio: Nemesis (212)
-- bardo/corte: Netherwind (210) · bardo/canalla: Shadowcraft (184)
-- cazador/inquisidor: Beaststalker (186) · cazador/rastreador: Giantstalker (206)
-- vidente/oraculo: Arcanist (201) · vidente/medium: Plagueheart (529)

DELETE FROM pacto.pacto_outfits;

INSERT INTO pacto.pacto_outfits (clase, variante, equip_slot, item_entry)
SELECT m.clase, m.variante,
       CASE it.InventoryType WHEN 3 THEN 2 WHEN 5 THEN 4 WHEN 20 THEN 4 WHEN 6 THEN 5
                             WHEN 7 THEN 6 WHEN 8 THEN 7 WHEN 9 THEN 8 WHEN 10 THEN 9 END,
       it.entry
FROM acore_world.item_template it
JOIN (SELECT 'baluarte' clase,  'alba' variante,       217 itemset
      UNION SELECT 'baluarte',  'piedra',      209
      UNION SELECT 'penitente', 'luz',         211
      UNION SELECT 'penitente', 'silencio',    212
      UNION SELECT 'bardo',     'corte',       210
      UNION SELECT 'bardo',     'canalla',     184
      UNION SELECT 'cazador',   'inquisidor',  186
      UNION SELECT 'cazador',   'rastreador',  206
      UNION SELECT 'vidente',   'oraculo',     201
      UNION SELECT 'vidente',   'medium',      529) m ON m.itemset = it.itemset
WHERE it.InventoryType IN (3, 5, 20, 6, 7, 8, 9, 10);

REPLACE INTO pacto.pacto_config (`key`, `value`) VALUES ('outfits_enabled', '1');
