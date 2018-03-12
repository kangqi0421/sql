/*
  LMSCollection_main.js  		v18.1.2
		This script is used to search for all the installed instances of Oracle  
		products in the target system. 
*/

/**
 * main
 */
//Set up use of Env variables
var WshShell = WScript.CreateObject("WScript.Shell");
var fso = new ActiveXObject("Scripting.FileSystemObject");
var SYSTEM_FOLDER = 1;
var TEMP_FOLDER   = 2;
var wbemFlagReturnImmediately = 0x10;
var wbemFlagForwardOnly = 0x20;

//Get the Temp folder
try {
	var tfolder = fso.GetSpecialFolder(TEMP_FOLDER);
} catch(e) {
	var tfolder = fso.getFolder(".").path +"\\temp";
} 

//declare and initialize vars
// Script descrptive vars
var SCRIPT_VERSION = "18.1.2"
var LMSCT_BUILD_VERSION = "18.1.2"
var SCRIPT_NAME = "LMSCollection_main.js"
var SCRIPT_OPTIONS = WScript.Arguments;

//LMSCT vars
var MACHINE_NAME = WshShell.ExpandEnvironmentStrings("%COMPUTERNAME%");
var LMSCT_HOME = fso.getFolder(".").path;
var LMSCT_PID = get_pid();
var LMSCT_TMP = tfolder + "\\lmsct_tmp_" + MACHINE_NAME + "_" + LMSCT_PID + "\\";

var OUTPUT_DIR = LMSCT_HOME + "\\output\\";
var LMSCT_DEBUG = ""

var SEARCH_DIR = GetDriveList();
var OUTPUT_DEBUG = "";
var DEBUG = false;
var LICAGREE = false;
var COLLECT_LMS_DEBUG = true;
var PRODLIST = "";
var FASTSEARCH = false;
var REMOTE_DB = "";
var MASK_DATA = "";
var ForReading = 1;
var TristateFalse = 0;
var ForWriting = 2, ForAppending = 8;
var SEARCH_COMMAND = "";
var WARNING_EMPTY = false;
var ERRORS_EMPTY = false;

//Product File lists and variables
var ALLSEARCHFILES =  "";
var PRODUCTLIST =  "";
var ALLPRODLIST = "";
var RUNLIST =  "";
var	RUNCPUQ = "";
var RANCPUQ = "false";
var PROCESSLIST = "";
var CMDOUTFILELIST =  "";
var COMPLETEPRODLIST =  "";
var BUNDLEFILES="";
var TSFILES="";
var TAILFILES="";
var LISTINGFILES="";
var COPYFILES="";
var LOGFILES="";
var LMS_HOMES="";
var LMS_HOMES_arr="";
var PRODUCTSRUN="";
var COLLECTRMDATAFILES="";
//debug and error files
var LMS_DEBUG_FILE_fname = "";
var LMS_DEBUG_FILE = "";


// check the command line arguements.
checkArguments(SCRIPT_OPTIONS);
try 
{
	createDirectoryFromPath(LMSCT_TMP);
}
catch (exception)
{
	WINDOWSCMDERR.WriteLine("The directory " + LMSCT_TMP + " can not be created. Exception:" + exception);
}

if ( !fso.FolderExists(LMSCT_TMP + "logs\\") )
{		
	try 
	{
		createDirectoryFromPath(LMSCT_TMP + "logs\\");
	}
	catch (exception)
	{
		echo_logs("LMSCT: LMS-00110: WARNING: The directory " + LMSCT_TMP + "logs\\ does not exist and can not be created.","Warnings");
	}
}
WScript.echo(LMSCT_TMP + "logs\\");

LMSCT_DEBUG = LMSCT_TMP + "\\debug\\";
try 
{
	createDirectoryFromPath(LMSCT_DEBUG);
}
catch (exception)
{
	WINDOWSCMDERR.WriteLine("The directory " + LMSCT_DEBUG + " can not be created. Exception:" + exception);
}




if ( DEBUG )
	debugWarning();


credentialValidation();

// print license if customer doesn't use -L Y
if ( !LICAGREE ) {
	runCommand("more ..\\resources\\util\\license_agreement.txt && pause", 1);

	WScript.StdOut.Write("\n\n  Do you accept the license agreement (y|n)");
	var ANSWER = WScript.StdIn.ReadLine();
	var licAgreeLoop = true;
	while ( licAgreeLoop ) {
		switch ( ANSWER ) 
		{
			case "Y" :
			case "y" :
				licAgreeLoop = false;
				break;
			case "n" :
			case "N" :
				printArgUsage();
				echo_logs("LMSCT: LMS-00102: WARNING: You must accept the license agreement to continue.","Warnings");
				licAgreeLoop = false;
				WScript.Quit(1);
				break;
			default : 
				WScript.StdOut.Write("Invalid option, please use y or n. Do you accept the license agreement (y|n)");
				ANSWER = WScript.StdIn.ReadLine();
		}
	}
}


var OUTPUT_DIR_FSO = fso.getFolder(OUTPUT_DIR);
	
var LMS_FILES_fname = LMSCT_TMP + "logs\\LMSfiles.txt";
//var LMS_FILES = fso.OpenTextFile(LMS_FILES_fname, ForWriting, "True");

var LMS_SORTED_FILES_fname = LMSCT_TMP + "logs\\LMSsortedfiles.txt";
//var LMS_SORTED_FILES = fso.OpenTextFile(LMS_SORTED_FILES_fname, ForWriting, "True");

var LMS_MACHINFO_FILE_fname = LMSCT_TMP + "logs\\" + MACHINE_NAME + "-info.txt";
var LMS_MACHINFO_FILE = fso.OpenTextFile(LMS_MACHINFO_FILE_fname, ForWriting, "True");	

var LMS_LOGS_FILE_fname = LMSCT_TMP + "logs\\LMSlogfiles.txt";
var LMS_LOGS_FILE = fso.OpenTextFile(LMS_LOGS_FILE_fname, ForWriting, "True");

var CMDFILE_fname = LMSCT_TMP + "logs\\OraCmdList.txt";
var CMDFILE = fso.OpenTextFile(CMDFILE_fname, ForWriting, "True");

var CMDOUTFILE_fname = LMSCT_TMP + "logs\\OraCmdOutFileList.txt";
var CMDOUTFILE = fso.OpenTextFile(CMDOUTFILE_fname, ForWriting, "True");

var WINDOWSCMDERR_fname = LMSCT_TMP + "logs\\windowscmderrs.txt";
var WINDOWSCMDERR = fso.OpenTextFile(WINDOWSCMDERR_fname, ForWriting, "True");
 
// results file
var LMS_RESULTS_FILE_fname = LMSCT_TMP + "logs\\LMSCollection-" + MACHINE_NAME + ".txt";
var LMS_RESULTS_FILE = fso.OpenTextFile(LMS_RESULTS_FILE_fname, ForWriting, "True");

var	LMS_ACTIONS_RESULTS_FILE_fname = LMSCT_TMP + "logs\\LMSCollection-Actions-" + MACHINE_NAME + ".txt";
var	LMS_ACTIONS_RESULTS_FILE = fso.OpenTextFile(LMS_ACTIONS_RESULTS_FILE_fname, ForWriting, "True");

var	LMSCT_COLLECTED_FILE_fname = LMSCT_TMP + "logs\\LMSCT_collected.log";
var	LMSCT_COLLECTED_FILE = fso.OpenTextFile(LMSCT_COLLECTED_FILE_fname, ForWriting, "True");

var	LMSCT_WARNINGS_FILE_fname = LMSCT_TMP + "logs\\LMSCT_warnings.log";
var	LMSCT_WARNINGS_FILE = fso.OpenTextFile(LMSCT_WARNINGS_FILE_fname, ForWriting, "True");

var	LMSCT_ERRORS_FILE_fname = LMSCT_TMP + "logs\\LMSCT_errors.log";
var	LMSCT_ERRORS_FILE = fso.OpenTextFile(LMSCT_ERRORS_FILE_fname, ForWriting, "True");

var LMS_HOMES_FILE_fname =  LMSCT_TMP + "logs\\LMSCollection-" + MACHINE_NAME + "-LMS_Homes.txt";
var	LMS_HOMES_FILE = fso.OpenTextFile(LMS_HOMES_FILE_fname, ForWriting, "True");

var LMS_RESULTS_SUMMARY_FILE_fname =  LMSCT_TMP + "logs\\results_summary.log";
var	LMS_RESULTS_SUMMARY_FILE = fso.OpenTextFile(LMS_RESULTS_SUMMARY_FILE_fname, ForWriting, "True");

PRODLIST = PRODLIST.slice(0,-1);

var scriptOptions = "";
for (var ii = 0; ii < SCRIPT_OPTIONS.length; ii++)
	scriptOptions += SCRIPT_OPTIONS(ii) + " ";


// get the Products to be searched for
try {
	getProducts();
} catch(e) {
	WINDOWSCMDERR.WriteLine("Exception during getProducts function processing. Exception "+ e.description);
} 

//parse and set search files and process list
try {
	parseProductFiles();
} catch(e) {
	WINDOWSCMDERR.WriteLine("Exception during parseProductFiles function processing. Exception "+ e.description);
} 
// export the output dir for child process only.
var wshSystemEnv = WshShell.Environment( "PROCESS" );
wshSystemEnv("OUTPUT_DIR") = OUTPUT_DIR; 
wshSystemEnv("PRODLIST") = PRODLIST;
wshSystemEnv("ALLPRODLIST") = ALLPRODLIST;
wshSystemEnv("PRODUCTLIST") = PRODUCTLIST;
wshSystemEnv("LICAGREE") = LICAGREE;
wshSystemEnv("SCRIPT_OPTIONS") = scriptOptions;
wshSystemEnv("REMOTE_DB") = REMOTE_DB;
wshSystemEnv("LMSCT_BUILD_VERSION") = LMSCT_BUILD_VERSION;
wshSystemEnv("LMSCT_TMP") = LMSCT_TMP;
wshSystemEnv("LMSCT_HOME") = LMSCT_HOME;


// Run CPUQ before machine info section
if ( RUNLIST.indexOf("cpuq_main") != -1 ) {
	doRunCmd(RUNCPUQ);
	RANCPUQ = "true";
}
	
//Generate a machine summary file 
try {
	printMachineInfo();
} catch(e) {
	WINDOWSCMDERR.WriteLine("Exception during printMachineInfo function processing. Exception "+ e.description);
} 

//Generate a list for fastsearch option
if ( ALLPRODLIST.indexOf("WLS") != -1 )
{
	try {
		getDefaultOracleEnv();
	} catch(e) {
		WINDOWSCMDERR.WriteLine("Exception during getDefaultOracleEnv function processing. Exception "+ e.description);
	} 
}
	
//search start time
var SEARCH_START = new Date();
var SEARCH_FINISH;
// find all the files on the target system; skip search if there are no search files
if ( ALLSEARCHFILES != "" )
{
	try {
		doSearch();
	} catch(e) {
		WINDOWSCMDERR.WriteLine("Exception during doSearch function processing. Exception "+ e.description);
	} 
	SEARCH_FINISH = new Date();
	WScript.echo("LMSCT file search started at " + SEARCH_START + "and finished at " +SEARCH_FINISH);
} else {
	SEARCH_FINISH = new Date();
}
	//# print search information
LMS_MACHINFO_FILE.WriteLine("[BEGIN SEARCH INFO]");
LMS_MACHINFO_FILE.WriteLine("Search start=" + SEARCH_START);
LMS_MACHINFO_FILE.WriteLine("Search command=" + SEARCH_COMMAND);
LMS_MACHINFO_FILE.WriteLine("Search finish=" + SEARCH_FINISH);
LMS_MACHINFO_FILE.WriteLine("[END SEARCH INFO]");

// Run the specified Commands or scripts
	
try {
	doRunCmd(RUNLIST);
} catch(e) {
	WINDOWSCMDERR.WriteLine("Exception during doRunCmd(RUNLIST) function processing. Exception "+ e.description);
} 

// Clean up the file list get rid of non LMS/Oracle config.xml and registry.xml

try {
	fileGetLMSFiles();
} catch(e) {
	WINDOWSCMDERR.WriteLine("Exception during fileGetLMSFiles function processing. Exception "+ e.description);
} 
// package LMS_SORTED_FILES results for post-processing

try {
	fileAction(); 
} catch(e) {
	WINDOWSCMDERR.WriteLine("Exception during fileAction function processing. Exception "+ e.description);
} 

try 
{

	//Add the WLST "compare_result.txt" file to the zip
	if ( fso.FileExists("compare_result.txt") )
		fso.CopyFile("compare_result.txt", LMSCT_TMP + "logs\\compare_result.txt");

} catch (exception)
{
	echo_logs("LMSCT: LMS-00125: WARNING: Error copying output files. Exception: " + exception.description,"Warnings");
}	


//Generate a list of FMWHomes collected
if ( ALLPRODLIST.indexOf("WLS") != -1 )
{
	try {
		getDefaultOracleEnv();
	} catch(e) {
	} 
}

//Generate a list of config locations collected
if ( ALLPRODLIST.indexOf("WLS") != -1 )
{
	try {
		configsCollected();	
	} catch(e) {
		WINDOWSCMDERR.WriteLine("Exception during configsCollected function processing. Exception "+ e.description);
	} 
}

//close the file objects and delete the files.
LMS_MACHINFO_FILE.Close();	
LMS_LOGS_FILE.Close();
CMDFILE.Close();
CMDOUTFILE.Close();
LMS_DEBUG_FILE.Close();
LMS_RESULTS_FILE.Close();
LMS_ACTIONS_RESULTS_FILE.Close();

