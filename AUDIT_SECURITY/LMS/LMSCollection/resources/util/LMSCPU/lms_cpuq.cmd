@echo off
:: ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::   lms_cpuq.cmd v.18.1
::    - grab cpu and machine info.
::
:: ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


SETLOCAL
if NOT [%LMSCT_BUILD_VERSION%]==[] (
	goto main
	)

echo Oracle License Management Services >"%TEMP%\lms_cpuq_tmp.txt"
echo License Agreement >>"%TEMP%\lms_cpuq_tmp.txt"
echo PLEASE SCROLL DOWN AND READ ALL OF THE FOLLOWING TERMS AND CONDITIONS OF THIS LICENSE AGREEMENT (“Agreement”) CAREFULLY BEFORE DEMONSTRATING YOUR ACCEPTANCE BY CLICKING AN “ACCEPT LICENSE AGREEMENT” OR SIMILAR BUTTON OR BY TYPING THE REQUIRED ACCEPTANCE TEXT OR INSTALLING OR USING THE PROGRAMS (AS DEFINED BELOW). >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo THIS AGREEMENT IS A LEGALLY BINDING CONTRACT BETWEEN YOU AND ORACLE AMERICA, INC. THAT SETS FORTH THE TERMS AND CONDITIONS THAT GOVERN YOUR USE OF THE PROGRAMS.  BY DEMONSTRATING YOUR ACCEPTANCE BY CLICKING AN “ACCEPT LICENSE AGREEMENT” OR SIMILAR BUTTON OR BY TYPING THE REQUIRED ACCEPTANCE TEXT OR INSTALLING AND/OR USING THE PROGRAMS, YOU AGREE TO ABIDE BY ALL OF THE TERMS AND CONDITIONS STATED OR REFERENCED HEREIN.  >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo IF YOU DO NOT AGREE TO ABIDE BY THESE TERMS AND CONDITIONS, DO NOT DEMONSTRATE YOUR ACCEPTANCE BY THE SPECIFIED MEANS AND DO NOT INSTALL OR USE THE PROGRAMS. >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo YOU MUST ACCEPT AND ABIDE BY THESE TERMS AND CONDITIONS AS PRESENTED TO YOU – ANY CHANGES, ADDITIONS OR DELETIONS BY YOU TO THESE TERMS AND CONDITIONS WILL NOT BE ACCEPTED BY US AND WILL NOT MAKE PART OF THIS AGREEMENT.  THE TERMS AND CONDITIONS SET FORTH IN THIS AGREEMENT SUPERSEDE ANY OTHER LICENSE TERMS APPLICABLE TO YOUR USE OF THE PROGRAMS.>>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo Definitions>>"%TEMP%\lms_cpuq_tmp.txt"
echo "We," "us," and "our" refers to Oracle America, Inc.  “Oracle” refers to Oracle Corporation and its affiliates.  >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo "You" and "your" refers to the individual or entity that wishes to use the programs (as defined below) provided by Oracle. >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo "Programs" or “programs” refers to the tool(s), script(s) and/or software product(s) and any applicable program documentation provided to you by Oracle which you wish to access and use to measure, monitor and/or manage your usage of separately-licensed Oracle software. >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo Rights Granted>>"%TEMP%\lms_cpuq_tmp.txt"
echo We grant you a non-exclusive, non-transferable limited right to use the programs, subject to the terms of this agreement, for the limited purpose of measuring, monitoring and/or managing your usage of separately-licensed Oracle software.  You may allow your agents and contractors (including, without limitation, outsourcers) to use the programs for this purpose and you are responsible for their compliance with this agreement in such use.  You (including your agents, contractors and/or outsourcers) may not use the programs for any other purpose. >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo Ownership and Restrictions >>"%TEMP%\lms_cpuq_tmp.txt"
echo Oracle and Oracle’s licensors retain all ownership and intellectual property rights to the programs. The programs may be installed on one or more servers; provided, however, that you may only make one copy of the programs for backup or archival purposes. >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo Third party technology that may be appropriate or necessary for use with the programs is specified in the program documentation, notice files or readme files.  Such third party technology is licensed to you under the terms of the third party technology license agreement specified in the program documentation, notice files or readme files and not under the terms of this agreement.    >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo You may not:>>"%TEMP%\lms_cpuq_tmp.txt"
echo -	use the programs for your own internal data processing or for any commercial or production purposes, or use the programs for any purpose except the purpose stated herein; >>"%TEMP%\lms_cpuq_tmp.txt"
echo -	remove or modify any program markings or any notice of Oracle’s or Oracle’s licensors’ proprietary rights;>>"%TEMP%\lms_cpuq_tmp.txt"
echo -	make the programs available in any manner to any third party for use in the third party’s business operations, without our prior written consent ;  >>"%TEMP%\lms_cpuq_tmp.txt"
echo -	use the programs to provide third party training or rent or lease the programs or use the programs for commercial time sharing or service bureau use; >>"%TEMP%\lms_cpuq_tmp.txt"
echo -	assign this agreement or give or transfer the programs or an interest in them to another individual or entity; >>"%TEMP%\lms_cpuq_tmp.txt"
echo -	cause or permit reverse engineering (unless required by law for interoperability), disassembly or decompilation of the programs (the foregoing prohibition includes but is not limited to review of data structures or similar materials produced by programs);>>"%TEMP%\lms_cpuq_tmp.txt"
echo -	disclose results of any program benchmark tests without our prior written consent; >>"%TEMP%\lms_cpuq_tmp.txt"
echo -	use any Oracle name, trademark or logo without our prior written consent .>>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo Disclaimer of Warranty>>"%TEMP%\lms_cpuq_tmp.txt"
echo ORACLE DOES NOT GUARANTEE THAT THE PROGRAMS WILL PERFORM ERROR-FREE OR UNINTERRUPTED.   TO THE EXTENT NOT PROHIBITED BY LAW, THE PROGRAMS ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND AND THERE ARE NO WARRANTIES, EXPRESS OR IMPLIED, OR CONDITIONS, INCLUDING WITHOUT LIMITATION, WARRANTIES OR CONDITIONS OF MERCHANTABILITY, NONINFRINGEMENT OR FITNESS FOR A PARTICULAR PURPOSE THAT APPLY TO THE PROGRAMS. >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo No Right to Technical Support>>"%TEMP%\lms_cpuq_tmp.txt"
echo You acknowledge and agree that Oracle’s technical support organization will not provide you with technical support for the programs licensed under this agreement.  >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo End of Agreement>>"%TEMP%\lms_cpuq_tmp.txt"
echo You may terminate this agreement by destroying all copies of the programs. We have the right to terminate your right to use the programs at any time upon notice to you, in which case you shall destroy all copies of the programs. >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo Entire Agreement>>"%TEMP%\lms_cpuq_tmp.txt"
echo You agree that this agreement is the complete agreement for the programs and supersedes all prior or contemporaneous agreements or representations, written or oral, regarding such programs. If any term of this agreement is found to be invalid or unenforceable, the remaining provisions will remain effective and such term shall be replaced with a term consistent with the purpose and intent of this agreement. >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo Limitation of Liability>>"%TEMP%\lms_cpuq_tmp.txt"
echo IN NO EVENT SHALL ORACLE BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, PUNITIVE OR CONSEQUENTIAL DAMAGES, OR ANY LOSS OF PROFITS, REVENUE, DATA OR DATA USE, INCURRED BY YOU OR ANY THIRD PARTY.  ORACLE’S ENTIRE LIABILITY FOR DAMAGES ARISING OUT OF OR RELATED TO THIS AGREEMENT, WHETHER IN CONTRACT OR TORT OR OTHERWISE, SHALL IN NO EVENT EXCEED ONE THOUSAND U.S. DOLLARS (U.S. $1,000).  >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo Export >>"%TEMP%\lms_cpuq_tmp.txt"
echo Export laws and regulations of the United States and any other relevant local export laws and regulations apply to the programs.  You agree that such export control laws govern your use of the programs (including technical data) provided under this agreement, and you agree to comply with all such export laws and regulations (including “deemed export” and “deemed re-export” regulations).    You agree that no data, information, and/or program (or direct product thereof) will be exported, directly or indirectly, in violation of any export laws, nor will they be used for any purpose prohibited by these laws including, without limitation, nuclear, chemical, or biological weapons proliferation, or development of missile technology.   >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo Other>>"%TEMP%\lms_cpuq_tmp.txt"
echo 1.	This agreement is governed by the substantive and procedural laws of the State of California. You and we agree to submit to the exclusive jurisdiction of, and venue in, the courts of San Francisco or Santa Clara counties in California in any dispute arising out of or relating to this agreement. >>"%TEMP%\lms_cpuq_tmp.txt"
echo 2.	You may not assign this agreement or give or transfer the programs or an interest in them to another individual or entity.  If you grant a security interest in the programs, the secured party has no right to use or transfer the programs.>>"%TEMP%\lms_cpuq_tmp.txt"
echo 3.	Except for actions for breach of Oracle’s proprietary rights, no action, regardless of form, arising out of or relating to this agreement may be brought by either party more than two years after the cause of action has accrued.>>"%TEMP%\lms_cpuq_tmp.txt"
echo 4.	Oracle may audit your use of the programs.  You agree to cooperate with Oracle’s audit and provide reasonable assistance and access to information.  Any such audit shall not unreasonably interfere with your normal business operations.  You agree that Oracle shall not be responsible for any of your costs incurred in cooperating with the audit.    >>"%TEMP%\lms_cpuq_tmp.txt"
echo 5.	The relationship between you and us is that of licensee/licensor. Nothing in this agreement shall be construed to create a partnership, joint venture, agency, or employment relationship between the parties.  The parties agree that they are acting solely as independent contractors hereunder and agree that the parties have no fiduciary duty to one another or any other special or implied duties that are not expressly stated herein.  Neither party has any authority to act as agent for, or to incur any obligations on behalf of or in the name of the other.  >>"%TEMP%\lms_cpuq_tmp.txt"
echo 6.	This agreement may not be modified and the rights and restrictions may not be altered or waived except in a writing signed by authorized representatives of you and of us.  >>"%TEMP%\lms_cpuq_tmp.txt"
echo 7.	Any notice required under this agreement shall be provided to the other party in writing.>>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo Contact Information>>"%TEMP%\lms_cpuq_tmp.txt"
echo Should you have any questions concerning your use of the programs or this agreement, please contact: >>"%TEMP%\lms_cpuq_tmp.txt"
echo.>>"%TEMP%\lms_cpuq_tmp.txt"
echo License Management Services at:>>"%TEMP%\lms_cpuq_tmp.txt"
echo http://www.oracle.com/us/corporate/license-management-services/index.html>>"%TEMP%\lms_cpuq_tmp.txt"
echo Oracle America, Inc.>>"%TEMP%\lms_cpuq_tmp.txt"
echo 500 Oracle Parkway, >>"%TEMP%\lms_cpuq_tmp.txt"
echo Redwood City, CA 94065 >>"%TEMP%\lms_cpuq_tmp.txt"

