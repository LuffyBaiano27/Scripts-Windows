@echo off
setlocal EnableExtensions DisableDelayedExpansion

REM --- Configuracoes ---
set "MAS_SCRIPT_NAME=MAS_AIO.cmd"
set "LOG_FILE=C:\AtivadorLuffyOnline_Log.txt"
set "HWID_PARAM=/HWID"       REM Parametro para ativar Windows via HWID
set "OHOOK_PARAM=/Ohook"     REM Parametro para ativar Office via Ohook
set "PING_TARGET=1.1.1.1"    REM Servidor para testar conectividade
set "PING_TIMEOUT_MS=1500"   REM Tempo maximo para esperar a resposta do ping (1.5 segundos)
REM --- Fim das Configuracoes ---

REM --- Variaveis Internas ---
set "MAS_SCRIPT_PATH=%~dp0%MAS_SCRIPT_NAME%"
set "NETWORK_AVAILABLE=0"
set "HWID_SUCCESS=0"
set "OHOOK_SUCCESS=0"
set "HWID_ERRORLEVEL=0"
set "OHOOK_ERRORLEVEL=0"
set "ERROR_DETAILS="
set "FINAL_ERRORLEVEL=998" REM Codigo de erro inicial (assume falha)
REM --- Fim Variaveis Internas ---

REM --- Inicio do Log ---
echo. >> "%LOG_FILE%"
echo [%DATE% %TIME%] --- Iniciando AtivadorLuffyOnline.bat --- >> "%LOG_FILE%"

REM Verifica se o script principal do MAS existe
if not exist "%MAS_SCRIPT_PATH%" (
    set ERROR_DETAILS=Nao foi possivel encontrar %MAS_SCRIPT_NAME% em %~dp0
    echo [%DATE% %TIME%] ERRO CRITICO: %ERROR_DETAILS% >> "%LOG_FILE%"
    echo ERRO CRITICO: O script %MAS_SCRIPT_NAME% nao foi encontrado!
    echo Verifique se ele esta na mesma pasta que AtivadorLuffyOnline.bat e se o nome esta correto.
    goto :EndScriptWithError
)

REM --- Verifica Conectividade com a Rede (ESSENCIAL para HWID e recomendado para Ohook) ---
echo [%DATE% %TIME%] Verificando conectividade com a rede (ping %PING_TARGET%)... >> "%LOG_FILE%"
ping -n 1 -w %PING_TIMEOUT_MS% %PING_TARGET% > nul 2>&1
if %ERRORLEVEL% EQU 0 (
    set NETWORK_AVAILABLE=1
    echo [%DATE% %TIME%] Rede detectada (conectada). >> "%LOG_FILE%"
) else (
    set NETWORK_AVAILABLE=0
    set ERROR_DETAILS=Rede nao detectada ou indisponivel. Ativacao HWID/Ohook requer conexao com a internet.
    echo [%DATE% %TIME%] ERRO: %ERROR_DETAILS% >> "%LOG_FILE%"
    echo ERRO: Rede nao detectada ou indisponivel.
    echo A ativacao HWID/Ohook requer conexao com a internet e provavelmente falhara.
    REM Aborta para automacao WDS, pois a chance de sucesso e baixa sem rede.
    goto :EndScriptWithError
)

REM --- Executa Ativacao HWID do Windows ---
echo Executando ativacao HWID do Windows... Por favor, aguarde.
echo [%DATE% %TIME%] Executando: "%MAS_SCRIPT_PATH%" %HWID_PARAM% >> "%LOG_FILE%"

call "%MAS_SCRIPT_PATH%" %HWID_PARAM%
set HWID_ERRORLEVEL=%ERRORLEVEL%

