@Echo off
SetLocal EnableDelayedExpansion
SetLocal EnableExtensions

:checking_connection_type 

setlocal 
for /f "delims=" %%i in (oracle_homes_a.txt) do (
    set  stOracleHome=%%i
    goto :endfor
)
:endfor

if exist oracle_homes_u.txt	 ( del oracle_homes_u.txt )

set "prev="
for /f "delims=" %%F in ('sort oracle_homes_a.txt') do (
  set "curr=%%F"
  setlocal enabledelayedexpansion
  if !prev! neq !curr! echo !curr!>> oracle_homes_u.txt
  endlocal
  set "prev=%%F"
)

if "!REMOTE_DB!" == "YES" ( goto :REMOTE_DB ) else (
		goto :WHILE_HOME)

:REMOTE_DB
echo REMOTE DB Script Start Time= %date%_%time% >> db_con_coll.log
set "DBLICAGREE=!LICAGREE!"
if "%DBLICAGREE%" == "True" ( set "DBLICAGREE=YES" ) else (
								set "DBLICAGREE=NO" )
set "DBALLPRODLIST=!ALLPRODLIST!"

IF /i "%DBALLPRODLIST:EBS=%"=="%DBALLPRODLIST%" (set "DBALLPRODLIST=DB") ELSE (set "DBALLPRODLIST=EBS~DB") 
set "SQLSCRIPT=db_conn_coll_main.sql"
set "V_SQL=%SQLSCRIPT% %DBLICAGREE% %DBALLPRODLIST%"

echo ------------------------------------------------------------------------------
echo Entering details for connecting SQL*Plus to the database via listener.
goto :ASK_FOR_CONNECTION_TYPE
EndLocal
Goto :EOF

REM CONNECT&COLLECT
:WHILE_HOME
	set ANSWER="n"
	echo.
	
	set ANSWER=%1
	set db_list=%2
	set ANSWER=%ANSWER:Y=y%
	set ANSWER=%ANSWER:N=n%
	if "%ANSWER%" == "y" goto :COLLECT_DB
	if "%ANSWER%" == "n" goto :PROMPT_DB 
	echo You have entered %ANSWER%. Try again and choose a valid option.
goto :WHILE_HOME

:COLLECT_DB
SetLocal EnableDelayedExpansion
set counter_=0
set ListDB1=%ListDB%


echo Script Start Time= %date%_%time% >> db_con_coll.log
		
for /f "skip=1 tokens=*" %%x in (!db_list!) do (
	set "pLINE=%%x"
	set "pLINE=!pLINE:,,=,#NULL#,!"
	set "pLINE=!pLINE:,,=,#NULL#,!"

	for /f "tokens=1,2,3,4,5,6,7,8,9,10,11,12,13,14 delims=," %%a in ("!pLINE!") do (			
		set "V_CONNECTION_METHOD=%%a"
		set "V_ORACLE_HOME_SERVER=%%b"
		set "V_ORACLE_SID=%%c"
		set "V_OS_USER=%%d"
		set "V_TNS_NAME=%%e"
		set "V_TNS_HOST=%%f"
		set "V_TNS_PORT=%%g"
		set "V_TNS_SERVICE_NAME=%%h"
		set "V_TNS_SID=%%i"
		set "V_DB_USER=%%j"
		set "V_SQL=%%k"
		set V_SQL=!V_SQL:^|=#!
		set "res=FALSE"
		set /A counter_+=1

		rem check DB selected from the list
		echo. !ListDB1! | findstr /C:",!counter_!," 1>nul && (
				set res=TRUE
			) || (
			    set res=FALSE
			)	

		if 	"%ANSWER%"=="y" set res=TRUE
		if 	"!res!"=="TRUE" (

			rem :LOCAL Connection
			if "!V_CONNECTION_METHOD!"=="LOCAL" ( 
			call :LOCAL_CONNECTION 
			)			
			
			rem :TNS_NAME
			if "!V_CONNECTION_METHOD!"=="TNS_NAME" ( 
			call :TNS_NAME_CONNECTION  
			)
										
			rem :HOST_PORT_SERVICE_NAME
			if "!V_CONNECTION_METHOD!"=="HOST_PORT_SERVICE_NAME"  (
			call :HOST_PORT_SERVICE_NAME 
			)
				
			rem :HOST_PORT_SID
			if "!V_CONNECTION_METHOD!"=="HOST_PORT_SID" (
			call :HOST_PORT_SID 	
			)				
		)
	)
)

echo Script End Time= %date%_%time% >> db_con_coll.log
	
Endlocal
goto :EOF

:PROMPT_DB
SetLocal EnableDelayedExpansion
SetLocal ENABLEEXTENSIONS
	set /A counter2=0
	
	echo All Databases
	
	for /f " skip=1 tokens=1,2,3 delims=, " %%a in (!db_list!) do (
		set /A counter2=counter2+1
		echo !counter2!	%%a %%c
		)
		echo Please insert wich DB you want to collect using following format list : 1,3,5
		set /p ListDB= Insert the list of databases
		set ListDB=,!ListDB!,
		goto :COLLECT_DB 
	
Endlocal		
goto :EOF

:CHECK_SQLPLUS
SetLocal 
	set V_ORACLE_HOME=%1
	if exist "%V_ORACLE_HOME%\bin\sqlplus.exe" (  set /A svar=0 ) else ( set /A svar=1	)
Endlocal & set "%~2=%svar%"
goto :EOF

:CHECK_TNSPING
SetLocal 
	set V_ORACLE_HOME=%1
	if exist "%V_ORACLE_HOME%\bin\tnsping.exe" (  set /A tvar=0) else ( set /A tvar=1 )