more "%TEMP%\lms_cpuq_tmp.txt"

:promptloop
set /p ANSWER=Accept License Agreement? (y\n\q)

if "%ANSWER%" == "y" (
       goto main
) else if "%ANSWER%" == "n" (
       goto licagreement
) else if "%ANSWER%" == "q" (
       goto licagreement
) else (
	goto promptloop
)

:licagreement
echo.
echo You cannot run this program without agreeing to the license agreement.
goto lms_cpu_info



:main
::
:: setup temp files to hold data
::
  rem set MACHINE_NAME=%COMPUTERNAME%
  rem set MACHINE_MSINFO=%1\%MACHINE_NAME%-MSinfo.txt
    
    set RETURN_FILE=%COMPUTERNAME%-lms_cpuq.txt
	if exist "%*" (
	    set TEMP=%*
		set RETURN_FILE="%*\%COMPUTERNAME%-lms_cpuq.txt"
	)
	
	del "%TEMP%\lms_cpuq_tmp.txt"

:: Get windows Version numbers
  For /f "tokens=2 delims=[]" %%G in ('ver') Do (set _version=%%G) 
  For /f "tokens=2,3,4 delims=. " %%G in ('echo %_version%') Do (set _major=%%G& set _minor=%%H& set _build=%%I) 
	
