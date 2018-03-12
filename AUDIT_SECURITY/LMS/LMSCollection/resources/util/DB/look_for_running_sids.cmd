@Echo off
SetLocal EnableDelayedExpansion
SetLocal EnableExtensions
	
	
	set v_sql_script=%1 %2 %3
	
	if exist oracle_homes_temp.txt	 ( del oracle_homes_temp.txt )
	if exist oracle_homes_a.txt	 ( del oracle_homes_a.txt )
	rem echo.>oracle_homes_a.txt
	rem echo.>oracle_homes_temp.txt
	where sqlplus.exe | findstr sqlplus>>oracle_homes_temp.txt
	
	for /f "tokens=*"  %%a in ('type oracle_homes_temp.txt') do (
			set str=%%a
			set str=!str:\BIN\sqlplus.exe=!
			>> oracle_homes_a.txt echo !str!
			)
	
	for /f "tokens=3" %%a in ('reg query HKLM\SOFTWARE\ORACLE\ /s /v "ORACLE_HOME" ^| findstr "ORACLE_HOME" ') do (	
		echo %%a>> oracle_homes_a.txt
		)
	for /f "tokens=3" %%a in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Oracle /s /v "ORACLE_HOME" ^| findstr "ORACLE_HOME"') do (
		echo %%a>> oracle_homes_a.txt
		)
		
 	if exist oracle_homes_temp.txt	 ( del oracle_homes_temp.txt )
	
	echo CONNECTION_METHOD,ORACLE_HOME_SERVER,ORACLE_SID,OS_USER,TNS_NAME,TNS_HOST,TNS_PORT,TNS_SERVICE_NAME,TNS_SID,DB_USER,SQL,MACHINE_NAME>db_list.csv

	set REG_SID=
	set V_REG_SID=
	set V_OS_USER=
	
	echo "net start | findstr OracleService" >> db_con_coll.log
	net start | findstr OracleService >>db_con_coll.log
	echo %date%_%time% >> db_con_coll.log
	net USER %USERNAME% | findstr "Group" >>db_con_coll.log
	
	for /f "tokens=1" %%n in ( 'net start ^| findstr "OracleService"' ) do (
		
		for /f "tokens=1" %%l in ( 'reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services /s /v "ImagePath" ^| findstr "OracleService"' ) do (
	
			for /f "skip=2 usebackq tokens=2*" %%a in ( `reg query %%l /v ImagePath` ) do (
			
				set "V_REG=%%b"

				for %%S in ( %%b ) do call set "REG_SID=%%S" 
				
				call :LENGTH !REG_SID! REG_SID_LENGTH
				
				set "V_REG_SID=OracleService!REG_SID!"
				
				if /I "%%n" == "!V_REG_SID!" ( 
				
					call set V_REG_OH=%%V_REG:~0,-!REG_SID_LENGTH!%%
					call set V_REG_OH=%%V_REG_OH:bin\ORACLE.EXE=%%	
					call :TRIM V_REG_OH
					call :TRIM V_REG_OH
		
					rem for /f "tokens=3 usebackq" %%u in (`reg query HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\%%n /v "ObjectName"`) do set V_OS_USER=%%u
					set V_OS_USER=%USERNAME%
					
					echo LOCAL,!V_REG_OH!,!REG_SID!,!V_OS_USER!,,,,,,,%v_sql_script%,%ComputerName%>> db_list.csv
				)			
			)	
		)
	)
	
GOTO :EOF

	REM Functions
	:UpCase
		FOR %%i IN ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K" "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W" "x=X" "y=Y" "z=Z") DO CALL SET "%1=%%%1:%%~i%%"
	GOTO :EOF

	:TRIM
		SetLocal EnableDelayedExpansion
		Call :TRIMSUB %%%1%%
		EndLocal & set %1=%tempvar%
	GOTO :EOF

	:TRIMSUB
		set tempvar=%*
	GOTO :EOF

	
	:LENGTH
	SetLocal
		if [%1] EQU [] goto end
 
		:loop
			if [%1] EQU [] goto end
			set _len=0
			set _str=%1
			set _subs=%_str%
 
		:getlen     
			if not defined _subs goto result
			:: remove first letter until empty
			set _subs=%_subs:~1%
			set /a _len+=1
			goto getlen
		:result
		
		:end
		EndLocal & set "%2=%_len%"	
			 
	GOTO :EOF	
	
	
EndLocal