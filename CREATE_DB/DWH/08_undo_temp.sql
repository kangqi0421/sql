--
-- UNDO TEMP
--

-- Add USER_TEMP
BEGIN
  EXECUTE IMMEDIATE
    'create bigfile temporary tablespace USER_TEMP
       tempfile size 100G autoextend on next 1G maxsize 700G';
EXCEPTION
  WHEN OTHERS THEN
    IF sqlcode != -1543 THEN RAISE;
    END IF;
END;
/

-- predchozi obcas nenastavi autoextend
alter database tempfile 2 autoextend on next 1G maxsize 700G;

BEGIN
  EXECUTE IMMEDIATE
    'alter database default temporary tablespace USER_TEMP';
EXCEPTION
  WHEN OTHERS THEN
    IF sqlcode != -12907 THEN RAISE;
    END IF;
END;
/

-- UNDOTBS2 as bigfile
BEGIN
  EXECUTE IMMEDIATE
    'create bigfile undo tablespace UNDOTBS2 datafile
       size 10G autoextend on next 1G maxsize 500G';
EXCEPTION
  WHEN OTHERS THEN
    IF sqlcode != -1543 THEN RAISE;
    END IF;
END;
/

alter system set undo_tablespace = UNDOTBS2;
