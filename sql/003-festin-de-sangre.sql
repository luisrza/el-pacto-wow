-- 003-festin-de-sangre.sql — EL PACTO: Festín de sangre del vampiro
-- (idea de Luis 2026-07-13: el racial renegado Canibalizar re-vestido como
--  beber la sangre de los caídos). ⚠️ Aplicar con --default-character-set=utf8mb4

-- rasgo nuevo: al login el vampiro aprende Canibalizar (spell en config)
REPLACE INTO pacto.pacto_traits (trait_key, linaje, hook, p1, p2, p3, descripcion, enabled) VALUES
('vampiro_festin', 'vampiro', 'on_login', 0, 0, 0,
 'Festín de sangre: te alimentas de los caídos (35% de vida en 10s, cadáveres humanoides/no-muertos)', 1);

-- knob del spell (Canibalizar, racial renegado — existe en todo cliente 3.3.5)
REPLACE INTO pacto.pacto_config (`key`, `value`) VALUES
    ('vamp_festin_spell', '20577');

-- el vampiro no bebe pociones: se alimenta de sus enemigos (kit de sabor pendiente
-- de los items renombrados; por ahora kit vacío)
UPDATE pacto.pacto_lineages SET kit_items = '' WHERE linaje = 'vampiro';
