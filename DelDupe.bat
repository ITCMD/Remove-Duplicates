@echo off
if "%~1"=="/?" goto help
set ran=%random%%random%%random%
set char=~
if /i "%~3"=="/c" set char=%~4
if /i "%~4"=="/c" set char=%~5
if /i "%~3"=="/f" set Force=True
if /i "%~4"=="/f" set Force=True
if /i "%~5"=="/f" set Force=True
if not "%~3"=="" set char=%~3
set PathF=%1
set PathN=%~1
Set FileName=%~2
pushd %pathF%
echo Listing Duplicates . . .
dir /b /s "%FileName%" >"%TEMP%\%ran%.ITCMD.log"
popd
echo.>"%TEMP%\%ran%.ITCMD.txt"
echo.>"%TEMP%\%ran%.ITCMD.inf"
setlocal EnableDelayedExpansion
echo Processing . . .
for /f "UseBackQ tokens=*" %%A in ("%TEMP%\%ran%.ITCMD.log") do (
	for %%B in ("%%A") do set FileDate=%%~tB
	echo %%A!char!!FileDate! >>"%TEMP%\%ran%.ITCMD.txt"
	)
echo Sorting . . .
::for /f "tokens=1,2,3* delims=~" %%A in (Owe.txt) do (

set num=0
for /f "UseBackQ tokens=1,2* delims=%char%" %%A in ("%TEMP%\%ran%.ITCMD.txt") do (
	set /a num+=1
	set path!num!=%%A
	set ModD!num!=%%B
	echo !num! %%B >>"%TEMP%\%ran%.ITCMD.inf"
)
set count=%num%
::Rem %%A number %%B month %%C Day %%D Year %%E Hour %%F Minute
for /f "UseBackQ tokens=1,2,3,4,5,6* delims=/,:, " %%A in ("%TEMP%\%ran%.ITCMD.inf") do (
	set CurrentTopDate=%%D/%%B/%%C%%E:%%F
	set CurrentTopNumb=%%A
	goto endinit
)
:endinit
for /f "UseBackQ skip=1 tokens=1,2,3,4,5,6* delims=/,:, " %%A in ("%TEMP%\%ran%.ITCMD.inf") do (
	if %%D/%%B/%%C%%E:%%F GTR !CurrentTopDate! set CurrentTopNumb=%%A
	if %%D/%%B/%%C%%E:%%F GTR !CurrentTopDate! set CurrentTopDate=%%D/%%B/%%C%%E:%%F
)
set /a del=%count%-1
echo Found Most Recently Modified File: !path%CurrentTopNumb%!
echo                     Modified Date: !ModD%CurrentTopNumb%!
echo                          Deleting: %del% Files of %count% Duplicates.
findstr /V /c:"!path%CurrentTopNumb%!" ""%TEMP%\%ran%.ITCMD.log"" >"%TEMP%\%ran%.ITCMD.delete"
type "%TEMP%\%ran%.ITCMD.delete"

if /i not define Force (
			echo.
			echo Are You sure you want to delete the older files?
			choice /c YN
			if %errorlevel%==2 goto cleanup
		)
echo Deleting . . .
for /f "UseBackQ tokens=*" %%A in ("%TEMP%\%ran%.ITCMD.delete") do (del /f /q "%%A")
echo Completed.
:cleanup
echo Cleaning Up . . .
del /f /q "%TEMP%\%ran%.ITCMD.*"
popd
exit /b


:help
set _FN=%~n0
echo %_FN%| find " ">nul
if %errorlevel%==1 set _FN="%~n0"
echo Deletes duplicate Files except the latest edited.
echo.
echo %_FN%  "Directory" "Filename" /F /C Char
	
