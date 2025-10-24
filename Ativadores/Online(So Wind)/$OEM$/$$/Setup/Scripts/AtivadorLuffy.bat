@echo off
setlocal EnableExtensions DisableDelayedExpansion

REM --- Configuracoes ---
set "MAS_SCRIPT_NAME=MAS_AIO.cmd"
set "LOG_FILE=C:\AtivadorLuffy_Log.txt"
set "SCOPE_PARAMETER=/HWID"  REM
set "PING_TARGET=1.1.1.1"
set "PING_TIMEOUT_MS=1500" REM Aumentado levemente o timeout
REM --- Fim das Configuracoes ---

REM --- Variaveis Internas ---
set "MAS_SCRIPT_PATH=%~dp0%MAS_SCRIPT_NAME%"
set "NETWORK_AVAILABLE=0"
set "METHOD_USED=HWID"
set "ERROR_DETAILS="
set "FINAL_ERRORLEVEL=998" REM Codigo de erro inicial
REM --- Fim Variaveis Internas ---

REM --- Inicio do Log ---
echo. >> "%LOG_FILE%"
echo [%DATE% %TIME%] --- Iniciando AtivadorLuffy.bat --- >> "%LOG_FILE%"

REM Verifica se o script principal do MAS existe
if not exist "%MAS_SCRIPT_PATH%" (
    set ERROR_DETAILS=Nao foi possivel encontrar %MAS_SCRIPT_NAME% em %~dp0
    echo [%DATE% %TIME%] ERRO CRITICO: %ERROR_DETAILS% >> "%LOG_FILE%"
    echo ERRO CRITICO: O script %MAS_SCRIPT_NAME% nao foi encontrado!
    echo Verifique se ele esta na mesma pasta que AtivadorLuffy.bat e se o nome esta correto.
    goto :EndScriptWithError
)

REM --- Verifica Conectividade com a Rede (ESSENCIAL para HWID) ---
echo [%DATE% %TIME%] Verificando conectividade com a rede (ping %PING_TARGET%)... >> "%LOG_FILE%"
ping -n 1 -w %PING_TIMEOUT_MS% %PING_TARGET% > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set NETWORK_AVAILABLE=1
    echo [%DATE% %TIME%] Rede detectada (conectada). >> "%LOG_FILE%"
) else (
    set NETWORK_AVAILABLE=0
    set ERROR_DETAILS=Rede nao detectada ou indisponivel. Ativacao HWID requer conexao com a internet.
    echo [%DATE% %TIME%] ERRO: %ERROR_DETAILS% >> "%LOG_FILE%"
    echo ERRO: Rede nao detectada ou indisponivel.
    echo A ativacao HWID requer conexao com a internet e falhara.
    REM Decide se quer abortar ou tentar mesmo assim (vai falhar sem rede)
    REM Para automacao total, vamos abortar. Comente a linha abaixo para tentar mesmo assim.
    goto :EndScriptWithError
)

REM --- Executa o Script MAS ---
echo Executando ativacao automatica (%METHOD_USED%)... Por favor, aguarde.
echo [%DATE% %TIME%] Executando: "%MAS_SCRIPT_PATH%" %SCOPE_PARAMETER% >> "%LOG_FILE%"

call "%MAS_SCRIPT_PATH%" %SCOPE_PARAMETER%
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
    echo ******************
    echo ERRO durante a ativacao automatica (%METHOD_USED%).
    echo Codigo de erro retornado pelo script principal: %FINAL_ERRORLEVEL%
    echo Verifique o log em %LOG_FILE% para mais detalhes.
    echo ******************
    echo.
)

:EndScriptCommon
echo [%DATE% %TIME%] --- Finalizando AtivadorLuffy.bat --- >> "%LOG_FILE%"

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
echo [%DATE% %TIME%] --- Finalizando AtivadorLuffy.bat com erro critico --- >> "%LOG_FILE%"
endlocal
exit /b 999