--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = riskengine, pg_catalog;

INSERT INTO databasechangelog (ID, AUTHOR, FILENAME, DATEEXECUTED, ORDEREXECUTED, MD5SUM, DESCRIPTION, COMMENTS, EXECTYPE, CONTEXTS, LABELS, LIQUIBASE, DEPLOYMENT_ID) VALUES ('00001-csas-ceres-schema', 'parchanskyv', 'changelog/changelog-schema.xml', NOW(), 1, '7:f76e05ac11c3e0753c4691ee275fcd65', 'sqlFile', '', 'EXECUTED', NULL, NULL, '3.5.4', '9977014256');

INSERT INTO databasechangeloglock (id, locked, lockgranted, lockedby) VALUES (1, false, NULL, NULL);

