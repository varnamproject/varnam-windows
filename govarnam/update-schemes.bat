@echo off

setlocal enabledelayedexpansion

:: Set the GitHub API URL for the latest release of varnamproject schemes
set "api_url=https://api.github.com/repos/varnamproject/schemes/releases/latest"

:: Set the directory path for the schemes to the current directory
set "schemes_path=%cd%\schemes"

:: Check for the 'update-schemes' command-line argument
set "should_update=0"
if "%~1"=="update-schemes" set "should_update=1"

:: Determine if updating is necessary
set "perform_update=0"
if "%should_update%"=="1" set "perform_update=1"
if not exist "%schemes_path%" set "perform_update=1"

:: Only proceed with update if necessary
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
    
    echo Files in 'schemes':
    dir "%schemes_path%"
) else (
    echo No update required or no argument provided.
)

endlocal
