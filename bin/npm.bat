@echo OFF

echo Installing node modules
echo .......................

echo Updating NPM ...
cmd /c npm i -g npm
echo Installing forever ...
cmd /c npm i -g forever
echo.

cd "%SystemDrive%\helper"
cmd /c npm i
cmd /c npm audit fix
cmd /c npm audit

cd "%SystemDrive%\var\www\meteor\bundle\programs\server"
cmd /c npm i
cmd /c npm audit fix
cmd /c npm audit

pause
