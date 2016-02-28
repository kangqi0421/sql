--detecting who’s causing excessive redo generation
@snapper "all,gather=s,sinclude=redo size" 10 1 all

-- user commits for USER sessions
@snapper "all,gather=s,sinclude=user commits" 10 1 "select sid from v$session where type = 'USER'"

-- BEGIN, END
VAR SNAPPER REFCURSOR
@snapper4 all,begin 5 1 "select distinct inst_id, sid from gv$mystat"
...
@snapper4 all,end 5 1 "select distinct inst_id, sid from gv$mystat"
