create FUNCTION ShellCmd (ptxt_cmd IN VARCHAR2) RETURN NUMBER IS
        LANGUAGE JAVA
NAME 'oscmd.plrunCommand(java.lang.String[]) return int';