//mask data if required.
if ( MASK_DATA == "all" || MASK_DATA == "IP" || MASK_DATA == "ip" || MASK_DATA == "user" )
{
	WScript.Echo("\nMasking sensitive data ...........\n");

	try {
		maskResults();
	} catch(e) {
		echo_logs("LMSCT: LMS-00120: WARNING: Exception during maskResults function processing. Exception "+ e.description,"Warnings");
	} 
}


//Clear screen before last messages
WScript.Echo("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");


//print output to screen
try {
	printResults();
} catch(e) {
	WINDOWSCMDERR.WriteLine("Exception during printResults function processing. Exception "+ e.description);
} 

// close and delete unecessary logs files
LMSCT_ERRORS_FILE.Close();
LMSCT_COLLECTED_FILE.Close();
LMSCT_WARNINGS_FILE.Close();
LMS_HOMES_FILE.Close();
LMS_RESULTS_SUMMARY_FILE.Close();
WINDOWSCMDERR.Close();

// mv files to debug
try
{
	debugFiles = ShowFiles(LMSCT_TMP + "logs\\");
} catch (e) {
		WScript.Echo("LMSCT: LMS-00122: WARNING: Exception during listing of debug files. Exception "+ e.description);
}

// loop through each of the files in the folder
for (; !debugFiles.atEnd(); debugFiles.moveNext())
{
	
	fname = debugFiles.item();
	shortFname = fso.GetBaseName(fname);
	extFname = fso.GetExtensionName(fname);

	if ( ALLPRODLIST.indexOf("WLS") != -1 || ALLPRODLIST.indexOf("OAS") != -1 || ALLPRODLIST.indexOf("Tuxedo") != -1 || ALLPRODLIST.indexOf("OBI") != 1 )
	{
		if ( shortFname != "db_list"  && fname != LMS_RESULTS_FILE_fname && fname != LMS_MACHINFO_FILE_fname && fname != LMS_LOGS_FILE_fname ) {
			try
			{
				fso.MoveFile(fname,LMSCT_DEBUG + "\\" + shortFname + "." + extFname);
			} catch (e) {
					WScript.Echo("LMSCT: LMS-00124: WARNING: Exception during moving of debug files. Exception "+ e.description);
			}
		}
		
	} else { 
		if ( shortFname != "db_list" )
		{
			try
			{
				fso.MoveFile(fname,LMSCT_DEBUG + "\\" + shortFname + "." + extFname);
			} catch (e) {
					WScript.Echo("LMSCT: LMS-00124: WARNING: Exception during moving of debug files. Exception "+ e.description);
			}
		}
	}
	
}

var currentdate = new Date();
var ZIPTIMESTAMP ="." + currentdate.getFullYear()
					+ (currentdate.getMonth()+1)
					+ currentdate.getDate() + "_"
					+ currentdate.getHours()  
					+ currentdate.getMinutes()
					+ currentdate.getSeconds();

//Compress the debug files
if ( COLLECT_LMS_DEBUG )
{	
	try {
		zipDebug();
	} catch(e) {
		WScript.Echo("LMSCT: LMS-00123: WARNING: Exception during zipDebug function processing. Exception "+ e.description);
	}
}

if ( PRODLIST === "LMSCPU," ) {
	try {	
		fso.DeleteFolder(LMSCT_TMP + "logs");
	} catch (e)
	{
	}
}
	

//Compress the Results file
try {
	zipFiles();
} catch(e) {
	WScript.Echo("LMSCT: LMS-00121: WARNING: Exception during zipFiles function processing. Exception "+ e.description);
} 

if ( fso.FileExists("compare_result.txt") )
{
	fso.DeleteFile("compare_result.txt");
}

if ( fso.FolderExists(LMSCT_TMP) )
{
	try {	
		fso.DeleteFolder(LMSCT_TMP.slice(0,-1));
	} catch (e)
	{
	}
}

//destroy the FSO object
fso = null;
/*############################ End MAIN ############################*/

/*
 ********************User Command Line Management Utilities*********************
 */

 /**
 * function to print the command line options syntax
 */
 function printArgUsage()
{
	var argUsage = new Array ();
	argUsage = ["-d search_dir [-p product] [-o full_path_dir_name] [-debug true|false] [-m all|ip|user]",
				"		[-L Y|y|N|n] [-fastsearch] [-tns] [-t full_path_dir_name] \n",
				"-d	Specifiy the directories to be searched for the installations.",
				"	A quoted string of directory names separated by a comma is required for",
				"	when more than 1 directory is to be searched. The default is all fixed ",
				"	or local drives. i.e. c:\,d:\ and not the CDROM or NFS drives.\n",
				"-o	Option to output the collected files to the directory",
				"	given by <full_path_dir_name>. The option should be a full path name.",
				"   It will be named LMSCollection-<MACHINE_NAME>.zip.",
				"	If not specified, default is the output directory where the tool is located.\n",
				"-debug [true|false]  Option to turn on debugging information. Default is false.\n",
				"-m	Option to turn on masking of sensitive information.",
				"	Perl needs to be in the system path for this to run.  Default is off.",
				"	It can mask username/password combinations or IP addressess, ",
				"	see README.txt for details.\n",
				"-L	Option to agree to license agreement without having it displayed.",
				"	Default is off, the License Agreement will be printed to the screen.\n",
				"	***USE OF THIS OPTION IMPLIES LICENSE ACCEPTENCE.***\n",
				"-p	Option to pass in a list of Oracle products to look for.",
				"	valid options include:",
				"		all,FormsReports,OAS,WLS,SOA,Tuxedo,LMSCPUQ,DB,EBS,",
				"		WLSNUP,WLSBasic,OBI,Webcenter\n",
				"-fastsearch	Option to auto detect Oracle product directories on the system.",
				"		Note: The fast search option of LMSCollection is intended to",
				"		gather information from the system with minimal file searching.\n",
				"-tns	Option to switch from the automatic local database connection",
				"	mode (the default) to an interactive remote database connection",
				"	mode, via database listener. The tool prompts for connection",
				"	description details (e.g. listener host, port, etc), database",
				"	user and password, then connects to the remote database using ",
				"	SQL*Plus and collects the data for the selected products",
				"	DB, EBS). Multiple databases can be collected.",
				"	This mode cannot be used together with the silent mode (-L Y).\n",
				"-t		Option to set the LMS Collection Tool temporary output to files in the",
				"	directory specified by full_path_dir_name. The option should",
				"  	be a full pathname. The files will be deleted at the end of the LMSCT",
				"	run.  If not specified default is the Windows %TMP% directory.\n"];

	
	for (var ii=0;ii<argUsage.length;ii++)
	{
		WScript.Echo(argUsage[ii]);
	}
}

/**
 * function to syntax check and process the command line options
 */
function checkArguments( argVals )
{
	var dEnum, folder;
	var searchDirs = new Array();
	
	for ( var ii=0; ii<argVals.length;ii++)
	{
		if ( argVals.Item(ii).indexOf("-") == 0 )
		{
			switch ( argVals.Item(ii) ) 
			{
				case "-d" :
					try {
						SEARCH_DIR = argVals.Item(ii +1);
					} catch (exception)
					{
						printArgUsage();
						echo_logs("LMSCT: LMS-00002: ERROR: No argument provided to the -d parameter.","Errors");
						WScript.Quit(1);
					}
					if ( SEARCH_DIR.indexOf(",") >= 0 )
					{
						searchDirs = SEARCH_DIR.split(',');
						for (var jj=0; jj<searchDirs.length; jj++)
						{
							folder = searchDirs[jj];
							if ( !fso.FolderExists(folder) )
							{
								printArgUsage();
								echo_logs("LMSCT: LMS-00001: ERROR: Argrument search directory " + searchDirs[jj] + " does not exist or is not readable.","Errors");
								WScript.Quit(1);
							}
						}	
					}
					else 
					{
						folder = SEARCH_DIR;
						if ( !fso.FolderExists(folder) )
						{
							printArgUsage();
							echo_logs("LMSCT: LMS-00001: ERROR: Argrument search directory " + SEARCH_DIR + " does not exist or is not readable.","Errors");										
							WScript.Quit(1);
						}
					}
					break;
				case "-o" :
					try {
						OUTPUT_DIR = argVals.Item(ii +1);
					} catch (exception)
					{
						printArgUsage();
						echo_logs("LMSCT: LMS-00005: ERROR:  No argument provided to the -o parameter.","Errors");				
						WScript.Quit(1);
					}					
					
					
					if ( OUTPUT_DIR.charAt(OUTPUT_DIR.length-1) != "\\" )
					{
						OUTPUT_DIR += "\\";
					}
					


					if ( !fso.FolderExists(OUTPUT_DIR) )
					{
						if(!OUTPUT_DIR.charAt(0).match(/^[a-zA-Z]/)) {
							printArgUsage();
							echo_logs("LMSCT: LMS-00024: ERROR: Output directory: " + OUTPUT_DIR + ", is not a valid Windows Full path name.","Errors");	
							WScript.Echo();	
							WScript.Quit(1);
						} else if(!OUTPUT_DIR.charAt(1).match(/^[:]/) || !OUTPUT_DIR.charAt(2).match(/^[\/\\]/)) {
							printArgUsage();
							echo_logs("LMSCT: LMS-00024: ERROR: Output directory: " + OUTPUT_DIR + ", is not a valid Windows Full path name.","Errors");	
							WScript.Quit(1);
						} else {
							try 
							{
								createDirectoryFromPath(OUTPUT_DIR);
							}
							catch (exception)
							{
								printArgUsage();
								echo_logs("LMSCT: LMS-00025: ERROR: The directory " + OUTPUT_DIR + " does not exist and can not be created.\n Please chose a different directory or create it outside of LMSCollection script.","Errors");	
								WScript.Quit(1);
							}
						}
						
		
					}
					break;
				case "-debug" :
					try {
						OUTPUT_DEBUG = argVals.Item(ii +1);
					} catch (exception)
					{
						printArgUsage();
						echo_logs("LMSCT: LMS-00002: ERROR: No argument provided to the -d parameter.","Errors");							
						WScript.Quit(1);
					}	
					
					if ( OUTPUT_DEBUG == "true" )
						DEBUG = true;
					else
						DEBUG = false;
					break;	
				case "-fastsearch" :
					FASTSEARCH = true;
					break;
				case "-tns" :
					REMOTE_DB = "YES";
					break;
				case "-L" :
					try {
						LICAGREE = argVals.Item(ii +1);
					} catch (exception)
					{
						printArgUsage();
						echo_logs("LMSCT: LMS-00008: ERROR:  No argument provided to the -L parameter.","Errors");						
						WScript.Quit(1);
					}					
					
					if ( LICAGREE == "Y" || LICAGREE == "y" )
						LICAGREE = true;
					else
						LICAGREE = false;
					break;
				case "-p" :
					try {
						PRODLIST = argVals.Item(ii +1);
					} catch (exception)
					{
						printArgUsage();
						echo_logs("LMSCT: LMS-00009: ERROR:  No argument provided to the -p parameter.","Errors");							
						WScript.Quit(1);
					}
				
					// make sure PRODLIST end with a ","
					if ( PRODLIST.charAt( PRODLIST.length-1 ) != "," )
						PRODLIST += ",";
					
					if ( PRODLIST != "all," ) {
						var PROD_ARRAY = PRODLIST.split(',');
						for (var jj=0; jj<PROD_ARRAY.length; jj++)
						{
							folder = "..\\resources\\products\\" + PROD_ARRAY[jj];
							if ( !fso.FolderExists(folder) )
							{
								printArgUsage();
								echo_logs("LMSCT: LMS-00010: ERROR: " + PROD_ARRAY[jj] + " is not a valid product family.","Errors");	
								WScript.Quit(1);;
							}
						}
					}
					break;
				case "-m" :
					try {
						MASK_DATA = argVals.Item(ii +1);
					} catch (exception)
					{
						printArgUsage();
						echo_logs("LMSCT: LMS-00011: ERROR:  Valid option not chosen for the -m mask parameter.","Errors");							
						WScript.Quit(1);
					}
					
					if ( MASK_DATA == "all" || MASK_DATA == "IP" || MASK_DATA == "ip" || MASK_DATA == "user")
					{
						//options match, do nothing.		
					}
					else
					{
						printArgUsage();
						echo_logs("LMSCT: LMS-00011: ERROR:  Valid option not chosen for the -m mask parameter.","Errors");	
						WScript.Quit(1);
					}
					
					var perlError;
					var perlDocsError;

					perlError = runCommand("perl -v", 0 );
									
					if ( perlError > 0 ) {
						printArgUsage();
						echo_logs("LMSCT: LMS-00012: ERROR:  Perl was not found in the system path.\nPlease review the documentation for masking requirements.","Errors");
						WScript.Quit(1);
					} else {				
						perlDocsError = runCommand("perldoc -l Digest::SHA", 0 );					
						if ( perlDocsError > 0 ) {
							printArgUsage();
							echo_logs("LMSCT: LMS-00013: ERROR:  Cannot find a perl with Digest::SHA installed.\nPlease review the documentation for masking requirements.","Errors");
							WScript.Quit(1);							
						}					
					}
					
					break;
				case "-t" :
					try {
						LMSCT_TMP = argVals.Item(ii +1);
					} catch (exception)
					{
						printArgUsage();
						echo_logs("LMSCT: LMS-00017: ERROR:  No argument provided to the -t parameter.","Errors");				
						WScript.Quit(1);
					}					
					LMSCT_TMP = argVals.Item(ii +1);
					if ( LMSCT_TMP.charAt(LMSCT_TMP.length-1) != "\\" )
					{
						LMSCT_TMP += "\\";

					}					
					
					LMSCT_TMP = LMSCT_TMP + "lmsct_tmp_" + MACHINE_NAME + "_" + LMSCT_PID + "\\";
					
					if ( !fso.FolderExists(LMSCT_TMP) )
					{
						if(!LMSCT_TMP.charAt(0).match(/^[a-zA-Z]/)) {
							printArgUsage();
							echo_logs("LMSCT: LMS-00028: ERROR: Output directory: " + LMSCT_TMP + ", is not a valid Windows Full path name.","Errors");	
							WScript.Echo();	
							WScript.Quit(1);
						} else if(!LMSCT_TMP.charAt(1).match(/^[:]/) || !LMSCT_TMP.charAt(2).match(/^[\/\\]/)) {
							printArgUsage();
							echo_logs("LMSCT: LMS-00028: ERROR: Output directory: " + LMSCT_TMP + ", is not a valid Windows Full path name.","Errors");	
							WScript.Quit(1);
						} else {
							try 
							{
								createDirectoryFromPath(LMSCT_TMP);
							}
							catch (exception)
							{
								printArgUsage();
								echo_logs("LMSCT: LMS-00029: ERROR: The directory " + LMSCT_TMP + " does not exist and can not be created.\n Please chose a different directory or create it outside of LMSCollection script.","Errors");	
								WScript.Quit(1);
							}
						}
						
		
					}
					break;					
				default : 
					printArgUsage();
					echo_logs("LMSCT: LMS-00015: ERROR: " + argVals.Item(ii) + " is an invalid entry.","Errors");
					WScript.Quit(1);					
			}
		}
	}

	if ( REMOTE_DB == "YES" && LICAGREE ) {
		printArgUsage();
		echo_logs("LMSCT: LMS-00016: ERROR:  -tns option cannot be used together with silent mode (-L Y)","Errors");
		WScript.Quit(1);	
	}
	
	if ( !fso.FolderExists(OUTPUT_DIR) )
	{	
		try
		{
			createDirectoryFromPath(OUTPUT_DIR);
		}
		catch (exception)
		{
			echo_logs("LMSCT: LMS-00109: WARNING: The directory " + OUTPUT_DIR + "\\output\\ does not exist and can not be created.","Warnings");
		}
	}
	
	if ( PRODLIST.indexOf("all") != -1 || PRODLIST.indexOf("WLS,") != -1 || PRODLIST.indexOf("FMW") != -1 || PRODLIST.indexOf("OAS") != -1 )
	{
		try
		{
			createDirectoryFromPath(LMSCT_TMP + "FMW\\");
		}
		catch (exception)
		{
			echo_logs("LMSCT: LMS-00109: WARNING: The directory " + LMSCT_TMP + "FMW\\ does not exist and can not be created.","Warnings");
		}
	}

	
	if ( !fso.FolderExists(LMSCT_TMP + "logs\\") )
	{		
		try 
		{
			createDirectoryFromPath(LMSCT_TMP + "logs\\");
		}
		catch (exception)
		{
			echo_logs("LMSCT: LMS-00110: WARNING: The directory " + LMSCT_TMP + "logs\\ does not exist and can not be created.","Warnings");
		}
	}
	
	
	LMSCT_DEBUG = LMSCT_TMP + "debug\\";

	if ( !fso.FolderExists( LMSCT_DEBUG ) )
	{		
		try 
		{
			createDirectoryFromPath( LMSCT_DEBUG );
		}
		catch (exception)
		{
			echo_logs("LMSCT: LMS-00111: WARNING: The directory " + LMSCT_DEBUG + " does not exist and can not be created.","Warnings");
		}
	}
	
	
	//debug and error files
	LMS_DEBUG_FILE_fname = LMSCT_TMP + "logs\\LMSdebugfile.txt";
	LMS_DEBUG_FILE = fso.OpenTextFile(LMS_DEBUG_FILE_fname, ForWriting, "True");	
	
	//debug
	var options = "";
	if ( DEBUG ) 
	{
		echo_debug("debug.function.checkSyntax");
		for (var ii = 0; ii < SCRIPT_OPTIONS.length; ii++)
			options += SCRIPT_OPTIONS(ii) + " ";
		echo_debug("debug.script options=" + options);
		echo_debug("MACHINE_NAME =" + MACHINE_NAME);
		echo_debug("OUTPUT_DIR =" + OUTPUT_DIR );
		echo_debug("SEARCH_DIR =" + SEARCH_DIR );
		echo_debug("OUTPUT_DEBUG =" + OUTPUT_DEBUG );
		echo_debug("LICAGREE =" + LICAGREE );
		echo_debug("PRODLIST =" + PRODLIST );
		echo_debug("MASK_DATA =" + MASK_DATA );
		echo_debug("\nLMS_DEBUG_FILE_fname==" + LMS_DEBUG_FILE_fname);

	}
	
}