Endlocal & set "%~2=%tvar%"
goto :EOF

:CHECK_TNSPING_CONNECTION
setlocal
	%2\bin\tnsping %1 >> db_con_coll.log
	if "%errorlevel%"=="0" ( set /A tvar=0 ) else ( set /A tvar=1 )
endlocal & set "%~3=%tvar%"
goto :EOF

:CHECK_DB_USER
setlocal EnableDelayedExpansion
echo %~1 | FINDSTR /C:"as sysdba" >nul && (
	for /f "tokens=1" %%s in (%1) do ( 
		set "V_DB_USER=%%s"
		set "V_SYS= as sysdba"
		)
	)	|| ( set "V_DB_USER=%~1" 
			  set "V_SYS=") 
endlocal & set V_DB_USER=%V_DB_USER% & set V_SYS=%V_SYS% 
goto :EOF

:CHECK_LOCAL_DB

SetLocal ENABLEEXTENSIONS
	echo. > checkconn.txt
	set  SQLPLUS_ORACLE_HOME=%1
	set  NLS_LANG=AMERICAN_AMERICA.UTF8
	set  ORACLE_HOME=%1
	echo ------------------------------------------------------------------------------
	echo Trying to connect to local instance !V_ORACLE_SID!
	echo set echo off > check.db
	echo set verify off >> check.db
	echo set termout off >> check.db
	echo spool checkconn.txt >> check.db
	echo select 'Connected' ^|^| ' successfully' from v$database; >> check.db
	echo exit >> check.db
	echo Check Connection Local Database !V_ORACLE_SID!  %date%_%time% >> db_con_coll.log
	type check.db | %SQLPLUS_ORACLE_HOME%\bin\sqlplus  "/ as sysdba" >> db_con_coll.log 2>>&1
	type checkconn.txt >>db_con_coll.log
Endlocal
goto :EOF


:CHECK_TNS_NAME_DB

SetLocal ENABLEEXTENSIONS
	echo. > checkconn.txt
	set  V_DB_USER=%~1
	call :CHECK_DB_USER "%V_DB_USER%" %V_SYS%
	set  V_DB_PASSWORD=%2
	set  SQLPLUS_ORACLE_HOME=%3
	set  NLS_LANG=AMERICAN_AMERICA.UTF8
	set  ORACLE_HOME=%3
	set  V_TNS_NAME=%4
	echo Trying to connect to TNS_NAME !V_TNS_NAME!
	echo Check Connection TNS_NAME %4 %date%_%time% >>db_con_coll.txt
(
	echo set echo off
	echo set verify off
	echo set termout off
	echo set define off
	echo connect %V_DB_USER%/%V_DB_PASSWORD%@%V_TNS_NAME% %V_SYS%
	echo select 'Connected' ^^^|^^^| ' successfully' from v$database;
	echo exit
) | %SQLPLUS_ORACLE_HOME%\bin\sqlplus /nolog >checkconn.txt
	type checkconn.txt | findstr /c:"SP2-" /c:"ORA-" >>db_con_coll.log
Endlocal
goto :EOF


:CHECK_HOST_PORT_SERVICE_NAME

SetLocal ENABLEEXTENSIONS
	echo. > checkconn.txt 
	set  V_DB_USER=%~1
	call :CHECK_DB_USER "%V_DB_USER%" %V_SYS%
	set  V_DB_PASSWORD=%2
	set  SQLPLUS_ORACLE_HOME=%3
	set  NLS_LANG=AMERICAN_AMERICA.UTF8
	set  ORACLE_HOME=%3
	set  V_TNS_HOST=%4
	set  V_TNS_PORT=%5
	set  V_TNS_SERVICE_NAME=%6
	set  conn_str="(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = %V_TNS_HOST%)(PORT = %V_TNS_PORT%)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = %V_TNS_SERVICE_NAME%)))"
	echo Trying to connect to HOST %4
	echo Check Connection SERVICE_NAME %6  %date%_%time% >>db_con_coll.log
(
	echo set echo off
	echo set verify off
	echo set termout off
	echo set define off
	echo connect  %V_DB_USER%/%V_DB_PASSWORD%@%conn_str% %V_SYS%
	echo select 'Connected' ^^^|^^^| ' successfully' from v$database;
	echo exit
) | %SQLPLUS_ORACLE_HOME%\bin\sqlplus /nolog >checkconn.txt	
	type checkconn.txt | findstr /c:"SP2-" /c:"ORA-" >>db_con_coll.txt
Endlocal
goto :EOF


:CHECK_HOST_PORT_SID

SetLocal ENABLEEXTENSIONS
	echo. > checkconn.txt 
	set  V_DB_USER=%~1
	call :CHECK_DB_USER "%V_DB_USER%" %V_SYS%
	set  V_DB_PASSWORD=%2
	set  SQLPLUS_ORACLE_HOME=%3
	set  NLS_LANG=AMERICAN_AMERICA.UTF8
	set  ORACLE_HOME=%3
	set  V_TNS_HOST=%4
	set  V_TNS_PORT=%5
	set  V_TNS_SID=%6
	set  conn_str="(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=%V_TNS_HOST%)(PORT=%V_TNS_PORT%))(CONNECT_DATA=(SID=%V_TNS_SID%)))"
	echo Trying to connect to HOST %V_TNS_HOST% SID %V_TNS_SID%
	echo Check Connection HOST %4 SID %6 %date%_%time% >>db_con_coll.log
