CREATE OR REPLACE PACKAGE MW.Service_Partition is

  /*
   * Package pro administraci partitions tabulek LOG_MW_MSG, LOG_MW_OUTPUT.
   * Tabulky jsou partitionovane podle datumoveho atributu,
   * pro kazdy den existuje prave jedna partition.
   *
   * Procedura cr_new(table_name, pocet_dnu) pridava partitions
   * od sysdate dopredu na pocet dni dany vstupnim parametrem
   *  - pokud dana partition neexistuje.
   *
   * Procedura dr_old(table_name, pocet_dnu) maze partitions
   * od (sysdate - hodnota vstupniho parametru) dozadu.
   */

  c_part_prefix      constant  varchar2(5)  := 'D';
  c_part_name_mask   constant  varchar2(8)  := 'YYYYMMDD';
  c_part_value_mask  constant  varchar2(21) := 'DD.MM.YYYY HH24:MI:SS';
  c_pocet_dnu_vpred  constant  integer := 7;
  c_pocet_dnu_vzad   constant  integer := 31;


  procedure Cr_New(
    p_table_name in varchar2,
    P_pocet_dnu  in integer := null
  );

  procedure Dr_Old(
    p_table_name in varchar2,
    P_pocet_dnu  in integer := null
  );

end Service_Partition;
/


CREATE OR REPLACE PACKAGE BODY MW.Service_Partition is

  ex_appl_error  exception;
  PRAGMA         EXCEPTION_INIT(ex_appl_error, -20001);


  /**
   * Funkce vraci jmeno vlastnika tabulky z dictionary objektu ALL_TABLES.
   * Chybi dodelat reseni chybovych stavu.
   */
  function Get_Table_Owner (p_table_name in varchar2)
  return varchar2 is

    cursor cu_tab_owner (cp_table_name varchar2) is
      select
        owner  owner
      from
        all_tables 
      where
        table_name = upper(cp_table_name);

    lv_table_owner  varchar2(64);

  begin
    for cur_owner_row in cu_tab_owner(p_table_name) loop
      lv_table_owner := cur_owner_row.owner;
    end loop;
    return (lv_table_owner);
  end Get_Table_Owner;


  /**
   * Vstupni parametry : jmeno tabulky, pocet dnu (muze byt null).
   *   pokud je pocet dnu null, pouzije se default hodnota dana konstantou
   *   teto package (c_pocet_dnu_vpred).
   * Procedura zjisti vlastnika tabulky, po dnech prochazi interval od SYSDATE po
   *   SYSDATE + pocet dnu, podle konvenci konstruuje jmeno partition,
   *   v dictionary (ALL_TAB_PARTITIONS) zjistuje zda pro
   *   danou tabulku, vlastnika a vytvorene jmeno existuje partition. Pokud
   *   neexistuje spusti ATER TABLE ADD PARTITION prikaz.
   */
  procedure Cr_New(
    p_table_name in varchar2,
    P_pocet_dnu  in integer := null
  ) is

    cursor cu_table_part (
      cp_table_owner  varchar2,
      cp_table_name   varchar2,
      cp_part_name    varchar2
      ) is
      select
        'X'  test
      from
        all_tab_partitions  atp
      where
        atp.table_owner = cp_table_owner and
        atp.table_name = cp_table_name and
        atp.partition_name = cp_part_name;

    lv_table_name      varchar2(64);
    lv_table_owner     varchar2(64);
    lv_pocet_dnu       integer;
    lv_part_name       varchar2(32);
    lv_part_notexists  boolean;
    lv_sql_str         varchar2(255);
    lv_tmp_str         varchar2(255);
    lv_tmp_datstr      varchar2(21);

  begin
