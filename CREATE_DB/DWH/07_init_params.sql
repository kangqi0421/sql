--
-- DWH change init params
--

alter system set db_files = 4000 scope=spfile;

-- disable recycle
alter system set recyclebin = OFF scope=spfile;

-- disable force logging
alter database no force logging;

-- disable adapt.plans
alter system set OPTIMIZER_ADAPTIVE_PLANS = false;
alter system set optimizer_dynamic_sampling = 1;

-- disable warning
alter system set "_kgl_large_heap_warning_threshold" = 209715200;