::
:: Gather OS, CPU, IP Address and machine name information
::  populate IP adresses to file
::

  echo Gathering machine information ....
  echo lms_cpuq.cmd v.18.1               > %RETURN_FILE%
  echo LMS_CT Version %LMSCT_BUILD_VERSION% >> %RETURN_FILE%
  echo ################################ >> %RETURN_FILE%
  echo Script Start Date: %date%        >> %RETURN_FILE%
  echo Script Start Time: %time%        >> %RETURN_FILE%
  if "%_major%"=="5" (
	:: Since catlist only supported on < Server 2008 and Windows, don't use it on those platforms.
	  "%ProgramFiles%\Common Files\Microsoft Shared\MSInfo\msinfo32.exe" /report "%TEMP%\lms_cpuq_tmp.txt" /categories catlist
	  echo "%ProgramFiles%\Common Files\Microsoft Shared\MSInfo\msinfo32.exe" /report "%TEMP%\lms_cpuq_tmp.txt" /categories catlist >> %RETURN_FILE%
	  echo ################################ >> %RETURN_FILE%
	  type "%TEMP%\lms_cpuq_tmp.txt"          >> %RETURN_FILE%
	 
	 %SystemRoot%\regedit /E "%TEMP%\lms_cpuq_tmp.txt" "HKEY_LOCAL_MACHINE\Hardware\Description\System\CentralProcessor"
	 echo ################################ >> %RETURN_FILE%
     echo regedit /E "%TEMP%\lms_cpuq_tmp.txt" "HKEY_LOCAL_MACHINE\Hardware\Description\System\CentralProcessor" >> %RETURN_FILE%
  ) else (
  	  echo "msinfo32.exe catlist option not run on Windows 2008, Windows Vista or greater." >> %RETURN_FILE%
	  echo ################################ >> %RETURN_FILE%
	 
	 %SystemRoot%\System32\reg export HKLM\Hardware\Description\System\CentralProcessor "%TEMP%\lms_cpuq_tmp.txt"
	 echo ################################ >> %RETURN_FILE%
     echo reg export HKLM\Hardware\Description\System\CentralProcessor "%TEMP%\lms_cpuq_tmp.txt" >> %RETURN_FILE%
  )
  

  echo ################################ >> %RETURN_FILE%
  type "%TEMP%\lms_cpuq_tmp.txt"          >> %RETURN_FILE%
  echo ################################ >> %RETURN_FILE%


  :: Preparing VB Script file
  :: Escaping with ^ all command characters & < > | ON OFF
  echo.' Set output file                                                                                                                                                      > "%TEMP%\lms_cpuq_tmp.vbs"
  echo.On Error Resume Next                                                                                                                                                  >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.Set objFSO = CreateObject("Scripting.FileSystemObject")                                                                                                               >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.Set objTextFile = objFSO.CreateTextFile("%TEMP%\lms_cpuq_tmp.txt")                                                                                                    >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.                                                                                                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.' Connect to Local Machine and get data.                                                                                                                              >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.' If cannot connect to Local Machine print message.                                                                                                                   >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.strComputer = "."                                                                                                                                                     >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.Set objWMIService = GetObject("winmgmts:" _                                                                                                                           >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo. ^& "{impersonationLevel=impersonate}!\\" ^& strComputer ^& "\root\cimv2")                                                                                            >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.If objWMIService Is Nothing Then                                                                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  objTextFile.WriteLine("Unable to bind to WMI!")                                                                                                                     >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.Else                                                                                                                                                                  >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  ' Get Operating System information                                                                                                                                  >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  Set colOSes = objWMIService.ExecQuery("Select * from Win32_OperatingSystem")                                                                                        >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  For Each objOS in colOSes                                                                                                                                           >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    objTextFile.WriteLine("Operating System")                                                                                                                         >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    objTextFile.WriteLine("  Caption: " ^& objOS.Caption)                                                                                                             >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    objTextFile.WriteLine("  Version: " ^& objOS.Version)                                                                                                             >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    objTextFile.WriteLine("Computer Name: " ^& objOS.CSName)                                                                                                          >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  Next                                                                                                                                                                >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.                                                                                                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  ' Get DNS Domain                                                                                                                                                    >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  Set colDNSs = objWMIService.ExecQuery ("Select DNSDomain from Win32_NetworkAdapterConfiguration WHERE IPEnabled=True")                                              >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  For Each objDNS in colDNSs                                                                                                                                          >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    If Not IsNull(objDNS.DNSDomain) Then                                                                                                                              >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      objTextFile.WriteLine("DNS Domain: " ^& objDNS.DNSDomain)                                                                                                       >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    End If                                                                                                                                                            >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  Next                                                                                                                                                                >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.                                                                                                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  objTextFile.WriteLine("System")                                                                                                                                     >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.                                                                                                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  ' Get UUID                                                                                                                                                          >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  Set colUUID = objWMIService.ExecQuery("select uuid from Win32_ComputerSystemProduct")                                                                               >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  For Each objUUID in colUUID                                                                                                                                         >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    If Not IsNull(objUUID.UUID) Then                                                                                                                                  >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      objTextFile.WriteLine("UUID=" ^& objUUID.UUID)                                                                                                                  >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    End If                                                                                                                                                            >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  Next                                                                                                                                                                >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.                                                                                                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  ' Get System Machine information.                                                                                                                                   >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  ' Check if script is running on a virtual machine                                                                                                                   >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  Set colCompSys = objWMIService.ExecQuery("Select * from Win32_ComputerSystem")                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  For Each objCS in colCompSys                                                                                                                                        >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    If InStr(objCS.Manufacturer, "VMware") ^> 0 Then                                                                                                                  >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      objTextFile.WriteLine("  VIRTUAL MACHINE RUNNING: " ^& objCS.Manufacturer)                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      isVirtualMachine = True                                                                                                                                         >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    ElseIf InStr(objCS.Manufacturer, "Xen") ^> 0 Then                                                                                                                 >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      objTextFile.WriteLine("  VIRTUAL MACHINE RUNNING: " ^& objCS.Manufacturer)                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      isVirtualMachine = True                                                                                                                                         >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    ElseIf InStr(objCS.Manufacturer, "Red Hat") ^> 0 Then                                                                                                             >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      objTextFile.WriteLine("  VIRTUAL MACHINE RUNNING: " ^& objCS.Manufacturer)                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      isVirtualMachine = True                                                                                                                                         >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    ElseIf InStr(objCS.Manufacturer, "Microsoft Corporation") ^> 0 Then                                                                                               >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      objTextFile.WriteLine("  VIRTUAL MACHINE RUNNING: " ^& objCS.Manufacturer)                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      objTextFile.WriteLine("  If this is a Hyper-V Virtualized environment " )                                                                                       >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      objTextFile.WriteLine("  please run lms_cpuq.cmd in the Root Partition" )                                                                                       >> "%TEMP%\lms_cpuq_tmp.vbs"  
  echo.      isVirtualMachine = True                                                                                                                                         >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    ElseIf InStr(objCS.Model, "VirtualBox") ^> 0 Then                                                                                                                 >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      objTextFile.WriteLine("  VIRTUAL MACHINE RUNNING: " ^& objCS.Model)                                                                                             >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      isVirtualMachine = True                                                                                                                                         >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    End If                                                                                                                                                            >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    If isVirtualMachine = True Then                                                                                                                                   >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      Wscript.StdOut.WriteBlankLines(1)                                                                                                                               >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      Wscript.StdOut.WriteLine "** NOTICE:  VIRTUAL MACHINE RUNNING: " ^& objCS.Manufacturer ^& " " ^& objCS.Model                                                    >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      Wscript.StdOut.WriteLine "** Please provide Oracle LMS with information about the hardware configuration "                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      Wscript.StdOut.WriteLine "** of the physical server which is hosting this Virtual Machine "                                                                     >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      Wscript.StdOut.WriteLine "** If applicable, please run the script on the host operating system "                                                                >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      Wscript.StdOut.WriteLine "** Thank You."                                                                                                                        >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      objTextFile.WriteLine("LMSCPU: LMS-01104: WARNING: "  ^& objCS.Manufacturer ^& " " ^& objCS.Model ^& " virtual machine, processor information is also needed for the physical machine") >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      Wscript.StdOut.WriteBlankLines(1)                                                                                                                               >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      If InStr(objCS.Manufacturer, "Microsoft Corporation") ^> 0 Then                                                                                                 >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.        Wscript.StdOut.WriteLine "  If this is a Hyper-V Virtualized environment "                                                                                    >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.        Wscript.StdOut.WriteLine "  please run lms_cpuq.cmd in the Root Partition"                                                                                    >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      End If                                                                                                                                                          >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    End If                                                                                                                                                            >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    objTextFile.WriteLine("  Manufacturer: " ^& objCS.Manufacturer)                                                                                                   >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    objTextFile.WriteLine("  Model: " ^& objCS.Model)                                                                                                                 >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    objTextFile.WriteLine("  NumberOfProcessors: " ^& objCS.NumberOfProcessors)                                                                                       >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  Next                                                                                                                                                                >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.                                                                                                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  objTextFile.WriteLine("Processors")                                                                                                                                 >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.                                                                                                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  ' Get CPU information                                                                                                                                               >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  Set colProcessors = objWMIService.ExecQuery("Select * from Win32_Processor")                                                                                        >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  For Each objProcessor in colProcessors                                                                                                                              >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    objTextFile.WriteLine("  CPU Name: " ^& objProcessor.Name)                                                                                                        >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    objTextFile.WriteLine("  CPU Description: " ^& objProcessor.Description)                                                                                          >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    objTextFile.WriteLine("  CPU MaximumClockSpeed [MHz]: " ^& objProcessor.MaxClockSpeed)                                                                            >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    objTextFile.WriteLine("  CPU NumberOfCores: " ^& objProcessor.NumberOfCores)                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    objTextFile.WriteLine("  CPU NumberOfLogicalProcessors: " ^& objProcessor.NumberOfLogicalProcessors)                                                              >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  Next                                                                                                                                                                >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.                                                                                                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  ' NumberOfCores and NumberOfLogicalProcessors are only supported in the latest WMI version (available as a hotfix)                                                  >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  If Err.Number = 438 Then                                                                                                                                            >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    objTextFile.WriteLine("  CPU NumberOfCores: PATCH NOT AVAILABLE (Error Number: " ^& Err.Number ^& "; Error Description: " ^& Err.Description ^& ")")              >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    objTextFile.WriteLine("  CPU NumberOfLogicalProcessors: PATCH NOT AVAILABLE (Error Number: " ^& Err.Number ^& "; Error Description: " ^& Err.Description ^& ")")  >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  End If                                                                                                                                                              >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.                                                                                                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  objTextFile.WriteLine("IP Address")                                                                                                                                 >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.                                                                                                                                                                      >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  ' Get IP Address(es)                                                                                                                                                >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  Set IPConfigSet = objWMIService.ExecQuery ("Select IPAddress from Win32_NetworkAdapterConfiguration WHERE IPEnabled=True")                                          >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  For Each IPConfig in IPConfigSet                                                                                                                                    >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    If Not IsNull(IPConfig.IPAddress) Then                                                                                                                            >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      For i=LBound(IPConfig.IPAddress) to UBound(IPConfig.IPAddress)                                                                                                  >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      If IPConfig.IPAddress(i) ^<^> "0.0.0.0" Then objTextFile.WriteLine("  IP Address: " ^& IPConfig.IPAddress(i))                                                   >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.      Next                                                                                                                                                            >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.    End If                                                                                                                                                            >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.  Next                                                                                                                                                                >> "%TEMP%\lms_cpuq_tmp.vbs"
  echo.End if                                                                                                                                                                >> "%TEMP%\lms_cpuq_tmp.vbs"

  echo Preparing to run VB Script file "%TEMP%\lms_cpuq_tmp.vbs": >> %RETURN_FILE%
  echo to query Windows Management Instrumentation (WMI) >> %RETURN_FILE%
  echo ################################ >> %RETURN_FILE%
  type "%TEMP%\lms_cpuq_tmp.vbs"          >> %RETURN_FILE%
  echo ################################ >> %RETURN_FILE%

       %SystemRoot%\System32\cscript.exe "%TEMP%\lms_cpuq_tmp.vbs" 2> "%TEMP%\cpu_info.err"
  echo %SystemRoot%\System32\cscript.exe "%TEMP%\lms_cpuq_tmp.vbs" 2^> "%TEMP%\cpu_info.err"  >> %RETURN_FILE%
  echo ################################ >> %RETURN_FILE%
  type "%TEMP%\lms_cpuq_tmp.txt"          >> %RETURN_FILE%
  type "%TEMP%\cpu_info.err"              >> %RETURN_FILE%
 
  del "%TEMP%\lms_cpuq_tmp.txt"
  del "%TEMP%\cpu_info.err"
  del "%TEMP%\lms_cpuq_tmp.vbs"
    
  echo Script End Time: %time%          >> %RETURN_FILE%
  echo ################################ >> %RETURN_FILE%

if not exist "%*" (
	echo Done.
	echo Please collect the output file: %RETURN_FILE%
)

  goto lms_cpu_info


:lms_cpu_info
endlocal
echo.
:EOF
