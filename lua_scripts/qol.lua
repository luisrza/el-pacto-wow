-- qol.lua — EL PACTO: calidad de vida (petición Luis 2026-07-15)
-- 1) Tutoriales MUERTOS para siempre: los flags viven por cuenta en
--    account_tutorial; al login se marcan TODOS como vistos (cubre cuentas
--    nuevas automáticamente — "para siempre").
-- Módulo autocontenido, pcall en todo.

local FF = 4294967295  -- 0xFFFFFFFF = todos los tutoriales vistos

RegisterPlayerEvent(3, function(event, p)  -- ON_LOGIN
    pcall(function()
        CharDBExecute(string.format([[
            REPLACE INTO account_tutorial (accountId, tut0, tut1, tut2, tut3, tut4, tut5, tut6, tut7)
            VALUES (%d, %d, %d, %d, %d, %d, %d, %d, %d)]],
            p:GetAccountId(), FF, FF, FF, FF, FF, FF, FF, FF))
    end)
end)

print("[ElPacto] qol.lua listo (tutoriales silenciados para siempre)")
