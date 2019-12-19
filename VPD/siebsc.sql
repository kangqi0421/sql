-------------------------------------------------------------------------------------------------------
-- CELY INSTALACNI SCRIPT SPUSTIT JAKO SIEBSC
-------------------------------------------------------------------------------------------------------

-- Tento script instaluje funkcnost, ktera znemozni beznym uzivatelum videt v tabulce systemovych preferenci SIEBEL.S_SYS_PREF
--    heslo, ktere je zde ulozeno v otevrene podobe.
-- Script vytvari jednu pomocnou funkci siebsc.crm_predicate, ktera je pouzivana Oracle politikou CRM_PLAIN_PSWD_POLICY
--    postavenou nad tabulkou systemovych preferenci SIEBEL.S_SYS_PREF.  
-- Predikatni funkce je ukozena ve schematu SIEBSC. Toto schema je zamcene, neda se do nej prihlasit a bylo jiz drive
--    zvoleno pro ukladani systemovych funkcnosti (napr. CX_USER_TRACK)

-- pomocne objekty pouzite pri ladeni funkcnosti
-- create table siebel.rsv_log (seq_num number, datum date, text varchar2(100));
-- grant all on siebel.rsv_log to sse_role;
-- grant all on siebel.rsv_log to siebsc;
-- create sequence siebel.rs_seq;
-- grant select on siebel.rs_seq to sse_role, siebsc;
------------------------------
-- drop sequence siebel.rs_seq;
-- drop table  siebel.rsv_log;


-- vytvoreni funkce pro tvorbu dynamickych predikatu
-- tyto predikaty znemozni jakemukoliv uzivateli z jakehokoliv prostredi videt radek s heslem uzivatele SIEBSA
-- uzivatel SIEBSA uvidi svoje heslo kdyz jde z aplikacniho GUI (z ad-hoc nastroju jako odbcsql, SQL*Plus ho nevidi)
-- SA LoginName se nesmi odfiltrovat protoze je na mnoha mistech volana ze SQL kodu pomoci LookupSystemPreference
-- 'CSAS Enable User Tracking', 'CSAS RT User' se nesmi odfiltrovat, protoze je kontrolovano v GUI pri prihlaseni
CREATE OR REPLACE FUNCTION siebsc.crm_predicate(schema_name in varchar2,object_name in varchar2) RETURN varchar2
IS
  lv_predicate varchar2(1000):='';
  counter NUMBER;
