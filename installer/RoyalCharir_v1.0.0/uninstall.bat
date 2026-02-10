@echo off
echo ========================================
echo   Royal Charir Uninstaller
echo ========================================
echo.
echo PERHATIAN: Ini akan menghapus aplikasi Royal Charir.
echo Data bisnis Anda di folder Documents\RoyalCharir TIDAK akan dihapus.
echo.
set /p confirm="Lanjutkan uninstall? (y/n): "
if /i not "%confirm%"=="y" goto :cancel

set "INSTALL_DIR=%LOCALAPPDATA%\RoyalCharir"

echo Menghapus aplikasi...
rmdir /S /Q "%INSTALL_DIR%" 2>nul

echo Menghapus shortcut...
del "%USERPROFILE%\Desktop\Royal Charir.lnk" 2>nul
del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Royal Charir.lnk" 2>nul

echo.
echo Uninstall selesai!
echo Data bisnis Anda tetap tersimpan di Documents\RoyalCharir
echo.
pause
goto :end

:cancel
echo Uninstall dibatalkan.
pause

:end
