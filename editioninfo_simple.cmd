@ECHO OFF
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "wt", "cmd.exe /k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
setlocal EnableExtensions EnableDelayedExpansion

title Windows Edition Info Simple

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
pause
