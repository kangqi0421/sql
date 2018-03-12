#!/usr/bin/perl
# maskdata.pl v17.2.1
#	Perl script to mask cutomer IP and user data from
#	files returned to Oracle License Management services.
#
#   Please use perl 5.24 or later versions
#
use File::Find;
use Digest::SHA qw(sha1_hex);
use Digest::SHA qw(sha256_hex);
use Digest::SHA qw(hmac_sha1_hex);
use Digest::SHA qw(hmac_sha256_hex);
use Text::ParseWords;

# set encryption key
my $key = 'XYZ';

#
# Set up needed variables.
#

$p_NonIpAdressRegex = qr/
([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})
/x;

$p_IpAdressPortRegex = qr/
(((25[0-5]|2[0-4][0-9]|1[0-9]{2}|[0-9]{1,2})\.){3}(25[0-5]:[0-9]+|2[0-4][0-9]:[0-9]+|1[0-9]{2}:[0-9]+|[0-9]{1,2}:[0-9]+))
/x;

#
#build IP regex
#
$p_IpAdressRegex = qr/
(
 (?:                               
  (?: 2(?:5[0-5]|[0-4][0-9])\. )   
  |                                
  (?: 1[0-9][0-9]\. )              
  |                                
  (?: (?:[1-9][0-9]?|[0-9])\. )    
 )
 {3}                               
 
(?:                                
 (?: 2(?:5[0-5]|[0-4][0-9]) )      
  |                                
 (?: 1[0-9][0-9] )                 
  |                               
 (?: [1-9][0-9]?|[0-9] )
 )
)
/x;

$p_version = "[Vv]ersion";
$p_userName = "<username>.*</username>";
$p_release = "[Rr]elease";
$p_desUserName = ".*password-encrypted>.*password-encrypted>";

$p_wlsuser = "WLS_USER=.*";
$p_wlsuserConfig = "<node-manager-username>.*</node-manager-username>";
$p_wlspass = "WLS_PW=.*";
$p_encPass = "<credential-encrypted>.*</credential-encrypted>";
$p_port = "<listen-port>.*</listen-port>";
$p_listenaddress = "<listen-address>.*</listen-address>";

$p_serverprivatekey = "<server-private-key-pass-phrase-encrypted>.*</server-private-key-pass-phrase-encrypted>";
$p_clusteraddress = "<cluster-address>.*</cluster-address>";
$p_shellcommand = "<shell-command>.*</shell-command>";
$p_constructorarg = '<constructor-arg index="0" value=".*" />';
$p_beanid = '<bean id=".*" class';
$p_propertyname = '<property name="url" value=".*" />';
$p_weblogic_process = "-Dweblogic.management.server=.*-";

$p_wls_user_name_attribute = '<wls:user-name-attribute>.*</wls:user-name-attribute>';
$p_wls_principal = '<wls:principal>.*</wls:principal>';
$p_wls_user_base_dn = '<wls:user-base-dn>.*</wls:user-base-dn>';
$p_wls_user_from_name_filter = '<wls:user-from-name-filter>.*</wls:user-from-name-filter>';
$p_wls_credential_encrypted = '<wls:credential-encrypted>.*</wls:credential-encrypted>';
$p_wls_group_base_dn = '<wls:group-base-dn>.*</wls:group-base-dn>';

$p_wls_username = ".management.username=.*?";
$p_wls_password = ".management.password=.*?";
$p_wls_username1 = ".admin.username=.*?";
$p_wls_port1 = ".admin.port=.*? ";

$p_composite_prop_password = '<property.*proxyPassword.*</property>';
$p_jdbc_user = '<name>user</name>\n<value>.*</value>';


my $dirname = $ARGV[0];
my $dataoption = $ARGV[1];
my $filename = "";
my $replacetextIP = "Ip Address or port masked.";
my $replacetextPort = "<listen-port><!-- listen port has been masked --></listen-port>";
my $replacetextListen = "<listen-address><!-- listen address has been masked --></listen-address>";
my $replacetextUser = "<credential-encrypted><!-- User or password has been masked --></credential-encrypted>";

my $replacetextserverprivatekey = "<server-private-key-pass-phrase-encrypted><!-- server-private-key-pass-phrase-encrypted has been masked --></server-private-key-pass-phrase-encrypted>";
my $replacetextclusteraddress = "<cluster-address><!-- cluster-address has been masked --></cluster-address>";
my $replacetextshellcommand = "<shell-command><!-- shell-command has been masked --></shell-command>";
my $replacetextconstructorarg = '<constructor-arg index="0" value="value has been masked" />';
my $replacetextbeanid = '<bean id="id has been masked" class';
my $replacetextpropertyname = '<property name="url" value="url has been masked" />';
my $replacetextWeblogicProcess = "-Dweblogic.management.server=Server Name masked.-";

