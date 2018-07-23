@echo OFF

echo Installing node modules
echo .......................

echo Updating NPM ...
cmd /c npm i -g npm
echo.

echo Installing helper node modules
cd "%SystemDrive%\helper"
cmd /c npm i
cmd /c npm audit fix
cmd /c npm audit
echo.

echo Installing Meteor.JS application node modules
cd "%SystemDrive%\var\www\meteor\bundle\programs\server"
cmd /c npm i
cmd /c npm audit fix
cmd /c npm audit
echo.

echo done

pause

exit /b