(
	echo set echo off
	echo set verify off
	echo set termout off
	echo set define off
	echo connect %V_DB_USER%/%V_DB_PASSWORD%@%conn_str% %V_SYS% 
	echo select 'Connected' ^^^|^^^| ' successfully' from v$database;
	echo exit
) | %SQLPLUS_ORACLE_HOME%\bin\sqlplus /nolog >checkconn.txt	
	type checkconn.txt | findstr /c:"SP2-" /c:"ORA-" >>db_con_coll.log
Endlocal
goto :EOF



:ORACLE_HOME_CHECK_SQLPLUS
SetLocal

	ECHO sqlplus is not found on %1\bin\ 
	
	set /p ANSWER1= Enter a valid ORACLE_HOME location for the SQL*Plus client to be used (y/n)?
	set ANSWER1=%ANSWER1:Y=y%
	set ANSWER1=%ANSWER1:N=n%
	
	if "%ANSWER1%" == "y" (
	
		set /p SORACLE_HOME=       Enter a valid ORACLE_HOME location for the SQL*Plus client to be used:
		echo  %SORACLE_HOME%
		set /p ANSWER2= Is this correct? [y/n]
		set ANSWER2=%ANSWER2:Y=y%
		set ANSWER2=%ANSWER2:N=n%

		if "%ANSWER2%" == "y" goto :EOF
		if "%ANSWER2%" == "n" ( 	echo ORACLE_HOME not set correctly - try again
								goto :ORACLE_HOME_CHECK_SQLPLUS )
	) 
	
	if "%ANSWER1%" == "n" (
		set SORACLE_HOME=
	)
	
Endlocal & set %1=%SORACLE_HOME%
goto :EOF


:ORACLE_HOME_CHECK_TNSPING
SetLocal
	ECHO tnsping is not found on %1\bin\ 
	
	set /p ANSWER1= Do you want to enter (again) the path for ORACLE_HOME (needed for the tnsping )? [y/n]
	set ANSWER1=%ANSWER1:Y=y%
	set ANSWER1=%ANSWER1:N=n%
	
	if "%ANSWER1%" == "y" (
	
		set /p SORACLE_HOME=       Enter a valid ORACLE_HOME location for the SQL*Plus client to be used:
		echo  %SORACLE_HOME%
		set /p ANSWER2= Is this correct? [y/n]
		set ANSWER2=%ANSWER2:Y=y%
		set ANSWER2=%ANSWER2:N=n%

		if "%ANSWER2%" == "y" goto :EOF
		if "%ANSWER2%" == "n" ( 	echo ORACLE_HOME not set correctly - try again
								goto :ORACLE_HOME_CHECK_SQLPLUS )
	) 
	
	if "%ANSWER1%" == "n" (
		set SORACLE_HOME=
	)
	
Endlocal & set %1=%SORACLE_HOME%
goto :EOF


:ORACLE_HOME_CHECK
SetLocal ENABLEEXTENSIONS
echo ------------------------------------------------------------------------------
echo Enter a valid ORACLE_HOME location for the SQL*Plus client to be used.

rem check if file is empty
set "filemask=oracle_homes_u.txt"
for %%A in (%filemask%) do if %%~zA LSS 3 ( goto :ENTER_OH )

echo Location(s) found on this machine:
type oracle_homes_u.txt
echo.

if defined stOracleHome (
	
	echo Enter ORACLE_HOME or press Return to accept the default
	echo !stOracleHome!
	set  "SORACLE_HOME=!stOracleHome!"
	set /p SORACLE_HOME=

	goto :OH
	)
	
if not defined 	stOracleHome (
	echo Enter ORACLE_HOME
	set /p SORACLE_HOME=

	goto :OH)
	
:ENTER_OH
	echo Enter a valid ORACLE_HOME location for the SQL*Plus client to be used
	set /p SORACLE_HOME=

:OH	

	
Endlocal & set "%1=%SORACLE_HOME%" & set "stOracleHome=%SORACLE_HOME%"
goto :EOF



:WRONG_HOMEMSG
echo.
echo sqlplus is not found or not executable at :  %SORACLE_HOME%bin
echo Please confirm location of ORACLE_HOME and that an sql client exists
echo.
goto :ORACLE_HOME_CHECK


:ASK_FOR_DB_PASSWORD


	:PINPUT
   SetLocal DisableDelayedExpansion
	
	echo ------------------------------------------------------------------------------ 
	Echo Enter password
   
   Set "Line="
   For /F %%# In (
   '"Prompt;$H&For %%# in (1) Do Rem"'
   ) Do Set "BS=%%#"
   
   :PLoop
   Set "Key="
   For /F "delims=" %%# In (
		'Xcopy /W "%~f0" "%~f0" 2^>Nul'
							) Do If Not Defined Key Set "Key=%%#"
   Set "Key=%Key:~-1%"
   SetLocal EnableDelayedExpansion
		If Not Defined Key goto :PEND 
		If %BS%==^%Key% (Set /P "=%BS% %BS%" <Nul
						 Set "Key="
						 If Defined Line Set "Line=!Line:~0,-1!"
						) Else Set /P "=*" <Nul
		If Not Defined Line (EndLocal &Set "Line=%Key%"
							) Else For /F delims^=^ eol^= %%# In ("!Line!") Do EndLocal &Set "Line=%%#%Key%" 
   Goto :PLoop
   :PEND 
	endlocal& endlocal& set "%1=%Line%" & echo.
goto :eof


:ASK_for_DB_USER
SetLocal
echo ------------------------------------------------------------------------------
echo Enter database user (e.g. SYS AS SYSDBA, SYSTEM, SCOTT)
set /p p_DB_USER=
Endlocal & set "%~1=%p_DB_USER%"
goto :EOF


