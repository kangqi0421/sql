--
-- UNDO TEMP
--

-- Add USER_TEMP
BEGIN
  EXECUTE IMMEDIATE
    'create temporary tablespace USER_TEMP tempfile
      size 1G autoextend on next 1G maxsize 63G,
      size 1G autoextend on next 1G maxsize 63G,
      size 1G autoextend on next 1G maxsize 63G,
      size 1G autoextend on next 1G maxsize 63G,
      size 1G autoextend on next 1G maxsize 63G,
      size 1G autoextend on next 1G maxsize 63G,
      size 1G autoextend on next 1G maxsize 63G,
      size 1G autoextend on next 1G maxsize 63G,
      size 1G autoextend on next 1G maxsize 63G,
      size 1G autoextend on next 1G maxsize 63G,
      size 1G autoextend on next 1G maxsize 63G,
      size 1G autoextend on next 1G maxsize 63G,
      size 1G autoextend on next 1G maxsize 63G';
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
