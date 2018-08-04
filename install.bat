@echo OFF

cls

echo.
echo Setting up Meteor application
echo .............................
echo.
echo.
echo.

for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set mydate=%%c-%%b-%%a)
for /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do (set mytime=%%a%%b)
set TIMENOW=%mydate%_%mytime%

echo Checking windows architecture ...
echo.
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=x86 || set OS=x64
echo %OS% architecture detected
echo.

echo.
echo Terminating any running instances ...
echo.
schTasks /query /tn "Meteor helper application" >nul 2>&1
if %ERRORLEVEL% EQU 0 schTasks /end /tn "Meteor helper application"
call "%~dp0\bin\kill_processes.bat"
echo.

:TASKSEND
echo Reading configuration ...
echo.
set APPNAME=cosmoslabs
set "APPTITLE=Cosmos Labs"
set "INSTALLDIR=%SystemDrive%\var\www\meteor\"
set APPVER=0.0.0
set /A CLEANUP=0
set /A HELPER=0
set /A RUNAPP=0
set /A RESTART=0
set /A UNATTENDED=0
for /F "delims= " %%a in (%~dp0install_config) do (
  if /I %%a == labox (
    set APPNAME=LaBox
    set "APPTITLE=Laboratory management system"
  )
  if /I %%a == hosbox (
    set APPNAME=HosBox
    set "APPTITLE=Hospital management system"
  )
  if /I %%a == pharmbox (
    set APPNAME=PharmBox
    set "APPTITLE=Pharmacy management system"
  )
  if /I %%a == iobox (
    set APPNAME=IOBox
    set "APPTITLE=Messages management system"
  )
  if /I %%a == givebox (
    set APPNAME=GiveBox
    set "APPTITLE=Charity organization management system"
  )
  if /I %%a == helper set /A HELPER=1
  if /I %%a == run set /A RUNAPP=1
  if /I %%a == cleanup set /A CLEANUP=1
  if /I %%a == restart set /A RESTART=1
  if /I %%a == unattended set /A UNATTENDED=1
  if /I %%a == eraseall set /A ERASEALL=1
)
for /F "delims= " %%a in (%~dp0version) do (
  set APPVER=%%a
)

echo.
echo ...........................................
echo Installing %APPTITLE%
echo version: %APPVER%
echo ...........................................
echo.

if %ERASEALL% EQU 1 (
  cmd /c "%~dp0\cleanup.bat" "true"
) else (
  if %CLEANUP% EQU 1 call "%~dp0cleanup.bat"
)

echo.
echo Detecting machine name ...
echo.
for /f "skip=1 delims=" %%A in (
  'wmic computersystem get name'
) do for /f "delims=" %%B in ("%%A") do set "COMPNAME=%%A"
echo Machine name {%COMPNAME%}
echo.

if %HELPER% EQU 1 (
  echo.
  echo Copying helper application files ...
  echo.
  xcopy "%~dp0helper" "%SystemDrive%\helper\" /s /e /f /j /h /y
  echo.
)

echo Copying scripting files ...
echo.
for %%i in ("%~dp0bin\*.bat") do xcopy "%%i" "%SystemDrive%\scripts\" /f /j /h /y
for %%i in ("%~dp0bin\*.vbs") do xcopy "%%i" "%SystemDrive%\scripts\" /f /j /h /y
echo.

call "%~dp0installdeps.bat"

set CURRENTVER=0.0.0
for /f "usebackq eol=H tokens=2*" %%D IN (`reg query "HKLM\SOFTWARE\Cosmos Labs\%APPNAME%" /v Version`) do (
  set CURRENTVER=%%E
)

if CURRENTVER==0.0.0 (
  echo Installing %APPNAME% version %APPVER%
) else (
  echo Current version: %CURRENTVER%
  echo Installer version: %APPVER%
)

if %CURRENTVER%==%APPVER% (
  echo.
  echo Same version exists
  echo Skipping ...
  echo.
  goto SCHEDULETASKS
) else (
  echo.
  echo Differant version detected
  echo Replacing ...
  echo.
  goto COPYAPPFILES
)

:COPYAPPFILES
if %OS%==x86 (
  if exist "%~dp0x86\bundle\" goto RENFILES
  if exist "%~dp0x86\bundle.tar" goto RENFILES
  if exist "%~dp0x86\bundle.tar.xz" goto RENFILES
  if exist "%~dp0x86\bundle.7z" (
    goto RENFILES
  ) else goto EXTRACTFILES
)
if %OS%==x64 (
  if exist "%~dp0x64\bundle\" goto RENFILES
  if exist "%~dp0x64\bundle.tar" goto RENFILES
  if exist "%~dp0x64\bundle.tar.xz" goto RENFILES
  if exist "%~dp0x64\bundle.7z" (
    goto RENFILES
  ) else goto EXTRACTFILES
)

