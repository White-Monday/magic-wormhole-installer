:: --- MAGIC WORMHOLE INSTALLER FOR WINDOWS ---
:: Author: Federico Bosetti


@echo off
chcp 65001 >nul

:: 1. Define Escape Character (ESC)
for /f "tokens=1 delims=#" %%a in ('"prompt #$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%a"

:: 2. Parameters check
if "%~1" neq "" (
    call :colorText "TITLE" "PARAMETERS DETECTED"
    if exist "%~1" (
        call :colorText "WARNING" "This script does not accept files or directories as parameters."
        pause & exit /b
    )
    if "%~2" neq "" (
        call :colorText "WARNING" "This script accepts maximum one parameter."
        pause & exit /b
    )
    call :colorText "INFO" "This script let you install Magic Wormhole and all the dependencies on your system. It does not accept parameters."
    pause & exit /b
)

setlocal enabledelayedexpansion

:: 3. Administrative Privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    call :colorText "TITLE" "ADMINISTRATIVE PRIVILEGES REQUIRED"
    call :colorText "WARNING" "Administrative privileges required..."
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)


:: 4. PATH Refresh Function (to call after each installation)
call :refreshPath

call :colorText "TITLE" "CHECKING SYSTEM FOR MAGIC WORMHOLE AND DEPENDENCIES"





:: -----------------------------
:: --- REVERSE CASCADE LOGIC ---
:: -----------------------------


:: CHECK 1: Magic Wormhole
echo.
call :colorText "TITLE" "CHECK 1: Magic Wormhole"
where wormhole >nul 2>&1
if %errorlevel% == 0 (
    call :colorText "SUCCESS" "Magic Wormhole is already installed and working."
    goto :end
) else (
    call :colorText "WARNING" "Magic Wormhole not found. Checking dependencies..."
)


:: CHECK 2: Pipx
echo.
call :colorText "TITLE" "CHECK 2: Pipx"
where pipx >nul 2>&1
if %errorlevel% == 0 (
    call :colorText "SUCCESS" "Pipx is already installed and working."
    goto :install_mw
) else (
    call :colorText "WARNING" "Pipx not found. Checking Python..."
)


:: CHECK 3: Python
echo.
call :colorText "TITLE" "CHECK 3: Python"
where python >nul 2>&1
if %errorlevel% == 0 (
    call :colorText "SUCCESS" "Python is already installed and working."
    goto :install_pipx
) else (
    call :colorText "WARNING" "Python not found."
    :: call :colorText "PROGRESS" "Checking for Python in common install locations..."
    :: TODO: Add check for python in common install locations (e.g., Microsoft Store, WindowsApps)
    :: User could have Python installed but not in PATH, especially if installed from Microsoft Store.
    goto :install_python
)





:: ---------------------------
:: ----- ACTION SECTIONS -----
:: ---------------------------


:install_python
echo.
call :colorText "TITLE" "INSTALLING PYTHON"
call :colorText "PROGRESS" "Python installation in progress..."
goto :try_winget


:try_winget
where winget >nul 2>&1
if %errorlevel% neq 0 goto :try_chocolatey
call :colorText "PROGRESS" "Trying with WinGet..."
winget install 9NQ7512CXL7T --source winget --accept-package-agreements --accept-source-agreements
if %errorlevel% == 0 goto :success_python
call :colorText "ERROR" "Python installation via WinGet failed."


:try_chocolatey
where choco >nul 2>&1
if %errorlevel% neq 0 goto :try_scoop
call :colorText "PROGRESS" "Trying with Chocolatey..."
choco install python --yes
if %errorlevel% == 0 goto :success_python
call :colorText "ERROR" "Python installation via Chocolatey failed."


:try_scoop
where scoop >nul 2>&1
if %errorlevel% neq 0 goto :try_curl
call :colorText "PROGRESS" "Trying with Scoop..."
scoop install python
if %errorlevel% == 0 goto :success_python
call :colorText "ERROR" "Python installation via Scoop failed."


