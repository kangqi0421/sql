@echo off
setlocal
setlocal EnableDelayedExpansion
:: ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::   wls-basic-measurement.cmd  		v18.1
::  	- Invoke WLS Basic feature usage script.  Connects to a running WLS server and 
::		returns WLS Basic feature usage information.                 			       
::  :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: init variables
set SCRIPT_VERSION=18.1(%LMSCT_BUILD_VERSION%)
set PYFILE=..\resources\util\WLST\WLSBasic\wls-basic-measurement.py
set COMPARE_RESULT_FILE=compare_result.txt
echo. > %COMPARE_RESULT_FILE%

set INPUTSETUP=

:: check to see if LMSCollection is running, if it is, don't print the license prompt again
tasklist /v | findstr /C:"Oracle LMS Collection Script"
echo er %errorlevel%
if errorlevel 1 (
  goto printLicense
) else ( goto checkInput )

:printLicense 
set PYFILE=.\wls-basic-measurement.py
more ..\..\license_agreement.txt

:promptloop
set /p ANSWER=Accept License Agreement? (y\n\q)
   
if "%ANSWER%"=="y" (
       goto checkInput
) else if "%ANSWER%"=="n" (
       goto licagreement
) else if "%ANSWER%"=="q" (
       goto licagreement
) else ( goto promptloop )
   
:licagreement
echo.
echo You cannot run this program without agreeing to the license agreement.
goto endwls-basic-measurement

:checkInput
set "WLS_LICAGREE=!LICAGREE!"
if "%WLS_LICAGREE%" == "True" ( 
	goto endgetWLS_NUP
)


if "%INPUTSETUP%"=="q" (
	echo QUIT_WLST=q> %COMPARE_RESULT_FILE%
	goto endwls-basic-measurement
)

set MACHINE_NAME=%COMPUTERNAME%
set COMMANDLINE=



:getpMW_HOME
set pMW_HOME=

:getMW_HOME
set MW_HOME=%MW_HOME%

:promptMW_HOME
if NOT "%pMW_HOME%" == "" set MW_HOME=%pMW_HOME%
if "%MW_HOME%"=="q" (
	echo User chose to quit wls-basic-measurement.
	echo QUIT_WLST=q> %COMPARE_RESULT_FILE%
	goto endwls-basic-measurement
)
if "%MW_HOME%"=="quit" (
	echo User chose to quit wls-basic-measurement.
	echo QUIT_WLST=q> %COMPARE_RESULT_FILE%
	goto endwls-basic-measurement
)
if "%MW_HOME%"=="Q" (
	echo User chose to quit wls-basic-measurement.
	echo QUIT_WLST=q> %COMPARE_RESULT_FILE%
	goto endwls-basic-measurement
)

if not exist "%MW_HOME%\oracle_common\common\bin\wlst.cmd" (
	echo Directory %MW_HOME%\oracle_common\common\bin does not exist or contain wlst.cmd.
	echo "Please enter the MW_HOME location where WebLogic is installed"
	set /p pMW_HOME=or to quit the WebLogic Basic script, enter [quit or q]:
	goto getMW_HOME 

)

REM SETLOCAL

if exist "%MW_HOME%\wlserver\server\bin\setWLSEnv.cmd" (
	CALL "%MW_HOME%\wlserver\server\bin\setWLSEnv.cmd"
)

if exist "%MW_HOME%\wlserver_10.3\server\bin\setWLSEnv.cmd" (
	CALL "%MW_HOME%\wlserver\server\bin\setWLSEnv.cmd"
)

set CLASSPATH=%CLASSPATH%;%MW_HOME%\server\lib\wlst.jar;%MW_HOME%\server\lib\jython.jar;


@echo off


:: setup output dir
if not exist "%LMSCT_TMP%\WLSBasic" (
	md %LMSCT_TMP%\WLSBasic
)

"%MW_HOME%\oracle_common\common\bin\wlst.cmd" %PYFILE% %COMPUTERNAME%


:endwls-basic-measurement

@endlocal
ENDLOCAL
