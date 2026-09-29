@echo off
rem ============================================
rem  EL PACTO - launcher (poner en la carpeta del WoW 3.3.5a
rem  junto con ElPacto-patch.mpq)
rem  Realmlist a El Pacto + instala el parche + limpia Cache.
rem ============================================
cd /d "%~dp0"
if not exist "Data\enUS" (
  echo No encuentro Data\enUS - pon este .bat en la carpeta del WoW.
  pause
  exit /b 1
)
attrib -r "Data\enUS\realmlist.wtf" >nul 2>&1
echo set realmlist <TAILSCALE_IP>:3725> "Data\enUS\realmlist.wtf"
rem --- parche de El Pacto (nombres/tooltips de habilidades) ---
if exist "ElPacto-patch.mpq" copy /y "ElPacto-patch.mpq" "Data\patch-4.MPQ" >nul
if exist Cache rmdir /s /q Cache
echo El Pacto te espera. Todo poder tiene un precio.
start Wow.exe
