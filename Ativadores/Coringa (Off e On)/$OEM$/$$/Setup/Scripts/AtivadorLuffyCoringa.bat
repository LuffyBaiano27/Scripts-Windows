@echo off
setlocal EnableExtensions DisableDelayedExpansion

REM --- Configuracoes ---
set "MAS_SCRIPT_NAME=MAS_AIO.cmd"
set "LOG_FILE=C:\AtivadorLuffyCoringa_Log.txt"
set "HWID_PARAM=/HWID"
set "OHOOK_PARAM=/Ohook"
set "TSFORGE_SCOPE_PARAM=/Z-WindowsESUOffice"
set "BUILD_THRESHOLD=26100" REM Build a partir da qual ZeroCID pode nao funcionar e KMS4k e necessario offline
set "PING_TARGET=1.1.1.1"
set "PING_TIMEOUT_MS=1000"
REM --- Fim das Configuracoes ---

REM --- Variaveis Internas ---
set "MAS_SCRIPT_PATH=%~dp0%MAS_SCRIPT_NAME%"
set "NETWORK_AVAILABLE=0"
set "BUILD_NUMBER=0"
set "HWID_ATTEMPTED=0"
set "HWID_SUCCESS=0"
set "HWID_ERRORLEVEL=-1"
set "OHOOK_ATTEMPTED=0"
set "OHOOK_SUCCESS=0"
set "OHOOK_ERRORLEVEL=-1"
set "TSFORGE_ATTEMPTED=0"
set "TSFORGE_SUCCESS=0"
set "TSFORGE_ERRORLEVEL=-1"
set "TSFORGE_METHOD_PARAM="
set "TSFORGE_METHOD_USED="
set "WINDOWS_ACTIVATED=0"
set "OFFICE_ACTIVATED=0"
set "ERROR_DETAILS="
set "FINAL_ERRORLEVEL=998" REM Codigo de erro inicial (assume falha)
REM --- Fim Variaveis Internas ---

REM --- Inicio do Log ---
echo. >> "%LOG_FILE%"
echo [%DATE% %TIME%] --- Iniciando AtivadorLuffyCoringa.bat --- >> "%LOG_FILE%"

REM Verifica se o script principal do MAS existe
if not exist "%MAS_SCRIPT_PATH%" (
    set ERROR_DETAILS=Nao foi possivel encontrar %MAS_SCRIPT_NAME% em %~dp0
    echo [%DATE% %TIME%] ERRO CRITICO: %ERROR_DETAILS% >> "%LOG_FILE%"
    echo ERRO CRITICO: O script %MAS_SCRIPT_NAME% nao foi encontrado!
    echo Verifique se ele esta na mesma pasta que este script.
    goto :EndScriptWithError
)

