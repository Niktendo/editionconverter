@ECHO OFF
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "wt", "cmd.exe /k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
setlocal EnableExtensions EnableDelayedExpansion

title Windows Edition Info

set /p image=Please enter the drive letter for the Windows image: 
echo.
if not exist "%image%\sources\boot.wim" (
	echo. Can't find Windows installation files in the specified drive letter...
	echo.
	echo. Please enter the correct drive Letter...
	goto :EOF
)

if not exist "%image%\sources\install.*" (
	echo. Can't find Windows installation files in the specified drive letter...
	echo.
	echo. Please enter the correct drive Letter...
	goto :EOF
)
cls
echo Getting image information:
dism /Get-WimInfo /wimfile:%image%\sources\install.wim
dism /Get-WimInfo /wimfile:%image%\sources\install.esd
echo.
set /p index=Please enter the image index: 
echo Mounting Windows image. This may take a while.
md %HOMEDRIVE%\scratchdir
dism /mount-image /imagefile:%image%\sources\install.wim /index:%index% /mountdir:%HOMEDRIVE%\scratchdir /ReadOnly
dism /mount-image /imagefile:%image%\sources\install.esd /index:%index% /mountdir:%HOMEDRIVE%\scratchdir /ReadOnly
cls

dism /image:%HOMEDRIVE%\scratchdir /get-targeteditions
echo.
pause
cls

echo Unmounting image...
dism /unmount-image /mountdir:%HOMEDRIVE%\scratchdir /discard
pause

echo Performing cleanup...
rd %HOMEDRIVE%\scratchdir /s /q
