-- SYN data from OEM
exec dbms_scheduler.run_job('DASHBOARD.OMS_OLI_REFRESH_DATA');

-- PL/SQL proc
exec dashboard.refresh_oli_dbhost_properties;