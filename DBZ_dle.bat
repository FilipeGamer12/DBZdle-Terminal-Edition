@echo off
setlocal enabledelayedexpansion
color a
chcp 65001 > nul
set "raiz=%cd%"
Title DBZ dle - Terminal edition

:Main
cls
echo.
echo Carregando...

if not exist "%raiz%\jsoncmd.exe" set err="jsoncmd.exe não encontrado!" && goto :erro
if not exist "%raiz%\data.json" set err="data.json não encontrado!" && goto :erro
if exist "%raiz%\results.cmd" del "%raiz%\results.cmd"

:: --- Carrega nomes
set i=0
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[].nome') do (
    :: %%b contem " Nome" (com espaco). O for/f abaixo remove espacos externos.
    for /f "delims=" %%c in ("%%b") do (
        set /a i+=1
        set "PERS[!i!]=%%c"
    )
)

if %i% EQU 0 (
    echo Nenhum personagem encontrado.
    pause
    exit /b 1
)

:: Seleciona personagem aleatorio
set /a CHOICE=%RANDOM% %% i + 1
set "dle=!PERS[%CHOICE%]!"

:: Calcula indice zero-based para usar no json (personagens[IDX])
set /a IDX=%CHOICE% - 1

:: --- Consulta outras chaves do personagem selecionado e salva em variaveis
:: RACA
set "RACA="
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%IDX%].raca') do (
    for /f "delims=" %%d in ("%%b") do set "RACA=%%d"
)

:: SAGA
set "SAGA="
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%IDX%].saga') do (
    for /f "delims=" %%d in ("%%b") do set "SAGA=%%d"
)

:: SAGAID
set "SAGAID="
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%IDX%].sagaid') do (
    for /f "delims=" %%d in ("%%b") do set "SAGAID=%%d"
)

:: HABILIDADE
set "HABILIDADE="
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%IDX%].habilidade') do (
    for /f "delims=" %%d in ("%%b") do set "HABILIDADE=%%d"
)


:menu
cls
echo.
echo Selecione a opção desejada:
echo.
echo [1] Jogar
echo [2] Tutorial
echo [3] Listar personagens
echo [4] Datacenter
echo [5] Sair
echo.

choice /c 12345 /n /m "Digite> "
if errorlevel 5 exit
if errorlevel 4 goto :datacenter
if errorlevel 3 goto :lista
if errorlevel 2 goto :tutorial
if errorlevel 1 goto :game

goto :Main
pause



:game
cls
if exist "%raiz%\results.cmd" call "%raiz%\results.cmd"
echo.
::echo %dle%
echo Tente advinhar o personagem de hoje:
echo.
set /p try="Digite um nome> "
cls
goto :analise
pause


:analise
echo.
echo Analisando tentativa...

if exist "%raiz%\results.cmd" del "%raiz%\results.cmd"

:: --- encontra índice do try no array PERS
set "tryIDX="
for /L %%i in (1,1,%i%) do (
    if /I "!PERS[%%i]!"==" %try%" set "tryIDX=%%i" 
)

:: --- verifica se o jogador acertou
if "!tryIDX!"=="%CHOICE%" (
    goto :win
)

if "!tryIDX!"=="" (
    echo Personagem "%try%" não encontrado na lista.
    echo Verifique a ortografia ou tente novamente.
    pause
    goto :game
)

:: --- pega sagaid do personagem sorteado (IDX) e do try (tryIDX)
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%IDX%].sagaid') do set "sagaA=%%b"
set /a tryIDXjson=%tryIDX%-1
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%tryIDXjson%].sagaid') do set "sagaB=%%b"

:: --- Cria arquivo de resultados
echo echo Resultados da rodada: > "%raiz%\results.cmd"
echo echo Tentativa: %try% > "%raiz%\results.cmd"

:: --- Raça
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%IDX%].raca') do set "racaA=%%b"
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%tryIDXjson%].raca') do set "racaB=%%b"

if "%racaA%"==" None" (
    echo.
    echo Personagem "%try%" não encontrado na lista.
    echo Verifique a ortografia ou tente novamente.
    echo.
    pause
    if exist "%raiz%\results.cmd" del "%raiz%\results.cmd"
    goto :game
)

if "!racaA!"=="!racaB!" (
    echo echo "Raça : !racaA! [=]" >> "%raiz%\results.cmd"
) else (
    echo echo "Raça : !racaB! [X]" >> "%raiz%\results.cmd"
)


