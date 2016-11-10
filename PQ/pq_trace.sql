-- PQ trace
alter system flush shared_pool; on all nodes
alter session set  TRACEFILE_IDENTIFIER  = 'PX_MISMATCH';
alter session set events 'trace[PX_Control] disk medium';
alter session set events 'trace[PX_Messaging] disk medium';
alter session set events 'trace[SQL_Compiler] disk high';
alter session set "_px_trace" = "high","compilation","medium","time";
alter session set events 'trace[SQL_Parallel_Compilation|SQL_Parallel_Optimization] disk medium';
alter session set events 'trace[Cursor] disk high';
 
alter session force parallel query 16;  