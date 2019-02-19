WITH
    FUNCTION get_number RETURN NUMBER IS
    BEGIN
        RETURN 12345;
    END;

SELECT employee_id, first_name, last_name, get_number()
FROM hr.employees;
