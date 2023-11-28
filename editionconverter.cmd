@ECHO OFF
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "wt", "cmd.exe /k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
setlocal EnableExtensions EnableDelayedExpansion

title Windows Edition Converter

set image=%HOMEDRIVE%\image
set scratchdir=%HOMEDRIVE%\scratchdir
set /p driveletter=Please enter the drive letter for the Windows image: 
echo.
if not exist "%driveletter%:\sources\boot.wim" (
	echo. Can't find Windows installation files in the specified drive letter...
	echo.
	echo. Please enter the correct drive Letter...
	goto :EOF
)

if not exist "%driveletter%:\sources\install.wim" (
	echo. Can't find Windows installation files in the specified drive letter...
	echo.
	echo. Please enter the correct drive Letter...
	goto :EOF
)
cls
md %image%
echo Copying Windows image...
xcopy /E /I /H /R /Y /J %driveletter%: %image% >nul
echo Copy complete!
sleep 2
cls

echo Getting image information:
dism /Get-WimInfo /wimfile:%image%\sources\install.wim
echo.
set /p index=Please enter the image index: 
echo Mounting Windows image. This may take a while.
md %HOMEDRIVE%\scratchdir
dism /mount-image /imagefile:%image%\sources\install.wim /index:%index% /mountdir:%HOMEDRIVE%\scratchdir
cls

dism /image:%HOMEDRIVE%\scratchdir /get-targeteditions
echo.
set /p edition=Choose the edition you want to upgrade to: 
set /p key=Enter your Product Key: 
if "%key%" EQU "" (dism /image:%HOMEDRIVE%\scratchdir /set-edition:%edition%) else (dism /image:%HOMEDRIVE%\scratchdir /set-edition:%edition% /set-productkey:%key%)
cls

echo Unmounting image...
dism /unmount-image /mountdir:%HOMEDRIVE%\scratchdir /commit
echo Creating ISO image...
%~dp0oscdimg.exe -m -o -u2 -udfver102 -bootdata:2#p0,e,b%image%\boot\etfsboot.com#pEF,e,b%image%\efi\microsoft\boot\efisys.bin %image% %~dp0image.iso
echo Creation completed. Press any key to exit the script...
pause

echo Performing cleanup...
rd %image% /s /q
rd %HOMEDRIVE%\scratchdir /s /q