:ASK_for_TNS
SetLocal
echo ------------------------------------------------------------------------------
	echo Enter value for TNS_NAME, as registered in your Oracle Names
	echo solution (tnsmanes.ora, Oracle Internet Directory, etc)
	set /p p_TNS=
Endlocal & set "%~1=%p_TNS%"
goto :EOF

:ASK_for_TNS_HOST 
SetLocal
echo ------------------------------------------------------------------------------
echo Enter value for listener HOST (network name or IP address)
set /p p_TNS_HOST=
Endlocal & set "%~1=%p_TNS_HOST%"
goto :EOF

:ASK_for_TNS_PORT
SetLocal
echo ------------------------------------------------------------------------------
echo Enter value for listener PORT
set /p p_TNS_PORT=
Endlocal & set "%~1=%p_TNS_PORT%"
goto :EOF

:ASK_for_SERVICE_NAME
SetLocal
echo ------------------------------------------------------------------------------
echo Enter value for database SERVICE_NAME, as known by the listener.
echo For container databases, enter the value for the CDB$ROOT container.
set /p p_SERVICE_NAME=
Endlocal & set "%~1=%p_SERVICE_NAME%"
goto :EOF

:ASK_for_V_TNS_SID
echo ------------------------------------------------------------------------------
SetLocal
echo Enter value for database SID.
set /p p_SID=
Endlocal & set "%~1=%p_SID%"
goto :EOF 


:ASK_FOR_ANOTHER_DB
echo ------------------------------------------------------------------------------
SetLocal
echo Do you want to proceed with another database (y/n)?
		call :ASK_ANSWER ANSWER
		if "!ANSWER!" == "y" ( goto :ASK_FOR_CONNECTION_TYPE )
		if "!ANSWER!" == "n" ( goto :ENDREMOTE )
		goto :ASK_FOR_ANOTHER_DB
EndLocal
goto :EOF 

:ASK_ANSWER
SetLocal
set /p ASKANSWER=
if "%ASKANSWER%" == "Y" (set "ASKANSWER=y")
if "%ASKANSWER%" == "N" (set "ASKANSWER=n")

if 	"%ASKANSWER%" == "y" (goto :END_ASK_ANWER)
if 	"%ASKANSWER%" == "n" (goto :END_ASK_ANWER)	
		
goto :ASK_ANSWER

:END_ASK_ANWER			
EndLocal & set "%1=%ASKANSWER%"
goto :EOF

:ERROR_CATCH
SetLocal

if "%2"=="YES" (
	
		set "v_m1=DB: LMS-02011 : Failed to connect to instance %1"
			for /f "tokens=*" %%a in ('type checkconn.txt ^| findstr /C:"ORA-"') do (
					set v_m2=%%a
					echo !v_m1! !v_m2! > error.txt
					) 
		type error.txt>> DB_errors.log
)	

if "%2"=="NO" ( 
		set "v_m1=DB: LMS-02011 : Failed to connect to instance %1"
			for /f "tokens=*" %%a in ('type checkconn.txt ^| findstr /C:"ORA-"') do (
					set v_m2=%%a
					echo !v_m1! !v_m2! > error.txt
				) 
)
Endlocal
goto :EOF
				
:ASK_FOR_CONNECTION_TYPE
rem echo ------------------------------------------------------------------------------
SetLocal
		
		echo.
		echo Select connection description method:
		set "V_CONNECT_METHOD=2"	
		
		echo   1) Enter TNS_NAME registered in your Oracle Names solution(ex. tnsmanes.ora)
		echo   2) Enter listener HOST (name or IP address), PORT and database SERVICE_NAME
		echo   3) Enter listener HOST (name or IP address), PORT and database instance SID
		echo   4) SKIP
		echo Enter selection or press Return to accept the default (2)
		set /p V_CONNECT_METHOD=
		
		
			if "!V_CONNECT_METHOD!"=="1" ( 
			echo ask_connection_method = !V_CONNECT_METHOD! %date%_%time%  >> db_con_coll.log
			call :ORACLE_HOME_CHECK  V_ORACLE_HOME_SERVER
			call :ASK_for_TNS V_TNS_NAME 
			call :ASK_for_DB_USER V_DB_USER
			call :ASK_FOR_DB_PASSWORD V_DB_PASSWORD
			call :TNS_NAME_CONNECTION  
			goto :EOF
			)
										
			if "!V_CONNECT_METHOD!"=="2"  (
			echo ask_connection_method = !V_CONNECT_METHOD! %date%_%time%  >> db_con_coll.log
			call :ORACLE_HOME_CHECK  V_ORACLE_HOME_SERVER
			call :ASK_for_TNS_HOST V_TNS_HOST
			call :ASK_for_TNS_PORT V_TNS_PORT 
			call :ASK_for_SERVICE_NAME V_TNS_SERVICE_NAME
			call :ASK_for_DB_USER V_DB_USER
			call :ASK_FOR_DB_PASSWORD V_DB_PASSWORD
			call :HOST_PORT_SERVICE_NAME
			goto :EOF
			)
				
			if "!V_CONNECT_METHOD!"=="3" (
			echo ask_connection_method = !V_CONNECT_METHOD! %date%_%time%  >> db_con_coll.log
			call :ORACLE_HOME_CHECK  V_ORACLE_HOME_SERVER
			call :ASK_for_TNS_HOST V_TNS_HOST
			call :ASK_for_TNS_PORT V_TNS_PORT
			call :ASK_for_V_TNS_SID V_TNS_SID
			call :ASK_for_DB_USER V_DB_USER
			call :ASK_FOR_DB_PASSWORD V_DB_PASSWORD
			call :HOST_PORT_SID
			goto :EOF
			)
			
			if "!V_CONNECT_METHOD!"=="4" ( 
			echo ask_connection_method = !V_CONNECT_METHOD! %date%_%time%  >> db_con_coll.log
			goto :EOF 
			) 
			goto :ASK_FOR_CONNECTION_TYPE 
			