if %HWID_ERRORLEVEL% EQU 0 (
    set HWID_SUCCESS=1
    echo [%DATE% %TIME%] SUCESSO: Ativacao HWID do Windows concluida (Codigo 0). >> "%LOG_FILE%"
    echo Ativacao HWID do Windows: SUCESSO
) else (
    set HWID_SUCCESS=0
    echo [%DATE% %TIME%] ERRO: Ativacao HWID do Windows falhou (Codigo: %HWID_ERRORLEVEL%). >> "%LOG_FILE%"
    echo Ativacao HWID do Windows: FALHA (Erro: %HWID_ERRORLEVEL%)
)
echo.

REM --- Executa Ativacao Ohook do Office ---
echo Executando ativacao Ohook do Office... Por favor, aguarde.
echo [%DATE% %TIME%] Executando: "%MAS_SCRIPT_PATH%" %OHOOK_PARAM% >> "%LOG_FILE%"

call "%MAS_SCRIPT_PATH%" %OHOOK_PARAM%
set OHOOK_ERRORLEVEL=%ERRORLEVEL%

if %OHOOK_ERRORLEVEL% EQU 0 (
    set OHOOK_SUCCESS=1
    echo [%DATE% %TIME%] SUCESSO: Ativacao Ohook do Office concluida (Codigo 0). >> "%LOG_FILE%"
    echo Ativacao Ohook do Office: SUCESSO
) else (
    set OHOOK_SUCCESS=0
    echo [%DATE% %TIME%] ERRO: Ativacao Ohook do Office falhou (Codigo: %OHOOK_ERRORLEVEL%). >> "%LOG_FILE%"
    echo Ativacao Ohook do Office: FALHA (Erro: %OHOOK_ERRORLEVEL%)
)
echo.

REM --- Verifica o Resultado Final ---
if %HWID_SUCCESS% EQU 1 if %OHOOK_SUCCESS% EQU 1 (
    set FINAL_ERRORLEVEL=0
    echo [%DATE% %TIME%] RESULTADO FINAL: SUCESSO (Ambas as ativacoes concluidas). >> "%LOG_FILE%"
    echo --------------------------------------------------
    echo Ativacao HWID (Windows) e Ohook (Office) concluidas com exito.
    echo --------------------------------------------------
) else (
    echo [%DATE% %TIME%] RESULTADO FINAL: FALHA (Pelo menos uma ativacao falhou). >> "%LOG_FILE%"
    echo **************************************************
    echo ERRO: Pelo menos uma das ativacoes (HWID ou Ohook) falhou.
    if %HWID_SUCCESS% EQU 0 echo  - Falha no HWID (Erro: %HWID_ERRORLEVEL%)
    if %OHOOK_SUCCESS% EQU 0 echo  - Falha no Ohook (Erro: %OHOOK_ERRORLEVEL%)
    echo Verifique o log em %LOG_FILE% para mais detalhes.
    echo **************************************************
    REM Define o codigo de erro final como o primeiro erro encontrado (prioriza HWID)
    if %HWID_ERRORLEVEL% NEQ 0 (
      set FINAL_ERRORLEVEL=%HWID_ERRORLEVEL%
    ) else (
      set FINAL_ERRORLEVEL=%OHOOK_ERRORLEVEL%
    )
)
echo.

:EndScriptCommon
echo [%DATE% %TIME%] --- Finalizando AtivadorLuffyOnline.bat --- >> "%LOG_FILE%"

REM Pausa opcional para visualizacao em execucao manual (remova ou comente para WDS)
REM echo Pressione qualquer tecla para sair...
REM pause > nul

endlocal
REM Sai do script retornando 0 se ambos OK, ou o codigo do primeiro erro encontrado.
exit /b %FINAL_ERRORLEVEL%

:EndScriptWithError
echo.
echo %ERROR_DETAILS%
echo Verifique o log em %LOG_FILE%.
REM Pausa para ver o erro em execucao manual
echo Pressione qualquer tecla para sair...
pause > nul
echo [%DATE% %TIME%] --- Finalizando AtivadorLuffyOnline.bat com erro critico --- >> "%LOG_FILE%"
endlocal
exit /b 999