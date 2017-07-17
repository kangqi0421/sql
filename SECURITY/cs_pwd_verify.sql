CREATE OR REPLACE FUNCTION cs_pwd_verify  
(username varchar2, 
   password varchar2, 
   old_password varchar2) 
   RETURN boolean IS  
   n boolean; 
   m integer; 
   differ integer; 
   isdigit boolean; 
   ischar  boolean; 
   ispunct boolean; 
   digitarray varchar2(20); 
   punctarray varchar2(25); 
   chararray varchar2(52); 

BEGIN  
   digitarray:= '0123456789'; 
   chararray:= 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'; 

--Check if the password is same as the username 
IF password = username THEN 
   raise_application_error(-20001, 'Password same as user'); 
END IF; 

--Check for the minimum length of the password 
IF length(password) < 8 THEN 
   raise_application_error(-20002, 'Password length less than 8'); 
END IF; 

--Check if the password contains at least one letter and one digit.
--1. Check for the digit 
--You may delete 1. and replace with 2. or 3.
isdigit:=FALSE; 
m := length(password); 
FOR i IN 1..10 LOOP  
  FOR j IN 1..m LOOP  
    IF substr(password,j,1) = substr(digitarray,i,1) THEN 
      isdigit:=TRUE; 
        GOTO findchar; 
    END IF; 
   END LOOP; 
END LOOP; 
IF isdigit = FALSE THEN 
  raise_application_error(-20003, 'Password should contain at least one digit and one character');
END IF; 
--2. Check for the character 

<<findchar>> 
ischar:=FALSE; 
FOR i IN 1..length(chararray) LOOP  
  FOR j IN 1..m LOOP  
    IF substr(password,j,1) = substr(chararray,i,1) THEN 
       ischar:=TRUE; 
         GOTO endsearch; 
       END IF; 
    END LOOP; 
END LOOP; 
IF ischar = FALSE THEN 
  raise_application_error(-20003, 'Password should contain at least one digit and one character');
END IF; 

<<endsearch>> 
--Check if the password differs from the previous password by at least 2 letters 
IF old_password = '' THEN 
  raise_application_error(-20004, 'Old password is null');
END IF; 
--Everything is fine; return TRUE ;    
differ := length(old_password) - length(password); 
IF abs(differ) < 2 THEN 
  IF length(password) < length(old_password) THEN 
    m := length(password); 
  ELSE 
    m:= length(old_password); 
  END IF; 
  differ := abs(differ); 
  FOR i IN 1..m LOOP 
    IF substr(password,i,1) != substr(old_password,i,1) THEN 
             differ := differ + 1; 
    END IF; 
  END LOOP; 
  IF differ < 2 THEN 
    raise_application_error(-20004, 'Password should differ by at least 2 characters');
    END IF; 
  END IF; 
--Everything is fine; return TRUE ;    
  RETURN(TRUE); 
END; 
/