Endlocal
goto :EOF

:LOCAL_CONNECTION
SetLocal ENABLEEXTENSIONS

set NLS_LANG=AMERICAN_AMERICA.UTF8
set ORACLE_HOME=!V_ORACLE_HOME_SERVER!
set ORACLE_SID=!V_ORACLE_SID!
set SQLPLUS_ORACLE_HOME=!V_ORACLE_HOME_SERVER!
						
	REM checking sqlplus as sysdba connection
	call :CHECK_SQLPLUS %SQLPLUS_ORACLE_HOME%, chksqlp
	
	if "%chksqlp%" == "0" (	set "SQLPLUS_ORACLE_HOME=%SQLPLUS_ORACLE_HOME%" ) else ( 
		if not "!DBLICAGREE!"=="YES" (
		echo sqlplus is not found at:  %SQLPLUS_ORACLE_HOME%\bin
		echo sqlplus executable was not found in $V_ORACLE_HOME/bin.
		echo Do you want to re-enter the connection details? ^(y/n^)
		call :ASK_ANSWER ANSWER
		if "!ANSWER!" =="y" ( call :ORACLE_HOME_CHECK S_ORACLE_HOME_SERVER && set SQLPLUS_ORACLE_HOME=%S_ORACLE_HOME_SERVER% ) else ( goto :EOF)
		)
	)

	REM	check local connection

	if not %SQLPLUS_ORACLE_HOME%=="#NULL#" (
		call :CHECK_LOCAL_DB %SQLPLUS_ORACLE_HOME%
		findstr  /c:"Connected successfully" checkconn.txt  && (
		
			echo Connected successfully to local instance !V_ORACLE_SID!, !ORACLE_HOME!, !V_SQL! >> db_con_coll.log
			echo GREPME_DB_LIST^>^>,LOCAL,!ORACLE_HOME!,!V_ORACLE_SID!,!V_OS_USER!,,,,,,,!V_SQL!,%date%_%time% >> db_con_coll.log
			
			rem : executing sql script
			:ProcessSQLlist_local_connection
			for /f "tokens=1* delims=#" %%a IN ("!V_SQL!") DO ( 
				if "%%a" NEQ "" ( 
					set _V_SQL=%%a
					echo ------------------------------------------------------------------------------
					echo Running !_V_SQL! on local instance !V_ORACLE_SID!...

					%SQLPLUS_ORACLE_HOME%\bin\sqlplus "/ as sysdba" @!_V_SQL! 
					call logcolstat.cmd DB NO
					call logcolstat.cmd EBS NO)	
					
				if "%%b" NEQ "" (
					set V_SQL=%%b
					goto :ProcessSQLlist_local_connection)	
			)  
		) || (
			
			call :ERROR_CATCH !V_ORACLE_SID! YES
			
			type checkconn.txt >> db_con_coll.log
			if not "!DBLICAGREE!"=="YES" (
				echo Failed to connect "sqlplus / as SYSDBA" using:
				echo OS user: !V_OS_USER!
				echo ORACLE_SID: !V_ORACLE_SID!
				echo ORACLE_HOME: !ORACLE_HOME!
				echo ^(errors are logged in db_con_coll.log file^)	
				echo Most common causes: your OS user does not have SYSDBA permission or
				echo the database is not properly open or mounted.
				echo.
				echo You can address the error and rerun the tool later or, alternately,
				echo you can continue now by trying to connect to this database via listener.
				
				GOTO :ASK_FOR_CONNECTION_TYPE 
				)
			)
			
	)	
Endlocal
goto :EOF


:TNS_NAME_CONNECTION
SetLocal ENABLEEXTENSIONS

if not !V_ORACLE_HOME_SERVER!=="#NULL#" ( 
		set NLS_LANG=AMERICAN_AMERICA.UTF8
		set ORACLE_HOME=!V_ORACLE_HOME_SERVER!) else ( 
			call :ORACLE_HOME_CHECK %V_ORACLE_HOME_SERVER%)
	
	set SQLPLUS_ORACLE_HOME=%V_ORACLE_HOME_SERVER%
	set TNSPING_ORACLE_HOME=%V_ORACLE_HOME_SERVER%
	
	call :CHECK_SQLPLUS %SQLPLUS_ORACLE_HOME%, sqlplus_result
	if not %sqlplus_result%==0  ( 
		echo sqlplus executable was not found in %SQLPLUS_ORACLE_HOME%/bin.
		echo Do you want to re-enter the connection details ^(y/n^)?
		call :ASK_ANSWER ANSWER		
		if "!ANSWER!"=="y" ( call :ORACLE_HOME_CHECK SQLPLUS_ORACLE_HOME ) else ( goto :ASK_FOR_CONNECTION_TYPE )
		)
	
	set V_TNS_NAME=!V_TNS_NAME!
	set V_DB_USER=!V_DB_USER!
		
	if "%V_TNS_NAME%" == "#NULL#" ( call :ASK_for_TNS V_TNS_NAME)
	if "%V_DB_USER%" == "#NULL#" ( call :ASK_for_DB_USER V_DB_USER )

	call :CHECK_TNSPING_CONNECTION %V_TNS_NAME% %SQLPLUS_ORACLE_HOME% v_tnsping
	