dbms_output.put_line('CREATING PARTITION: ' || p_table_name || ' - START: ' || to_char(sysdate));

    lv_table_name := upper(p_table_name);
    lv_pocet_dnu := p_pocet_dnu;
    if (p_pocet_dnu is null) then
      lv_pocet_dnu := c_pocet_dnu_vpred;
    end if;

    lv_table_owner := Get_Table_Owner(p_table_name);

    for lv_i in 0..lv_pocet_dnu loop
      lv_part_notexists := false;
      lv_part_name := c_part_prefix || to_char(sysdate + lv_i, c_part_name_mask);
      open cu_table_part(lv_table_owner, lv_table_name, lv_part_name);
      fetch cu_table_part into lv_tmp_str;
      if (cu_table_part%notfound) then
        lv_part_notexists := true;
      end if;
      close cu_table_part;
      if (lv_part_notexists) then
        lv_tmp_datstr := to_char(trunc(sysdate) + lv_i + 1, c_part_value_mask);
        lv_sql_str := 'ALTER TABLE ' ||
                      lv_table_owner || '.' || lv_table_name || ' ' ||
                      'ADD PARTITION ' || lv_part_name || ' ' ||
                      'VALUES LESS THAN (TO_DATE(' || '''' ||
                      lv_tmp_datstr || '''' || ',' || '''' || c_part_value_mask ||
                      '''' || ',' || '''' || 'NLS_CALENDAR=GREGORIAN' || '''' ||
                      '))';
dbms_output.put_line(lv_sql_str);
        execute immediate lv_sql_str;
      end if;
    end loop;

dbms_output.put_line('CREATING PARTITION: ' || p_table_name || ' - SUCCESSFUL: ' || to_char(sysdate));
  exception
    when ex_appl_error then
      dbms_output.put_line('Application Error: ' || sqlerrm);
    when others then
      dbms_output.put_line(sqlerrm);
  end Cr_New;


  /**
   * Vstupni parametry : jmeno tabulky, pocet dnu (muze byt null).
   *   pokud je pocet dnu null, pouzije se default hodnota dana konstantou
   *   teto package (c_pocet_dnu_vzad).
   * Procedura zjisti vlastnika tabulky, zkonstruuje jmeno nejstarsi ponechavane
   *   partition a s vyuzitim toho, ze konvence jmena partition umoznuje
   *   prorovnavani podle data, prochazi dictionary (ALL_TAB_PARTITIONS) a dotahuje
   *   partitions starsi, nez vytvorena mez - poradi dotahovani je nejstarsi
   *   nejdrive. Tyto partitions maze prikazem ATER TABLE DROP PARTITION.
   */
  procedure Dr_Old(
    p_table_name in varchar2,
    P_pocet_dnu  in integer := null
  ) is

    cursor cu_table_part (
      cp_table_owner  varchar2,
      cp_table_name   varchar2,
      cp_mez          varchar2
      ) is
      select
        atp.partition_name  partition_name
      from
        all_tab_partitions  atp
      where
        atp.table_owner = cp_table_owner and
        atp.table_name = cp_table_name and
        atp.partition_name < cp_mez
      order by
        atp.partition_name desc;

    lv_table_name      varchar2(64);
    lv_table_owner     varchar2(64);
    lv_pocet_dnu       integer;
    lv_part_name       varchar2(32);
    lv_part_name_tmp   varchar2(32);
    lv_sql_str         varchar2(255);

  begin
dbms_output.put_line('DROPING PARTITION: ' || p_table_name || ' - START: ' || to_char(sysdate));

    lv_table_name := upper(p_table_name);
    lv_pocet_dnu := p_pocet_dnu;
    if (p_pocet_dnu is null) then
      lv_pocet_dnu := c_pocet_dnu_vzad;
    end if;

    lv_table_owner := Get_Table_Owner(p_table_name);
    lv_part_name := c_part_prefix || to_char(sysdate - lv_pocet_dnu, c_part_name_mask);

    for cur_table_part in cu_table_part(
                            lv_table_owner,
                            lv_table_name,
                            lv_part_name
                          ) loop
      lv_part_name_tmp := cur_table_part.partition_name;
      lv_sql_str := 'ALTER TABLE ' ||
                    lv_table_owner || '.' || lv_table_name || ' ' ||
                    'DROP PARTITION ' || lv_part_name_tmp;
dbms_output.put_line(lv_sql_str);
      execute immediate lv_sql_str;
    end loop;

dbms_output.put_line('DROPING PARTITION: ' || p_table_name || ' - SUCCESSFUL: ' || to_char(sysdate));
  exception
    when ex_appl_error then
      dbms_output.put_line('Application Error: ' || sqlerrm);
    when others then
      dbms_output.put_line(sqlerrm);
  end Dr_Old;


end Service_Partition;
/


