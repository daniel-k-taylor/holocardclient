@echo off
setlocal

set "DirectoryPath=D:\Projects\godot\holocardclient\export"
set "BulterPath=D:\Projects\butler"
set "ProjectName=holoduel"

REM Delete the existing game.zip if it exists
if exist "%DirectoryPath%\game.zip" (
    del "%DirectoryPath%\game.zip"
)

REM Zip all the contents of the directory into game.zip
powershell -command "Compress-Archive -Path '%DirectoryPath%\*' -DestinationPath '%DirectoryPath%\game.zip'"

if errorlevel 1 (
    echo Error occurred while creating game.zip.
    exit /b 1
)

REM Call butler.exe with the path to game.zip
set "butlerCommand=%BulterPath%\butler.exe"
if not exist "%butlerCommand%" (
    echo butler.exe not found. Please make sure it is in the current directory or provide the full path.
    exit /b 1
)

"%butlerCommand%" push "%DirectoryPath%\game.zip" daktagames/%ProjectName%:html5

endlocal
