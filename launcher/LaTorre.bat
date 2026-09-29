@echo off
rem ============================================
rem  LA TORRE - launcher (poner en la carpeta del WoW 3.3.5a)
rem  Realmlist a La Torre + QUITA el parche de El Pacto + limpia Cache.
rem ============================================
cd /d "%~dp0"
if not exist "Data\enUS" (
  echo No encuentro Data\enUS - pon este .bat en la carpeta del WoW.
  pause
  exit /b 1
)
attrib -r "Data\enUS\realmlist.wtf" >nul 2>&1
echo set realmlist <TAILSCALE_IP>> "Data\enUS\realmlist.wtf"
rem --- sin el parche de El Pacto: La Torre se juega vanilla ---
if exist "Data\patch-4.MPQ" del /f /q "Data\patch-4.MPQ"
if exist Cache rmdir /s /q Cache
echo La Torre te reclama.
start Wow.exe
