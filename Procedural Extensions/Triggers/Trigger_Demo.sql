CREATE TABLE student
(
	roll_no NUMERIC(10),
	name VARCHAR(30),
	course VARCHAR(30)
);



CREATE TABLE student_logs
(
	roll_no_old NUMERIC(10),
	name_old VARCHAR(30),
	course_old VARCHAR(30)
);


CREATE OR REPLACE FUNCTION student_log_trigger()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
	RAISE NOTICE 'Table fired on : %, Table operation : %',
	TG_TABLE_NAME, TG_OP;
	 -- For UPDATE
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO student_logs(roll_no_old, name_old, course_old)
        VALUES(OLD.roll_no, OLD.name, OLD.course);
        RETURN NEW; -- allow update
    END IF;

    -- For DELETE
    IF TG_OP = 'DELETE' THEN
        INSERT INTO student_logs(roll_no_old, name_old, course_old)
        VALUES(OLD.roll_no, OLD.name, OLD.course);
        RETURN OLD; -- allow delete
    END IF;
END;
$$;



CREATE OR REPLACE TRIGGER student_trg
BEFORE UPDATE OR DELETE 
ON student
FOR EACH row 
EXECUTE PROCEDURE student_log_trigger();

ALTER TABLE student
ADD CONSTRAINT student_pkey PRIMARY KEY (roll_no);

SELECT * FROM student;
SELECT * FROM student_logs;

INSERT INTO student VALUES (1,'Manit','Science');
INSERT INTO student VALUES (2,'Kashvi','Commerce');
INSERT INTO student VALUES (3,'Mridvi','Physics');
INSERT INTO student VALUES (4,'Prarthi','Biology');
INSERT INTO student VALUES (5,'Tirthi','MBA');
INSERT INTO student VALUES (6,'Prakshal','Medicines');
INSERT INTO student VALUES (7,'Kalpesh','BCOM');
INSERT INTO student VALUES (8,'Messi','Goat');

UPDATE student SET course = 'Astronomy' WHERE name = 'Manit';
DELETE FROM student_logs WHERE roll_no_old = 8;