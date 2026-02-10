@echo off
echo ========================================
echo   Royal Charir Installer v1.0.0
echo ========================================
echo.

set "INSTALL_DIR=%LOCALAPPDATA%\RoyalCharir"
set "DATA_DIR=%USERPROFILE%\Documents\RoyalCharir"

echo Menginstall ke: %INSTALL_DIR%
echo Data akan disimpan di: %DATA_DIR%
echo.

:: Buat direktori instalasi
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%DATA_DIR%" mkdir "%DATA_DIR%"
if not exist "%DATA_DIR%\Backups" mkdir "%DATA_DIR%\Backups"

:: Copy files
echo Menyalin file aplikasi...
xcopy /E /Y /Q "%~dp0*" "%INSTALL_DIR%\" >nul
del "%INSTALL_DIR%\install.bat" 2>nul
del "%INSTALL_DIR%\uninstall.bat" 2>nul

:: Create shortcuts
echo Membuat shortcut...
powershell -Command " = New-Object -ComObject WScript.Shell;  = .CreateShortcut('%USERPROFILE%\Desktop\Royal Charir.lnk'); .TargetPath = '%INSTALL_DIR%\royal_charir_app.exe'; .WorkingDirectory = '%INSTALL_DIR%'; .Save()"
powershell -Command " = New-Object -ComObject WScript.Shell;  = .CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Royal Charir.lnk'); .TargetPath = '%INSTALL_DIR%\royal_charir_app.exe'; .WorkingDirectory = '%INSTALL_DIR%'; .Save()"

echo.
echo ========================================
echo   Instalasi Selesai!
echo ========================================
echo.
echo PENTING:
echo - Data bisnis Anda tersimpan di: %DATA_DIR%
echo - Folder ini AMAN dari update/reinstall
echo - Selalu backup data secara rutin!
echo.
echo Shortcut telah dibuat di Desktop.
echo.
pause