/**
 * function to check if the current user is an administrator.
 */
function credentialValidation()
{
	var credentials = runCommand("net session >nul 2>&1",0);
	if ( credentials != 0 )
	{
		echo_logs("LMSCT: LMS-00100: WARNING: Current OS user does NOT have 'administrative' rights!\nIf you're sure that the Current OS user is granted the required privileges, continue with yes(y), otherwise select No(n) and please log on with a OS user with sufficient privileges.\nRunning the LMSCollection Script with insufficient privileges may have a significant impact on the quality of the data and information collected from this environment. Due to this, Oracle LMS may have to get back to you and ask for additional items, or to execute again.","Warnings");
		if ( !LICAGREE ) {

			WScript.StdOut.Write("\n\n  Please choose an Y to continue or N to quit:");
			var ANSWER = WScript.StdIn.ReadLine();
			var licAgreeLoop = true;
			while ( licAgreeLoop ) {
				switch ( ANSWER ) 
				{
					case "Y" :
					case "y" :
						licAgreeLoop = false;
						break;
					case "n" :
					case "N" :
						echo_logs("LMSCT: LMS-00101: WARNING:  \nUser chose not to continue the LMSCollection Script.","Warnings");
						licAgreeLoop = false;
						WScript.Quit(1);
						break;
					default : 
						WScript.StdOut.Write("Invalid option, please use y or n. (y|n)");
						ANSWER = WScript.StdIn.ReadLine();
				}
			}
		}
	} 
}

/**
 * function to check if the user understands the debug risk.
 */
function debugWarning()
{
	echo_logs("LMSCT: LMS-00200: WARNING: You have chosen to run the LMSCollection tool in debug mode.\n  The script will write data in files in order for Oracle LMS to debug the running of the scripts. You are required to inspect the files for any data that may be sensitive before returning the output to Oracle LMS.  \nIf you wish to continue, continue with yes(y), otherwise select no(n) and contact your LMS representative for more details.","Warnings");

	WScript.StdOut.Write("\n\n  Please choose an Y to continue or N to quit:");
	var ANSWER = WScript.StdIn.ReadLine();
	var licAgreeLoop = true;
	while ( licAgreeLoop ) {
		switch ( ANSWER ) 
		{
			case "Y" :
			case "y" :
				licAgreeLoop = false;
				break;
			case "n" :
			case "N" :
				echo_logs("LMSCT: LMS-00101: WARNING:  \nUser chose not to continue the LMSCollection Script.","Warnings");
				licAgreeLoop = false;
				WScript.Quit(1);
				break;
			default : 
				WScript.StdOut.Write("Invalid option, please use y or n. (y|n)");
				ANSWER = WScript.StdIn.ReadLine();
		}
	}

}


/**	################################################################################
	#
	#***********************Helper and Debug Functions************************
	#
	################################################################################
 */

/**
 * get_pid - get the pid of the cscript running this.
 */
function get_pid()
{
	var objWMIService = GetObject("winmgmts:\\\\.\\root\\CIMV2");
	var pidItems = objWMIService.ExecQuery("Select * from Win32_Process Where Name = 'cscript.exe'", "WQL",
										  wbemFlagReturnImmediately | wbemFlagForwardOnly);

	var pid;
	try {
		var enumItems = new Enumerator(pidItems);
		for (; !enumItems.atEnd(); enumItems.moveNext()) {
			var objItem = enumItems.item();

			if ( objItem.CommandLine.indexOf("LMSCollection_main.js") > -1 )
				pid = objItem.ProcessID;
		}
	} catch(e) {
		pid = 0000;
		if( DEBUG )
			echo_debug("OBJItem error==" + e.description);
	}
	return pid;
}

 
/**
 * echo_debug - enhace debugging
 */
function echo_debug(args)
{
    WScript.Echo(args);
	try {
		LMS_DEBUG_FILE.WriteLine(args);
	} catch(e) {
	}
}

/**
 * echo_logs - enhace debugging
 */
function echo_logs(loggingText,loggingFile)
{
    WScript.Echo(loggingText);
	try {
		if ( loggingFile.indexOf("Collected") != -1 ) {
			LMSCT_COLLECTED_FILE.WriteLine(loggingText);
		} else if ( loggingFile.indexOf("Warnings") != -1 ) {
			LMSCT_WARNINGS_FILE.WriteLine(loggingText);
		} else if( loggingFile.indexOf("Errors") != -1 ) {
			LMSCT_ERRORS_FILE.WriteLine(loggingText);
		} else if( loggingFile.indexOf("WindowsCMD") != -1 ) {
			WINDOWSCMDERR.WriteLine(loggingText);
		}
	} catch(e) {
	}
}


/**
 * GetAllDriveList - function to get all of drives on the system.
 */
function GetAllDriveList()
{
	//Initialize variables
	var list = new Array();
	var dEnum, driveItem;
	dEnum = new Enumerator(fso.Drives);
	for (; !dEnum.atEnd(); dEnum.moveNext())
	{
		driveItem = dEnum.item();
		switch ( driveItem.DriveType ) 
		{
			case 0 :
				list.push(driveItem.Path+ "\\ , DriveType: Unknown");
				break;
			case 1 :
				list.push(driveItem.Path+ "\\ , DriveType: Removable Drive");
				break;
			case 2 :
				list.push(driveItem.Path+ "\\ , DriveType: Fixed Disk");
				break;
			case 3 :
				list.push(driveItem.Path+ "\\ , DriveType: Remote Disk");
				break;
			case 4 :
				list.push(driveItem.Path+ "\\ , DriveType: CDROM Drive");
				break;
			case 5 :
				list.push(driveItem.Path+ "\\ , DriveType: RAM Disk");
				break;
			default : 
				list.push(driveItem.Path+ "\\ , DriveType: Not Found");
		}
	}	
   
	return(list);
}

/**
 * GetDriveList - function to get all of the local/fixed drives on the system.
 */
function GetDriveList()
{
	//Initialize variables
	var list, dEnum, driveItem;
	dEnum = new Enumerator(fso.Drives);
	list = "";
	for (; !dEnum.atEnd(); dEnum.moveNext())
	{
		driveItem = dEnum.item();
		if (driveItem.DriveType == 2)
			list = list + driveItem.Path+ "\\," ;
	}	
   
	return(list.slice(0,-1));
}

/**
 * ShowFolders - function to return a comma separated list of the folders in a directory.
 */
 function ShowFolders(folderName)
{
  var fs, f, fc, s, dir;
  s = "";
  dir = "";
  f = fso.GetFolder(folderName);
  fc = new Enumerator(f.SubFolders);
  for (; !fc.atEnd();fc.moveNext())
  {
	s += fso.GetBaseName(fc.item());
    s += ",";
   }
  return(s);
}

/**
 * ShowFiles - function to return collection of the files in a directory.
 */
 function ShowFiles(folderName)
{
	var fs, f, fc, s;
	s = "";
	f = fso.GetFolder(folderName);
	fc = new Enumerator(f.Files);
  return(fc);
}

/** 
 * runCommand - Runs a specific command, uses WindowStyle and waits for the 
 *				command to return.
 *
 */
function runCommand(theRunCommand,windowStyle) {
	var cmdLine = "cmd.exe /c " + theRunCommand;
	var errorCode;
	
	if ( theRunCommand.indexOf("dir /a") == -1 )
		WScript.Echo("\nRunning ... \n" + cmdLine);	
	
	errorCode = WshShell.Run(cmdLine, windowStyle, true);

	return errorCode;
}

/** 
 *	removeLMSHOMEDupes
 *		pass in Oracle HOME arrary, truncate it to toplevel dir and remove dupes using the
 *      funcitonality of hashmaps.
 *     
 */
function removeLMSHOMEDupes(LMSarr) {
  var ii;
  var retArr=[];
  var objArr={};
 
  for (var ii=0;ii<LMSarr.length;ii++) {
    objArr[LMSarr[ii].substring(0,LMSarr[ii].indexOf("\\",3)).toLowerCase()]=0;
  }
  for (item in objArr) {
    retArr.push(item);
  }
  return retArr;
}



/** 
 * execCommand - Executes a specific command, doesn't open a window, and waits for the 
 *				command to return.  This function provides acccess to the output
 *				stream of the command being run.
 */
function execCommand(theExecCommand) {
	var execLine = theExecCommand;
	//WScript.Echo("cmdLine==" + cmdLine);
	WScript.Echo("Running ... " + execLine);
	var oExec = WshShell.Exec(execLine);
	var input = "";
	while (true)
	{
		if (!oExec.StdOut.AtEndOfStream)
		{
			WScript.Echo(oExec.StdOut.ReadLine());
		} else {
			break;
		}
		
		 WScript.Sleep(100);
	}

	oExec.StdIn.Write("\n");

	while (oExec.Status != 1)
		 WScript.Sleep(100);

}