:try_curl
where curl >nul 2>&1
if %errorlevel% neq 0 goto :manual_install_python
call :colorText "PROGRESS" "Trying with Curl..."
call :colorText "PROGRESS" "Trying to download MSIX package (Microsoft Store)..."
set "PY_MSIX=%temp%\python-installer.msix"
set "PY_MSIX_URL=https://www.python.org/ftp/python/pymanager/python-manager-26.1.msix"
curl -L --connect-timeout 10 -o "%PY_MSIX%" "%PY_MSIX_URL%"
if %errorlevel% neq 0 (
    call :colorText "ERROR" "MSIX package download failed."
    call :deleteFile "%PY_MSIX%"
    goto :try_curl_exe
)
call :verifyFile "%PY_MSIX%"
if %errorlevel% neq 0 (
    call :colorText "ERROR" "Downloaded MSIX file is invalid."
    call :deleteFile "%PY_MSIX%"
    goto :try_curl_exe
)
call :colorText "PROGRESS" "Installing package..."
powershell -Command "Add-AppxPackage -Path '%PY_MSIX%'"
if %errorlevel% == 0 (
    call :deleteFile "%PY_MSIX%"
    goto :success_python
) else (
    call :colorText "ERROR" "MSIX installation failed."
    call :deleteFile "%PY_MSIX%"
    goto :try_curl_exe
)


:try_curl_exe
call :colorText "PROGRESS" "Downloading traditional EXE installer..."
set "PY_VER=3.14.4"
set "PY_EXE=%temp%\python-installer.exe"
set "PY_EXE_URL=https://www.python.org/ftp/python/%PY_VER%/python-%PY_VER%-%PC_ARCH%.exe"
call :determineArchitecture
curl -L --connect-timeout 10 -o "%PY_EXE%" "%PY_EXE_URL%"
if %errorlevel% neq 0 (
    call :colorText "ERROR" "Python installer download failed."
    call :deleteFile "%PY_EXE%"
    goto :manual_install_python
)
call :verifyFile "%PY_EXE%"
if %errorlevel% neq 0 (
    call :colorText "ERROR" "Downloaded installer file is invalid."
    call :deleteFile "%PY_EXE%"
    goto :manual_install_python
)
call :colorText "PROGRESS" "Starting silent installation (EXE)..."
start /wait "" "%PY_EXE%" /quiet PrependPath=1 Include_test=0 Include_pip=1
if %errorlevel% == 0 (
    call :deleteFile "%PY_EXE%"
    goto :success_python
) else (
    call :colorText "ERROR" "EXE installation failed."
    call :deleteFile "%PY_EXE%"
    goto :manual_install_python
)


:manual_install_python
echo.
call :colorText "ERROR" "Unable to install Python automatically."
call :colorText "WARNING" "Download and install Python manually from https://www.python.org/downloads/"
call :colorText "PROGRESS" "Follow the instructions to install Python. Make sure to select \"Add Python to PATH\"."
start "" "https://www.python.org/downloads/"
if %errorlevel% neq 0 (
    call :colorText "ERROR" "Unable to open browser. Please go to https://www.python.org/downloads/ manually."
)
pause & exit /b


:success_python
echo.
call :colorText "SUCCESS" "Python installed. Automatically restarting script..."
timeout /t 3 >nul
start "" "%~f0"
exit /b


:install_pipx
echo.
call :colorText "TITLE" "INSTALLING PIPX"
call :colorText "PROGRESS" "Upgrading pip and installing pipx via pip..."
python -m pip install --user --upgrade pip
if %errorlevel% neq 0 (
    call :colorText "ERROR" "Pip upgrade failed. Check your connection or Python installation."
)
python -m pip install --user pipx
if %errorlevel% neq 0 (
    call :colorText "ERROR" "Pipx installation failed. Check your connection or Python installation."
    pause & exit /b
)
:: Path Configuration
python -m pipx ensurepath >nul 2>&1
if %errorlevel% neq 0 (
    call :colorText "ERROR" "Failed to configure PATH for pipx. You may need to add it manually."
    call :colorText "INFO" "Pipx is typically installed in %USERPROFILE%\.local\bin. Add this to your PATH environment variable."
    pause & exit /b
)
call :refreshPath
call :colorText "SUCCESS" "Pipx installed successfully."