if 	"%v_tnsping%"=="0" ( 
	call :CHECK_TNS_NAME_DB "%V_DB_USER%", "%V_DB_PASSWORD%", %SQLPLUS_ORACLE_HOME%, %V_TNS_NAME%
	
	findstr  /c:"Connected successfully" checkconn.txt  && (
	
		echo Connected successfully to TNS_NAME   !ORACLE_HOME!,%V_TNS_NAME%,!V_SQL! >> db_con_coll.log
		echo GREPME_DB_LIST^>^>,TNS_NAME_CONNECTION,!ORACLE_HOME!,,!V_OS_USER!,,,,%V_TNS_NAME%,,%V_DB_USER%,!V_SQL!,%date%_%time% >> db_con_coll.log			
		
		:ProcessSQLlist_tns_connection
		for /f "tokens=1* delims=#" %%a IN ("!V_SQL!") DO ( 
			if "%%a" NEQ "" ( 
				set _V_SQL=%%a
				echo ------------------------------------
				echo Running !_V_SQL! on TNS_NAME %V_TNS_NAME%...
				set NLS_LANG=AMERICAN_AMERICA.UTF8
				set ORACLE_HOME=%SQLPLUS_ORACLE_HOME%
				set V_TNS_NAME=%V_TNS_NAME%
				call :CHECK_DB_USER "%V_DB_USER%" %V_SYS%
				%SQLPLUS_ORACLE_HOME%\bin\sqlplus  "!V_DB_USER!/%V_DB_PASSWORD%@%V_TNS_NAME% !V_SYS!" @!_V_SQL! 
				call logcolstat.cmd DB NO
				call logcolstat.cmd EBS NO
			)
			if "%%b" NEQ "" (
				set V_SQL=%%b
				goto :ProcessSQLlist_tns_connection)
			)
		goto :ASK_FOR_ANOTHER_DB	
	) || (		
				call :ERROR_CATCH %V_TNS_NAME% NO
				
				echo Failed to connect to the database.
				findstr  /c:"ORA-01017" /c:"ORA-28009" /c:"ORA-01031" checkconn.txt >nul 2>&1 && (
					echo Connection error: invalid username/password
					echo Do you want to re-enter the database user and password? ^(y/n^)
					call :ASK_ANSWER ANSWER
					if "!ANSWER!" == "y" (
						call :ASK_FOR_DB_USER V_DB_USER	
						call :ASK_for_DB_PASSWORD V_DB_PASSWORD
						call :TNS_NAME_CONNECTION
					)
					if "!ANSWER!" == "n" ( 
						echo Do you want to re-enter the connection details? ^(y/n^)
						call :ASK_ANSWER ANSWER
						if "!ANSWER!" == "y" (goto :ASK_FOR_CONNECTION_TYPE)  
						if "!ANSWER!" == "n" (goto :ENDREMOTE  )	
					)
				) || (
					echo Do you want to re-enter the database user and password? ^(y/n^)
					call :ASK_ANSWER ANSWER
					if "!ANSWER!" == "y" (
						call :ASK_FOR_DB_USER V_DB_USER	
						call :ASK_for_DB_PASSWORD V_DB_PASSWORD
						call :TNS_NAME_CONNECTION
						)
					if "!ANSWER!" == "n" (goto :ASK_FOR_ANOTHER_DB )	
					)			
		)
	) else (
	echo TNSPING test failed for the specified connection description.
		:ASK_CONN_DETAILS
		echo Do you want to re-enter the connection details ^(y/n^)?
		set /p TANS=
		set "TANS=!TANS:Y=y!"
		set "TANS=!TANS:N=n!"
		if "!TANS!"=="y" (goto :ASK_FOR_CONNECTION_TYPE) 
		if "!TANS!"=="n" (goto :ASK_FOR_ANOTHER_DB)
		goto :ASK_CONN_DETAILS
	)
		
Endlocal
goto :EOF

:HOST_PORT_SERVICE_NAME
SetLocal EnableExtensions EnableDelayedExpansion

if not !V_ORACLE_HOME_SERVER!=="#NULL#" ( 
		set NLS_LANG=AMERICAN_AMERICA.UTF8
		set ORACLE_HOME=!V_ORACLE_HOME_SERVER!) else ( 
			call :ORACLE_HOME_CHECK %V_ORACLE_HOME_SERVER%)
			
set SQLPLUS_ORACLE_HOME=!V_ORACLE_HOME_SERVER!
set TNSPING_ORACLE_HOME=!V_ORACLE_HOME_SERVER!

call :CHECK_SQLPLUS %SQLPLUS_ORACLE_HOME%, sqlplus_result
	if not %sqlplus_result%==0  ( 
		echo sqlplus executable was not found in $V_ORACLE_HOME/bin.
		echo Do you want to re-enter the connection details ^(y/n^)?
		set /p ANSWER=
		call :ASK_ANSWER ANSWER	
		if "!ANSWER!"=="y" ( call :ORACLE_HOME_CHECK SQLPLUS_ORACLE_HOME ) else ( goto :EOF )
		)
		
			
set "V_TNS_HOST=!V_TNS_HOST!"
set "V_TNS_PORT=!V_TNS_PORT!"
set "V_TNS_SERVICE_NAME=!V_TNS_SERVICE_NAME!"
set "V_DB_USER=!V_DB_USER!"


