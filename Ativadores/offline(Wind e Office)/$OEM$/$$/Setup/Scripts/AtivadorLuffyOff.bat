@echo off
setlocal EnableExtensions DisableDelayedExpansion

REM --- Configuracoes ---
set "MAS_SCRIPT_NAME=MAS_AIO.cmd"
set "LOG_FILE=C:\AtivadorLuffy_Log.txt"
set "SCOPE_PARAMETER=/Z-WindowsESUOffice" REM Escopo: Ativar Windows, ESU e Office
set "BUILD_THRESHOLD=26100" REM Build a partir da qual StaticCID/KMS4k sao preferiveis/necessarios
set "PING_TARGET=1.1.1.1" REM Servidor para testar conectividade (Cloudflare DNS)
set "PING_TIMEOUT_MS=1000" REM Tempo maximo para esperar a resposta do ping (1 segundo)
REM --- Fim das Configuracoes ---

REM --- Variaveis Internas ---
set "MAS_SCRIPT_PATH=%~dp0%MAS_SCRIPT_NAME%"
set "MAS_METHOD_PARAM="
set "NETWORK_AVAILABLE=0"
set "BUILD_NUMBER=0"
set "METHOD_USED=Desconhecido"
set "ERROR_DETAILS="
set "FINAL_ERRORLEVEL=998" REM Codigo de erro inicial
REM --- Fim Variaveis Internas ---

REM --- Inicio do Log ---
echo. >> "%LOG_FILE%"
echo [%DATE% %TIME%] --- Iniciando AtivadorLuffyOff.bat (Modo Hibrido Online/Offline) --- >> "%LOG_FILE%"

REM Verifica se o script principal do MAS existe
if not exist "%MAS_SCRIPT_PATH%" (
    set ERROR_DETAILS=Nao foi possivel encontrar %MAS_SCRIPT_NAME% em %~dp0
    echo [%DATE% %TIME%] ERRO CRITICO: %ERROR_DETAILS% >> "%LOG_FILE%"
    echo ERRO CRITICO: O script %MAS_SCRIPT_NAME% nao foi encontrado!
    echo Verifique se ele esta na mesma pasta que AtivadorLuffyOff.bat e se o nome esta correto.
    goto :EndScriptWithError
)

REM --- Detecta a Build do Windows ---
echo [%DATE% %TIME%] Detectando a build do Windows... >> "%LOG_FILE%"
for /f "tokens=2 delims=[]" %%G in ('ver') do for /f "tokens=2,3,4 delims=. " %%H in ("%%~G") do set "BUILD_NUMBER=%%J"
if "%BUILD_NUMBER%"=="0" (
    for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber 2^>nul') do set "BUILD_NUMBER=%%b"
)
if "%BUILD_NUMBER%"=="0" (
    echo [%DATE% %TIME%] AVISO: Nao foi possivel detectar a build do Windows. Usando metodo ZeroCID como padrao. >> "%LOG_FILE%"
    set BUILD_NUMBER=10240 REM Define um valor baixo para usar ZeroCID por padrao se falhar
) else (
    echo [%DATE% %TIME%] Build do Windows detectada: %BUILD_NUMBER% >> "%LOG_FILE%"
)

REM --- Verifica Conectividade com a Rede ---
echo [%DATE% %TIME%] Verificando conectividade com a rede (ping %PING_TARGET%)... >> "%LOG_FILE%"
ping -n 1 -w %PING_TIMEOUT_MS% %PING_TARGET% > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set NETWORK_AVAILABLE=1
    echo [%DATE% %TIME%] Rede detectada (conectada). >> "%LOG_FILE%"
) else (
    set NETWORK_AVAILABLE=0
    echo [%DATE% %TIME%] Rede nao detectada (desconectada ou ping falhou). >> "%LOG_FILE%"
)

REM --- Escolhe o Metodo TSforge ---
if %BUILD_NUMBER% GEQ %BUILD_THRESHOLD% (
    REM Builds recentes (W11 >= 26100)
    if %NETWORK_AVAILABLE% EQU 1 (
        set MAS_METHOD_PARAM=/Z-SCID
        set METHOD_USED=StaticCID (Online - Preferencial para builds recentes)
    ) else (
        set MAS_METHOD_PARAM=/Z-KMS4k
        set METHOD_USED=KMS4k (Offline - Fallback para builds recentes, pode nao ativar Retail)
    )
) else (
    REM Builds antigas (W10, W11 < 26100)
    set MAS_METHOD_PARAM=/Z-ZCID
    set METHOD_USED=ZeroCID (Funciona Online/Offline para builds antigas)
)
echo [%DATE% %TIME%] Metodo TSforge escolhido: %METHOD_USED% (Parametro: %MAS_METHOD_PARAM%) >> "%LOG_FILE%"

REM --- Executa o Script MAS ---
echo Executando ativacao automatica (%METHOD_USED%)... Por favor, aguarde.
echo [%DATE% %TIME%] Executando: "%MAS_SCRIPT_PATH%" %SCOPE_PARAMETER% %MAS_METHOD_PARAM% >> "%LOG_FILE%"

call "%MAS_SCRIPT_PATH%" %SCOPE_PARAMETER% %MAS_METHOD_PARAM%
set FINAL_ERRORLEVEL=%ERRORLEVEL%

REM --- Verifica o Resultado ---
if %FINAL_ERRORLEVEL% EQU 0 (
    echo [%DATE% %TIME%] SUCESSO: %MAS_SCRIPT_NAME% concluido com exito (Codigo 0). >> "%LOG_FILE%"
    echo.
    echo --------------------------------------------------
    echo Ativacao automatica (%METHOD_USED%) concluida com exito.
    echo --------------------------------------------------
    echo.
) else (
    set ERROR_DETAILS=%MAS_SCRIPT_NAME% retornou erro (Codigo: %FINAL_ERRORLEVEL%)
    echo [%DATE% %TIME%] ERRO: %ERROR_DETAILS% >> "%LOG_FILE%"
    echo.
    echo **************************************************
    echo ERRO durante a ativacao automatica (%METHOD_USED%).
    echo Codigo de erro retornado pelo script principal: %FINAL_ERRORLEVEL%
    echo Verifique o log em %LOG_FILE% para mais detalhes.
    echo **************************************************
    echo.
)

:EndScriptCommon
echo [%DATE% %TIME%] --- Finalizando AtivadorLuffyOff.bat --- >> "%LOG_FILE%"

REM Pausa opcional para visualizacao em execucao manual (remova ou comente para WDS)
REM echo Pressione qualquer tecla para sair...
REM pause > nul

endlocal
REM Sai do script retornando o codigo de erro original do MAS (ou 0 se sucesso, ou 998/999 se erro interno)
exit /b %FINAL_ERRORLEVEL%

:EndScriptWithError
echo.
echo %ERROR_DETAILS%
echo Verifique o log em %LOG_FILE%.
REM Pausa para ver o erro em execucao manual
echo Pressione qualquer tecla para sair...
pause > nul
echo [%DATE% %TIME%] --- Finalizando AtivadorLuffyOff.bat com erro critico --- >> "%LOG_FILE%"
endlocal
exit /b 999