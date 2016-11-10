/* Setting up a snapshot site replication enviroment */

/* Creating replication adminstrator at site ORIGIN.NATUR.CUNI.CZ */

/* Creating user SNAPADMIN at site ORIGIN.NATUR.CUNI.CZ... */

create user "SNAPADMIN" identified by "jiricek"

/* Granting admin privileges to SNAPADMIN at site ORIGIN.NATUR.CUNI.CZ... */

BEGIN
   DBMS_REPCAT_ADMIN.GRANT_ADMIN_ANY_SCHEMA(
	username => 'SNAPADMIN');
END;

grant comment any table to "SNAPADMIN"

grant lock any table to "SNAPADMIN"

/* Creating propagator at site ORIGIN.NATUR.CUNI.CZ */

/* Registering propagator SNAPADMIN at site ORIGIN.NATUR.CUNI.CZ ... */

BEGIN
   DBMS_DEFER_SYS.REGISTER_PROPAGATOR(
     username => 'SNAPADMIN');
END;

/* Creating user SNAPADMIN_ORIGIN_NATUR_CUNI_CZ at site TWINSEN.NATUR.CUNI.CZ... */

create user "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ" identified by "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

/* Granting snapshot receiver privileges to SNAPADMIN_ORIGIN_NATUR_CUNI_CZ at master site TWINSEN.NATUR.CUNI.CZ... */

BEGIN
	DBMS_REPCAT_ADMIN.GRANT_SNAPADMIN_PROXY(username => 'SNAPADMIN_ORIGIN_NATUR_CUNI_CZ');
END;

grant alter session to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant create cluster to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant create database link to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant create sequence to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant create session to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant create synonym to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant create table to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant create view to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant create procedure to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant create trigger to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant unlimited tablespace to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant create type to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant execute any procedure to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant create any trigger to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant create any procedure to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

grant select any table to "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

/*Connecting to site ORIGIN.NATUR.CUNI.CZ as user SNAPADMIN...*/

/* Scheduling purge at site ORIGIN.NATUR.CUNI.CZ... */

BEGIN
   DBMS_DEFER_SYS.SCHEDULE_PURGE(
   next_date => SYSDATE,
   interval => '/*1:Hr*/ sysdate + 1/24',
   delay_seconds => 0,
   rollback_segment => '');
END;

CREATE DATABASE LINK "TWINSEN.NATUR.CUNI.CZ"
CONNECT TO "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ" IDENTIFIED BY "SNAPADMIN_ORIGIN_NATUR_CUNI_CZ"

/* Scheduling link TWINSEN at site ORIGIN.NATUR.CUNI.CZ... */

BEGIN
   DBMS_DEFER_SYS.SCHEDULE_PUSH(
     destination => 'TWINSEN.NATUR.CUNI.CZ',
     interval => '/*1:Hr*/ sysdate + 1/24',
     next_date => SYSDATE,
     stop_on_error => FALSE,
     delay_seconds => 0,
     parallelism => 0);
END;

/*Connecting to site ORIGIN.NATUR.CUNI.CZ as user SNAPADMIN...*/

grant alter session to "STDOWNER"

grant create cluster to "STDOWNER"

grant create database link to "STDOWNER"

grant create sequence to "STDOWNER"

grant create session to "STDOWNER"

grant create synonym to "STDOWNER"

grant create table to "STDOWNER"

grant create view to "STDOWNER"

grant create procedure to "STDOWNER"

grant create trigger to "STDOWNER"

grant unlimited tablespace to "STDOWNER"

grant create type to "STDOWNER"

grant create any snapshot to "STDOWNER"

grant alter any snapshot to "STDOWNER"

/*Connecting to site ORIGIN.NATUR.CUNI.CZ as user STDOWNER...*/

CREATE DATABASE LINK "TWINSEN.NATUR.CUNI.CZ"
CONNECT TO "STDOWNER" IDENTIFIED BY "chaloupek"