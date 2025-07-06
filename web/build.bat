@echo off
cd /d "%~dp0"

echo ===================================
echo Detectando gerenciador de pacotes...
echo ===================================

set "PACKAGE_MANAGER="

where pnpm >nul 2>nul
if %errorlevel%==0 (
    goto :found_pnpm
)

where yarn >nul 2>nul
if %errorlevel%==0 (
    goto :found_yarn
)

where npm >nul 2>nul
if %errorlevel%==0 (
    goto :found_npm
)

echo Nenhum gerenciador de pacotes (pnpm, yarn ou npm) encontrado.
pause
exit /b

:found_pnpm
set "PACKAGE_MANAGER=pnpm"
goto :continue

:found_yarn
set "PACKAGE_MANAGER=yarn"
goto :continue

:found_npm
set "PACKAGE_MANAGER=npm"
goto :continue

:continue
echo Usando %PACKAGE_MANAGER%
echo ===================================

echo Instalando dependencias...
call %PACKAGE_MANAGER% install

echo.
echo Pressione qualquer tecla para continuar...
pause >nul

echo.
echo ===========================
echo Escolha uma opcao:
echo 1. Build (compilar)
echo 2. Watch (modo desenvolvimento)
echo ===========================
set /p choice="Digite sua opcao (1-2): "

if "%choice%"=="1" (
    call %PACKAGE_MANAGER% run build
    pause
) else if "%choice%"=="2" (
    call %PACKAGE_MANAGER% run start
    pause
) else (
    echo Opcao invalida.
    pause
)
