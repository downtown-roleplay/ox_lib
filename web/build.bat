@echo off
cd /d "%~dp0"

echo ===================================
echo Instalando dependencias com npm...
echo ===================================
call pnpm i

echo.
echo Pressione qualquer tecla para continuar...
pause >nul

echo.
echo ===========================
echo Escolha uma opçao:
echo 1. Build (compilar)
echo 2. Watch (modo desenvolvimento)
echo ===========================
set /p choice="Digite sua opçao (1-2): "

if "%choice%"=="1" (
    call pnpm build
    pause
) else if "%choice%"=="2" (
    call pnpm start
    pause
) else (
    echo Opçao invalida.
    pause
)