REM --- Detecta a Build do Windows ---
echo [%DATE% %TIME%] Detectando a build do Windows... >> "%LOG_FILE%"
for /f "tokens=2 delims=[]" %%G in ('ver') do for /f "tokens=2,3,4 delims=. " %%H in ("%%~G") do set "BUILD_NUMBER=%%J"
if "%BUILD_NUMBER%"=="0" ( for /f "skip=2 tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuildNumber 2^>nul') do set "BUILD_NUMBER=%%b" )
if "%BUILD_NUMBER%"=="0" (
    echo [%DATE% %TIME%] AVISO: Nao foi possivel detectar a build. Usando ZeroCID como fallback offline. >> "%LOG_FILE%"
    set BUILD_NUMBER=10240
) else ( echo [%DATE% %TIME%] Build do Windows detectada: %BUILD_NUMBER% >> "%LOG_FILE%" )

REM --- Verifica Conectividade com a Rede ---
echo [%DATE% %TIME%] Verificando conectividade com a rede... >> "%LOG_FILE%"
ping -n 1 -w %PING_TIMEOUT_MS% %PING_TARGET% > nul 2>&1
if %ERRORLEVEL% EQU 0 ( set NETWORK_AVAILABLE=1 & echo [%DATE% %TIME%] Rede detectada (conectada). >> "%LOG_FILE%" ) else ( set NETWORK_AVAILABLE=0 & echo [%DATE% %TIME%] Rede nao detectada (offline). >> "%LOG_FILE%" )

REM --- Tenta Ativacao HWID (Windows - Online) ---
if %NETWORK_AVAILABLE% EQU 1 (
    set HWID_ATTEMPTED=1
    echo Executando ativacao HWID do Windows (requer online)...
    echo [%DATE% %TIME%] Executando: "%MAS_SCRIPT_PATH%" %HWID_PARAM% >> "%LOG_FILE%"
    call "%MAS_SCRIPT_PATH%" %HWID_PARAM%
    set HWID_ERRORLEVEL=%ERRORLEVEL%
    if %HWID_ERRORLEVEL% EQU 0 (
        set HWID_SUCCESS=1
        set WINDOWS_ACTIVATED=1
        echo [%DATE% %TIME%] SUCESSO: HWID do Windows concluido (Codigo 0). >> "%LOG_FILE%"
        echo Ativacao HWID do Windows: SUCESSO
    ) else (
        echo [%DATE% %TIME%] ERRO: HWID do Windows falhou (Codigo: %HWID_ERRORLEVEL%). >> "%LOG_FILE%"
        echo Ativacao HWID do Windows: FALHA (Erro: %HWID_ERRORLEVEL%)
    )
) else (
    echo [%DATE% %TIME%] INFO: Pular HWID do Windows (offline). >> "%LOG_FILE%"
    echo Pulando ativacao HWID do Windows (offline).
    set HWID_ERRORLEVEL=-1 REM Indica que foi pulado
)
echo.

REM --- Tenta Ativacao Ohook (Office - Online/Offline) ---
set OHOOK_ATTEMPTED=1
echo Executando ativacao Ohook do Office...
echo [%DATE% %TIME%] Executando: "%MAS_SCRIPT_PATH%" %OHOOK_PARAM% >> "%LOG_FILE%"
call "%MAS_SCRIPT_PATH%" %OHOOK_PARAM%
set OHOOK_ERRORLEVEL=%ERRORLEVEL%
if %OHOOK_ERRORLEVEL% EQU 0 (
    set OHOOK_SUCCESS=1
    set OFFICE_ACTIVATED=1
    echo [%DATE% %TIME%] SUCESSO: Ohook do Office concluido (Codigo 0). >> "%LOG_FILE%"
    echo Ativacao Ohook do Office: SUCESSO
) else (
    echo [%DATE% %TIME%] ERRO: Ohook do Office falhou (Codigo: %OHOOK_ERRORLEVEL%). >> "%LOG_FILE%"
    echo Ativacao Ohook do Office: FALHA (Erro: %OHOOK_ERRORLEVEL%)
)
echo.

REM --- Tenta Ativacao TSforge (Fallback Windows + ESU + Office - Offline) se HWID falhou ou foi pulado ---
if %HWID_SUCCESS% NEQ 1 (
    set TSFORGE_ATTEMPTED=1
    REM --- Escolhe o Metodo TSforge OFFLINE ---
    if %BUILD_NUMBER% GEQ %BUILD_THRESHOLD% ( set TSFORGE_METHOD_PARAM=/Z-KMS4k & set TSFORGE_METHOD_USED=KMS4k ) else ( set TSFORGE_METHOD_PARAM=/Z-ZCID & set TSFORGE_METHOD_USED=ZeroCID )
    echo [%DATE% %TIME%] Metodo TSforge offline escolhido para fallback: %TSFORGE_METHOD_USED% (%TSFORGE_METHOD_PARAM%) >> "%LOG_FILE%"

    echo Executando ativacao TSforge como fallback (%TSFORGE_METHOD_USED%)...
    echo [%DATE% %TIME%] Executando: "%MAS_SCRIPT_PATH%" %TSFORGE_SCOPE_PARAM% %TSFORGE_METHOD_PARAM% >> "%LOG_FILE%"
    call "%MAS_SCRIPT_PATH%" %TSFORGE_SCOPE_PARAM% %TSFORGE_METHOD_PARAM%
    set TSFORGE_ERRORLEVEL=%ERRORLEVEL%
    if %TSFORGE_ERRORLEVEL% EQU 0 (
        set TSFORGE_SUCCESS=1
        REM Assume que TSForge ativou o Windows se HWID falhou
        set WINDOWS_ACTIVATED=1
        REM TSForge tambem pode ter ativado o Office, entao marcamos como sucesso se Ohook falhou
        if %OHOOK_SUCCESS% EQU 0 set OFFICE_ACTIVATED=1
        echo [%DATE% %TIME%] SUCESSO: TSforge concluido (Codigo 0). >> "%LOG_FILE%"
        echo Ativacao TSforge (%TSFORGE_METHOD_USED%): SUCESSO
    ) else (
        echo [%DATE% %TIME%] ERRO: TSforge falhou (Codigo: %TSFORGE_ERRORLEVEL%). >> "%LOG_FILE%"
        echo Ativacao TSforge (%TSFORGE_METHOD_USED%): FALHA (Erro: %TSFORGE_ERRORLEVEL%)
    )
    echo.
) else (
    echo [%DATE% %TIME%] INFO: Pular TSforge (HWID para Windows foi bem-sucedido). >> "%LOG_FILE%"
    echo Pulando TSforge (HWID para Windows foi bem-sucedido).
    echo.
)

REM --- Verifica o Resultado Final ---
if %WINDOWS_ACTIVATED% EQU 1 if %OFFICE_ACTIVATED% EQU 1 (
    set FINAL_ERRORLEVEL=0
    echo [%DATE% %TIME%] RESULTADO FINAL: SUCESSO (Windows e Office ativados). >> "%LOG_FILE%"
    echo --------------------------------------------------
    echo Ativacao concluida com exito para Windows e Office.
    echo --------------------------------------------------
) else (
    echo [%DATE% %TIME%] RESULTADO FINAL: FALHA (Pelo menos um produto nao foi ativado). >> "%LOG_FILE%"
    echo **************************************************
    echo ERRO: Falha ao ativar um ou ambos os produtos.
    if %WINDOWS_ACTIVATED% EQU 0 echo  - Falha na ativacao do Windows (HWID Erro: %HWID_ERRORLEVEL%, TSforge Erro: %TSFORGE_ERRORLEVEL%)
    if %OFFICE_ACTIVATED% EQU 0 echo  - Falha na ativacao do Office (Ohook Erro: %OHOOK_ERRORLEVEL%, TSforge Erro: %TSFORGE_ERRORLEVEL%)
    echo Verifique o log em %LOG_FILE% para mais detalhes.
    echo **************************************************
    REM Define o codigo de erro final
    if %HWID_ATTEMPTED% EQU 1 if %HWID_ERRORLEVEL% NEQ 0 (
      set FINAL_ERRORLEVEL=%HWID_ERRORLEVEL%
    ) else if %OHOOK_ATTEMPTED% EQU 1 if %OHOOK_ERRORLEVEL% NEQ 0 (
      set FINAL_ERRORLEVEL=%OHOOK_ERRORLEVEL%
    ) else if %TSFORGE_ATTEMPTED% EQU 1 if %TSFORGE_ERRORLEVEL% NEQ 0 (
      set FINAL_ERRORLEVEL=%TSFORGE_ERRORLEVEL%
    ) else (
      REM Se chegou aqui com erro mas nenhum codigo foi capturado, define um generico
      if %FINAL_ERRORLEVEL% EQU 998 set FINAL_ERRORLEVEL=1
    )
)
echo.

:EndScriptCommon
echo [%DATE% %TIME%] --- Finalizando AtivadorLuffyCoringa.bat --- >> "%LOG_FILE%"

REM Pausa opcional para visualizacao em execucao manual
REM echo Pressione qualquer tecla para sair...
REM pause > nul

endlocal
exit /b %FINAL_ERRORLEVEL%

:EndScriptWithError
echo.
echo %ERROR_DETAILS%
echo Verifique o log em %LOG_FILE%.
REM Pausa para ver o erro em execucao manual
echo Pressione qualquer tecla para sair...
pause > nul
echo [%DATE% %TIME%] --- Finalizando AtivadorLuffyCoringa.bat com erro critico --- >> "%LOG_FILE%"
endlocal
exit /b 999