my $replacetext_wls_user_name_attribute = '<wls:user-name-attribute><!-- user-name-attribute has been masked --></wls:user-name-attribute>';
my $replacetext_wls_principal = '<wls:principal><!-- user principal been masked --></wls:principal>';
my $replacetext_wls_user_base_dn = '<wls:user-base-dn><!-- user-base-dn has been masked --></wls:user-base-dn>';
my $replacetext_wls_user_from_name_filter = '<wls:user-from-name-filter><!-- user-from-name-filter has been masked --></wls:user-from-name-filter>';
my $replacetext_wls_credential_encrypted = '<wls:credential-encrypted><!-- credential-encrypted has been masked --></wls:credential-encrypted>';
my $replacetext_wls_group_base_dn = '<wls:group-base-dn><!-- wls:group-base-dn has been masked --></wls:group-base-dn>';


my $replacetext_wls_username = '.management.username=<!-- User or password has been masked --> ';
my $replacetext_wls_password = '.management.password=<!-- User or password has been masked --> ';
my $replacetext_wls_username1 = '.admin.username=<!-- User or password has been masked --> ';
my $replacetext_wls_port1 = '.admin.port=<!-- listen port has been masked --> ';

my $replacetext_composite_prop_password = '<property name="oracle.webservices.proxyPassword">ProxyPassword has been masked.</property>';
my $replacetext_jdbc_user = '<name>user</name>\n<value>JDBC Property Password has been masked.</value>';

my @outLines; 
my $line; 


find(\&mask, $dirname);

sub mask_column256 {

	my ($col) = @_;
	$position = $col - 1;
	if ( @mylist[$position] =~ "^\"" ) { 
		@mylist[$position] = "\"".sha256_hex(substr(@mylist[$position], 1, length(@mylist[$position])-2))."\"";
		}
		else {
		@mylist[$position] = sha256_hex(@mylist[$position]);
		}
}

sub mask_column {

	my ($col) = @_;
	$position = $col - 1;
	my $stripped_string = @mylist[$position];
	$stripped_string =~ s/"//g; #remove the double quotes (") to see if the string is empty, like ""
	if ( @mylist[$position] !~ /\n/ ) {
		if ( length($stripped_string) > 0 ) { 
			if ( @mylist[$position] =~ "^\"" ) { 
				# first step: lowercase(USER) then hash sha256_hex, then uppercase(all)
				@mylist[$position] = "\"".uc sha256_hex(substr(lc @mylist[$position], 1, length(@mylist[$position])-2))."\"";
				# second step: hash sha256_hex with provided key, uppercase, then prefix with OBF_
				@mylist[$position] = "\"OBF_".uc hmac_sha256_hex((substr(@mylist[$position], 1, length(@mylist[$position])-2)), $key)."\"";
			}
			else {
				# first step: lowercase(USER) then hash sha256_hex, then uppercase(all)
				@mylist[$position] = uc sha256_hex(lc @mylist[$position]);
				# second step: hash sha256_hex with provided key, uppercase, then prefix with OBF_
				@mylist[$position] = "OBF_".uc hmac_sha256_hex((@mylist[$position]), $key);
			}
		}
	}
}

sub mask_ip {
	$outline2 = $outline;
	while( $outline2 =~ m/$p_NonIpAdressRegex/ ) {
		$outline2 =~ s/$p_NonIpAdressRegex//g;
	}
	if ( $outline2 =~ m/$p_IpAdressRegex/ ) {
		# first step: lowercase(USER) then hash sha256_hex, then uppercase(all)
		$replacetextIP = "OBF_".uc sha256_hex(lc $1);
		# second step: hash sha256_hex with provided key, uppercase, then prefix with OBF_
		$replacetextIP = "OBF_".uc hmac_sha256_hex($replacetextIP, $key);
		$outline =~ s/$1/$replacetextIP/g;
	}
}

sub mask_users_wlsnup {

$p_wlsnup_username = qr/
(WLSNUP_SHA1:)(.+)
/x;
	
	if ( not -l $filename ) { 
		# make sure the file is not a symlink
		#try opening file matched from find
		#
		open (FILE, $filename ) || print "Can't open $filename: $!\n";
		#
		#loop throught file looking for match
		#
		while ( $line = <FILE> ) {
			$outline=$line;			
			if ( $outline =~ m/$p_wlsnup_username/ ) {
				$replacetextWLSNUP = "OBF_".uc sha256_hex(lc $2);
				# second step: hash sha256_hex with provided key, uppercase, then prefix with OBF_
				$replacetextWLSNUP = "OBF_".uc hmac_sha256_hex($replacetextWLSNUP, $key);
				$outline =~ s/$2/$replacetextWLSNUP/g;	
				$outline =~ s/WLSNUP_SHA1/WLSNUP_SHA2/g;		
			}
			push(@outLines, $outline);
		}
		close FILE;
	}
	open ( OUTFILE, ">$filename" ) || print "Can't open $filename: $!\n";
	print ( OUTFILE @outLines );
	close ( OUTFILE );
	undef( @outLines );		
}

