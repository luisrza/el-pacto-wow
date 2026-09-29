-- 002-linajes.sql — EL PACTO: los 7 linajes + sus números (spec: design/linajes.md)
-- Gate global lineages_enabled sigue en 0 hasta que Luis apruebe los números.
-- ⚠️ Aplicar con --default-character-set=utf8mb4

REPLACE INTO pacto.pacto_lineages (linaje, nombre, lema, kit_items, kit_copper, ventaja_tiradas, bienvenida, enabled) VALUES
('vampiro',   'Vampiro',            'La noche te alimenta; el día te cobra.',            '118:5', 0, 'car',
 'Hueles a noche vieja, {nombre}. La sed que firmaste te hará terrible en la oscuridad... pero el sol guarda la factura. Tu historia dice: "{trasfondo}".', 1),
('licantropo','Licántropo',         'La luna decide, no tú.',                            '118:5', 0, 'fue',
 'La mordida no pide permiso, {nombre}. De noche serás la cacería entera; de día, solo el recuerdo. Y cuando la luna esté llena... no prometas nada. Tu historia dice: "{trasfondo}".', 1),
('nigromante','Nigromante menor',   'Nunca caminas solo... y eso incomoda.',             '118:5', 0, 'intel',
 'Los muertos te escuchan, {nombre}. Los vivos, por eso mismo, no te invitan a cenar. Tu historia dice: "{trasfondo}".', 1),
('pactado',   'Pactado',            'El poder es prestado. El cobrador existe.',         '118:5', 0, 'car',
 'Leíste el contrato, {nombre}? Nadie lo lee. Golpearás como un dios prestado, y cuando caigas... el Sepulturero te cobrará doble. Tu historia dice: "{trasfondo}".', 1),
('tocado',    'Tocado por la Luz',  'La luz te sostiene; la oscuridad te apaga.',        '118:5', 0, 'sab',
 'Algo te eligió, {nombre}, y no pidió permiso. De día sanarás lo insanable; de noche, camina cerca de la hoguera. Tu historia dice: "{trasfondo}".', 1),
('tormenta',  'Hijo de la Tormenta','El trueno responde... a veces de más.',             '118:5', 0, 'des',
 'El rayo te partió y decidió quedarse, {nombre}. Cuando llueva, reza para que sea de tu lado. Tu historia dice: "{trasfondo}".', 1),
('gigante',   'Sangre de Gigante',  'Cuanto más te duele, más fuerte golpeas.',          '118:5', 0, 'con',
 'Hay montaña en tu sangre, {nombre}. Cuando estés a punto de caer, ella se despierta... y no siempre pregunta qué quieres tú. Tu historia dice: "{trasfondo}".', 1);

-- ============ rasgos (p1..p3 = knobs; spec design/linajes.md) ============
REPLACE INTO pacto.pacto_traits (trait_key, linaje, hook, p1, p2, p3, descripcion, enabled) VALUES
-- vampiro
('vampiro_sed',       'vampiro',   'on_kill', 5, 0, 0,   'Al matar: curas p1% de tu vida máxima', 1),
('vampiro_oscuridad', 'vampiro',   'pulse',   0, 0, 0,   'En oscuridad: aura de +daño (spell en config vamp_dark_spell)', 1),
('vampiro_sol',       'vampiro',   'pulse',   3, 20, 0,  'De día a la intemperie: -p1% vida por pulso, piso p2%', 1),
-- licántropo
('lobo_noche',        'licantropo','pulse',   10, 0, 0,  'De noche: +velocidad y +p1% daño', 1),
('lobo_luna',         'licantropo','pulse',   2, 0, 0,   'Luna llena: transformación (morph) y bonos x p1', 1),
('lobo_dia',          'licantropo','pulse',   10, 0, 0,  'De día: -p1% daño (la bestia duerme)', 1),
-- nigromante (esbirro pendiente de validación técnica — stub)
('nigro_esbirro',     'nigromante','pulse',   5, 0, 0,   'Esqueleto escolta; re-alza a los p1 min del mundo [VALIDAR F1]', 0),
('nigro_cosecha',     'nigromante','on_kill', 30, 0, 0,  'Al matar humanoide/no-muerto: p1% de curar al esbirro [VALIDAR F1]', 0),
-- pactado
('pacto_golpe',       'pactado',   'on_kill', 25, 10, 25,'Al matar: p1% de gracia prestada (+p3% daño por p2s)', 1),
('pacto_factura',     'pactado',   'on_death',2, 0, 0,   'Resurrección del Sepulturero cuesta x p1', 1),
-- tocado (validaciones pendientes)
('tocado_manos',      'tocado',    'pulse',   15, 0, 0,  'De día: +p1% curación [VALIDAR aura F1]', 0),
('tocado_terror',     'tocado',    'pulse',   20, 0, 0,  'No-muerto que te golpea: p1% de huir [VALIDAR F1]', 0),
('tocado_sombra',     'tocado',    'pulse',   10, 0, 0,  'De noche/oscuridad: -p1% daño y curación', 1),
-- tormenta
('tormenta_eco',      'tormenta',  'on_kill', 30, 2, 3,  'Al matar: p1% de rayo en cadena (nivel x p2, hasta p3 objetivos)', 1),
('tormenta_carga',    'tormenta',  'pulse',   2, 0, 0,   'Con lluvia/tormenta: ecos dobles, cuestan p1% vida [VALIDAR clima F1]', 0),
-- gigante
('gigante_furia',     'gigante',   'pulse',   40, 0, 0,  'Bajo p1% de vida: furia (+daño)', 1),
('gigante_desboque',  'gigante',   'on_kill', 25, 10, 0, 'Matar en furia: p1% de quedar desbocado p2s', 1),
('gigante_exhausto',  'gigante',   'pulse',   15, 0, 0,  'Al salir de furia: exhausto p1s [VALIDAR aura F1]', 0);

-- knobs de linajes
REPLACE INTO pacto.pacto_config (`key`, `value`) VALUES
    ('vamp_dark_spell',  '8599'),  -- aura +daño de oscuridad (vampiro)
    ('lobo_sprint_spell','2983'),  -- estallido de velocidad nocturno (suave)
    ('lobo_worgen_display','729'), -- morph de luna llena [VALIDAR en cliente F1]
    ('lineage_pulse_s',  '30');    -- cadencia del pulso de rasgos
