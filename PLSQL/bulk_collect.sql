When querying multiple rows of data from Oracle, don't use the cursor FOR loop. Instead, assuming you are running at least Oracle8i, start using the wonderful, amazing BULK COLLECT query, which improves query response time very dramatically. The following statement, for example, retrieves all the rows in the employee table and deposits them directly into a collection of records:

DECLARE
   TYPE employee_aat IS TABLE OF employee%ROWTYPE
      INDEX BY BINARY_INTEGER;
   l_employees employee_aat;
BEGIN  
   SELECT *    
      BULK COLLECT INTO l_employees    
      FROM employee;
END;

Of course, if your table has 1,000,000 rows in it, the above block of code will consume enormous amounts of memory. In this case, you will want to take advantage of the LIMIT clause of BULK COLLECT as follows:

DECLARE   
  TYPE employee_aat IS TABLE OF employee%ROWTYPE
      INDEX BY BINARY_INTEGER;
     
  l_employees employee_aat;
 
  CURSOR employees_cur IS SELECT * FROM employee;
BEGIN
    OPEN employees_cur;
    LOOP
        FETCH employees_cur
         BULK COLLECT INTO l_employees LIMIT 100;
        EXIT WHEN l_employees.COUNT = 0;
       
        -- Process these 100 rows and then
       
        -- move on to next 100.
    END LOOP;
END;

Important! When you use BULK COLLECT, Oracle will not raise NO_DATA_FOUND even if no rows are found by the implicit query. Also, within the loop (using LIMIT), you cannot rely on cursor%FOUND to determine if the last fetch returned any rows. Instead, check the contents of the collection. If empty, then you are done.