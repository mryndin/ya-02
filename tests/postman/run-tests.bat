@echo off
setlocal enabledelayedexpansion

:: Дефолтные значения
set ENVIRONMENT=local
set FOLDER=
set REPORTERS=cli,htmlextra,junit
set BAIL=false
set TIMEOUT=10000
set USE_DOCKER=false

:parse_args
if "%~1"=="" goto end_parse
if "%~1"=="-e" (set ENVIRONMENT=%~2& shift & shift & goto parse_args)
if "%~1"=="--environment" (set ENVIRONMENT=%~2& shift & shift & goto parse_args)
if "%~1"=="-f" (set FOLDER=%~2& shift & shift & goto parse_args)
if "%~1"=="--folder" (set FOLDER=%~2& shift & shift & goto parse_args)
if "%~1"=="-r" (set REPORTERS=%~2& shift & shift & goto parse_args)
if "%~1"=="--reporters" (set REPORTERS=%~2& shift & shift & goto parse_args)
if "%~1"=="-b" (set BAIL=true& shift & goto parse_args)
if "%~1"=="--bail" (set BAIL=true& shift & goto parse_args)
if "%~1"=="-t" (set TIMEOUT=%~2& shift & shift & goto parse_args)
if "%~1"=="--timeout" (set TIMEOUT=%~2& shift & shift & goto parse_args)
if "%~1"=="-d" (set USE_DOCKER=true& shift & goto parse_args)
if "%~1"=="--docker" (set USE_DOCKER=true& shift & goto parse_args)
if "%~1"=="-h" goto show_usage
if "%~1"=="--help" goto show_usage
shift
goto parse_args

:end_parse

:: Проверка зависимостей
if "%USE_DOCKER%"=="true" (
    docker --version >nul 2>&1
    if errorlevel 1 (
        echo Error: Docker is not installed or not in PATH.
        exit /b 1
    )
) else (
    node --version >nul 2>&1
    if errorlevel 1 (
        echo Error: Node.js is not installed. Use -d to run in Docker.
        exit /b 1
    )
)

:: Подготовка аргументов для run-tests.js
set CMD_ARGS=--environment %ENVIRONMENT% --reporters %REPORTERS% --timeout %TIMEOUT%
if not "%FOLDER%"=="" set CMD_ARGS=%CMD_ARGS% --folder "%FOLDER%"
if "%BAIL%"=="true" set CMD_ARGS=%CMD_ARGS% --bail

:: Создание папки для отчетов
if not exist "reports" mkdir reports

:: Запуск
if "%USE_DOCKER%"=="true" (
    echo Running tests in Docker container...
    docker build -t cinemaabyss-api-tests .
    docker run --network=cinemaabyss-network -v "%cd%/reports:/app/reports" cinemaabyss-api-tests %CMD_ARGS%
) else (
    echo Running tests locally...
    node run-tests.js %CMD_ARGS%
)

goto :eof

:show_usage
echo Usage: run-tests.bat [options]
echo.
echo Options:
echo   -e, --environment ENV   Specify environment (local, docker)
echo   -f, --folder FOLDER     Run specific test folder
echo   -r, --reporters LIST    Comma-separated list of reporters
echo   -b, --bail              Stop on first error
echo   -t, --timeout MS        Request timeout in milliseconds
echo   -d, --docker            Run tests in Docker container
echo   -h, --help              Show this help message
exit /b 0