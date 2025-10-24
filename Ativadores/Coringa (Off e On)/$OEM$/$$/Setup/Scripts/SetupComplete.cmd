@echo off
set SCRIPTDIR=%~dp0
cd /d "%SCRIPTDIR%"

echo [%DATE% %TIME%] Iniciando SetupComplete.cmd >> C:\SetupComplete_Log.txt
echo [%DATE% %TIME%] Chamando AtivadorLuffyCoringa.bat >> C:\SetupComplete_Log.txt

call "%SCRIPTDIR%AtivadorLuffyCoringa.bat"

if %ERRORLEVEL% EQU 0 (
  echo [%DATE% %TIME%] AtivadorLuffyCoringa.bat retornou sucesso (0). >> C:\SetupComplete_Log.txt
) else (
  echo [%DATE% %TIME%] AtivadorLuffyCoringa.bat retornou erro (%ERRORLEVEL%). Verificar C:\AtivadorLuffyCoringa_Log.txt >> C:\SetupComplete_Log.txt
)

echo [%DATE% %TIME%] Finalizando SetupComplete.cmd >> C:\SetupComplete_Log.txt

REM Limpeza padrao do SetupComplete.cmd
cd \
(goto) 2>nul & (if "%SCRIPTDIR%"=="%SystemRoot%\Setup\Scripts\" rd /s /q "%SCRIPTDIR%")

exit /b