sub mask_users_csv {

	if ( not -l $filename ) { 
		# make sure the file is not a symlink
		#try opening file matched from find
		#
		open (FILE, $filename ) || print "Can't open $filename: $!\n";
		#
		#loop throught file looking for match
		#
		while ( $line = <FILE> ) {
			$outline = "";			
			if ( $line =~ "," ) {
				$mylist =[];

				@mylist = parse_line(q{,}, 1, $line);

				if (@mylist[0] ne "AUDIT_ID" ) 		{ if ($#mylist>=1) { mask_column(2) } };
				
				foreach $x (@mylist) { $outline = $outline.",".$x }
				# remove the first comma from the line
				$outline =~ s/^.//;
			} else {
				$outline=$line;
			}
			
			if ( uc($dataoption) =~ "ALL" ) { mask_ip() };

			push(@outLines, $outline);
		}
		close FILE;
	}
	open ( OUTFILE, ">$filename" ) || print "Can't open $filename: $!\n";
	print ( OUTFILE @outLines );
	close ( OUTFILE );
	undef( @outLines );		
}

sub mask_segments_csv {
	if ( not -l $filename ) { 
		# make sure the file is not a symlink
		#try opening file matched from find
		#
		open (FILE, $filename ) || print "Can't open $filename: $!\n";
		#
		#loop throught file looking for match
		#
		while ( $line = <FILE> ) {
			$outline = "";			
			if ( $line =~ "," ) {
				$mylist =[];
				
				@mylist = parse_line(q{,}, 1, $line);			

				if (@mylist[0] ne "AUDIT_ID" )		{ if ($#mylist>=1) { mask_column(2) } };

				foreach $x (@mylist) { $outline = $outline.",".$x }
				# remove the first comma from the line
				$outline =~ s/^.//;
			} else {
				$outline=$line;
			}
			
			if ( uc($dataoption) =~ "ALL" ) { mask_ip() };
			
			push(@outLines, $outline);
		}
		close FILE;
	}
	open ( OUTFILE, ">$filename" ) || print "Can't open $filename: $!\n";
	print ( OUTFILE @outLines );
	close ( OUTFILE );
	undef( @outLines );		
}

sub mask_session_csv {
	if ( not -l $filename ) { 
		# make sure the file is not a symlink
		#try opening file matched from find
		#
		open (FILE, $filename ) || print "Can't open $filename: $!\n";
		#
		#loop throught file looking for match
		#
		while ( $line = <FILE> ) {
			$outline = "";			
			if ( $line =~ "," ) {
				$mylist =[];
				
				#@mylist = split(",",$line);
				@mylist = parse_line(q{,}, 1, $line);
				
				if (@mylist[0] ne "AUDIT_ID" )	{
					if ($#mylist>=3) { mask_column(4) };
					if ($#mylist>=7) { mask_column(8) };
					if ($#mylist>=8) { mask_column(9) };
				}
				
				foreach $x (@mylist) { $outline = $outline.",".$x }
				# remove the first comma from the line
				$outline =~ s/^.//;
			} else {
				$outline=$line;
			}
			
			if ( uc($dataoption) =~ "ALL" ) { mask_ip() };
			
			push(@outLines, $outline);
		}
		close FILE;
	}
	open ( OUTFILE, ">$filename" ) || print "Can't open $filename: $!\n";
	print ( OUTFILE @outLines );
	close ( OUTFILE );
	undef( @outLines );		
}
				
sub mask_oraproducts_csv {
	if ( not -l $filename ) { 
		# make sure the file is not a symlink
		#try opening file matched from find
		#
		open (FILE, $filename ) || print "Can't open $filename: $!\n";
		#
		#loop throught file looking for match
		#
		while ( $line = <FILE> ) {
			$outline = "";			
			
			if ( $line =~ "^GREPEBS" ) {
				$mylist =[];
				
				@mylist = parse_line(q{,}, 1, $line);
				
				if (@mylist[5] ne "LAST_DDL_TIME")		{ if ($#mylist>=1) { mask_column(2) } };
				
				foreach $x (@mylist) { $outline = $outline.",".$x }
				# remove the first comma from the line
				$outline =~ s/^.//;
				
			} elsif ( $line =~ "^GREPME" ) {
				$mylist =[];
				
				@mylist = parse_line(q{,}, 1, $line);

				if (@mylist[6] eq "EBS"	&& @mylist[7] eq "EBS_SCHEMAS") 				{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "EBS"	&& @mylist[7] eq "SYSTEM.FND_ORACLE_USERID") 	{ if ($#mylist>=11) { mask_column(12) } ; if ($#mylist>=15) { mask_column(16) } };					
				if (@mylist[6] eq "EBS" && @mylist[7] eq "EBS_SPECIFIC_OBJECTS") 		{ if ($#mylist>=12) { mask_column(13) } };
				if (@mylist[6] eq "OWB" && @mylist[7] eq "OBJECTS_DEPLOYED") 			{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "OWB" && @mylist[7] eq "JOBS_RUN") 					{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "OWB" && @mylist[7] eq "FEATURES") 					{ if ($#mylist>=10) { mask_column(11) } ; if ($#mylist>=11) { mask_column(12) } };
				if (@mylist[6] eq "OWB" && @mylist[7] eq "LOCATIONS") 					{ if ($#mylist>=10) { mask_column(11) } ; if ($#mylist>=11) { mask_column(12) } };
				if (@mylist[6] eq "OWB" && @mylist[7] eq "MAPPINGS_TLO") 				{ if ($#mylist>=10) { mask_column(11) } ; if ($#mylist>=11) { mask_column(12) } };
				
				foreach $x (@mylist) { $outline = $outline.",".$x }
				# remove the first comma from the line
				$outline =~ s/^.//;
			}
			
			elsif ( $line =~ "^END OF SCRIPT" ) {
				$outline=$line;
			}
			
			else {
				#$outline="\n"; 
				#$outline=$line; 
			}
			
			if ( uc($dataoption) =~ "ALL" ) { mask_ip() };
			
			push(@outLines, $outline);
		}
		close FILE;
	}
	open ( OUTFILE, ">$filename" ) || print "Can't open $filename: $!\n";
	print ( OUTFILE @outLines );
	close ( OUTFILE );
	undef( @outLines );		
}	

sub mask_summary_csv {
	if ( not -l $filename ) { 
		# make sure the file is not a symlink
		#try opening file matched from find
		#
		open ( OUTFILE, ">$filename" ) || print "Can't open $filename: $!\n";
		print ( OUTFILE "replaced\n" );
		close ( OUTFILE );
	}
}

sub mask_options_csv {
	if ( not -l $filename ) { 
		# make sure the file is not a symlink
		#try opening file matched from find
		#
		open (FILE, $filename ) || print "Can't open $filename: $!\n";
		#
		#loop throught file looking for match
		#
		while ( $line = <FILE> ) {
			$outline = "";			
			
			if ( $line =~ "^GREPME" ) {
				$mylist =[];
				
				@mylist = parse_line(q{,}, 1, $line);

				if (@mylist[6] eq "DBA_REGISTRY" 			&& @mylist[7] eq "9i_r2") 										{ if ($#mylist>=14) { mask_column(15) } };
				if (@mylist[6] eq "PARTITIONING" 			&& @mylist[7] eq "PARTITIONED_SEGMENTS") 						{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "PARTITIONING" 			&& @mylist[7] eq "OLAP_AWS_SEGMENTS") 							{ if ($#mylist>=10) { mask_column(11) } ; if ($#mylist>=14) { mask_column(15) } };
				if (@mylist[6] eq "PARTITIONING" 			&& @mylist[7] eq "PARTITION_OBJ_RECYCLEBIN") 					{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "PARTITIONING" 			&& @mylist[7] eq "DBA_FLASHBACK_ARCHIVE_TABLES+INDEXES+LOBS")	{ if ($#mylist>=10) { mask_column(11) } ; if ($#mylist>=14) { mask_column(15) } };
				if (@mylist[6] eq "PARTITIONING" 			&& @mylist[7] eq "ALL_CHANGE_TABLES")							{ if ($#mylist>=11) { mask_column(12) } ; if ($#mylist>=13) { mask_column(14) } };
				if (@mylist[6] eq "PARTITIONING" 			&& @mylist[7] eq "SCHEMA_VERSION_REGISTRY")						{ if ($#mylist>=15) { mask_column(16) } };
				if (@mylist[6] eq "OLAP" 					&& @mylist[7] eq "OLAPSYS.DBA\$OLAP_CUBES") 					{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "OLAP" 					&& @mylist[7] eq "DBA_CUBES") 									{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "OLAP" 					&& @mylist[7] eq "ANALYTIC_WORKSPACES") 						{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "DATA_MINING" 			&& @mylist[7] eq "11g+.DBA_MINING_MODELS") 						{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "SPATIAL" 				&& @mylist[7] eq "ALL_SDO_GEOM_METADATA") 						{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "ADVANCED_SECURITY" 		&& @mylist[7] eq "COLUMN_ENCRYPTION") 							{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "ADVANCED_SECURITY" 		&& @mylist[7] eq "SECUREFILES_ENCRYPTION") 						{ if ($#mylist>=11) { mask_column(12) } };
				if (@mylist[6] eq "ADVANCED_COMPRESSION" 	&& @mylist[7] eq "TABLE_COMPRESSION") 							{ if ($#mylist>=11) { mask_column(12) } };
				if (@mylist[6] eq "ADVANCED_COMPRESSION" 	&& @mylist[7] eq "SECUREFILES_COMPRESSION_AND_DEDUPLICATION")	{ if ($#mylist>=11) { mask_column(12) } };
				if (@mylist[6] eq "ADVANCED_COMPRESSION" 	&& @mylist[7] eq "DBA_FLASHBACK_ARCHIVE_TABLES") 				{ if ($#mylist>=11) { mask_column(12) } };
				if (@mylist[6] eq "DATABASE_VAULT" 			&& @mylist[7] eq "DVSYS_SCHEMA") 								{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "DATABASE_VAULT" 			&& @mylist[7] eq "DVF_SCHEMA") 									{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "DB_IN_MEMORY" 			&& @mylist[7] eq "INMEMORY_ENABLED_TABLES") 					{ if ($#mylist>=11) { mask_column(12) } };
				if (@mylist[6] eq "DB_IN_MEMORY" 			&& @mylist[7] eq "GV\$IM_SEGMENTS") 							{ if ($#mylist>=13) { mask_column(14) } };
				if (@mylist[6] eq "OEM" 					&& @mylist[7] eq "GRID_CONTROL+11g") 							{ if ($#mylist>=17) { mask_column(18) } };
				if (@mylist[6] eq "OEM" 					&& @mylist[7] eq "MGMT_LICENSES") 								{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "OEM" 					&& @mylist[7] eq "MGMT_LICENSE_CONFIRMATION") 					{ if ($#mylist>=11) { mask_column(12) } };
				if (@mylist[6] eq "OEM" 					&& @mylist[7] eq "DBA_ADVISOR_TASKS") 							{ if ($#mylist>=11) { mask_column(12) } };
				if (@mylist[6] eq "OEM" 					&& @mylist[7] eq "DBA_SQLSET") 									{ if ($#mylist>=12) { mask_column(13) } };
				if (@mylist[6] eq "OEM" 					&& @mylist[7] eq "DBA_SQLSET_REFERENCES") 						{ if ($#mylist>=12) { mask_column(13) } ; if ($#mylist>=14) { mask_column(15) } };
				if (@mylist[6] eq "AUDIT_VAULT*" 			&& @mylist[7] eq "AVSYS_SCHEMA") 								{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "CONTENT_AND_RECORDS" 	&& @mylist[7] eq "CONTENT_SCHEMA") 								{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "OWB" 					&& @mylist[7] eq "REPOSITORY") 									{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "EXTRA_INFO" 				&& @mylist[7] eq "V\$SESSION") 									{ if ($#mylist>=12) { mask_column(13) }; if ($#mylist>=16) { mask_column(17) }; if ($#mylist>=17) { mask_column(18) }; };
				if (@mylist[6] eq "USER_PRIVS" 				&& @mylist[7] eq "USER") 										{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "USER_PRIVS" 				&& @mylist[7] eq "USER_SYS_PRIVS") 								{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "USER_PRIVS" 				&& @mylist[7] eq "USER_ROLE_PRIVS") 							{ if ($#mylist>=10) { mask_column(11) } ; if ($#mylist>=11) { mask_column(12) } };
				if (@mylist[6] eq "USER_PRIVS" 				&& @mylist[7] eq "ROLE_SYS_PRIVS") 								{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "PARTITIONING" 			&& @mylist[7] eq "DBA_USERS.ORACLE_MAINTAINED") 				{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "PARTITIONING" 			&& @mylist[7] eq "DBA_USERS.IMPLICIT") 							{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "ADVANCED_SECURITY" 		&& @mylist[7] eq "REDACTION_POLICIES") 							{ if ($#mylist>=10) { mask_column(11) } };
				if (@mylist[6] eq "ADVANCED_COMPRESSION" 	&& @mylist[7] eq "DBA_INDEXES.COMPRESSION") 					{ if ($#mylist>=10) { mask_column(11) }; if ($#mylist>=12) { mask_column(13) } };																

				foreach $x (@mylist) { $outline = $outline.",".$x }
				# remove the first comma from the line
				$outline =~ s/^.//;
			} 
			
			
			elsif ( $line =~ "\\*\\*\\* EXTRA INFO \\*\\*\\* Troubleshooting" ) {
				$outline=$line;
			}

			else {
				#$outline="\n"; 
				#$outline=$line; 
			}
			
			if ( uc($dataoption) =~ "ALL" ) { mask_ip() };	
			
			push(@outLines, $outline);
		}
		close FILE;
	}
	open ( OUTFILE, ">$filename" ) || print "Can't open $filename: $!\n";
	print ( OUTFILE @outLines );
	close ( OUTFILE );
	undef( @outLines );		
}



sub mask {
	$filename=$File::Find::name;
	#print "$filename\n";
	
	##########################################
	#              FMW section               #
	##########################################	
		
	if ( (/\.xml$/) || (/\.bea$/) || (/\.txt$/) || (/\.properties$/) || (/\.sh$/) || (/\.log$/) ){
		
		if ( not -l $filename ) { 
			# make sure the file is not a symlink
			print "Masking $dataoption from FMW output file: $filename\n";
			#try opening file matched from find
			#
			open (FILE, $filename ) || print "Can't open $filename: $!\n";
			
			#
			#loop throught file looking for match
			#
			while ( $line = <FILE> ) {	
				if ( $dataoption =~ "user" ) {
					if ( $line =~ m/$p_userName/ ) {
						$line =~ s/$p_userName/$replacetextUser/g;
					} elsif ( $line =~ m/$p_desUserName/ ) {
						$line =~ s/$p_desUserName/$replacetextUser/g;
					} elsif ( $line =~ m/$p_wlsuser/ ) {
						$line =~ s/$p_wlsuser/$replacetextUser/g;
					} elsif ( $line =~ m/$p_wlsuserConfig/ ) {
						$line =~ s/$p_wlsuserConfig/$replacetextUser/g;
					} elsif ( $line =~ m/$p_wlspass/ ) {
						$line =~ s/$p_wlspass/$replacetextUser/g;
					} elsif ( $line =~ m/$p_encPass/ ) {
						$line =~ s/$p_encPass/$replacetextUser/g;
					} elsif ( $line =~ m/$p_composite_prop_password/ ) {
						$line =~ s/$p_composite_prop_password/$replacetext_composite_prop_password/g;	
					} elsif ( $line =~ m/$p_jdbc_user/ ) {
						$line =~ s/$p_jdbc_user/$replacetext_jdbc_user/g;	
					} elsif ( $line =~ m/$p_wls_username(^|\s)/ || $line =~ m/$p_wls_password(^|\s)/ || $line =~ m/$p_wls_username1(^|\s)/ ) {
						$line =~ s/$p_wls_username(^|\s)/$replacetext_wls_username/g;
						$line =~ s/$p_wls_username1(^|\s)/$replacetext_wls_username1/g;
						$line =~ s/$p_wls_password(^|\s)/$replacetext_wls_password/g;	
					}					
				} elsif ( $dataoption =~ "IP" ) {
					if ( $line =~ m/$p_IpAdressPortRegex/ ) {
						$line =~ s/$p_IpAdressPortRegex/$replacetextIP/g;
					} elsif ($line =~ m/$p_IpAdressRegex/ && $line !~ m/$p_NonIpAdressRegex/ && $line !~ m/$p_version/ && $line !~ m/$p_release/ ) {	
						$line =~ s/$p_IpAdressRegex/$replacetextIP/g;
					} elsif ( $line =~ m/$p_port/ ) {
						$line =~ s/$p_port/$replacetextPort/g;
					} elsif ( $line =~ m/$p_listenaddress/ ) {
						$line =~ s/$p_listenaddress/$replacetextListen/g;
					}
				} else {
					#Find IP match but ignore lines with version in it so config.xml, registry.xml versions are left alone.
					if ( $line =~ m/$p_IpAdressRegex/ && $line !~ m/$p_NonIpAdressRegex/ && $line !~ m/$p_version/ && $line !~ m/$p_release/ ) {	
						$line =~ s/$p_IpAdressRegex/$replacetextIP/g;
						if ( $line =~ m/$p_wls_username(^|\s)/ || $line =~ m/$p_wls_password(^|\s)/ || $line =~ m/$p_wls_username1(^|\s)/ || $line =~ m/$p_wls_port1(^|\s)/) {
						$line =~ s/$p_wls_username1(^|\s)/$replacetext_wls_username1/g;
						$line =~ s/$p_wls_username(^|\s)/$replacetext_wls_username/g;
						$line =~ s/$p_wls_password(^|\s)/$replacetext_wls_password\n/g;
						$line =~ s/$p_wls_port1(^|\s)/$replacetext_wls_port1/g;	
						}
					} elsif ( $line =~ m/$p_userName/ ) {
						$line =~ s/$p_userName/$replacetextUser/g;
					} elsif ( $line =~ m/$p_desUserName/ ) {
						$line =~ s/$p_desUserName/$replacetextUser/g;
					} elsif ( $line =~ m/$p_wlsuser/ ) {
						$line =~ s/$p_wlsuser/$replacetextUser/g;
					} elsif ( $line =~ m/$p_wlsuserConfig/ ) {
						$line =~ s/$p_wlsuserConfig/$replacetextUser/g;
					} elsif ( $line =~ m/$p_wlspass/ ) {
						$line =~ s/$p_wlspass/$replacetextUser/g;
					} elsif ( $line =~ m/$p_encPass/ ) {
						$line =~ s/$p_encPass/$replacetextUser/g;
					} elsif ( $line =~ m/$p_port/ ) {
						$line =~ s/$p_port/$replacetextPort/g;
					} elsif ( $line =~ m/$p_listenaddress/ ) {
						$line =~ s/$p_listenaddress/$replacetextIP/g;
					} elsif ( $line =~ m/$p_serverprivatekey/ ) {
						$line =~ s/$p_serverprivatekey/$replacetextserverprivatekey/g;
					} elsif ( $line =~ m/$p_clusteraddress/ ) {
						$line =~ s/$p_clusteraddress/$replacetextclusteraddress/g;
					} elsif ( $line =~ m/$p_shellcommand/ ) {
						$line =~ s/$p_shellcommand/$replacetextshellcommand/g;
					} elsif ( $line =~ m/$p_constructorarg/ ) {
						$line =~ s/$p_constructorarg/$replacetextconstructorarg/g;
					} elsif ( $line =~ m/$p_beanid/ ) {
						$line =~ s/$p_beanid/$replacetextbeanid/g;
					} elsif ( $line =~ m/$p_propertyname/ ) {
						$line =~ s/$p_propertyname/$replacetextpropertyname/g;
					} elsif ( $line =~ m/$p_weblogic_process/ ) {
						$line =~ s/$p_weblogic_process/$replacetextWeblogicProcess/g;
					} elsif ( $line =~ m/$p_wls_user_name_attribute/ ) {
						$line =~ s/$p_wls_user_name_attribute/$replacetext_wls_user_name_attribute/g;
					} elsif ( $line =~ m/$p_wls_principal/ ) {
						$line =~ s/$p_wls_principal/$replacetext_wls_principal/g;
					} elsif ( $line =~ m/$p_wls_user_base_dn/ ) {
						$line =~ s/$p_wls_user_base_dn/$replacetext_wls_user_base_dn/g;
					} elsif ( $line =~ m/$p_wls_user_from_name_filter/ ) {
						$line =~ s/$p_wls_user_from_name_filter/$replacetext_wls_user_from_name_filter/g;
					} elsif ( $line =~ m/$p_wls_credential_encrypted/ ) {
						$line =~ s/$p_wls_credential_encrypted/$replacetext_wls_credential_encrypted/g;
					} elsif ( $line =~ m/$p_wls_group_base_dn/ ) {
						$line =~ s/$p_wls_group_base_dn/$replacetext_wls_group_base_dn/g;					
					} elsif ( $line =~ m/$p_composite_prop_password/ ) {
						$line =~ s/$p_composite_prop_password/$replacetext_composite_prop_password/g;	
					} elsif ( $line =~ m/$p_jdbc_user/ ) {
						$line =~ s/$p_jdbc_user/$replacetext_jdbc_user/g;	
					} elsif ( $line =~ m/$p_wls_username(^|\s)/ || $line =~ m/$p_wls_username1(^|\s)/ || $line =~ m/$p_wls_password(^|\s)/ ) {
						$line =~ s/$p_wls_username1(^|\s)/$replacetext_wls_username1/g;
						$line =~ s/$p_wls_username(^|\s)/$replacetext_wls_username/g;
						$line =~ s/$p_wls_password(^|\s)/$replacetext_wls_password\n/g;
						$line =~ s/$p_wls_port1(^|\s)/$replacetext_wls_port1/g;						
					}				
				}
				
				push(@outLines, $line);
			}
			close FILE;
		
			open ( OUTFILE, ">$filename" ) || print "Can't open $filename: $!\n";

			print ( OUTFILE @outLines );
			close ( OUTFILE );

			undef( @outLines );
			
			if (/WLS_NUP\.txt$/)  { mask_users_wlsnup(); }
		}
		
	} elsif (/\.csv$/) {
	
		##########################################
		#              EBS section               #
		##########################################	
		
		if ((/FND_USER\.csv$/) || (/WF_USER_ROLE_ASSIGNMENTS.csv$/) || (/WF_LOCAL_USER_ROLES.csv$/)) {

			#print "EBS1";
			print "Masking $dataoption from EBS output file: $filename\n";
			if ( $dataoption =~ "IP"){
			
				print "\tSkipping file\n";
				
			} elsif ( $dataoption =~ "user" ) {
			
				#try opening file matched from find
				#
				open (FILE, $filename ) || print "Can't open $filename: $!\n";

				#
				#loop throught file looking for match
				#
				$column_masked=0; #store here the number of the column which needs to be masked
				while ( $line = <FILE> ) {
					# EBS part will not be masked for IP bu only for: user, all
					$outline = "";	
					$encrypted_username = "";					
					if ( $line =~ "," ) {
						#mask usernames
						$mylist =[];
						$cnt=0; #count here all the columns from the row split by comma
						$rcnt=0; #store here the current column number					
						if ($column_masked==0) {
							@mylist = split(",",$line);
							#find the column number which needs to be masked
							foreach $x (@mylist) {
								++$cnt;
								$x=~ s/[\^'*||\~||]*//g; # get rid of the special delimiters/chars
								if ($x eq "USER_NAME") {
									$column_masked=$cnt;
								}
							}
							#print "column to be masked=$column_masked\n";
							$outline=$line;
						} else {
								
							@mylist = split(/(?:,\^\~\*\~\^)/,$line);
							$rcnt=0;
							foreach $x (@mylist) {
								++$rcnt;
								#print "Elementul $rcnt este: $x\n";
								if ($rcnt==$column_masked) {
									#print "original=$x\n";
									$x=~ s/[\^'*||\~||]*//g;
									#print "modified=$x\n";
									
									# first step: lowercase(USER) then hash sha256_hex, then uppercase(all)
									$encrypted_username = uc sha256_hex(lc $x);
									# second step: hash sha256_hex with provided key, uppercase, then prefix with OBF_
									$encrypted_username = "OBF_".uc hmac_sha256_hex($encrypted_username, $key);
									$outline = $outline.",^~*~^".$encrypted_username."^~*~^";
	
									#print "$outline\n";
								} else {
									#print "$x\n";
									if ($rcnt==1) {
										$outline = $x;
									} else {
										$outline = $outline.",^~*~^".$x;
									}
								}
							}
						}
					} else {
						$outline=$line;
					}
					
					push(@outLines, $outline);
									
				}
				close FILE;
			
				open ( OUTFILE, ">$filename" ) || print "Can't open $filename: $!\n";

				print ( OUTFILE @outLines );
				close ( OUTFILE );

				undef( @outLines );
				
			} else {
			
				#try opening file matched from find
				#
				open (FILE, $filename ) || print "Can't open $filename: $!\n";

				#
				#loop throught file looking for match
				#
				$column_masked=0; #store here the number of the column which needs to be masked
				while ( $line = <FILE> ) {
					# EBS part will not be masked for IP bu only for: user, all
					$outline = "";	
					$encrypted_username = "";					
					if ( $line =~ "," ) {
						#mask usernames
						$mylist =[];
						$cnt=0; #count here all the columns from the row split by comma
						$rcnt=0; #store here the current column number					
						if ($column_masked==0) {
							@mylist = split(",",$line);
							#find the column number which needs to be masked
							foreach $x (@mylist) {
								++$cnt;
								$x=~ s/[\^'*||\~||]*//g; # get rid of the special delimiters/chars
								if ($x eq "USER_NAME") {
									$column_masked=$cnt;
								}
							}
							#print "column to be masked=$column_masked\n";
							$outline=$line;
						} else {								
							@mylist = split(/(?:,\^\~\*\~\^)/,$line);
							$rcnt=0;
							foreach $x (@mylist) {
								++$rcnt;
								#print "Elementul $rcnt este: $x\n";
								if ($rcnt==$column_masked) {
									#print "original=$x\n";
									$x=~ s/[\^'*||\~||]*//g;
									#print "modified=$x\n";
									
									# first step: lowercase(USER) then hash sha256_hex, then uppercase(all)
									$encrypted_username = uc sha256_hex(lc $x);
									# second step: hash sha256_hex with provided key, uppercase, then prefix with OBF_
									$encrypted_username = "OBF_".uc hmac_sha256_hex($encrypted_username, $key);
									$outline = $outline.",^~*~^".$encrypted_username."^~*~^";
	
									#print "$outline\n";
								} else {
									#print "$x\n";
									if ($rcnt==1) {
										$outline = $x;
									} else{
										$outline = $outline.",^~*~^".$x;
									}
								}
							}
						}
					} else {
						$outline=$line;
					}
					
					#just in case, mask any IP address found in the files
					mask_ip();
					
					push(@outLines, $outline);
									
				}
				close FILE;
			
				open ( OUTFILE, ">$filename" ) || print "Can't open $filename: $!\n";

				print ( OUTFILE @outLines );
				close ( OUTFILE );

				undef( @outLines );
			}
			
		} else {
		
			###############################################
			#              Database section               #
			###############################################
			
			#print "DB";
			print "Masking $dataoption from DB output file: $filename\n";
				
			if ( $dataoption =~ "user" ) {

				if 		(/users\.csv$/) 		{ mask_users_csv() }
				elsif 	(/segments\.csv$/) 		{ mask_segments_csv() }
				elsif 	(/session\.csv$/) 		{ mask_session_csv() }
				elsif 	(/oraproducts\.csv$/) 	{ mask_oraproducts_csv() }
				elsif 	(/summary\.csv$/) 		{ mask_summary_csv() }
				elsif 	(/options\.csv$/) 		{ mask_options_csv() }

			} elsif ( $dataoption =~ "IP" ) {
				if ( not -l $filename ) { 
						# make sure the file is not a symlink
						#try opening file matched from find
						#
						open (FILE, $filename ) || print "Can't open $filename: $!\n";
						#
						#loop throught file looking for match
						#dbip
						while ( $line = <FILE> ) {
							$outline=$line;
							while( $outline =~ m/$p_NonIpAdressRegex/ ) {
								$outline =~ s/$p_NonIpAdressRegex//g;
							}
							$outline2 = $outline;
							if ( $outline2 =~ m/$p_IpAdressRegex/ ) {
								# first step: lowercase(USER) then hash sha256_hex, then uppercase(all)
								$replacetextIP = "OBF_".uc sha256_hex(lc $1);
								# second step: hash sha256_hex with provided key, uppercase, then prefix with OBF_
								$replacetextIP = "OBF_".uc hmac_sha256_hex($replacetextIP, $key);
								$outline =~ s/$1/$replacetextIP/g;
							}											
							$outline=$line;

							#print $line;
							push(@outLines, $outline);
						}
						close FILE;
				}
				open ( OUTFILE, ">$filename" ) || print "Can't open $filename: $!\n";
				print ( OUTFILE @outLines );
				close ( OUTFILE );
				undef( @outLines );		
			
			} else {
				# $dataoption =~ "all" 

				if 		(/users\.csv$/) 		{ mask_users_csv() }				
				elsif 	(/segments\.csv$/) 		{ mask_segments_csv() }
				elsif 	(/session\.csv$/) 		{ mask_session_csv() }
				elsif 	(/oraproducts\.csv$/) 	{ mask_oraproducts_csv() }
				elsif 	(/summary\.csv$/) 		{ mask_summary_csv() }
				elsif 	(/options\.csv$/) 		{ mask_options_csv() }

				else {
				
					if ( not -l $filename ) { 
							# make sure the file is not a symlink
							#try opening file matched from find
							#
							open (FILE, $filename ) || print "Can't open $filename: $!\n";
							#
							#loop throught file looking for match
							#dbip
							while ( $line = <FILE> ) {
								$outline=$line;
								while( $outline =~ m/$p_NonIpAdressRegex/ ) {
									$outline =~ s/$p_NonIpAdressRegex//g;
								}
								if ( $outline =~ m/$p_IpAdressRegex/ ) {
									# first step: lowercase(USER) then hash sha256_hex, then uppercase(all)
									$replacetextIP = "OBF_".uc sha256_hex(lc $1);
									# second step: hash sha256_hex with provided key, uppercase, then prefix with OBF_
									$replacetextIP = "OBF_".uc hmac_sha256_hex($replacetextIP, $key);
									$line =~ s/$1/$replacetextIP/g;
								}								
								push(@outLines, $line);
							}
							close FILE;
					}
					open ( OUTFILE, ">$filename" ) || print "Can't open $filename: $!\n";
					print ( OUTFILE @outLines );
					close ( OUTFILE );
					undef( @outLines );					
				}
			}
		}
	}
}