if "%V_TNS_HOST%" == "#NULL#" ( call :ASK_for_TNS_HOST V_TNS_HOST )
if "%V_TNS_PORT%" == "#NULL#" ( call :ASK_for_TNS_PORT V_TNS_PORT )
if "%V_TNS_SERVICE_NAME%" == "#NULL#" ( call :ASK_for_SERVICE_NAME V_TNS_SID )
if "%V_DB_USER%" =="#NULL#" ( call :ASK_for_DB_USER V_DB_USER )

set conn_str=(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = %V_TNS_HOST%)(PORT = %V_TNS_PORT%)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = %V_TNS_SERVICE_NAME%)))

call :CHECK_TNSPING_CONNECTION "%conn_str%" %SQLPLUS_ORACLE_HOME% v_tnsping

if 	"%v_tnsping%"=="0" ( 
call :CHECK_HOST_PORT_SERVICE_NAME "%V_DB_USER%", "%V_DB_PASSWORD%", %SQLPLUS_ORACLE_HOME% , %V_TNS_HOST%, %V_TNS_PORT%, %V_TNS_SERVICE_NAME% 
	findstr  /c:"Connected successfully" checkconn.txt  && (
		echo Connected successfully to %V_TNS_SERVICE_NAME% %V_TNS_HOST% %V_TNS_PORT% !V_SQL! >> db_con_coll.log
		echo GREPME_DB_LIST^>^>,HOST_PORT_SERVICE_NAME,,,,%V_TNS_HOST%,%V_TNS_PORT%,%V_TNS_SERVICE_NAME%,,%V_DB_USER%,!V_SQL!,%date%_%time% >> db_con_coll.log			
		
		rem : executing sql scripts
		:ProcessSQLlist_host_port_connection
		for /f "tokens=1* delims=#" %%a IN ("!V_SQL!") DO ( 
			if "%%a" NEQ "" ( 
				set _V_SQL=%%a
				echo ------------------------------------
				echo Running !_V_SQL! on TNS_NAME %V_TNS_SERVICE_NAME%...
				set NLS_LANG=AMERICAN_AMERICA.UTF8
				set ORACLE_HOME=%SQLPLUS_ORACLE_HOME%
				call :CHECK_DB_USER "%V_DB_USER%" %V_SYS%
				%SQLPLUS_ORACLE_HOME%\bin\sqlplus  "!V_DB_USER!/%V_DB_PASSWORD%@%conn_str% !V_SYS!" @!_V_SQL! 
				call logcolstat.cmd DB NO	
				call logcolstat.cmd EBS NO
				)
			if "%%b" NEQ "" (
				set V_SQL=%%b
				goto :ProcessSQLlist_host_port_connection)
				)
			goto :ASK_FOR_ANOTHER_DB		
			) || (
			
			call :ERROR_CATCH %V_TNS_SERVICE_NAME% NO
			
			echo Failed to connect to the database.
			findstr  /c:"ORA-01017" /c:"ORA-28009" /c:"ORA-01031" checkconn.txt >nul 2>&1 && (
				echo Connection error: invalid username/password
				echo Do you want to re-enter the database user and password? ^(y/n^)
				call :ASK_ANSWER ANSWER
				if "!ANSWER!" == "y" (
					call :ASK_FOR_DB_USER V_DB_USER	
					call :ASK_for_DB_PASSWORD V_DB_PASSWORD
					call :HOST_PORT_SERVICE_NAME
					)
				if "!ANSWER!" == "n" ( 
					echo Do you want to re-enter the connection details? ^(y/n^)
					call :ASK_ANSWER ANSWER
					if "!ANSWER!" == "y" (goto :ASK_FOR_CONNECTION_TYPE)  
					if "!ANSWER!" == "n" (goto :ENDREMOTE )	
				)
			) || ( 
				echo Do you want to re-enter the database user and password? ^(y/n^)
				call :ASK_ANSWER ANSWER
				if "!ANSWER!" == "y" (
					call :ASK_FOR_DB_USER V_DB_USER	
					call :ASK_for_DB_PASSWORD V_DB_PASSWORD
					call :HOST_PORT_SERVICE_NAME
					)
				if "!ANSWER!" == "n" (goto :ASK_FOR_ANOTHER_DB )	
				)			
		)
	) else (
	echo TNSPING test failed for the specified connection description.
		:ASK_CONN_DETAILS
		echo Do you want to re-enter the connection details ^(y/n^)?
		set /p TANS=
		set "TANS=!TANS:Y=y!"
		set "TANS=!TANS:N=n!"
		if "!TANS!"=="y" (goto :ASK_FOR_CONNECTION_TYPE) 
		if "!TANS!"=="n" (goto :ASK_FOR_ANOTHER_DB )
		goto :ASK_CONN_DETAILS
	)
		
Endlocal
goto :EOF


:HOST_PORT_SID
SetLocal ENABLEEXTENSIONS

if not !V_ORACLE_HOME_SERVER!=="#NULL#" (
		set NLS_LANG=AMERICAN_AMERICA.UTF8
		set ORACLE_HOME=!V_ORACLE_HOME_SERVER! ) else ( 
			call :ORACLE_HOME_CHECK %V_ORACLE_HOME_SERVER%)
			
set SQLPLUS_ORACLE_HOME=%V_ORACLE_HOME_SERVER%
set TNSPING_ORACLE_HOME=%V_ORACLE_HOME_SERVER%

call :CHECK_SQLPLUS %SQLPLUS_ORACLE_HOME%, sqlplus_result	
	if not %sqlplus_result%==0  ( 
		echo sqlplus executable was not found in $V_ORACLE_HOME/bin.
		echo Do you want to re-enter the connection details ^(y/n^)^?
		call :ASK_ANSWER ANSWER	
		if "!ANSWER!"=="y" ( call :ORACLE_HOME_CHECK SQLPLUS_ORACLE_HOME ) else ( goto :EOF )
		)					