:RENFILES
if exist "%INSTALLDIR%\bundle\" (
  echo Bundle folder exists
  echo Renaming ...
  ren "%INSTALLDIR%\bundle\" "bundle_%TIMENOW%"
  echo.
)
if exist "%INSTALLDIR%\bundle.tar" (
  echo Bundle tar archive exists
  echo Renaming ...
  ren "%INSTALLDIR%\bundle.tar" "bundle_%TIMENOW%.tar"
  echo.
)
if exist "%INSTALLDIR%\bundle.tar.xz" (
  echo Bundle tar.xz archive exists
  echo Renaming ...
  ren "%INSTALLDIR%\bundle.tar.xz" "bundle_%TIMENOW%.tar.xz"
  echo.
)
if exist "%INSTALLDIR%\bundle.7z" (
  echo Bundle 7z archive exists
  echo Renaming ...
  ren "%INSTALLDIR%\bundle.7z" "bundle_%TIMENOW%.7z"
  echo.
)

echo.
echo Copying application core files ...
echo.
if not exist %INSTALLDIR% mkdir %INSTALLDIR%
if %OS%==x86 xcopy /s /e /j /h /y /i "%~dp0x86" %INSTALLDIR%
if %OS%==x64 xcopy /s /e /j /h /y /i "%~dp0x64" %INSTALLDIR%

:EXTRACTFILES
if exist "%INSTALLDIR%\bundle.tar.xz" (
  if %UNATTENDED% EQU 0 (
    start cmd /k "%~dp0extract.bat"
    echo.
    echo Please wait until extraction is completed
    echo.
    pause
  ) else call "%~dp0extract.bat"
  goto CHECKBUNDLEDIR
)
if exist "%INSTALLDIR%\bundle.tar" (
  if %UNATTENDED% EQU 0 (
    start cmd /k "%~dp0extract.bat"
    echo.
    echo Please wait until extraction is completed
    echo.
    pause
  ) else call "%~dp0extract.bat"
  goto CHECKBUNDLEDIR
)
if exist "%INSTALLDIR%\bundle.7z" (
  if %UNATTENDED% EQU 0 (
    start cmd /k "%~dp0extract.bat"
    echo.
    echo Please wait until extraction is completed
    echo.
    pause
  ) else call "%~dp0extract.bat"
)

:CHECKBUNDLEDIR
if not exist "%INSTALLDIR%\bundle\" goto UNKOWNERROR

echo.
echo Writing registry values ...
echo.
REG ADD "HKLM\SOFTWARE\Cosmos Labs\%APPNAME%" /v "InstallDir" /t REG_SZ /d %INSTALLDIR% /f
REG ADD "HKLM\SOFTWARE\Cosmos Labs\%APPNAME%" /v "Version" /t REG_SZ /d "0.11.50" /f
REG ADD "HKLM\SOFTWARE\Cosmos Labs\%APPNAME%" /v "Helper" /t REG_DWORD /d %HELPER% /f
echo.

:SCHEDULETASKS
echo.
echo Creating scheduled tasks ...
echo.
call "%~dp0\bin\schedule.bat"
echo.

echo.
echo Creating shortcuts ...
echo.
::for /f "usebackq eol=H tokens=2*" %%D IN (`reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v Desktop`) do (
::  if exist %%E (
::    set "DESKTOPDIR=%%E"
::  ) else (
::    set "DESKTOPDIR=%USERPROFILE%\Desktop"
::  )
::)

echo Desktop directory is "%SystemDrive%\Users\Public\Desktop"
::xcopy /h /y "%~dp0bin\Server.bat" "%DESKTOPDIR%"
mklink "%SystemDrive%\Users\Public\Desktop\Server.lnk" "%SystemDrive%\scripts\Server.bat"
echo [InternetShortcut] > "%SystemDrive%\Users\Public\Desktop\Sys.url"
echo URL="http://localhost:8000" >> "%SystemDrive%\Users\Public\Desktop\Sys.url"
echo.

if %UNATTENDED% EQU 0 (
  start cmd /k "%SystemDrive%\scripts\npm.bat"
  echo.
  echo Please wait until modules installation is completed
  echo.
  pause
) else call "%SystemDrive%\scripts\npm.bat"

echo.
echo Finished
echo.

if %RUNAPP% EQU 0 (
echo Bye!
) else (
  schTasks /query /tn "Meteor helper application" >nul 2>&1
  if %ERRORLEVEL% EQU 0 (
    echo.
    echo Terminating any running instances ...
    echo.
    schTasks /end /tn "Meteor helper application"
    call "%~dp0\bin\kill_processes.bat"
    echo.
    schTasks /run /tn "Meteor helper application"
  ) else (
    goto UNKOWNERROR
  )
)
goto FINISH

:UNKOWNERROR
echo.
echo Something went wrong
echo Installation didn't completed as expected
echo.

:FINISH
echo.
echo.
echo.

echo ----------------------------------------------------
echo.
echo Setup went to an end and will exit installer
echo review steps above to be sure before proceed
echo.
echo ----------------------------------------------------

echo.
echo.
echo.

if %UNATTENDED% EQU 0 pause

::cmd /c "%userprofile%\Desktop\Server.bat"
if %RESTART% EQU 0 (
  exit
) else (
  shutdown /r /t 0
)