--  exc_code NUMBER;  -- pouze pro ladici ucely
--  PRAGMA AUTONOMOUS_TRANSACTION;  -- pouze pro ladici ucely 
BEGIN

  -- zkontroluj, jestli bezi vubec nejaky AOM (jestli bezi site)
  SELECT COUNT(*)
    INTO counter
    FROM SYS.V_$SESSION
    WHERE program LIKE 'siebmtshmw%';   -- siebmtshmw% predstavuje interaktivni multithreaded OM based komponenty (WF Proc Managery, GUI procesy)

  IF counter>0 THEN  -- site bezi a ma vyznam resit pripojeni pres GUI nebo CSAS Operation WF Process Manager

    -- implicitne je zakazano videt heslo na SIEBSA pro vsechny uzivatele autentizovane jinak nez SIEBSA a SADMIN
    IF SYS_CONTEXT('USERENV', 'SESSION_USER')<>'SIEBSA' AND SYS_CONTEXT('USERENV', 'SESSION_USER')<>'SADMIN' 
    THEN
      lv_predicate:='sys_pref_cd NOT IN (''SA Password'')';
    
    ELSE   -- cast pro uzivatele SIEBSA+SADMIN: umozneni procesum GUI Siebelu (resp. vsem procesum siebmtshmw, tzn. interaktivnim a batchovym
           --     komponentam ktere jsou multithreaded a object manager based) videt danou preferenci
           -- tato cast je pripravena tak, aby umoznila videt systemovou preferenci i v pripade, ze by se AOM zmigrovaly na Windows
           -- resi se zde pro AT a PROD prostredi, ze pro uzivatele SADMIN mohou systemovou preferenci videt pouze siebmtshmw% procesy bezici na
           --    stejnem serveru, jako siebproc (tedy workflow policy) - pro SIEBSA uzivatele mohou syst.pref. videt vsechny siebmtshmw procesy
           --    z jakehokoliv serveru

      -- zjisti, zda je aktualni proces nasledujicim procesem master procesu FINS AOM a/nebo WF Proc Managera - rozlisuj SIEBSA a SADMIN
      -- rozliseni SIEBSA a SADMIN je zde kvuli PROD+AT prostredi protoze na ostatnich jednoserverovych neni mozne rozlisit, jestli se SADMIN
      --     hlasi pod GUI a nebo z CSAS Operation WF Proc Managera - proto se v techto prostredich zobrazi heslo i SADMINovi
      IF SYS_CONTEXT('USERENV', 'SESSION_USER')='SIEBSA' THEN
        SELECT COUNT(*)
        INTO counter 
        FROM siebsc.vsession s,
          (SELECT decode(instr(process,':'),'0',process,substr(process,1,instr(process,':')-1)) c_procesu, -- dekodovani cisla procesu bez threadu
                  logon_time, machine 
           FROM SYS.V_$SESSION
           WHERE program LIKE 'siebmtshmw%'      -- vsechny OM based a multithreaded interactive proces maji pravo videt heslo SIEBSA v S_SYS_PREF
          ) ss
        WHERE s.process in ss.c_procesu
        AND s.logon_time>ss.logon_time;
      ELSIF SYS_CONTEXT('USERENV', 'SESSION_USER')='SADMIN' THEN
        SELECT COUNT(*)
        INTO counter
        FROM siebsc.vsession s,
          (SELECT decode(instr(process,':'),'0',process,substr(process,1,instr(process,':')-1)) c_procesu, -- dekodovani cisla procesu bez threadu 
                  logon_time, machine 
           FROM SYS.V_$SESSION
           WHERE program LIKE 'siebmtshmw%'     -- pouze Operation WFPM ma pravo videt heslo v tabulce systemovych preferenci
           AND machine IN (SELECT distinct machine FROM SYS.V_$SESSION WHERE program LIKE 'siebproc@%')
          ) ss
        WHERE s.process in ss.c_procesu
        AND s.logon_time<>ss.logon_time;
      END IF;
      
      -- pokud je counter >=1 tak se jedna o:
      --           - nasledny proces master GUI a/nebo CSAS Operation WF Proc Mgr (pro uzivatele SIEBSA)
      --           - pouze nasledny proces master CSAS Operation WF Proc Mgr (pro uzivatele SADMIN)
      IF counter>=1 THEN
        -- zkontroluj, zda proces bezi pod spravnym uzivatelem a zda to neni prejmenovane SQL*Plus
        IF (SYS_CONTEXT('USERENV', 'OS_USER')='siebadm'                  -- uzivatel na unixu 
            OR UPPER(SYS_CONTEXT('USERENV', 'OS_USER')) LIKE 'SXA%'      -- uzivatel na Windows (kazdy Win host vraci jina pismena -> proto UPPER)
            OR UPPER(SYS_CONTEXT('USERENV', 'OS_USER'))='ADMINISTRATOR'  -- uzivatel na Windows
           )
           AND SYS_CONTEXT('USERENV', 'MODULE')<>'SQL*Plus'
        THEN    -- proces je skutecne CSAS Operation WF Proc Mgr a/nebo GUI (podle toho jaky select se vyse spustil) 
          lv_predicate:='';
        ELSE    -- proces je sice siebmtshmw, ale nesedi uzivatel nebo je to prejmenovane SQL*Plus - nezobraz heslo
          lv_predicate:='sys_pref_cd NOT IN (''SA Password'')';
        END IF;
        
      ELSE   -- IF counter>=1 - nevysla podminka, ze proces je naslednym procesem Oper WF Proc Mgr a/nebo GUI - muze se jednat o testy, kde master
             -- proces jiz vytimeoutoval - proved overeni jestli je tomu tak
        -- zjisti, zda se jedna o siebmtshmw% proces
        SELECT COUNT(*)
          INTO counter 
          FROM siebsc.vsession
          WHERE program LIKE 'siebmtshmw%';

        -- zkontroluj, zda proces bezi pod spravnym uzivatelem a zda to neni prejmenovane SQL*Plus
        IF (SYS_CONTEXT('USERENV', 'OS_USER')='siebadm'                  -- uzivatel na unixu 
            OR UPPER(SYS_CONTEXT('USERENV', 'OS_USER')) LIKE 'SXA%'      -- uzivatel na Windows (kazdy Win host vraci jina pismena -> proto UPPER)
            OR UPPER(SYS_CONTEXT('USERENV', 'OS_USER'))='ADMINISTRATOR'  -- uzivatel na Windows
           )
           AND SYS_CONTEXT('USERENV', 'MODULE')<>'SQL*Plus'              -- neni to prejmenovane SQL*Plus
           AND counter=1                                                 -- nazev procesu je siebmtshmw%
        THEN    -- proces neni naslednym procesem ale uzivatel OS je spravny - testuj dale 
          -- udelatko pro jednoserverova prostredi (train, dev, test,...)
          -- z duvodu maleho poctu uzivatelu se muze stat, ze master proces GUI a/nebo CSAS Oper WF Proc Mgr se jiz od databaze diky timeoutu 
          --      odpojil a aktualni session (ktera testuje zda je naslednym procesem tohoto master procesu) je jedinou session s danym PID
          -- V takovem pripade by se heslo v teto session nezobrazilo a v testu/devu/trainu/... by nekdy nebylo mozne heslo pres aplikaci zmenit.
          -- Proto pro zachovani konzistentniho look and feel s produkci se zde pocita pocet serveru v enterprise a pokud je pocet serveru
          --   kde bezi siebmtshmw (tedy Object Manager based a multithreaded komponenta) mensi nez 4, tak se heslo zobrazi v kazdem pripade
          --   protoze GUI procesy bezi na stejnem serveru jako CSAS Oper WF Proc Mgr  
          SELECT COUNT(distinct machine)
            INTO counter
            FROM SYS.V_$SESSION
            WHERE program LIKE 'siebmtshmw%'   -- siebmtshmw% kontroluje interaktivni multithreaded OM based komponenty 
          ;
          IF counter>=4 THEN  -- jedna se o produkci nebo AT a proto se heslo skutecne nezobrazi protoze se potvrdilo, ze je to podvrzena session
            lv_predicate:='sys_pref_cd NOT IN (''SA Password'')';
          ELSE  -- jedna se o jednoserverove neprodukcni prostredi a proto se heslo zobrazi, i kdyz se nevyhovelo podmince
            lv_predicate:='';
          END IF;
        ELSE   -- nesedi ani uzivatel operacniho systemu nebo je to SQL*Plus prejmenovany na siebmtshmw - heslo nezobraz  
          lv_predicate:='sys_pref_cd NOT IN (''SA Password'')';
        END IF;
      END IF;   -- IF counter>=1

    END IF;  -- konec ELSE pro uzivatele SIEBSA

  ELSE    -- ELSE pokud nebezi site (nebezi zadny proces siebmthmw%)
    -- site nebezi a systemovou preferenci neni mozne/relevantni videt/zmenit (protoze se musi zmenit pres aplikaci, aby to bylo auditovane)
    lv_predicate:='sys_pref_cd NOT IN (''SA Password'')';
  END IF;

  RETURN lv_predicate;

EXCEPTION
  WHEN OTHERS THEN   -- exception zajisti, ze v pripade chyby funkce heslo nebude viditelne
    lv_predicate:='sys_pref_cd NOT IN (''SA Password'')';
    RETURN lv_predicate;

END;   -- FUNCTION siebsc.crm_predicate
/
-- drop function siebsc.crm_predicate;




