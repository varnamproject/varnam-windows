@echo off

setlocal enabledelayedexpansion

:: Set the GitHub API URL for the latest release
set "api_url=https://api.github.com/repos/varnamproject/schemes/releases/latest"

:: Set .libvarnam schemes directory path
set "govarnam_path=C:\Users\%USERNAME%\.libvarnam"

:: Set .libvarnam\schemes directory path
set "schemes_path=%govarnam_path%\schemes"

:: Check for the 'update-schemes' command-line argument
set "should_update=0"
if "%~1"=="update-schemes" set "should_update=1"

:: Determine if updating is necessary
set "perform_update=0"
if "%should_update%"=="1" set "perform_update=1"
if not exist "%schemes_path%" set "perform_update=1"

:: Only update if necessary
if "%perform_update%"=="1" (
    echo Updating schemes...

    :: Clear the target directory if it exists
    if exist "%schemes_path%" rd /s /q "%schemes_path%"
    mkdir "%schemes_path%"

    :: Use PowerShell to download and unzip files from the latest release
    powershell -Command ^
        "$response = Invoke-RestMethod -Uri '%api_url%'; " ^
        "foreach ($asset in $response.assets) { " ^
        "   if ($asset.name -like '*.zip') { " ^
        "       $zipUrl = $asset.browser_download_url; " ^
        "       $zipResponse = Invoke-WebRequest -Uri $zipUrl -UseBasicParsing; " ^
        "       $zipFile = [System.IO.Path]::Combine('%schemes_path%', $asset.name); " ^
        "       [System.IO.File]::WriteAllBytes($zipFile, $zipResponse.Content); " ^
        "       Expand-Archive -Path $zipFile -DestinationPath '%schemes_path%'; " ^
        "       Remove-Item $zipFile; " ^
        "   } " ^
        "}"
    
    echo Files in '.libvarnam\schemes':
    dir "%schemes_path%"
) else (
    echo No update required or no argument provided.
)

SET "CGO_CFLAGS=-Dvarnam_EXPORTS"
SET CGO_ENABLED=1

REM Getting the last commit from git
for /f %%i in ('git rev-parse --short HEAD 2^>nul') do SET "LAST_COMMIT=%%i"

REM Create a temporary file
SET TEMP_FILE=%TEMP%\gitversion.txt

REM Run the Git command and redirect output to the temporary file
git describe --abbrev=0 --tags > "%TEMP_FILE%" 2>nul

REM Read the output from the temporary file
SET /p VERSION=<"%TEMP_FILE%"

REM Delete the temporary file
DEL "%TEMP_FILE%"

REM Check if VERSION is empty and set to latest if necessary
if "%VERSION%"=="" SET "VERSION=latest"

REM Strip leading 'v' from VERSION if present
SET VERSION=%VERSION:v=%

REM Build string with UTC time
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set "today=%%c-%%a-%%b"
for /f "tokens=1-3 delims=:. " %%a in ('time /t') do set "now=%%a:%%b:%%c"
SET "BUILDSTR=%VERSION% (#%LAST_COMMIT% %today%T%now%Z)"

SET "LIB_NAME=libgovarnam.dll"
SET INSTALL_DIR=C:\lib

REM Print all constructed values for debugging
echo "CGO_CFLAGS: %CGO_CFLAGS%"
echo "CGO_ENABLED: %CGO_ENABLED%"
echo "LAST_COMMIT: %LAST_COMMIT%"
echo "VERSION: %VERSION%"
echo "BUILDSTR: %BUILDSTR%"
echo "LIB_NAME: %LIB_NAME%"
echo "INSTALL_DIR: %INSTALL_DIR%"

REM Build the DLL
go build -tags "fts5" -buildmode=c-shared -ldflags "-s -w -X 'github.com/varnamproject/govarnam/govarnam.BuildString=%BUILDSTR%' -X 'github.com/varnamproject/govarnam/govarnam.VersionString=%VERSION%'" -o %LIB_NAME% .
if %errorlevel% neq 0 exit /b %errorlevel%

REM Check if the install directory exists, create it if it doesn't
IF NOT EXIST "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

REM Copy the DLL to the install directory
copy %LIB_NAME% "%INSTALL_DIR%" > nul
if %errorlevel% neq 0 exit /b %errorlevel%

REM Check if INSTALL_DIR is in PATH; if not, append it
echo %PATH% | findstr /C:"%INSTALL_DIR%" > nul
IF %errorlevel% NEQ 0 SETX PATH "%PATH%;%INSTALL_DIR%"

echo Installation completed. DLL copied to %INSTALL_DIR%
