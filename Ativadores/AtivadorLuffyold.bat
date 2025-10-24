@echo off
setlocal EnableExtensions DisableDelayedExpansion

REM --- Configuracoes ---
REM Nome do script principal do MAS (deve estar na mesma pasta)
set "MAS_SCRIPT_NAME=MAS_AIO.cmd"
REM Parametro para executar TSforge -> Activate All
set "MAS_PARAMETER=/Z-WindowsESUOffice"
REM Arquivo para registrar o log da operacao
set "LOG_FILE=C:\AtivadorLuffy_Log.txt"
REM --- Fim das Configuracoes ---

REM Define o caminho completo para o script principal do MAS
set "MAS_SCRIPT_PATH=%~dp0%MAS_SCRIPT_NAME%"

REM --- Inicio do Log ---
echo. >> "%LOG_FILE%"
echo [%DATE% %TIME%] --- Iniciando AtivadorLuffy.bat --- >> "%LOG_FILE%"
echo [%DATE% %TIME%] Tentando executar %MAS_SCRIPT_NAME% com o parametro %MAS_PARAMETER% >> "%LOG_FILE%"

REM Verifica se o script principal do MAS existe
if not exist "%MAS_SCRIPT_PATH%" (
    echo [%DATE% %TIME%] ERRO CRITICO: Nao foi possivel encontrar o script %MAS_SCRIPT_NAME% em %~dp0 >> "%LOG_FILE%"
    echo ERRO CRITICO: O script %MAS_SCRIPT_NAME% nao foi encontrado!
    echo Verifique se ele esta na mesma pasta que AtivadorLuffy.bat e se o nome esta correto.
    echo [%DATE% %TIME%] --- Finalizando AtivadorLuffy.bat com erro --- >> "%LOG_FILE%"
    timeout /t 10 > nul
    exit /b 999
)

REM Executa o script MAS com o parametro desejado
echo Executando ativacao automatica (TSforge - All)... Por favor, aguarde. O processo pode levar alguns minutos.

call "%MAS_SCRIPT_PATH%" %MAS_PARAMETER%

REM Verifica o codigo de saida (ERRORLEVEL) do script MAS
if %ERRORLEVEL% EQU 0 (
    echo [%DATE% %TIME%] SUCESSO: O script %MAS_SCRIPT_NAME% foi concluido com exito (Codigo 0). >> "%LOG_FILE%"
    echo.
    echo --------------------------------------------------
    echo Ativacao automatica (TSforge - All) concluida com exito.
    echo --------------------------------------------------
    echo.
    set FINAL_ERRORLEVEL=0
) else (
    echo [%DATE% %TIME%] ERRO: O script %MAS_SCRIPT_NAME% retornou um erro (Codigo: %ERRORLEVEL%). >> "%LOG_FILE%"
    echo.
    echo **************************************************
    echo ERRO durante a ativacao automatica (TSforge - All).
    echo Codigo de erro retornado pelo script principal: %ERRORLEVEL%
    echo Verifique o log em %LOG_FILE% para mais detalhes (se disponiveis no script principal).
    echo **************************************************
    echo.
    set FINAL_ERRORLEVEL=%ERRORLEVEL%
)

echo [%DATE% %TIME%] --- Finalizando AtivadorLuffy.bat --- >> "%LOG_FILE%"

REM Pausa opcional para visualizacao em execucao manual (remova ou comente para WDS)
REM echo Pressione qualquer tecla para sair...
REM pause > nul

endlocal
REM Sai do script retornando o codigo de erro original do MAS
exit /b %FINAL_ERRORLEVEL%