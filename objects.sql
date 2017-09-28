USE employees;

DELIMITER //
DROP FUNCTION IF EXISTS emp_dept_id //
DROP FUNCTION IF EXISTS emp_dept_name //
DROP FUNCTION IF EXISTS emp_name //
DROP FUNCTION IF EXISTS current_manager //
DROP PROCEDURE IF EXISTS show_departments //

--
-- returns the department id of a given employee
--
CREATE FUNCTION emp_dept_id(employee_id INT)
  RETURNS CHAR(4)
READS SQL DATA
  BEGIN
    DECLARE max_date DATE;
    SET max_date = (
      SELECT max(from_date)
      FROM
        dept_emp
      WHERE
        emp_no = employee_id
    );
    SET @max_date = max_date;
    RETURN (
      SELECT dept_no
      FROM
        dept_emp
      WHERE
        emp_no = employee_id
        AND
        from_date = max_date
      LIMIT 1
    );
  END //

--
-- returns the department name of a given employee
--

CREATE FUNCTION emp_dept_name(employee_id INT)
  RETURNS VARCHAR(40)
READS SQL DATA
  BEGIN
    RETURN (
      SELECT dept_name
      FROM
        departments
      WHERE
        dept_no = emp_dept_id(employee_id)
    );
  END//

--
-- returns the employee name of a given employee id
--
CREATE FUNCTION emp_name(employee_id INT)
  RETURNS VARCHAR(32)
READS SQL DATA
  BEGIN
    RETURN (
      SELECT concat(first_name, ' ', last_name) AS name
      FROM
        employees
      WHERE
        emp_no = employee_id
    );
  END//

--
-- returns the manager of a department
-- choosing the most recent one
-- from the manager list
--
CREATE FUNCTION current_manager(dept_id CHAR(4))
  RETURNS VARCHAR(32)
READS SQL DATA
  BEGIN
    DECLARE max_date DATE;
    SET max_date = (
      SELECT max(from_date)
      FROM
        dept_manager
      WHERE
        dept_no = dept_id
    );
    SET @max_date = max_date;
    RETURN (
      SELECT emp_name(emp_no)
      FROM
        dept_manager
      WHERE
        dept_no = dept_id
        AND
        from_date = max_date
      LIMIT 1
    );
  END //

DELIMITER ;

--
--  selects the employee records with the
--  latest department
--

CREATE OR REPLACE VIEW v_full_employees
AS
  SELECT
    emp_no,
    first_name,
    last_name,
    birth_date,
    gender,
    hire_date,
    emp_dept_name(emp_no) AS department
  FROM
    employees;

--
-- selects the department list with manager names
--

CREATE OR REPLACE VIEW v_full_departments
AS
  SELECT
    dept_no,
    dept_name,
    current_manager(dept_no) AS manager
  FROM
    departments;

DELIMITER //

--
-- shows the departments with the number of employees
-- per department
--
CREATE PROCEDURE show_departments()
MODIFIES SQL DATA
  BEGIN
    DROP TABLE IF EXISTS department_max_date;
    DROP TABLE IF EXISTS department_people;
    CREATE TEMPORARY TABLE department_max_date
    (
      emp_no         INT  NOT NULL PRIMARY KEY,
      dept_from_date DATE NOT NULL,
      dept_to_date   DATE NOT NULL, # bug#320513
      KEY (dept_from_date, dept_to_date)
    );
    INSERT INTO department_max_date
      SELECT
        emp_no,
        max(from_date),
        max(to_date)
      FROM
        dept_emp
      GROUP BY
        emp_no;

    CREATE TEMPORARY TABLE department_people
    (
      emp_no  INT     NOT NULL,
      dept_no CHAR(4) NOT NULL,
      PRIMARY KEY (emp_no, dept_no)
    );

    INSERT INTO department_people
      SELECT
        dmd.emp_no,
        dept_no
      FROM
        department_max_date dmd
        INNER JOIN dept_emp de
          ON dmd.dept_from_date = de.from_date
             AND dmd.dept_to_date = de.to_date
             AND dmd.emp_no = de.emp_no;
    SELECT
      dept_no,
      dept_name,
      manager,
      count(*)
    FROM v_full_departments
      INNER JOIN department_people USING (dept_no)
    GROUP BY dept_no;
    # with rollup;
    DROP TABLE department_max_date;
    DROP TABLE department_people;
  END //

DROP FUNCTION IF EXISTS employees_usage //
DROP PROCEDURE IF EXISTS employees_help //

CREATE FUNCTION employees_usage()
  RETURNS TEXT
DETERMINISTIC
  BEGIN
    RETURN
    '
        == USAGE ==
        ====================
    
        PROCEDURE show_departments()
    
            shows the departments with the manager and
            number of employees per department
    
        FUNCTION current_manager (dept_id)
    
            Shows who is the manager of a given departmennt
    
        FUNCTION emp_name (emp_id)
    
            Shows name and surname of a given employee
    
        FUNCTION emp_dept_id (emp_id)
    
            Shows the current department of given employee
    ';
  END //

CREATE PROCEDURE employees_help()
DETERMINISTIC
  BEGIN
    SELECT employees_usage() AS info;
  END//

DELIMITER ;

