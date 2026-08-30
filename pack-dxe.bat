@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

set "RAR=C:\Program Files\WinRAR\Rar.exe"
if not exist "%RAR%" (
    echo [!] WinRAR not found: %RAR%
    pause
    exit /b 1
)

echo Deleting existing archive (if any)...
if exist "CTM-DXE-CN.rar" del /q "CTM-DXE-CN.rar"

set "LIST="
for /d %%D in (DXE*) do set "LIST=!LIST! "%%D""

echo Packaging DXE folders (excluding .kilo, tools) into CTM-DXE-CN.rar ...
"%RAR%" a -ep1 -r -o+ -m5 -x".kilo\*" -x"tools\*" "CTM-DXE-CN.rar" %LIST%

echo.
if errorlevel 1 (
    echo [!] Packaging failed.
) else (
    echo Done. Archive created: CTM-DXE-CN.rar
)
pause
endlocal