/** 
 * createDirectoryFromPath - Takes a path argument and will create the dir and subdirs
 *							of that path if necessary.
 *				
 */
function createDirectoryFromPath(path) {
    var tmpFileLoc = "";
	var pattern = /(.*?)\\/gm;
    while (result = pattern.exec(path)) {
        tmpFileLoc = tmpFileLoc.concat(result[0]);
		if ( !fso.FolderExists(tmpFileLoc) ) {
			try {
				fso.CreateFolder(tmpFileLoc);
			} catch(e) {
				if( DEBUG )
					echo_debug("folder error==" + e.description);
				throw "Error creating folder";
			} 

		}
    }
}


/** 
 * rmData - remove sensitive data from files 				
 */
function rmData(fileProcessed, numProccessed) {
			
	var fDest = LMSCT_TMP + "FMW\\" + fileProcessed.replace(":","");
	if ( DEBUG )
		echo_debug("removing data from:" +fDest);
	var rmDataText;
	var regexArray;
	var str,res,resultMatch;
	var rmDataRegex;
	var rmDataRegexGI;
	
	try {
		var fsRead = fso.OpenTextFile(fDest, ForReading, "True");
		var fsWrite = fso.OpenTextFile(fDest+".tmp", ForWriting, "True");
		var rmdataWin = fso.OpenTextFile(fso.getFolder("..").path +  "\\resources\\util\\common\\bin\\rmdata_win.txt", ForReading, "True");
	
	while (!rmdataWin.AtEndOfStream) {
			rmDataText = rmdataWin.ReadAll();
		}	

		regexArray = rmDataText.split('\n');

		while (!fsRead.AtEndOfStream) {
			str = fsRead.ReadLine();
			res = str;
						
			for (var jj=0; jj<regexArray.length; jj += 2 )
			{	

				rmDataRegex = RegExp(regexArray[jj],"i");
				str = res;

				resultMatch = str.match(rmDataRegex);	
				if ( resultMatch != null ) {
					rmDataRegexGI = RegExp(regexArray[jj],"gi");
					res = str.replace(rmDataRegexGI, regexArray[jj+1]);				
				} 
			}

			fsWrite.WriteLine(res);

		}	

		fsRead.Close();
		fsWrite.Close();
		rmdataWin.Close();

		
		fso.CopyFile(fDest+".tmp", fDest);
		LMS_ACTIONS_RESULTS_FILE.Writeline("Zip up " + fileProcessed + " and removed sensitive data.");
		fso.DeleteFile(fDest+".tmp");


	} 
	catch (exception)
	{
		fso.DeleteFile(fDest+".tmp");
		fso.DeleteFile(fDest);
		echo_logs("LMSCT: LMS-00027: ERROR:  Unable to remove data from  " + fDest + " Exception:" + exception.description,"Errors");
	}
}



/**	################################################################################
	#
	#***********************License File Detection Utilities************************
	#
	################################################################################
*/
/** 
 *	regGetSubKeys
 *		getRegistry subkeys 
 */
function regGetSubKeys(strComputer, strRegPath) 
{ 
    var aNames = null; 
	var objLocator     = new ActiveXObject("WbemScripting.SWbemLocator"); 
    var objService     = objLocator.ConnectServer(strComputer, "root\\default"); 
    var objReg         = objService.Get("StdRegProv"); 
    var objMethod      = objReg.Methods_.Item("EnumKey"); 
    var objInParam     = objMethod.InParameters.SpawnInstance_(); 
    objInParam.hDefKey = "HKLM"; 
    objInParam.sSubKeyName = strRegPath; 
    var objOutParam = objReg.ExecMethod_(objMethod.Name, objInParam); 
    switch(objOutParam.ReturnValue) 
    { 
      case 0:          // Success 
        aNames = (objOutParam.sNames != null) ? objOutParam.sNames.toArray(): null; 
        break; 
 
      case 2:        // Not Found 
        aNames = null; 
        break; 
    } 
    return { Results : 0, SubKeys : aNames }; 
}

/** 
 *	getDefaultOracleEnv
 *		check running Java processes, known behomeslist and registry entries for
 * 		LMS, WebLogic and Oracle default installations.
 */
