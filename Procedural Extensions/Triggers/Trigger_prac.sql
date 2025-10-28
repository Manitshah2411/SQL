/*
1. Logging Updates
* Create a table employees(emp_id, name, salary).
* Create another table employee_logs(emp_id, old_salary, new_salary, changed_on).
* Write a trigger that fires BEFORE UPDATE on employees.salary.
* It should insert a record into employee_logs whenever salary changes.
*/

DROP TABLE IF EXISTS employees CASCADE; -- CASCADE forcefully breaks the chain if there are dependencies on that table
DROP TABLE IF EXISTS employees_logs CASCADE;

CREATE TABLE employees(
    emp_id INT PRIMARY KEY,
    name VARCHAR(20),
    salary INT
);

CREATE TABLE employees_logs(
    log_id SERIAL PRIMARY KEY,        
    emp_id INT,
    old_salary INT,
    new_salary INT,
    changed_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION employees_trg()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.salary IS DISTINCT FROM OLD.salary THEN 
        INSERT INTO employees_logs(emp_id, old_salary, new_salary, changed_on)
        VALUES(OLD.emp_id, OLD.salary, NEW.salary, NOW());
    END IF;
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER employee_logs_trg
BEFORE UPDATE OF salary 
ON employees
FOR EACH ROW
EXECUTE FUNCTION employees_trg();

-- test data
INSERT INTO employees VALUES(1, 'Manit', 80000);
INSERT INTO employees VALUES(2, 'Kashvi', 60000);
INSERT INTO employees VALUES(3, 'Prarthi', NULL);
INSERT INTO employees VALUES(4, 'Prakshal', 20000);
INSERT INTO employees VALUES(5, 'Kalpesh', 60000);
INSERT INTO employees VALUES(6, 'Tanu', 70000);

-- fire trigger
UPDATE employees
SET salary = 70000
WHERE name = 'Prarthi';

UPDATE employees
SET name = 'Tirthi'
WHERE emp_id = 6;

SELECT * FROM employees;
SELECT * FROM employees_logs;


/*
2. Auto-updating Timestamp
* Create a table orders(order_id, product, last_updated).
* Write a trigger that BEFORE UPDATE automatically updates the last_updated column with the current timestamp.
*/

CREATE TABLE IF NOT EXISTS orderss(
	order_id INT PRIMARY KEY,
	product VARCHAR(20),
	last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

INSERT INTO orderss VALUES(1,'Bottle');
INSERT INTO orderss VALUES(2,'Wire');
INSERT INTO orderss VALUES(3,'Keyboard');
INSERT INTO orderss VALUES(4,'Mouse');
INSERT INTO orderss VALUES(5,'Bag');

SELECT * FROM orderss;

CREATE OR REPLACE FUNCTION updated_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	IF NEW.product IS DISTINCT FROM OLD.product THEN
		NEW.last_updated := CURRENT_TIMESTAMP;
	END IF;
	RETURN NEW;
		
END;
$$;

CREATE OR REPLACE TRIGGER orderss_trg
BEFORE UPDATE ON orderss
FOR EACH ROW 
EXECUTE FUNCTION updated_timestamp();

UPDATE orderss
SET product = 'Laptop'
WHERE order_id = 2;


/*
3. Prevent Deletion
* Create a table students(id, name, is_active).
* Write a trigger that prevents deleting a student record.
* Instead of deleting, it should mark is_active = false.
*/

DROP TABLE IF EXISTS students;
CREATE TABLE IF NOT EXISTS students(
	id INT PRIMARY KEY,
	name VARCHAR(20),
	is_active BOOLEAN DEFAULT TRUE
)

INSERT INTO students VALUES(1,'Manit');
INSERT INTO students VALUES(2,'Shah');
INSERT INTO students VALUES(3,'Messi');
INSERT INTO students VALUES(4,'Lionel');


CREATE OR REPLACE FUNCTION prevent_dlt()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	UPDATE students
	SET is_active = FALSE
	WHERE id = OLD.id;

	RETURN NULL; -- this prevents the delete and the above UPDATE just updates the flag is_active to FALSE
END;
$$;

CREATE OR REPLACE TRIGGER prevent_dlt_trg
BEFORE DELETE ON students
FOR EACH ROW
EXECUTE FUNCTION prevent_dlt();

DELETE FROM students
WHERE id = 3;

SELECT * FROM students;


/*
4. Audit Trail
* Create a table accounts(acc_id, balance).
* Create an audit_logs(acc_id, action, old_balance, new_balance, changed_by, changed_on).
* Write a trigger that fires on both INSERT and UPDATE of accounts.
* It should insert an entry into audit_logs showing what happened.
*/

CREATE TABLE IF NOT EXISTS accounts(
	acc_id INT PRIMARY KEY,
	balance INT NOT NULL
)

CREATE TABLE IF NOT EXISTS audit_logs(
	acc_id INT,
	action VARCHAR(15),
	old_balance INT,
	new_balance INT,
	changed_by VARCHAR(20),
	changed_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
)

INSERT INTO accounts VALUES(1,20000);
INSERT INTO accounts VALUES(2,40000);
INSERT INTO accounts VALUES(3,50000);
INSERT INTO accounts VALUES(4,35000);
INSERT INTO accounts VALUES(5,30000);

UPDATE accounts SET balance = 90000 WHERE acc_id = 1;
UPDATE accounts SET balance = 90000 WHERE acc_id = 2;
UPDATE accounts SET balance = 90000 WHERE acc_id = 3;

SELECT * FROM accounts;
SELECT * FROM audit_logs;

CREATE OR REPLACE FUNCTION acc_audit()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE 
	v_changed_by VARCHAR(20);
BEGIN
	v_changed_by := current_user;
	IF TG_OP = 'INSERT' OR TG_OP = 'insert' OR TG_OP = 'UPDATE' OR TG_OP = 'update' THEN
		INSERT INTO audit_logs VALUES(NEW.acc_id,TG_OP,OLD.balance,NEW.balance,v_changed_by, CURRENT_TIMESTAMP);
	END IF;
	RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER acc_audit_trg
AFTER INSERT OR UPDATE ON accounts
FOR EACH ROW
EXECUTE FUNCTION acc_audit();

/*
5. Enforce Business Rule
* Create a table products(pid, pname, price).
* Write a trigger that ensures price cannot be negative.
* If someone tries to insert or update with negative price, raise an error.
*/

CREATE TABLE IF NOT EXISTS products(
	pid INT PRIMARY KEY,
	pname VARCHAR,
	price INT
)

INSERT INTO products VALUES(1,'Bottle',100);
INSERT INTO products VALUES(2,'Bag', 300);

UPDATE products 
SET price = 250
WHERE pid = 2;

SELECT * FROM products;

CREATE OR REPLACE FUNCTION prevent_neg_price()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	IF NEW.price < 0 THEN 
		RAISE NOTICE 'Price cannot be smaller than zero';
		RETURN NULL;
	ELSE
		RETURN NEW;
	END IF;
END;
$$;

CREATE OR REPLACE TRIGGER neg_price_trg
BEFORE UPDATE OR INSERT ON products
FOR EACH ROW 
EXECUTE FUNCTION prevent_neg_price();


/*
6. Cascading Trigger
* Create department(dept_id, dept_name) and employees(emp_id, name, dept_id).
* Write a trigger so that if a department is deleted, all employees in that department are also deleted.
*/

CREATE TABLE IF NOT EXISTS dept(
	dpt_id INT PRIMARY KEY NOT NULL,
	dpt_name VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS emp(
	emp_id INT PRIMARY KEY NOT NULL,
	name VARCHAR(20),
	dpt_id INT REFERENCES dept(dpt_id) ON DELETE CASCADE
);

INSERT INTO dept VALUES(1,'IT');
INSERT INTO dept VALUES(2,'HR');
INSERT INTO dept VALUES(3,'Sales');
INSERT INTO dept VALUES(4,'Marketing');

INSERT INTO emp VALUES(1, 'Manit', 1);
INSERT INTO emp VALUES(2, 'Kashvi', 1);
INSERT INTO emp VALUES(3, 'Shah', 2);
INSERT INTO emp VALUES(4, 'Mridvi', 2);
INSERT INTO emp VALUES(5, 'Choti', 3);

SELECT * FROM dept;
SELECT * FROM emp;

DELETE FROM dept WHERE dpt_id = 3;


CREATE OR REPLACE FUNCTION cascade_dlt()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	DELETE FROM emp WHERE dpt_id = OLD.dpt_id;
	RETURN OLD;
END;
$$;


CREATE OR REPLACE TRIGGER cascade_dlt_trg
AFTER DELETE ON dept
FOR EACH ROW
EXECUTE FUNCTION cascade_dlt();


/*
7. History Table
* Create bookings(bid, user_id, status) and booking_history(bid, old_status, new_status, changed_on).
* Write a trigger that logs every status change into booking_history.
*/

CREATE TABLE IF NOT EXISTS bookings(
	bid INT PRIMARY KEY NOT NULL,
	user_id INT,
	status VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS booking_history(
	bid INT,
	old_status VARCHAR(20),
	new_status VARCHAR(20),
	changed_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO bookings VALUES(1, 1, 'Process');
INSERT INTO bookings VALUES(2, 1, 'Booked');
INSERT INTO bookings VALUES(3, 2, 'Payment');

UPDATE bookings
SET status = 'Booked'
WHERE bid = 3;

SELECT * FROM bookings;
SELECT * FROM booking_history;


CREATE OR REPLACE FUNCTION booking_logs()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	INSERT INTO booking_history VALUES(OLD.bid, OLD.status, NEW.status, CURRENT_TIMESTAMP);
	RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER booking_trg
BEFORE UPDATE ON bookings
FOR EACH ROW
EXECUTE FUNCTION booking_logs();