set "V_TNS_HOST=!V_TNS_HOST!"
set "V_TNS_PORT=!V_TNS_PORT!"
set "V_TNS_SID=!V_TNS_SID!"
set "V_DB_USER=!V_DB_USER!"

if "%V_TNS_HOST%" == "#NULL#" ( call :ASK_for_TNS_HOST V_TNS_HOST )
if "%V_TNS_PORT%" == "#NULL#" ( call :ASK_for_TNS_PORT V_TNS_PORT )
if "%V_TNS_SID%"=="#NULL#" ( call :ASK_for_V_TNS_SID V_TNS_SID )
if "%V_DB_USER%"=="#NULL#" ( call :ASK_for_DB_USER V_DB_USER )

set ORACLE_SID=%V_TNS_SID%
set ORACLE_HOME=%SQLPLUS_ORACLE_HOME%
set conn_str=(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = %V_TNS_HOST%)(PORT = %V_TNS_PORT%))(CONNECT_DATA=(SID = %V_TNS_SID%)))

call :CHECK_TNSPING_CONNECTION "%conn_str%" %SQLPLUS_ORACLE_HOME% v_tnsping

if 	"%v_tnsping%"=="0" ( 
call :CHECK_HOST_PORT_SID "%V_DB_USER%", "%V_DB_PASSWORD%", %SQLPLUS_ORACLE_HOME%, %V_TNS_HOST%, %V_TNS_PORT%, %V_TNS_SID%
	findstr  /c:"Connected successfully" checkconn.txt  && (
		echo Connected successfully to %V_TNS_SID% %V_TNS_HOST% %V_TNS_PORT% !V_SQL! >> db_con_coll.log
		echo GREPME_DB_LIST^>^>,HOST_PORT_SID,%SQLPLUS_ORACLE_HOME%,,,,%V_TNS_HOST%,%V_TNS_PORT%,%V_TNS_SID%,%V_DB_USER%,!V_SQL!,%date%_%time% >> db_con_coll.log				
		
		rem : executing sql scripts
		:ProcessSQLlist_port_sid
		for /f "tokens=1* delims=#" %%a IN ("!V_SQL!") DO ( 
			if "%%a" NEQ "" ( 
				set _V_SQL=%%a
				echo ------------------------------------
				echo Running !_V_SQL! on TNS_NAME %V_TNS_SID%...
				set NLS_LANG=AMERICAN_AMERICA.UTF8
				set ORACLE_HOME=%SQLPLUS_ORACLE_HOME%
				call :CHECK_DB_USER "%V_DB_USER%" %V_SYS%
				%SQLPLUS_ORACLE_HOME%\bin\sqlplus  "!V_DB_USER!/%V_DB_PASSWORD%@%conn_str% !V_SYS!" @!_V_SQL!
				call logcolstat.cmd DB NO
				call logcolstat.cmd EBS NO
				)
			if "%%b" NEQ "" (
				set V_SQL=%%b
				goto :ProcessSQLlist_port_sid)
				)
			goto :ASK_FOR_ANOTHER_DB		
			) || (
			
			call :ERROR_CATCH %V_TNS_SID% NO
			
			echo Failed to connect to the database.
			findstr  /c:"ORA-01017" /c:"ORA-28009" /c:"ORA-01031" checkconn.txt >nul 2>&1 && (
				echo Connection error: invalid username/password
				echo Do you want to re-enter the database user and password? ^(y/n^)
				call :ASK_ANSWER ANSWER
				if "!ANSWER!" == "y" (
					call :ASK_FOR_DB_USER V_DB_USER	
					call :ASK_for_DB_PASSWORD V_DB_PASSWORD
					call :HOST_PORT_SID
					)
				if "!ANSWER!" == "n" ( 
					echo Do you want to re-enter the connection details? ^(y/n^)
					call :ASK_ANSWER ANSWER
					if "!ANSWER!" == "y" (goto :ASK_FOR_CONNECTION_TYPE)  
					if "!ANSWER!" == "n" (goto :ENDREMOTE )	
				)
			) || ( 
				echo Do you want to re-enter the database user and password? ^(y/n^)
				call :ASK_ANSWER ANSWER
				if "!ANSWER!" == "y" (
					call :ASK_FOR_DB_USER V_DB_USER	
					call :ASK_for_DB_PASSWORD V_DB_PASSWORD
					call :HOST_PORT_SID
					)
				if "!ANSWER!" == "n" (goto :ASK_FOR_ANOTHER_DB )	
				)			
		)	
	) else (
	echo TNSPING test failed for the specified connection description.
		:ASK_CONN_DETAILS
		echo Do you want to re-enter the connection details ^(y/n^)?
		set /p TANS=
		set "TANS=!TANS:Y=y!"
		set "TANS=!TANS:N=n!"
		if "!TANS!"=="y" (goto :ASK_FOR_CONNECTION_TYPE) 
		if "!TANS!"=="n" (goto :ASK_FOR_ANOTHER_DB )
		goto :ASK_CONN_DETAILS
	)
		
Endlocal
goto :EOF

	:TRIM
		SetLocal EnableDelayedExpansion
		Call :TRIMSUB %%%1%%
		EndLocal & set %1=%tempvar%
	GOTO :EOF

	:TRIMSUB
		set tempvar=%*
	GOTO :EOF

	
goto :EOF

:ENDREMOTE
type error.txt >> DB_errors.log


Endlocal