:install_mw
echo.
call :colorText "TITLE" "INSTALLING MAGIC WORMHOLE"
call :colorText "PROGRESS" "Installing Magic Wormhole..."
pipx install magic-wormhole
if %errorlevel% neq 0 (
    call :colorText "ERROR" "Critical error during Magic Wormhole installation."
    pause & exit /b
)
call :colorText "SUCCESS" "Magic Wormhole installed successfully."


:end
echo.
call :colorText "TITLE" "MAGIC WORMHOLE IS READY TO USE"
echo.
call :colorText "INFO" "Type 'wormhole' to get started."
call :colorText "INFO" "Read README.md for available commands."
echo.
pause & exit /b





:: ---------------------------
:: ------- SUBROUTINES -------
:: ---------------------------


:refreshPath
for /f "tokens=2*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "REG_USER=%%B"
for /f "tokens=2*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "REG_SYS=%%B"
set "PATH=!REG_USER!;!REG_SYS!"
call :addPathIfMissing "%USERPROFILE%\.local\bin"
call :addPathIfMissing "%APPDATA%\Python\Scripts"
goto :eof


:addPathIfMissing
if exist "%~1" (
    echo "%PATH%" | findstr /I /C:";%~1;" >nul
    set "check1=!errorlevel!"
    echo "%PATH%" | findstr /I /C:"%~1;" >nul
    set "check2=!errorlevel!"
    if !check1! neq 0 if !check2! neq 0 (
        set "tempPath=%PATH%;%~1"
        set "length=0"
        set "testStr=!tempPath!"
        for /L %%A in (0,1,8192) do (
            if "!testStr:~%%A,1!" neq "" set /a length=%%A + 1
        )
        if !length! geq 8000 (
            call :colorText "ERROR" "PATH near limit (8192)! Cannot add: %~1"
            call :colorText "WARNING" "Consider removing unnecessary entries from PATH to avoid future issues."
            call :colorText "INFO" "Current PATH length: !length! characters."
        ) else (
            set "PATH=%PATH%;%~1"
        )
    )
)
goto :eof



:deleteFile
set "target=%~1"
if exist "%target%" (
    del "%target%" >nul 2>&1
    if !errorlevel! neq 0 (
        call :colorText "ERROR" "Impossible to delete %target% if it exists."
        call :colorText "WARNING" "Please check the file and delete it manually: %target%"
    )
)
goto :eof


:verifyFile
set "file=%~1"
if not exist "%file%" (
    call :colorText "ERROR" "File non trovato: %file%"
    exit /b 1
)
for %%I in ("%file%") do if %%~zI equ 0 (
    call :colorText "ERROR" "Download corrotto (0 KB): %file%"
    call :deleteFile "%file%"
    exit /b 1
)
exit /b 0


:determineArchitecture
set "PC_ARCH=amd64"
if "%PROCESSOR_ARCHITECTURE%"=="x86" if "%PROCESSOR_ARCHITEW6432%"=="" set "PC_ARCH=win32"
call :colorText "INFO" "Architecture detected: %PC_ARCH%"
goto :eof


:colorText
setlocal disabledelayedexpansion
set "type=%~1"
set "msg=%~2"
set "pre="
set "colorCode=1"
if /i "%type%"=="ERROR"    (set "colorCode=91" & set "pre=[ERR] ")
if /i "%type%"=="SUCCESS"  (set "colorCode=92" & set "pre=[OK] ")
if /i "%type%"=="WARNING"  (set "colorCode=93" & set "pre=[!] ")
if /i "%type%"=="INFO"     (set "colorCode=96" & set "pre=[?] ")
if /i "%type%"=="PROGRESS" (set "colorCode=1"  & set "pre=[*] ")
if /i "%type%"=="TITLE"    (set "colorCode=1"  & set "pre=---- %msg%" & set "msg= ----")
echo %ESC%[%colorCode%m%pre%%msg%%ESC%[0m
endlocal
goto :eof