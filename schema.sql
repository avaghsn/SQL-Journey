-- *********************** Creating Tables *********************** --

CREATE TABLE employee (
	emp_id INT PRIMARY KEY,
	first_name VARCHAR(10),
	last_name VARCHAR(10),
	birthday DATE,
	gender VARCHAR(1),
	salary FLOAT,
	super_id INT, -- foreign key pointing to another employee
	branch_id INT -- foreign key pointing to the branch table
);

CREATE TABLE branch (
  branch_id INT PRIMARY KEY,
  branch_name VARCHAR(40),
  mgr_id INT,
  mgr_start_date DATE,
  FOREIGN KEY(mgr_id) REFERENCES employee(emp_id) ON DELETE SET NULL
);

CREATE TABLE client (
  client_id INT PRIMARY KEY,
  client_name VARCHAR(40),
  branch_id INT,
  FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE SET NULL
);

CREATE TABLE works_with (
  emp_id INT,
  client_id INT,
  total_sales INT,
  PRIMARY KEY(emp_id, client_id), -- composite key
  FOREIGN KEY(emp_id) REFERENCES employee(emp_id) ON DELETE CASCADE,
  FOREIGN KEY(client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

CREATE TABLE branch_supplier (
  branch_id INT,
  supplier_name VARCHAR(40),
  supply_type VARCHAR(40),
  PRIMARY KEY(branch_id, supplier_name),
  FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE CASCADE
);

-- *********************** INSERTING FOREIGN KEYS *********************** --

ALTER TABLE employee
ADD FOREIGN KEY(branch_id)
REFERENCES branch(branch_id)
ON DELETE SET NULL;

ALTER TABLE employee
ADD FOREIGN KEY(super_id)
REFERENCES employee(emp_id)
ON DELETE SET NULL;

-- *********************** PRINTING TABLES *********************** --

SELECT * FROM employee;
SELECT * FROM branch;
SELECT * FROM client;
SELECT * FROM works_with;
SELECT * FROM branch_supplier;

-- *********************** INSERTING VALUES *********************** --

INSERT INTO employee VALUES 
(100, 'David', 'Wallace', '1967-11-17', 'M', 250000, NULL, NULL ),
(101, 'Jan','Levinson', '1961-05-11', 'F', 110000, NULL, NULL ),
(102, 'Michael', 'Scott', '1964-03-15', 'M', 75000, NULL, NULL ),
(103, 'Angela', 'Martin', '1971-06-25', 'F', 63000, NULL, NULL ),
(104, 'Kelly', 'Kapoor', '1980-02-05', 'F', 55000, NULL, NULL ),
(105, 'Stanley', 'Hudson', '1958-02-19', 'M', 69000, NULL, NULL ),
(106, 'Josh', 'Porter', '1969-09-05', 'M', 78000, NULL, NULL ),
(107, 'Andy', 'Bernard', '1973-07-22', 'M', 65000, NULL, NULL ),
(108, 'Jim', 'Halpert', '1978-10-01', 'M', 71000, NULL, NULL );

INSERT INTO branch VALUES 
(1, 'Corporate', 100, '2006-02-09'),
(2, 'Scranton', 102, '1992-04-06'),
(3, 'Stamford', 106, '1998-02-13');

INSERT INTO client VALUES
(400, 'Dunmore Highschool', 2),
(401, 'Lackawana Country', 2),
(402, 'FedEx', 3),
(403, 'John Daly Law, LLC', 3),
(404, 'Scranton Whitepages', 2),
(405, 'Times Newspaper', 3),
(406, 'FedEx', 2);

INSERT INTO works_with VALUES
(105, 400, 55000),
(102, 401, 267000),
(108, 402, 22500),
(107, 403, 5000),
(108, 403, 12000),
(105, 404, 33000),
(107, 405, 26000),
(102, 406, 15000),
(105, 406, 130000);

INSERT INTO branch_supplier VALUES
(2, 'Hammer Mill', 'Paper'),
(2, 'Uni-ball', 'Writing Utensils'),
(3, 'Patriot Paper', 'Paper'),
(2, 'J.T. Forms & Labels', 'Custom Forms'),
(3, 'Uni-ball', 'Writing Utensils'),
(3, 'Hammer Mill', 'Paper'),
(3, 'Stamford Lables', 'Custom Forms');

-- *********************** UPDATING TABLES *********************** --

UPDATE employee
SET branch_id = 1
WHERE emp_id = 100;

UPDATE employee
SET branch_id = 2
WHERE emp_id = 102;

UPDATE employee
SET branch_id = 3
WHERE emp_id = 106;

-- *********************** SELECTING COLUMNS *********************** --

SELECT * FROM employee ORDER BY salary DESC;
SELECT * FROM employee LIMIT 5;

SELECT first_name,last_name FROM employee;
SELECT first_name AS forename, last_name AS surname FROM employee;
SELECT DISTINCT gender FROM employee;

SELECT COUNT(emp_id) FROM employee;
SELECT COUNT(emp_id) FROM employee WHERE gender = 'F' AND birthday > '1970-01-01';

SELECT AVG(salary) FROM employee;
SELECT SUM(salary) FROM employee;

SELECT COUNT(gender), gender FROM employee GROUP BY gender;
SELECT SUM(total_sales), emp_id From works_with GROUP BY emp_id;

-- *********************** WILDCARDS *********************** --

-- % = any # of characters 
-- _ = one characters 

SELECT * FROM client WHERE client_name LIKE '%LLC%';
SELECT * FROM branch_supplier WHERE supplier_name LIKE '%Label%';
SELECT * FROM employee WHERE birthday LIKE '%____-10%'; -- 4 digit year so 4 _ for year and - and 10 for month
SELECT * FROM client WHERE client_name LIKE '%school%';

-- *********************** UNIONS *********************** --

SELECT first_name AS names FROM employee
UNION
SELECT branch_name FROM branch;

SELECT salary AS total_spent_money FROM employee
UNION
SELECT total_sales FROM works_with;

-- *********************** JOINS *********************** --

/* inner join: combining rows from 2 or more tables */
SELECT emp_id, first_name, last_name, branch_name
FROM employee
JOIN branch
ON employee.emp_id = branch.mgr_id;

/* left join: all of the rows in the employee table are getting included, 
but only the rows in the branch table that match are getting included */
SELECT emp_id, first_name, last_name, branch_name
FROM employee
LEFT JOIN branch
ON employee.emp_id = branch.mgr_id;

/* right join: getting all the rows from right table */
SELECT emp_id, first_name, last_name, branch_name
FROM employee
RIGHT JOIN branch
ON employee.emp_id = branch.mgr_id;

/* full join: getting all the tables joined together */

-- *********************** NESTED QUERIES *********************** --

SELECT first_name, last_name 
FROM employee 
WHERE emp_id IN 
  (SELECT emp_id FROM works_with WHERE total_sales > 30000);

SELECT client_name 
FROM client 
WHERE branch_id = (
  SELECT branch_id FROM branch WHERE mgr_id = 102 LIMIT 1
  );

-- *********************** ON DELETE *********************** --

-- ON DELETE SET NULL : if we delete a data, the row will be set to null
-- ON DELETE CASCADE : delete entirely 

-- *********************** TRIGGER *********************** --

-- trigger : define a certain action that should happen when a certain operation get performed on the database
-- delimiter : changes the mysql delimiter which is ; to sth else
-- when defining triggers ';' indicates the end of a SQl statment, in order to indicate the end of trigger we need to change the delimiter to e.g $$

CREATE TABLE trigger_test (
  message VARCHAR(100)
);

-- delimiter is not defined on text editors, it should be don using command line
DELIMITER $$
CREATE
    TRIGGER my_trigger BEFORE INSERT
    ON employee
    FOR EACH ROW BEGIN
        INSERT INTO trigger_test VALUES('added new employee');
    END$$
DELIMITER ; -- we have to change the delimiter to ';' again
 
INSERT INTO employee VALUES(109, 'Oscar', 'Martinez', '1968-02-19', 'M', 69000, 106, 3);


DELIMITER $$
CREATE
    TRIGGER my_trigger_1 BEFORE INSERT
    ON employee
    FOR EACH ROW BEGIN
        INSERT INTO trigger_test VALUES(NEW.first_name);
    END$$
DELIMITER ;

INSERT INTO employee VALUES(110, 'Kevin', 'Malone', '1978-02-19', 'M', 69000, 106, 3);


DELIMITER $$
CREATE
    TRIGGER my_trigger_2 BEFORE INSERT
    ON employee
    FOR EACH ROW BEGIN
        IF NEW.gender = 'M' THEN
              INSERT INTO trigger_test VALUES('added male employee');
        ELSEIF NEW.gender = 'F' THEN
              INSERT INTO trigger_test VALUES('added female employee');
        ELSE
              INSERT INTO trigger_test VALUES('added other employee');
        END IF;
    END$$
DELIMITER ;

INSERT INTO employee VALUES(111, 'Pam', 'Beesly', '1988-02-19', 'F', 69000, 106, 3);

SELECT * from trigger_test;