:: --- pega animeid do personagem sorteado (IDX) e do try (tryIDX)
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%IDX%].animeid') do set "animeA=%%b"
::set /a tryIDXjson=%tryIDX%-1
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%tryIDXjson%].animeid') do set "animeB=%%b"

:: --- Anime
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%IDX%].anime') do set "animeC=%%b"
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%tryIDXjson%].anime') do set "animeTryText=%%b"

if "!animeA!"=="!animeB!" (
    echo echo "Anime: !animeC! [=]" >> "%raiz%\results.cmd"
) else (
    if !animeA! gtr !animeB! (
        echo echo "Anime: !animeTryText! [-]" >> "%raiz%\results.cmd"
    ) else (
        echo echo "Anime: !animeTryText! [+]" >> "%raiz%\results.cmd"
    )
)


:: --- Sagas
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%IDX%].saga') do set "sagaC=%%b"
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%tryIDXjson%].saga') do set "sagaTryText=%%b"

if "!sagaA!"=="!sagaB!" (
    echo echo "Saga : !sagaC! [=]" >> "%raiz%\results.cmd"
) else (
    if !sagaA! gtr !sagaB! (
        echo echo "Saga : !sagaTryText! [-]" >> "%raiz%\results.cmd"
    ) else (
        echo echo "Saga : !sagaTryText! [+]" >> "%raiz%\results.cmd"
    )
)

goto :game


:win
cls
echo.
echo Analisando tentativa...
:: RACA
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%IDX%].raca') do set "RACA=%%b"

:: SAGA
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%IDX%].saga') do set "SAGA=%%b"

:: HABILIDADE
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%IDX%].habilidade') do set "HABILIDADE=%%b"

:: ANIME
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%IDX%].anime') do set "ANIME=%%b"

:: --- Mostra resultado
cls
echo.
echo Parabéns!, você acertou.
echo.
echo Personagem do dia: %dle%
echo.
echo Anime     : %ANIME%
echo Saga      : %SAGA%
echo Raça      : %RACA%
echo Habilidade: %HABILIDADE%
echo.
echo Pressione qualquer tecla para voltar ao menu.
pause > nul
goto :Main



:tutorial
cls
echo.
echo Você deve tentar advinhar o personagem de Dragon Ball.
echo Cada rodada, você vai receber dicas de acordo com as suas tentativas.
echo Alguns simbolos úteis:
echo.
echo [-] Abaixo da correta
echo [+] Acima da correta
echo [=] Correto
echo [X] Errado
echo.
echo Pressione qualquer tecla para voltar ao menu.
pause > nul
goto :menu


:lista
cls
echo.
echo Lista de personagens disponíveis:
echo.
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[].nome') do echo -%%b
echo.
echo Pressione qualquer tecla para voltar ao menu.
pause > nul
goto :menu


:datacenter
cls
echo.
echo Qual personagem você quer mais informações?
echo.
set /p esc="Digite> "
cls
echo.
echo Buscando informações...

set "escIDX="
for /L %%i in (1,1,%i%) do (
    if /I "!PERS[%%i]!"==" %esc%" set "escIDX=%%i" 
)

set /a escIDX=%escIDX%-1

for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%escIDX%].raca') do set "racaE=%%b"
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%escIDX%].saga') do set "sagaE=%%b"
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%escIDX%].habilidade') do set "habilidadeE=%%b"
for /f "tokens=1,* delims=:" %%a in ('jsoncmd.exe personagens[%escIDX%].anime') do set "animeE=%%b"


if "%escIDX%"=="" (
    echo.
    echo Personagem "%esc%" não encontrado na lista.
    echo Verifique a ortografia ou tente novamente.
    echo.
    pause
    goto :datacenter
)

if "%racaE%"==" None" (
    echo.
    echo Personagem "%esc%" não encontrado na lista.
    echo Verifique a ortografia ou tente novamente.
    echo.
    pause
    goto :datacenter
)

cls
echo.
echo Personagem:  %esc%
echo Raça      : %racaE%
echo Habilidade: %habilidadeE%
echo Anime     : %animeE%
echo Saga      : %sagaE%
echo.
echo Pressione qualquer tecla para voltar ao menu.
pause > nul
goto :menu


:erro
cls
echo.
echo A seguinte dependência está faltando:
echo %err%
echo.
echo Pressione qualquer tecla para sair.
pause > nul
exit 