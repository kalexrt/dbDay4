CREATE TABLE employeeRecords (
	id SERIAL,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Sex CHAR(1),
    DOJ DATE,
    CurrentDate DATE,
    Designation VARCHAR(100),
    Age INT,
    Salary DECIMAL(10, 2),
    Unit VARCHAR(100),
    LeavesUsed INT,
    LeavesRemaining INT,
    Ratings DECIMAL(3, 2),
    PastExperience INT
);

COPY employeeRecords(FirstName, LastName, Sex, DOJ, CurrentDate, Designation, Age, Salary, Unit, LeavesUsed, LeavesRemaining, Ratings, PastExperience)
FROM 'E:/lf_data/data_pro.csv'
DELIMITER ','
CSV HEADER;

-- Common Table Expressions (CTEs):
-- Question 1: Calculate the average salary by department for all Analysts.
With analyst_salary AS (
	SELECT e.unit, e.salary
	FROM employeeRecords e
	WHERE e.designation = 'Analyst'
)
SELECT d.unit, ROUND(AVG(d.salary)) AS avg_salary
FROM analyst_salary d
GROUP BY d.unit

-- Question 2: List all employees who have used more than 10 leaves.
WITH leaver AS(
	SELECT e.firstname, e.lastname, e.leavesused
	FROM employeeRecords e
	WHERE e.leavesused > 10
)
SELECT * 
FROM leaver

-- Views:
-- Question 3: Create a view to show the details of all Senior Analysts.
CREATE VIEW senior_analyst AS
	SELECT * 
	FROM employeeRecords e
	WHERE e.designation = 'Senior Analyst'

-- Materialized Views:
-- Question 4: Create a materialized view to store the count of employees by department.
CREATE MATERIALIZED VIEW employee_count_by_department AS
	SELECT e.unit AS Department, COUNT(e.id)
	FROM employeeRecords e
	GROUP BY Department
	
-- Procedures (Stored Procedures):
-- Question 6: Create a procedure to update an employee's salary by their first name and last name.
CREATE OR REPLACE PROCEDURE update_employee_salary(
	fname VARCHAR(50),
	lname VARCHAR(50),
	new_salary DECIMAL(10,2))
LANGUAGE plpgsql
AS $$
BEGIN 
	UPDATE employeeRecords 
	SET salary = new_salary
	WHERE firstname = fname AND lastname = lname;
END;
$$;

--call the procedure 
CALL update_employee_salary('TOMASA','ARMEN',10);

--check the updated table
SELECT firstname, lastname, salary
FROM employeeRecords 
ORDER BY id

-- Question 7: Create a procedure to calculate the total number of leaves used across all departments.
CREATE OR REPLACE PROCEDURE total_leaves()
LANGUAGE plpgsql
AS $$
BEGIN
	CREATE OR REPLACE VIEW total_leaves AS 
		SELECT SUM(leavesused)
		FROM employeeRecords;
END;
$$;

--call the procedure
CALL total_leaves()

--display results
SELECT * 
FROM total_leaves