function getDefaultOracleEnv () {

// check running processes for java command line get info from printMachineInfo run
// look for weblogic.jar in classpath
// look for weblogic.home= in java options
// look for wls.home= in java options
// look for oracle.home= in java options
// look for domain.home= in java options
// check HKLM\\SOFTWARE\\Oracle
	
	var LMS_MACHINFO_FILE_read = fso.OpenTextFile(LMS_MACHINFO_FILE_fname, ForReading, "True");	

	var machineInfo;
	var linemachineInfo;
	var envParser;
	var wlservIndex;
	var rDomainRegisty;
	var longName;
	var checkBEAHOMESReg = false;
	
	// check c:\bea and d:\bea for beahomelist
	var beahomelist;
	if ( fso.FileExists("c:\\bea\\beahomelist") ) {
		beahomelist = "c:\\bea\\beahomelist";
	} else if ( fso.FileExists("d:\\bea\\beahomelist") ) {
		beahomelist = "d:\\bea\\beahomelist";
	} else {
		checkBEAHOMESReg = true;
	}
	var beahomeArray;
	if ( checkBEAHOMESReg == true ) {
		beahomelist = WshShell.RegRead("HKLM\\SOFTWARE\\Oracle\\BEAHOMELIST");
		beahomeArray = beahomelist.split(";");
	} else {
		var fbeahomes = fso.OpenTextFile(String(beahomelist), ForReading, "True");
		
		while (!fbeahomes.AtEndOfStream){
			var linebeahomes = "";
			linebeahomes += fbeahomes.ReadLine();  // Read Data		
			beahomeArray = linebeahomes.split(";"); // Parse data into String array
		}
		
		fbeahomes.Close();
	}

	for (var ii=0; ii<beahomeArray.length; ii++)
	{
		if ( LMS_HOMES.toLowerCase().indexOf(beahomeArray[ii])  == -1  )
			LMS_HOMES += beahomeArray[ii] + ",";
	}
	
	if ( DEBUG )
		echo_debug("FASTSEARCH directories after BEAHOME: " + LMS_HOMES + "\n");

	while (!LMS_MACHINFO_FILE_read.AtEndOfStream){
		linemachineInfo = LMS_MACHINFO_FILE_read.ReadLine();  // Read Data
		if ( linemachineInfo.indexOf("CommandLine") != -1  ) 
		{
			machineInfo = linemachineInfo.split(/[ ;\"]+/); // Parse data into String array
			for (var ii=0; ii<machineInfo.length; ii++)
			{	
				if ( machineInfo[ii].indexOf("weblogic.jar") != -1  ) {
					wlservIndex = machineInfo[ii].toLowerCase().indexOf("wlserv");
					longName = fso.GetAbsolutePathName(machineInfo[ii].substring(0,wlservIndex));
					//if ( ! LMS_HOMES.toLowerCase().indexOf(longName) != -1  ) 
						LMS_HOMES += longName +",";
				} else if ( machineInfo[ii].toLowerCase().indexOf(".home=")  != -1 || machineInfo[ii].toLowerCase().indexOf("_HOME=") != -1  ) {
					envParser = machineInfo[ii].split("=");
					wlservIndex = envParser[1].toLowerCase().indexOf("wlserv");
					longName = fso.GetAbsolutePathName(envParser[1].substring(0,wlservIndex));
					//if ( ! LMS_HOMES.toLowerCase().indexOf(longName) ) 
						LMS_HOMES += longName+",";
				} 
			}
		}
	}

	LMS_MACHINFO_FILE_read.Close();
	
	if ( DEBUG )
		echo_debug("FASTSEARCH directories after -info.txt: " + LMS_HOMES + "\n");

	// use WMI Objects to get env.
	var objWMIService = GetObject("winmgmts:\\\\.\\root\\CIMV2");
	
	//set up look for key environment variables.
	var envStatement = "SELECT * FROM Win32_Environment WHERE Name = 'BEA_HOME' OR Name = 'WL_HOME' OR Name = 'MW_HOME' OR Name = 'WEBLOGIC_HOME' OR Name = 'ORACLE_HOME' or Name = 'ORACLE_SID'";
	
	
	// Execute and enumerate WMI statement for Windows processes.
	var colItems = objWMIService.ExecQuery(envStatement, "WQL",
										  wbemFlagReturnImmediately | wbemFlagForwardOnly);

	var enumItems = new Enumerator(colItems);
	for (; !enumItems.atEnd(); enumItems.moveNext()) {
		var objItem = enumItems.item();
		longName = fso.getFileName(objItem.VariableValue);
		if ( LMS_HOMES.toLowerCase().indexOf(longName) == -1  )
			LMS_HOMES += longName +",";
	}

	if ( DEBUG )
		echo_debug("FASTSEARCH directories after WMIENV: " + LMS_HOMES + "\n");

	
	LMS_HOME_arr = LMS_HOMES.split(",");
	var domainReadline;
	var locationXML;
	var startLocation;
	var endLocation;
	var baseIndex = 0;
	var indexCount;
	for (var ii=0; ii<LMS_HOME_arr.length-1; ii++)
	{
		if ( fso.FileExists(LMS_HOME_arr[ii] + "\\domain-registry.xml") )
		{
			rDomainRegisty = fso.OpenTextFile(LMS_HOME_arr[ii] + "\\domain-registry.xml", ForReading, "True");
			while (!rDomainRegisty.AtEndOfStream){
				domainReadline = rDomainRegisty.ReadLine();
				if ( domainReadline.toLowerCase().indexOf("location")  != -1 )
				{
					startLocation = domainReadline.indexOf("\"") +1;
					endLocation = domainReadline.lastIndexOf("\"");
					locationXML = domainReadline.substring(startLocation,endLocation);
					// use last index of 3 times to get base directory
					// 3 times removes domain name, domains, and user_project dir.
					indexCount = 0;
					while (indexCount < 3 && baseIndex !== -1) {
						baseIndex = locationXML.lastIndexOf("\\");
						locationXML = locationXML.substring(0,baseIndex);
						indexCount++;
					}
					
					if ( LMS_HOMES.toLowerCase().indexOf(locationXML) == -1  )
						LMS_HOMES += locationXML + ",";
				}	
			}
			rDomainRegisty.Close();
		}
		
	}
	
	if ( DEBUG )
		echo_debug("FASTSEARCH directories after domain-registry: " + LMS_HOMES + "\n");

	
	//check reg for ORACLE_HOME
	var OracleEntry;
	var rtn = regGetSubKeys(".", "SOFTWARE\\Oracle");
	if ( rtn.Results == 0 )
	{
	  for (var idx=0;idx<rtn.SubKeys.length;idx++)
	  {
		WScript.Echo(rtn.SubKeys[idx]);
		try {
			OracleEntry = WshShell.RegRead("HKLM\\SOFTWARE\\Oracle\\" + rtn.SubKeys[idx] + "\\ORACLE_HOME");
			LMS_HOMES += OracleEntry + ",";
		} catch (e) {
			OracleEntry = "ORACLE_HOME not found";
		}		
	  }
	}


	// trim the last comma
	LMS_HOMES = LMS_HOMES.slice(0,-1);
	LMS_HOME_arr = LMS_HOMES.split(",");
	LMS_HOMES = "";

	var LMS_HOME_arr_sort;
	LMS_HOME_arr_sort = removeLMSHOMEDupes(LMS_HOME_arr);
	for (var ii=0; ii<LMS_HOME_arr_sort.length; ii++)
	{
		LMS_HOMES +=  LMS_HOME_arr_sort[ii] +",";
		LMS_HOMES_FILE.Writeline(LMS_HOME_arr_sort[ii] + "\n");

	}	
	// trim the last comma
	LMS_HOMES = LMS_HOMES.slice(0,-1);
	
}


/** 
 *	getProducts
 *		Prompt user for products to be searched if the -p option was not passed
 *		in on the command line.
 */
function getProducts() {

	// Get a list of Product Family directories under the resource directory
	var PRODFAMILYLIST = ShowFolders( "..\\resources\\products" );
	var folder = "";
	var prodFamilies = new Array();
	var showMenu = "all,DB,EBS,FormsReports,FMW,LMSCPU,OAS,SOA,WLS,OBI,Webcenter";

	PRODFAMILYLIST = PRODFAMILYLIST.replace("Tuxedo,", "");
	PRODFAMILYLIST = PRODFAMILYLIST.replace("FMWRUL,", "");
	
	if ( PRODLIST == "all") 
	{
		PRODUCTSRUN = "_all";
		PRODLIST = PRODFAMILYLIST;
	} else if ( ! PRODLIST == "" ) {
		var TMPPLIST = PRODLIST;
		PRODLIST = "";
		
		var TMPPLIST_ARRAY = TMPPLIST.split(',');
		
		for (var ii=0; ii<TMPPLIST_ARRAY.length; ii++)
		{
			folder = "..\\resources\\products\\" + TMPPLIST_ARRAY[ii];
			if ( !fso.FolderExists(folder) )
			{
				echo_logs("LMSCT: LMS-00010: ERROR: " + TMPPLIST_ARRAY[ii] + " is not a valid product family.","Errors");
				continue;
			}
							
			PRODLIST += TMPPLIST_ARRAY[ii];
			PRODLIST += ",";
			PRODUCTSRUN += "_";
			PRODUCTSRUN += TMPPLIST_ARRAY[ii];
		}
	} else {
		WScript.Echo("Product Families to look for:\n");
		var tmpPRODFAMILYLIST = PRODFAMILYLIST + "all,";
		
		prodFamilies = tmpPRODFAMILYLIST.split(',');
		
		for (var ii=0; ii<prodFamilies.length; ii++)
		{
			if ( showMenu.indexOf(prodFamilies[ii]) >= 0 )
			{
				WScript.Echo( prodFamilies[ii] );
			}
		}
		
		PRODLIST = "";
		var ANSWER = "";
		
		while (  ANSWER == "" )
		{
			// Prompt for user value
			WScript.Echo("\nWhich Product Family would you like to search for?");
			ANSWER = WScript.StdIn.ReadLine();
			if ( ANSWER == "All" ) 
			{
				ANSWER = "all";
			}
			
			//Make sure value is valid
			if ( ANSWER != "all" && ANSWER.indexOf(",") != -1 ) {
				var PROD_ARRAY = ANSWER.split(',');
				for (var jj=0; jj<PROD_ARRAY.length; jj++)
				{
					folder = "..\\resources\\products\\" + PROD_ARRAY[jj];
					if ( !fso.FolderExists(folder) )
					{
						echo_logs("LMSCT: LMS-00010: ERROR: " + PROD_ARRAY[jj] + " is not a valid product family.","Errors");

						WScript.Echo("Please choose from the menu above\n");
						ANSWER = "";
					} else {
						PRODUCTSRUN += "_";
						PRODUCTSRUN += PROD_ARRAY[jj];
					}
				}
			}
	
			// Check and eliminate duplicates.
			if ( PRODLIST.indexOf(ANSWER) == -1 ) 
			{
				PRODLIST += ANSWER;
				PRODLIST += ",";
				if ( DEBUG ) 
					echo_debug("\PRODLIST==" + PRODLIST +"\n");
			}	
			
			if ( ANSWER == "all" ) 
			{
				PRODUCTSRUN = "_all";
				PRODLIST = PRODFAMILYLIST;
			} else {
				// ask for another product Prompt
				WScript.Echo("Product Families chosen so far: " + PRODLIST +"\n");
				WScript.Echo("Would you like to add another Product? [y/n]:");
				ANSWER = WScript.StdIn.ReadLine();
				var switchBoolean = true;
				while ( switchBoolean ) {
					// Act on response 
					switch ( ANSWER ) 
					{
						case "y" :
						case "Y" :
							// They want to add a product, set answer to blank and reprompt.
							ANSWER = "";
							switchBoolean = false;
							break;
						case "n" :
						case "N" :
							// quit prompt.
							switchBoolean = false;
							break;
						default : 
							// invalid answer reprompt
							WScript.Echo("Please use y/n, would you like to add another Product? [y/n]:");
							ANSWER = WScript.StdIn.ReadLine();
					}
				}
			}	
			
		}
	}
}

/**
 * parseProductFiles - parse SEARCHFILES tag and set search  
 *  files and the action used to identify Oracle product for installations
 * 
 *  parse ORACLEPROCESS tag and create a list of process names used to identify Oracle products
 * 
 */
function parseProductFiles() {

	// PRODLIST gets set in getProducts()
	// Loop through each directory in PRODLIST and generate a 
	// list(PRODUCTLIST) of individual Products and specific versions 
	
		

	var INCLUDETAGS = "";
	var PRODFAMILY = PRODLIST.split(',');
	var prodfolder = new Enumerator();
	var shortFname = "";
	var fname = "";
	var fRead;
	var data = "";
	var key, value, action, valueMatch;	
	var prodCmdArray;
	var slash;
	var valueProd;
	var valueProdComma;
					
	for (var ii=0; ii<PRODFAMILY.length; ii++)
	{
		// get all files in the specified product folder
				
		prodfolder = ShowFiles("..\\resources\\products\\" + PRODFAMILY[ii]);
		
		// loop through each of the files in the folder
		for (; !prodfolder.atEnd(); prodfolder.moveNext())
		{
			
			fname = prodfolder.item();
			shortFname = fso.GetBaseName(fname);

			// if the product is not part of the ALLPRODUCTS list, then add it.
			if ( ALLPRODLIST.indexOf(shortFname) == -1  )
			{
				ALLPRODLIST += shortFname;
				ALLPRODLIST += ",";
				if ( DEBUG )
					echo_debug("adding " + shortFname + " to ALLPRODLIST==" + ALLPRODLIST);
			}
			
			fRead = fso.OpenTextFile(String(fname), ForReading, "True");
			
			//search the product file for each of the LMS tags.
			while (!fRead.AtEndOfStream){
				data = "";
				data += fRead.ReadLine();  // Read Data
				
				prodCmdArray = data.split(/[=\|]/); // Parse data into String array
				key = prodCmdArray[0];
				value = prodCmdArray[1];
				action = prodCmdArray[2];
				
				valueMatch = "," + value + ",";
							
				if ( DEBUG ) {
					echo_debug("Readline==" + data);
					echo_debug("key==" + key);
					echo_debug("value==" + value);
					echo_debug("action==" + action);
				}
				switch(key)
				{
				case "INCLUDEPRODUCT":	// Match INCLUDEPRODUCT
					slash = value.indexOf("/");
					valueProd = value.substring(0,slash);
					valueProdComma = valueProd + ",";

					if ( PRODLIST.indexOf(valueProd) == -1  || PRODLIST.indexOf(valueProdComma) == -1 ) 
					{
						PRODFAMILY[PRODFAMILY.length] = valueProd;
						if ( DEBUG ) 
							echo_debug("\nadding "+ valueProd + "to PRODLIST==" + PRODLIST +"\n");
					}	
					break;				
				case "ORACLEPRODUCT":	// Match ORACLEPRODUCT
					if ( PRODUCTLIST.indexOf(value) == -1  ) 
					{
						PRODUCTLIST += value;
						PRODUCTLIST += ",";
						if ( DEBUG ) 
							echo_debug("\nadding " + value + " to PRODUCTLIST==" + PRODUCTLIST +"\n");
					}	
					break;
				case "SEARCHFILE":	// Match SEARCHFILE
					if ( value.substring(0,1) == "\*" ) 
					{
						value = "\\" +value;
						valueMatch = "," + value + ",";
					}
					if ( value.indexOf("server.xml") != -1  ) 
					{
						value = "server.xml";
					}
					if ( ALLSEARCHFILES.indexOf(valueMatch) == -1  ) 
					{
						ALLSEARCHFILES += value;
						ALLSEARCHFILES += ",";
						if ( DEBUG ) 
							echo_debug("\nadding " + value + " to ALLSEARCHFILES==" +ALLSEARCHFILES+"\n");
						switch (action)
						{
						case "BUNDLE":
							if ( BUNDLEFILES.indexOf(valueMatch)  == -1 ) 
							{
								BUNDLEFILES += value;
								BUNDLEFILES += ",";
								if ( DEBUG ) 
									echo_debug("\nadding " + value + " to BUNDLEFILES==" + BUNDLEFILES +"\n");
							}	
							break;
						case "TIMESTAMP":
							if ( TSFILES.indexOf(valueMatch) == -1  ) 
							{
								TSFILES += value;
								TSFILES += ",";
								if ( DEBUG ) 
									echo_debug("\nadding " + value + " to TSFILES==" + TSFILES +"\n");
							}
							break;
						case "TAIL":
							if ( TAILFILES.indexOf(valueMatch) == -1  ) 
							{
								TAILFILES += value;
								TAILFILES += ",";
								if ( DEBUG ) 
									echo_debug("\nadding " + value + " to TAILFILES==" + TAILFILES +"\n");
							}
							break;
						case "LISTING":
							if ( LISTINGFILES.indexOf(valueMatch) == -1  ) 
							{
								LISTINGFILES += value;
								LISTINGFILES += ",";
								if ( DEBUG ) 
									echo_debug("\nadding " + value + " to LISTINGFILES==" + LISTINGFILES +"\n");
							}
							break;
						case "COPY":
							if ( COPYFILES.indexOf(valueMatch) == -1  ) 
							{
								COPYFILES += value;
								COPYFILES += ",";
								if ( DEBUG ) 
									echo_debug("\nadding " + value + " to COPYFILES==" + COPYFILES +"\n");
							}
							break;
						case "LOG":
							if ( LOGFILES.indexOf(valueMatch) == -1  ) 
							{
								LOGFILES += value;
								LOGFILES += ",";
								if ( DEBUG ) 
									echo_debug("\nadding " + value + " to LOGFILES==" + LOGFILES +"\n");
							}
							break;
						case "COLLECTRMDATA":
							if ( COLLECTRMDATAFILES.indexOf(valueMatch) == -1  ) 
							{
								COLLECTRMDATAFILES += value;
								COLLECTRMDATAFILES += ",";
								if ( DEBUG ) 
									echo_debug("\nadding " + value + " to COLLECTRMDATAFILES==" + COLLECTRMDATAFILES +"\n");
							}
							break;
						}
					}	
					break;
				case "ORACLEPROCESS":	// Match ORACLEPROCESS
					if ( PROCESSLIST.indexOf(valueMatch) == -1 ) 
					{
						PROCESSLIST += value;
						PROCESSLIST += ",";
						if ( DEBUG ) 
							echo_debug("\nadding " + value + " to PROCESSLIST==" + PROCESSLIST +"\n");

					}	
					break;
				case "CMDOUTFILE":	// Match CMDOUTFILE
					if ( value.substring(0,1) == "\*" ) 
					{
						value = "\\" +value;
					} else if ( value.substring(0,2) == ".." ) 
					{
						value = value.substring(2);
						value = fso.getFolder("..").path + value.replace(/\//g,"\\");
					} else if ( value.substring(0,1) == "." ) 
					{
						value = value.substring(1);
						value = LMSCT_HOME + value.replace(/\//g,"\\");
					}
					
					if ( value.indexOf("TMPDIR") != -1  ){
						value = value.replace("\${TMPDIR}/",TMPDIR +"\\");
					}
					
					if ( CMDOUTFILELIST.indexOf(value)  == -1 ) 
					{
						CMDOUTFILELIST += value + ",";
						if ( DEBUG ) 
							echo_debug("\nadding " + value + " to CMDOUTFILELIST==" + CMDOUTFILELIST +"\n");
					}
					switch (action)
						{
						case "BUNDLE":
							if ( BUNDLEFILES.indexOf(value) == -1  ) 
							{
								BUNDLEFILES += value;
								BUNDLEFILES += ",";
								if ( DEBUG ) 
									echo_debug("\nadding " + value + " to BUNDLEFILES==" + BUNDLEFILES +"\n");
							}	
							break;
						case "TIMESTAMP":
							if ( TSFILES.indexOf(value) == -1  ) 
							{
								TSFILES += value;
								TSFILES += ",";
								if ( DEBUG ) 
									echo_debug("\nadding " + value + " to TSFILES==" + TSFILES +"\n");
							}
							break;
						}
					break;
                case "RUNCMD":    // Match RUNCMD
					// make RUNLIST value Windows compliant
					if ( value.substring(0,2) == ".." ) 
					{
						value = value.substring(2);
						value = fso.getFolder("..").path + value.replace(/\//g,"\\");
					}
					
					if ( RUNLIST.indexOf(value + "|" + action) == -1 ) 
					{
						// Run CPUQ before machine info section
						if ( value.indexOf("cpuq_main") != -1 ) {
							RUNCPUQ += value + "|" + action;
							RUNCPUQ += ",";
						} 
					
						RUNLIST += value + "|" + action;
						RUNLIST += ",";
						if ( DEBUG ) 
							echo_debug("\nadding " + value + " to RUNLIST==" + RUNLIST +"\n");
					} else
						if ( DEBUG ) 
							echo_debug("\nDidn't add " + value + "|" + action + " to RUNLIST==" + RUNLIST +"\n");
					
                    break;
				default:
				  if ( DEBUG ) 
					echo_debug("no match for data==" + data +"\n");
				}
			}
		}	
	}
	
	LMS_ACTIONS_RESULTS_FILE.Writeline("Product Name discovery list: " + PRODUCTLIST+ "\n");
	LMS_ACTIONS_RESULTS_FILE.Writeline("All Product files used: " + ALLPRODLIST+ "\n");
	
	LMS_ACTIONS_RESULTS_FILE.Writeline("Files to be bundled: " + BUNDLEFILES+ "\n");
	LMS_ACTIONS_RESULTS_FILE.Writeline("Files to be collected and sensitive data removed: " + COLLECTRMDATAFILES+ "\n");
	LMS_ACTIONS_RESULTS_FILE.Writeline("Search files: " + ALLSEARCHFILES+ "\n");
	LMS_ACTIONS_RESULTS_FILE.Writeline("Oracle processes: " + PROCESSLIST+ "\n");
	LMS_ACTIONS_RESULTS_FILE.Writeline("Commands to be run: " + RUNLIST+ "\n");
	LMS_ACTIONS_RESULTS_FILE.Writeline("Command Output Files: " + CMDOUTFILELIST+ "\n");
	LMS_ACTIONS_RESULTS_FILE.Writeline("LMSCT_HOME: " + LMSCT_HOME+ "\n");
	LMS_ACTIONS_RESULTS_FILE.Writeline("LMSCT_TMP: " + LMSCT_TMP+ "\n");

}


/**
 * doSearch() - search Windows hard drives and directories
 * 				for files releated to Oracle products.
 */

function doSearch() {
	var driveList = SEARCH_DIR.split(",");
	var searchArray = ALLSEARCHFILES.split(",");
	var searchFiles = "";
	var drive = "";
	var thisDir = LMSCT_HOME;
	
	// Setup search dirs if fastsearh
	if ( FASTSEARCH )
	{
		driveList = LMS_HOMES.split(",");
		LMS_ACTIONS_RESULTS_FILE.Writeline("FASTSEARCH directories: " + LMS_HOMES + "\n");

	}
	
	for (var ii=0; ii<searchArray.length - 1; ii++) 
	{
		if ( searchArray[ii].substring(0,1) == "\\" ) 
		{
			searchFiles += searchArray[ii].substring(1) +" ";
		} else {
			searchFiles += searchArray[ii] +" ";
		}
	}
	
	searchFiles = searchFiles.substring(0,searchFiles.length - 1);

	// check for duplicate processes, in case a previous run was unexpectedly cancelled.
		// use WMI Objects to get running processes.

	var objWMIService = GetObject("winmgmts:\\\\.\\root\\CIMV2");
	var colItems = objWMIService.ExecQuery("Select * from Win32_Process Where Name = 'cmd.exe'", "WQL",
										  wbemFlagReturnImmediately | wbemFlagForwardOnly);

	

	try {
		var enumItems = new Enumerator(colItems);
		for (; !enumItems.atEnd(); enumItems.moveNext()) {
			var objItem = enumItems.item();

			if ( objItem.CommandLine.indexOf("LMSfiles.txt") > -1 )
				objItem.Terminate();
		}
	} catch(e) {
		if( DEBUG )
			echo_debug("OBJItem error==" + e.description);
	}
 	
	// Iterate the Drives 
	for (var ii=0; ii<driveList.length; ii++) 
	{
		drive = driveList[ii];
		var drivecount = ii + 1;
		var lastChar = drive.charAt(drive.length - 1);
		
		if ( lastChar != ("\\") )
		{
			drive = drive +"\\";
		} 
		
		WScript.Echo("\nSearching location [" + drivecount + " of " + driveList.length + "]," + drive + " for Oracle product and configuration files...\n");
		
		var runReturn;
		runReturn = runCommand("\"cd /d \"" + drive + "\" && dir /a:-d /b /s " + searchFiles + ">> \"" + LMS_FILES_fname +"\" && cd /d \""+thisDir +"\"\"",0);
		SEARCH_COMMAND += "\"cd /d \"" + drive + "\" && dir /a:-d /b /s " + searchFiles + ">> \"" + LMS_FILES_fname +"\" && cd /d \""+thisDir +"\"\"";
		
		if ( runReturn != 0 ) {
			echo_logs("Search of  " + drive + " returned with error code: " + errorCode ,"WindowsCMD");
		} 
		
    }

}

/**
 * doRunCmd() - Parse CMDLIST and run any OS commands or scripts.
 */
function doRunCmd( cmdsToRun ) {
	// split the commands lists into an array
	var cmdList = cmdsToRun.split(",");
	var runReturn;
	
	if ( DEBUG )
		WScript.Echo("cmdsToRun=="+cmdsToRun);
	
	// loop through each command
	for (var ii=0; ii<cmdList.length - 1; ii++) 
	{
		// split the comannd into the command and the type
		var cmdAndType = cmdList[ii].split(/[\|]/); 
		//Bundle files written in Unix syntax, so replace / with "\\"
		var cmd = cmdAndType[0].replace(/\//g,"\\");
		var cmdType = cmdAndType[1];
		
		// check command type, add appropriate extenstion
		if ( cmdType == "SCRIPT" ) 
			cmd += ".cmd";
		else 
			cmd += ".exe";

		if ( DEBUG )
			WScript.Echo("Run cmd1 ==" + cmd);
		
		//make sure the script exists
		if ( ! fso.FileExists(cmd) )
			WScript.Echo("\nCommand " + cmd + " not found.");
		else if ( cmd.indexOf("cpuq_main.cmd")  != -1 ) {
			if ( RANCPUQ == "false" ) {
				//wrap cmd in quotes for directories with spaces
				cmd = "\"" + cmd + "\"";
				// To avoid running the license again on LMS CPUQ, give it a 2nd cmd line arg. and delete previous temp file

				try {
					fso.DeleteFile(LMSCT_TMP + "LMSCPU\\"+"\\lms_cpuq_tmp.txt");
					fso.DeleteFile(LMSCT_TMP + "LMSCPU\\"+MACHINE_NAME+"-lms_cpuq.txt");
				} catch (exception) {
					if ( DEBUG )
						echo_debug("No CPUQ file to delete\n");
				}
				
				if ( DEBUG )
					WScript.Echo("Run cmd2 ==" + cmd);
				
				runReturn = runCommand(cmd,1);
				if ( runReturn != 0 ) {
					echo_logs("Command " + cmd + "returned with error code: " + runReturn ,"WindowsCMD");
				}
			} 			
			
		} else {
					
			//wrap cmd in quotes for directories with spaces
			cmd = "\"" + cmd + "\"";
				
			if ( DEBUG )
				WScript.Echo("Run cmd2 ==" + cmd);
				
			runReturn = runCommand(cmd,1);	
			if ( runReturn != 0 ) {
				echo_logs("Command " + cmd + "returned with error code: " + runReturn ,"WindowsCMD");
			}
		}
	}
}


/**
*
* function to add any command or script generated output files to the
* list of files we need information for
*
*/
function addOutputFiles() {
	var LMS_FILES = fso.OpenTextFile(LMS_FILES_fname, ForAppending, "True");
	var cmdOutBase, cmdOutFile, tmpFile, tmpFolder;
	
	if ( DEBUG )
		echo_debug("debug.function.addOutputFiles");

	cmdOutArray = CMDOUTFILELIST.split(',');

	// Go through CMDOUTFILELIST, add to LMS_FILES as necessary.
	for (var ii=0; ii<cmdOutArray.length-1; ii++)
	{
		// FSO file names can't contain wildcards.  
		// check for wildcards and replace with the actual file name if there.
		if ( cmdOutArray[ii].indexOf("\*") != -1 )
		{
			cmdOutBase = cmdOutArray[ii].substring(0, cmdOutArray[ii].lastIndexOf("\\") );
			
			//find out where the wildcard is, then grab the correct cmd out pattern
			if ( cmdOutArray[ii].lastIndexOf("*")+1 == cmdOutArray[ii].length ) 
			{
				cmdOutFile = cmdOutArray[ii].substring(cmdOutArray[ii].lastIndexOf("\\")+1,cmdOutArray[ii].lastIndexOf("*") );
			} else {
				cmdOutFile = cmdOutArray[ii].substring(cmdOutArray[ii].lastIndexOf("*")+1 );
			}
			
			if ( DEBUG )
				echo_debug("cmdOutFile==" + cmdOutFile);

			if ( fso.FolderExists(cmdOutBase) ) 
			{
				if ( DEBUG )
					echo_debug("cmdOutFile . index==" + cmdOutFile.lastIndexOf("."));
				if ( cmdOutFile.lastIndexOf(".") >= 0 ) 
				{
					var cmdOutFileColl = ShowFiles(cmdOutBase);
					// Traverse through the FileCollection using the FOR loop
					for(; !cmdOutFileColl.atEnd(); cmdOutFileColl.moveNext()) {
						tmpFile = String(cmdOutFileColl.item());
						if ( tmpFile.indexOf(cmdOutFile) != -1 ) {
							LMS_FILES.WriteLine(tmpFile);
							bundleResults(tmpFile, 0);
						}
					}
				} else {			
					var cmdOutFolderColl = ShowFolders(cmdOutBase).split(',');
					if ( DEBUG )
						echo_debug("cmdOutFolderColl==" + cmdOutFolderColl);

					for (var jj=0; jj<cmdOutFolderColl.length-1; jj++)
					{
						tmpFolder = cmdOutBase + "\\" + cmdOutFolderColl[jj];
						if ( DEBUG )
							echo_debug("tmpFolder==" + tmpFolder);
						if ( tmpFolder.indexOf(cmdOutFile)  != -1 ) {
							LMS_FILES.WriteLine(tmpFolder);
							bundleResults(tmpFolder, 0);
						}
					}	
				}
			}
		} else {
			LMS_FILES.WriteLine(cmdOutArray[ii]);
			bundleResults(cmdOutArray[ii], 0);
		}
	}
	LMS_FILES.Close();
	
}

/**
 * fileGetLMSFiles() - remove Non-Oracle files from collection
 *	 
 */

function fileGetLMSFiles() 
{
	var LMS_ONLY_FILES = LMSCT_TMP + "logs\\LMSCollection_ONLY.txt";
	var runReturn;
	// first delete files in samples or other Windows directories where LMS
	// files are either not commonly found or not need for licenseable determination.
	runReturn = runCommand("findstr /v /i /g:\"" + fso.getFolder("..").path + "\\resources\\util\\file_sort_list_win.txt\" \"" + LMS_FILES_fname + "\">\"" + LMS_SORTED_FILES_fname + "\"",0);
	if ( runReturn != 0 ) {
		WINDOWSCMDERR.WriteLine("Command findstr /v /i /g:\"" + fso.getFolder("..").path + "\\resources\\util\\file_sort_list_win.txt\" " + LMS_FILES_fname + "\">\"" + LMS_SORTED_FILES_fname +"\" returned with error code: " + runReturn );
	} 
	

	if ( DEBUG ) {
		//WScript.Echo("LMS_ONLY_FILES path==" + LMS_ONLY_FILES);
		echo_debug("LMS_SORTED_FILES path==" + LMS_SORTED_FILES_fname);
	}

	/* remove server.xml files that are not LMS or otherwise Oracle related. */
	runReturn = runCommand("findstr /v /i server.xml \"" + LMS_SORTED_FILES_fname + "\"> noserverxml.txt",0);
	if ( runReturn != 0 ) {
		WINDOWSCMDERR.WriteLine("Command findstr /v /i server.xml " + LMS_SORTED_FILES_fname + "> noserverxml.txt returned with error code: " + runReturn );
	} 
	runReturn = runCommand("findstr /i server.xml \"" + LMS_SORTED_FILES_fname + "\"> allserverxml.txt",0);
	if ( runReturn != 0 ) {
		WINDOWSCMDERR.WriteLine("Command findstr /i server.xml " + LMS_SORTED_FILES_fname + "> allserverxml.txt returned with error code: " + runReturn );
	} 
	runReturn = runCommand("findstr /i j2ee allserverxml.txt > j2eeserverxml.txt",0);
	if ( runReturn != 0 ) {
		WINDOWSCMDERR.WriteLine("Command findstr /i j2ee allserverxml.txt > j2eeserverxml.txt returned with error code: " + runReturn );
	} 	
	runReturn = runCommand("type noserverxml.txt >> j2eeserverxml.txt",0);
	if ( runReturn != 0 ) {
		WINDOWSCMDERR.WriteLine("Command type noserverxml.txt >> j2eeserverxml.txt returned with error code: " + runReturn );
	} 	
	runReturn = runCommand("type j2eeserverxml.txt >\"" + LMS_SORTED_FILES_fname +"\"",0);
	if ( runReturn != 0 ) {
		WINDOWSCMDERR.WriteLine("Command type j2eeserverxml.txt >" + LMS_SORTED_FILES_fname + " returned with error code: " + runReturn );
	}
	
	fso.DeleteFile("noserverxml.txt");
	fso.DeleteFile("j2eeserverxml.txt");
	fso.DeleteFile("allserverxml.txt");
}


/***
 *  fileCopy() - function to copy files to the output dir.
 */
function fileCopy(fileProcessed, numProccessed) 
{
	// debug - Add debug info
	//WScript.Echo("debug.function.fileCopy");
	//WScript.Echo("debug.processing.file"+numProcessed+".copy="+fileProccessed);
	
	// obtain timestamp for all copied files
	fileTimestamp(fileProcessed,numProccessed);
		
	LMS_RESULTS_FILE.WriteLine("processing.file" + numProccessed + ".copy.data="+fileProcessed);
	LMS_RESULTS_FILE.WriteLine("[COPY_TAG_BEGIN]");
	
	// post command to results file
	var fCopy = fso.GetFile(fileProcessed);
	var ts = fCopy.OpenAsTextStream(ForReading, TristateFalse);
	
	while (!ts.AtEndOfStream){
		LMS_RESULTS_FILE.WriteLine(ts.ReadLine());
	}
	
	LMS_RESULTS_FILE.WriteLine("\n[COPY_TAG_END]"); 	
}

/***
 *  fileTail() - function to print the last few lines of a file to the LOGS.
 */
function fileTail(fileProcessed, numProccessed) 
{
	//debug
	//WScript.Echo("debug.function.fileTail");
	//WScript.Echo("debug.processing.file"+numProcessed+".tail="+fileProccessed);

	LMS_LOGS_FILE.WriteLine("processing.file" + numProccessed + ".tail.data="+fileProcessed);
	LMS_LOGS_FILE.WriteLine("[TAIL_TAG_BEGIN]");
	
	var strFile, objFile, arrFileLen, tailStart;
	var arrFile = new Array ();

	// open file as a stream, input lines into array
	objFile = fso.GetFile(fileProcessed);
	var strFile = objFile.OpenAsTextStream(ForReading, TristateFalse);
	
	arrFileLen = 0;
	while (!strFile.AtEndOfStream){
		arrFile[arrFileLen] = strFile.ReadLine();
		arrFileLen++;
	}
	
	// if arrFileLen > 20 tail the last 20 lines, else tail the whole file.
	if ( arrFileLen > 20 )
		tailStart = arrFileLen - 20;
	else 
		tailStart = 0;
	
	if ( arrFileLen == 0 )
		LMS_LOGS_FILE.WriteLine("Log file is empty");
	else {
		for (var ii = tailStart; ii<arrFileLen; ii++) 
		{
			LMS_LOGS_FILE.WriteLine(arrFile[ii]);
		}
	}
	
	LMS_LOGS_FILE.WriteLine("\n[TAIL_TAG_END]"); 	

}

/**
 *  fileTimestamp() - list the files and dates of a file.
 */

function fileTimestamp(fileProcessed, numProccessed) {

	//debug
	//WScript.Echo("debug.function.fileTimestamp");
	//WScript.Echo("debug.processing.file" + numProccessed + ".timestamp=" +fileProcessed);
	var fObj, fAttrib;
	
	LMS_RESULTS_FILE.WriteLine("processing.file" + numProccessed + ".timestamp.data="+fileProcessed);
	LMS_RESULTS_FILE.WriteLine("[TIMESTAMP_TAG_BEGIN]");
	
	// post command to results file
	LMS_RESULTS_FILE.WriteLine("Date Created\t\t\t\t\t\tDate Last Modified\t\t\t\tFile Name");
	LMS_RESULTS_FILE.WriteLine("------------\t\t\t\t\t\t------------------\t\t\t\t----------");
	fObj = fso.GetFile(fileProcessed);
	fAttrib = fObj.DateLastModified + "\t\t" +fObj.DateCreated + "\t\t" + fObj.Name;
	LMS_RESULTS_FILE.WriteLine(fAttrib);

	LMS_RESULTS_FILE.WriteLine("[TIMESTAMP_TAG_END]");
}

/***
 *  fileListing() - list the files and dates of a directory.
 */
function fileListing(fileProcessed, numProccessed) {

	//debug
	//WScript.Echo("debug.function.fileTail");
	//WScript.Echo("debug.processing.file"+numProcessed+".tail="+fileProccessed);
	
	LMS_RESULTS_FILE.WriteLine("processing.file"+numProccessed +".listing.data="+fileProcessed);
	LMS_RESULTS_FILE.WriteLine("[LISTING_TAG_BEGIN]");
	
	var fItem; 
	
	var DIR_NAME = fso.GetFile(fileProcessed).ParentFolder;
	var folderList = new Enumerator(DIR_NAME.Files);
	var fAttrib;
	
	LMS_RESULTS_FILE.WriteLine("Date Created\t\t\t\t\t\tDate Last Modified\t\t\t\t\tFile Name");
	LMS_RESULTS_FILE.WriteLine("------------\t\t\t\t\t\t------------------\t\t\t\t----------");


	for (; !folderList.atEnd(); folderList.moveNext())
	{
		fItem = fso.GetFile(folderList.item());
		
		fAttrib = fItem.DateLastModified + "\t\t" +fItem.DateCreated + "\t\t" + fItem.Name;
		LMS_RESULTS_FILE.WriteLine(fAttrib);
	}
	
	LMS_RESULTS_FILE.WriteLine("[LISTING_TAG_END]");
}

/**
 * bundleResults(fileProcessed, numProccessed) - copy files to output.
 *
 */

function bundleResults(fileProcessed, numProccessed) {

	// debug
	//WScript.Echo("debug.function.bundleResults");
	//WScript.Echo("debug.processing.file"+numProccessed+".tar="+fileProcessed);
	var fDest = LMSCT_TMP + "FMW\\" + fileProcessed.replace(":","");
	var fIndex = fDest.lastIndexOf("\\") + 1;
	var dirDest = fDest.substring(0,fIndex);
	
	if ( DEBUG )
		echo_debug("Copy from:" +fileProcessed +" to:" +fDest);
	try 
	{
		createDirectoryFromPath(dirDest);
	}
	catch (exception)
	{
		WINDOWSCMDERR.WriteLine("The directory " + dirDest + " can not be created. Exception:" + exception);
	}

	try {
		if ( fso.FileExists(fileProcessed) )
		{
			fso.CopyFile(fileProcessed, fDest);
			if ( fileProcessed.indexOf("config.xml") == -1 )
				LMS_ACTIONS_RESULTS_FILE.Writeline("Zip up "+ fileProcessed);
		} else if ( fso.FolderExists(fileProcessed) )
		{
			fso.CopyFolder(fileProcessed, fDest);
			LMS_ACTIONS_RESULTS_FILE.Writeline("Zip up "+ fileProcessed);
		}
	} 
	catch (exception)
	{
		echo_logs("LMSCT: LMS-00026: ERROR:  The file " + fileProcessed + " can not be copied. Exception:" + exception.description,"Errors");
	}
	
}



/**
 * zipFiles() - compress the bundled files.
 *
 */

function zipFiles() {

	// bundled results file
	// create as zip

	var LMS_TAR_FILE_SUFF = "";
	var	LMS_TAR_FILE_fname = "";

	if ( MASK_DATA == "" )
	{
		LMS_TAR_FILE_SUFF = "LMSCollection-" + MACHINE_NAME + PRODUCTSRUN + ".zip";
	} else {
		LMS_TAR_FILE_SUFF = "LMSCollection-" + MACHINE_NAME + PRODUCTSRUN + "-masked.zip";
	}
	
	LMS_TAR_FILE_fname = OUTPUT_DIR + LMS_TAR_FILE_SUFF;
	
	if ( fso.FileExists(LMS_TAR_FILE_fname) ) {
		fso.CopyFile(LMS_TAR_FILE_fname, LMS_TAR_FILE_fname + ZIPTIMESTAMP);
	}
	
	var objShell = new ActiveXObject("shell.application");
	var zipFolder = new Object;
	var sourceItems = new Object;
	var objFolder = new Object;
	
	// if we don't want to collect LMS Debug files, then delete debug folder here.
	if ( !COLLECT_LMS_DEBUG ) {
		if ( !DEBUG ) {
			try {	
				fso.DeleteFolder(LMSCT_DEBUG.slice(0,-1));
			} catch (e)
			{
			}
		}
		
	}
	

	objFolder = objShell.NameSpace(LMSCT_TMP);
	
	for(var objEnum = new Enumerator(objFolder.items()); !objEnum.atEnd(); objEnum.moveNext()) {
		numItems = objShell.NameSpace(objEnum.item()).items(); 
		if ( numItems.Count == 0 ) {
			fso.DeleteFolder(LMSCT_TMP + "\\" + objEnum.item());
		}	
	}

	sourceItems = objFolder.items(); 	
	
	var LMS_TAR_FILE = fso.CreateTextFile(LMS_TAR_FILE_fname, true);
	LMS_TAR_FILE.write("PK");
	LMS_TAR_FILE.write(String.fromCharCode(5));
	LMS_TAR_FILE.write(String.fromCharCode(6));
	LMS_TAR_FILE.write('\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0');

	LMS_TAR_FILE.Close();
	
	zipFolder = objShell.NameSpace(LMS_TAR_FILE_fname);

	var sourceCount = sourceItems.Count;
	var zipCount;
	if ( zipFolder != null ) {
		zipFolder.CopyHere(sourceItems, 1044);  
		do 
		{
			WScript.Sleep(500);
			zipCount = zipFolder.items().Count; 
		} while (sourceCount != zipCount);

	}		

	WScript.Sleep(1000);
	
	if ( ! fso.FileExists(OUTPUT_DIR + LMS_TAR_FILE_SUFF)  ) {
		if ( WARNING_EMPTY ) {
			WScript.Echo("\n## LMSCT ## Warnings\n");
			WARNING_EMPTY = false;
		}		
		WScript.Echo("LMSCT: LMS-00112: WARNING: Could not compress output file directory " + OUTPUT_DIR,". Please use 7zip or similar to compress and send to your LMS contact.","Warnings");
	} else {
		WScript.Echo("Successfully compressed the results file "  + OUTPUT_DIR + LMS_TAR_FILE_SUFF);
		WScript.Echo("\nCollection process is completed, please forward "  + OUTPUT_DIR + LMS_TAR_FILE_SUFF +  " to your LMS Contact.");
	}
}

/**
 * zipDebug() - compress the debug_folder.
 *
 */

function zipDebug() {

	// bundled results file
	// create as zip

	var	LMS_DEBUG_TAR_FILE_fname = "";
	var LMS_DEBUG_TAR_FILE_SUFF = "";

	if ( MASK_DATA == "" )
	{
		LMS_DEBUG_TAR_FILE_SUFF = "debug_LMSCollection-" + MACHINE_NAME + PRODUCTSRUN + ".zip";
	} else {
		LMS_DEBUG_TAR_FILE_SUFF = "debug_LMSCollection-" + MACHINE_NAME + PRODUCTSRUN + "-masked.zip";
	}
	
	LMS_DEBUG_TAR_FILE_fname = OUTPUT_DIR + LMS_DEBUG_TAR_FILE_SUFF;
	
	if ( fso.FileExists(LMS_DEBUG_TAR_FILE_fname) ) {
		fso.CopyFile(LMS_DEBUG_TAR_FILE_fname, LMS_DEBUG_TAR_FILE_fname + ZIPTIMESTAMP);
	}

						
	var objShell = new ActiveXObject("shell.application");
	var zipFolder = new Object;
	var sourceItems = new Object;
	var objFolder = new Object;
	
	objFolder = objShell.NameSpace(LMSCT_TMP+"debug\\");
	sourceItems = objFolder.items(); 
	

	var LMS_DEBUG_TAR_FILE = fso.CreateTextFile(LMS_DEBUG_TAR_FILE_fname, true);
	LMS_DEBUG_TAR_FILE.write("PK");
	LMS_DEBUG_TAR_FILE.write(String.fromCharCode(5));
	LMS_DEBUG_TAR_FILE.write(String.fromCharCode(6));
	LMS_DEBUG_TAR_FILE.write('\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0');
	LMS_DEBUG_TAR_FILE.Close();

	zipFolder = objShell.NameSpace(LMS_DEBUG_TAR_FILE_fname);

	var sourceCount = sourceItems.Count;
	var zipCount;
	if ( zipFolder != null ) {
		zipFolder.CopyHere(sourceItems, 1044);  
		do 
		{
			WScript.Sleep(500);
			zipCount = zipFolder.items().Count; 
		} while (sourceCount != zipCount);

	}	

	WScript.Sleep(1000);
	
	if ( ! fso.FileExists(LMS_DEBUG_TAR_FILE_fname)  ) {
		if ( WARNING_EMPTY ) {
			WScript.Echo("\n## LMSCT ## Warnings\n");
			WARNING_EMPTY = false;
		}
		WScript.Echo("LMSCT: LMS-00113: WARNING: Could not compress debug file directory " + LMS_DEBUG_TAR_FILE_fname,"Warnings");
	} else {
		if ( WARNING_EMPTY ) {
			WScript.Echo("\n## LMSCT ## Warnings\n");
			WARNING_EMPTY = false;
		}
		
		WScript.Echo("LMSCT: LMS-00114: WARNING: Please note that for debugging purposes the following archive file was created in the output folder:"  + LMS_DEBUG_TAR_FILE_fname + "\n");
		
	}
	
	try {	
		fso.DeleteFolder(LMSCT_DEBUG.slice(0,-1));
	} catch (e)
	{
	}
}

/**
 *
 * fileAction() input a list of filenames and assign them to the right action.
 * 
*/
function fileAction() {

	var NUMPROCESSFILE = 0;
	var fs = fso.OpenTextFile(LMS_SORTED_FILES_fname, ForReading, "True");
	var fObj, FILE_NAME, PROCESS_FILE_NAME, PRODUCT_FILE_BASENAME;
	var bundlefilesArray = BUNDLEFILES.split(",");
	var tsfilesArray = TSFILES.split(",");
	var tailfilesArray = TAILFILES.split(",");
	var listingfilesArray = LISTINGFILES.split(",");
	var copyfilesArray = COPYFILES.split(",");
	var collectrmfilesArray = COLLECTRMDATAFILES.split(",");
	
	var matchB,regex,result;
	
	while (!fs.AtEndOfStream) {
		//read the filenames from the file
		FILE_NAME = fs.ReadLine();
		try {
					
			NUMPROCESSFILE += 1;
			
			fObj = fso.GetFile(FILE_NAME);
			//get full path and File name from text file
			PROCESS_FILE_NAME = fObj.Path;
			//get just file name
			PRODUCT_FILE_BASENAME = fObj.Name;
	
			//Write processing info to LMS results
			LMS_RESULTS_FILE.WriteLine("Processing file " + NUMPROCESSFILE + " name=" + FILE_NAME);
			
			//Check the file processing tags, take appropriate action
			for (var ii=0; ii<bundlefilesArray.length - 1; ii++) 
			{
				if (  bundlefilesArray[ii].substring(0,1) == "*" ) 
				{
					regex = bundlefilesArray[ii].substring(1);
				} else {
					regex = bundlefilesArray[ii];
				}
				result = PRODUCT_FILE_BASENAME.match(regex);

				if ( result != null ) {
					bundleResults(FILE_NAME,NUMPROCESSFILE);
					break;
				} 
				
			}			
			
			for (var ii=0; ii<tsfilesArray.length - 1; ii++) 
			{
				if (  tsfilesArray[ii].substring(0,1) == "*" ) 
				{
					regex = tsfilesArray[ii].substring(1);
				} else if ( tsfilesArray[ii].indexOf("*") != -1 )
				{
					regex = tsfilesArray[ii].substring(0,tsfilesArray[ii].indexOf("*") - 1 );		
				} else {
					regex = tsfilesArray[ii];
				}
				result = PRODUCT_FILE_BASENAME.match(regex);

				if ( result != null ) {
					fileTimestamp(FILE_NAME,NUMPROCESSFILE);
					break;
				} 
				
			}				
			
			for (var ii=0; ii<tailfilesArray.length - 1; ii++) 
			{
				if (  tailfilesArray[ii].substring(0,1) == "*" ) 
				{
					regex = tailfilesArray[ii].substring(1);
				} else if ( tailfilesArray[ii].indexOf("*") != -1 )
				{
					regex = tailfilesArray[ii].substring(0,tailfilesArray[ii].indexOf("*") - 1 );		
				} else {
					regex = tailfilesArray[ii];
				} 
				result = PRODUCT_FILE_BASENAME.match(regex);

				if ( result != null ) {
					fileTail(FILE_NAME,NUMPROCESSFILE);
					break;
				} 
				
			}				
			
			for (var ii=0; ii<listingfilesArray.length - 1; ii++) 
			{
				if (  listingfilesArray[ii].substring(0,1) == "*" ) 
				{
					regex = listingfilesArray[ii].substring(1);
				} else {
					regex = listingfilesArray[ii];
				}
				result = PRODUCT_FILE_BASENAME.match(regex);

				if ( result != null ) {
					fileListing(FILE_NAME,NUMPROCESSFILE);
					break;
				} 
				
			}	

			for (var ii=0; ii<copyfilesArray.length - 1; ii++) 
			{
				if (  copyfilesArray[ii].substring(0,1) == "*" ) 
				{
					regex = copyfilesArray[ii].substring(1);
				} else {
					regex = copyfilesArray[ii];
				}
				result = PRODUCT_FILE_BASENAME.match(regex);

				if ( result != null ) {
					fileCopy(FILE_NAME,NUMPROCESSFILE);
					break;
				} 
				
			}	

			for (var ii=0; ii<collectrmfilesArray.length - 1; ii++) 
			{
				if (  collectrmfilesArray[ii].substring(0,1) == "*" ) 
				{
					regex = collectrmfilesArray[ii].substring(1);
				} else {
					regex = collectrmfilesArray[ii];
				}

				if (  collectrmfilesArray[ii].slice(-1) == "*" ) 
				{
					regex = collectrmfilesArray[ii].slice(0,-1);
				} else {
					regex = collectrmfilesArray[ii];
				}				
				
				
				result = PRODUCT_FILE_BASENAME.match(regex);

				if ( result != null ) {
					bundleResults(FILE_NAME,NUMPROCESSFILE);
					rmData(FILE_NAME,NUMPROCESSFILE);
					break;
				} 
				
			}
			

		} catch ( ex ) {
			//Write processing info to LMS results
			LMS_RESULTS_FILE.WriteLine("Error processing file " + NUMPROCESSFILE + " " + FILE_NAME);
		}
		
	}
	fs.Close();

}



/**
 * printMachineInfo() function to print out the results from the cpuq and results.
 *
*/

function printMachineInfo() {
	
	//NUMIPADDR=0
	var options = "";
	// print script information
	LMS_MACHINFO_FILE.WriteLine("[BEGIN SCRIPT INFO]");
	LMS_MACHINFO_FILE.WriteLine("Script Name=" + SCRIPT_NAME);
	LMS_MACHINFO_FILE.WriteLine("Script Version=" + SCRIPT_VERSION);
	// loop through SCRIPT_OPTIONS array to get a single string with the options.
	for (var ii = 0; ii < SCRIPT_OPTIONS.length; ii++)
		options += SCRIPT_OPTIONS(ii) + " ";
	LMS_MACHINFO_FILE.WriteLine("Script Command options=" + options);
	LMS_MACHINFO_FILE.WriteLine("Available Drives and types=");
	var allDriveTypes = GetAllDriveList();
	for (var ii = 0; ii < allDriveTypes.length; ii++)
		LMS_MACHINFO_FILE.WriteLine(allDriveTypes[ii]);
	LMS_MACHINFO_FILE.WriteLine("Script Filter File options=");
	//open and read the filter file
	var filterFile = fso.OpenTextFile(fso.getFolder("..").path + "\\resources\\util\\file_sort_list_win.txt" , ForReading, "True");
	while (!filterFile.AtEndOfStream)
		LMS_MACHINFO_FILE.WriteLine(filterFile.ReadLine());
	
	filterFile.Close();
		LMS_MACHINFO_FILE.WriteLine("[END SCRIPT INFO]");

	LMS_MACHINFO_FILE.WriteLine("[BEGIN ORACLE PROCESS INFO]");
	// use WMI Objects to get running processes.

	var objWMIService = GetObject("winmgmts:\\\\.\\root\\CIMV2");
	
	//set up process statements
	var processStatement = "SELECT * FROM Win32_Process WHERE Name = '";
	var processArray;
	processArray = PROCESSLIST.split(',');
	
	// Go through PROCESSLIST, add to statment, transform to Windows exe or .cmd as necessary.
	for (var ii=0; ii<processArray.length; ii++)
	{
		var dotIndex = processArray[ii].indexOf(".");
		if ( dotIndex <= 0 && ii != (processArray.length - 1) )
			processStatement += processArray[ii] +".exe' OR Name = '";
		else if ( ii != (processArray.length - 1) )
			processStatement += processArray[ii].substring(0,dotIndex) +".cmd' OR Name = '";
	}

	// slice the last ' OR Name =' fromthe command statment.
	processStatement = processStatement.slice(0,-12);
	
	if ( DEBUG )
		echo_debug("processStatement=="+processStatement);
	
	// Execute and enumerate WMI statement for Windows processes.
	var colItems = objWMIService.ExecQuery(processStatement, "WQL",
										  wbemFlagReturnImmediately | wbemFlagForwardOnly);
		  										  							  
	var enumItems = new Enumerator(colItems);
	
		// set up password and user regex
	var cmdLineUserRegex = new RegExp("(user.*=)","i");
	var cmdLinePassRegex = new RegExp("(pass.*=)","i");
	
	var cmdLineUserMatch, cmdLinePassMatch;
	var regexMatchCMDGI,regexMatchPassGI;
	var tempProcessLine;

	try {
		var rmdataWin = fso.OpenTextFile(fso.getFolder("..").path +  "\\resources\\util\\common\\bin\\rmdata_win.txt", ForReading, "True");
	
		while (!rmdataWin.AtEndOfStream) {
				rmDataText = rmdataWin.ReadAll();
			}	

		var regexArray = rmDataText.split('\n');
		rmdataWin.Close();

	}
	catch (exception)
	{
		echo_logs("LMSCT: LMS-00028: ERROR:  Unable to remove open data removal input file. Exception:" + exception.description,"Errors");
	}

	var rmProcessDataRegex;
	var resultMatch;
	for (; !enumItems.atEnd(); enumItems.moveNext()) {
		var objItem = enumItems.item();

		LMS_MACHINFO_FILE.WriteLine("-------------------------------------------");
		LMS_MACHINFO_FILE.WriteLine("Name: " + objItem.Name);  
		LMS_MACHINFO_FILE.WriteLine("ExecutablePath: " + objItem.ExecutablePath);
		tempProcessLine = objItem.CommandLine; 
		
		for (var ii=0; ii<regexArray.length; ii += 2 )
		{	
			rmProcessDataRegex = RegExp(regexArray[ii],"i");


			resultMatch = tempProcessLine.match(rmProcessDataRegex);	
			if ( resultMatch != null ) {
				rmProcessDataRegexGI = RegExp(regexArray[ii],"gi");
				tempProcessLine = tempProcessLine.replace(rmProcessDataRegexGI, regexArray[ii+1]);				
			} 
		}

		LMS_MACHINFO_FILE.WriteLine("CommandLine: " + tempProcessLine);
		
	}

	LMS_MACHINFO_FILE.WriteLine("[END ORACLE PROCESS INFO]");

}


/**
 * printResults - print out the search results  
 */

function printResults() {
	
	var tmpFile;
	var line;
	var LOGFILES;
	var COLLECTEDLOGFILE, ERRORLOGFILE, WARNINGLOGFILE;
	var COLLECTEDLOG = "";
	var ERRORLOG = ""
	var WARNINGLOG = "";

	try {
		LOGFILES = ShowFiles(LMSCT_TMP + "logs\\");

		for(; !LOGFILES.atEnd(); LOGFILES.moveNext()) {
			tmpFile = String(LOGFILES.item());
			if ( tmpFile.indexOf("collected.log") != -1  ) 
			{
				try {
					COLLECTEDLOGFILE = fso.OpenTextFile(tmpFile, ForReading, "True");
					while (!COLLECTEDLOGFILE.AtEndOfStream)
					{
						line = COLLECTEDLOGFILE.ReadLine();
						COLLECTEDLOG += line + "\n";
					}
					COLLECTEDLOGFILE.Close();
				}  catch (exception) {
					WScript.Echo("Can't open Collected Log files.\n");
				}
			} else if ( tmpFile.indexOf("warnings.log") != -1  )
			{	
				try {
					WARNINGLOGFILE = fso.OpenTextFile(tmpFile, ForReading, "True");
					while (!WARNINGLOGFILE.AtEndOfStream)
					{
						line = WARNINGLOGFILE.ReadLine();
						WARNINGLOG += line + "\n";
					}
					WARNINGLOGFILE.Close();
				}  catch (exception) {
					WScript.Echo("Can't open Warning Log files.\n");
				}
		
			} else if ( tmpFile.indexOf("errors.log") != -1  )
			{	
				try {
					ERRORLOGFILE = fso.OpenTextFile(tmpFile, ForReading, "True");
					while (!ERRORLOGFILE.AtEndOfStream)
					{
						line = ERRORLOGFILE.ReadLine();
						ERRORLOG += line + "\n";
					}
					ERRORLOGFILE.Close();
				}  catch (exception) {
					WScript.Echo("Can't open Error Log files.\n");
				}
		
			}
		}			
	} catch (exception) {
		WScript.Echo("Can't open Log files.\n");
	}
	
	if ( COLLECTEDLOG != "" ) {
		WScript.Echo("\n## LMSCT ## Collected\n");
		WScript.Echo(COLLECTEDLOG);
	}
	LMS_RESULTS_SUMMARY_FILE.WriteLine("\n## LMSCT ## Collected\n");
	LMS_RESULTS_SUMMARY_FILE.WriteLine(COLLECTEDLOG);

	if ( WARNINGLOG != "" ) {
		WScript.Echo("\n## LMSCT ## Warnings\n");
		WScript.Echo(WARNINGLOG);
	} else
		WARNING_EMPTY = true;
	
	
	LMS_RESULTS_SUMMARY_FILE.WriteLine("\n## LMSCT ## Warnings\n");
	LMS_RESULTS_SUMMARY_FILE.WriteLine(WARNINGLOG);

	if ( ERRORLOG != "" ) {
		WScript.Echo("\n## LMSCT ## Errors\n");
		WScript.Echo(ERRORLOG);
	} else
		ERRORS_EMTPY = true;
		
	LMS_RESULTS_SUMMARY_FILE.WriteLine("\n## LMSCT ## Errors\n");
	LMS_RESULTS_SUMMARY_FILE.WriteLine(ERRORLOG);


	LMS_DEBUG_FILE.Close();

    //LMS_DEBUG_FILE_fname = TMPDIR + "\\LMSdebugfile.txt";
    LMS_DEBUG_FILE = fso.OpenTextFile(LMS_DEBUG_FILE_fname, ForReading, "True");

	if ( DEBUG ) 
	{
        var f = LMS_DEBUG_FILE;
        while (!f.AtEndOfStream){
            WScript.echo(f.ReadLine());
        }
	}
	LMS_DEBUG_FILE.Close();
}

/**
 *  maskResults() - use perl script to mask the results of the output file.
 *
 */
function maskResults() {
	// use runcommand to execute Perl Script
	var perlError;
	var perlDocsError;

	perlError = runCommand("perl maskdata.pl \"" + LMSCT_TMP.slice(0,-1) + "\" " + MASK_DATA, 0 );
	if ( perlError > 0 ) {
		echo_logs("LMSCT: LMS-00023: ERROR: Perl error while masking data occured.  Please see documentation for troubleshooting instructions." ,"Errors");
		MASK_DATA = "";
	}
}

/**
 *  configsCollected() - find the directories where configs where collected.
 *
 */
function configsCollected() {

	var runReturn;
	var configIndex;
	var FMW_DOMAINS;
	var lineconfigs;
	
	runReturn = runCommand("findstr \"Zip\" \"" + LMS_ACTIONS_RESULTS_FILE_fname + "\" \| findstr \"config.xml\" > configs.txt",0);
	if ( runReturn != 0 ) {
		WINDOWSCMDERR.WriteLine("findstr \"Zip\" " + LMS_ACTIONS_RESULTS_FILE_fname + " \| findstr \"config.xml\" > configs.txt returned with error code: " + runReturn );
	} 

	var	ConfigsCollectedRead = fso.OpenTextFile(fso.getFolder(".").path + "\\configs.txt", 1, "True");
	
	try {
		while (!ConfigsCollectedRead.AtEndOfStream){
			lineconfigs = ConfigsCollectedRead.ReadLine();  // Read Data		
			configIndex = lineconfigs.indexOf("\\config\\");
			if ( configIndex != -1 ) {
				FMW_DOMAINS = lineconfigs.substring(7,configIndex);
				echo_logs("LMSCT: LMS-00200: COLLECTED: FMW configuration files for " + FMW_DOMAINS,"Collected");
			}
		}
		ConfigsCollectedRead.Close();
		fso.DeleteFile(fso.getFolder(".").path + "\\configs.txt");
	} catch (exception) {
	}
	
}