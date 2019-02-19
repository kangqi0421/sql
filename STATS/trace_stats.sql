
K trasování dbms_stats existuje Internal Note:

How to Trace the DBMS_STATS Package (Doc ID 742519.1)

cituji:
========================================
Tracing is enabled using the DBMS_STATS.SET_GLOBAL_PREFS() procedure with a trace level.
For example:
SQL> exec DBMS_STATS.SET_GLOBAL_PREFS('trace', &level);

In previous versions, you could also use DBMS_STATS.SET_PARAM() but this is now deprecated.  (Prior to 11.1, you must use DBMS_STATS.SET_PARAM().)
SQL> exec DBMS_STATS.SET_PARAM('trace', &level);
  See:
Oracle® Database PL/SQL Packages and Types Reference
12c Release 1 (12.1)
E17602-14
Section 153 DBMS_STATS
SET_PARAM Procedure
https://docs.oracle.com/database/121/ARPLS/d_stats.htm#ARPLS68668

The trace levels enable various different features dependent on the supplied values.
You can check on the current level by selecting as follows:
SQL> select DBMS_STATS.GET_PARAM('trace') from dual;

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
The meanings of the various levels can be found in prvtstas.sql:
-- tracing can be enabled using dbms_stats.set_param procedure.
-- set_param set both trace_level variable and update the record in
-- optstat_hist_control$ (depending on DSC_SESSION_TRC is set or not).

DSC_DBMS_OUTPUT_TRC CONSTANT NUMBER := 1; -- use dbms_output.put_line
                                         -- instead of writing into trc file
DSC_SESSION_TRC CONSTANT NUMBER := 2; -- enable trace only at session level
DSC_TAB_TRC CONSTANT NUMBER := 4; -- trace table stats
DSC_IND_TRC CONSTANT NUMBER := 8; -- trace index stats
DSC_COL_TRC CONSTANT NUMBER := 16; -- trace column stats
DSC_AUTOST_TRC CONSTANT NUMBER := 32; -- trace auto stats (get snapshot)
                                   -- refer to save_target_list()
  WARNING: Do not set DSC_AUTOST_TRC without creating SYS.STATS_TARGET$_LOG,
  otherwise the auto stats task will fail (see DBMS_STATS.SAVE_TARGET_LIST())

DSC_SCALING_TRC CONSTANT NUMBER := 64; -- trace scaling
DSC_ERROR_TRC CONSTANT NUMBER := 128; -- dump backtrace on error
DSC_DUBIOUS_TRC CONSTANT NUMBER := 256; -- dubious stats detection
DSC_AUTOJOB_TRC CONSTANT NUMBER := 512; -- auto stats job
DSC_PX_TRC CONSTANT NUMBER := 1024; -- parallel execution
DSC_Q_TRC CONSTANT NUMBER := 2048; -- print query before execution
DSC_CCT_TRC CONSTANT NUMBER := 4096; -- cct()
DSC_DIFFST_TRC CONSTANT NUMBER := 8192; -- trace diff_table_stats*

11.1 and above
DSC_USTATS_TRC CONSTANT NUMBER := 16384; -- user stats (extensibility)
-- Don't store histogram (used for combo ndv scaling)

11.2.0.2 and above
DSC_SYN_TRC CONSTANT NUMBER := 32768;    -- dump synopses

12.1.0.1 and above
DSC_ONLINE_TRC CONSTANT NUMBER := 65536; -- online stats gathering
DSC_ADOP_TRC CONSTANT NUMBER := 131072;  -- auto dop

12.1.0.2 and above
DSC_SYSSTATS_TRC CONSTANT NUMBER := 262144; -- trace system stats


If you add multiple flags together, all of the traces will be set, so setting level 2+4+8+16+64+512+1024+2048 would:
    enable trace only at session level
    trace table stats
    trace index stats
    trace column stats
    trace scaling
    trace auto stats job
    trace parallel execution
    print query before execution

Note that if you set a session-level trace (i.e. includes level 2), it will not be reflected in the get param value, rather it will just show the previous setting prior to the change.
For example:
SQL> exec DBMS_STATS.SET_GLOBAL_PREFS('trace',0);
PL/SQL procedure successfully completed.
SQL> select dbms_stats.get_param('trace') from dual;
DBMS_STATS.GET_PARAM('TRACE')
--------------------------------------------------------------------------------
0
SQL> exec DBMS_STATS.SET_GLOBAL_PREFS('trace', 2+4+8+16+64+512+1024+2048 /* 3678 */);
PL/SQL procedure successfully completed.
SQL> select dbms_stats.get_param('trace') from dual;
DBMS_STATS.GET_PARAM('TRACE')
--------------------------------------------------------------------------------
0
SQL> exec DBMS_STATS.SET_GLOBAL_PREFS('trace', 4+8+16+64+512+1024+2048 /* 3676 */);
PL/SQL procedure successfully completed.
SQL>  select dbms_stats.get_param('trace') from dual;
DBMS_STATS.GET_PARAM('TRACE')
--------------------------------------------------------------------------------
3676
SQL>  exec DBMS_STATS.SET_GLOBAL_PREFS('trace', 2+4+8+16+64+512+1024+2048 /* 3678 */);
PL/SQL procedure successfully completed.
SQL>  select dbms_stats.get_param('trace') from dual;
DBMS_STATS.GET_PARAM('TRACE')
--------------------------------------------------------------------------------
3676

If trace level set is not session-level (does not include 2), then the trace value is saved in optstat_hist_control$.
When you run the dbms_stats package next, it will create a trace file in the dump directory.

<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

To turn off the tracing run:
exec DBMS_STATS.SET_GLOBAL_PREFS('trace',0);