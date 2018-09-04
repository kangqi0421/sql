--
-- UNDO TEMP
--

-- Add USER_TEMP
BEGIN
  EXECUTE IMMEDIATE
    'create bigfile temporary tablespace USER_TEMP
       tempfile size 10G autoextend on next 1G maxsize 600G';
EXCEPTION
  WHEN OTHERS THEN
    IF sqlcode != -1543 THEN RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE
    'alter database default temporary tablespace USER_TEMP';
EXCEPTION
  WHEN OTHERS THEN
    IF sqlcode != -12907 THEN RAISE;
    END IF;
END;
/

-- App TEMP tablespace
BEGIN
  EXECUTE IMMEDIATE
    'drop tablespace TEMP';
EXCEPTION
  WHEN OTHERS THEN
    IF sqlcode != -959 THEN RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE
    'create bigfile temporary tablespace TEMP
       tempfile size 10G autoextend on next 1G maxsize 600G';
EXCEPTION
  WHEN OTHERS THEN
    IF sqlcode != -1543 THEN RAISE;
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
