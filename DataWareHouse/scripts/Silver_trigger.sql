---------------------------------------------------------------------
-- Trigger silver.crm_cust_info

CREATE OR REPLACE FUNCTION null_value_name()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	IF NEW.cust_firstname IS NULL THEN
		NEW.cust_firstname := 'UNKNOWN';
	END IF;
	IF NEW.cust_lastname IS NULL THEN
		NEW.cust_lastname := 'UNKNOWN';
	END IF;
	RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER null_value_name_trg
BEFORE INSERT ON silver.crm_cust_info
FOR EACH ROW
EXECUTE FUNCTION null_value_name();


---------------------------------------------------------------------
-- Dynamic Trigger function for last_updated column for silver.<tablename>

-- Generic function NOTE : the column name should be exactly 'last_updated' to make dynamic
CREATE OR REPLACE FUNCTION update_last_updated()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	NEW.last_updated := NOW();
	RETURN NEW;
END;
$$

-- Anonymous Function For automating the creation of the Triggers

DO $$
DECLARE 
	tb1 RECORD;
BEGIN
	FOR tb1 IN
		SELECT table_name
		FROM information_schema.columns
		WHERE table_schema = 'silver'
		AND column_name = 'last_updated'

	LOOP
		EXECUTE FORMAT('
			CREATE TRIGGER trg_%I_last_updated
			BEFORE UPDATE ON silver.%I
			FOR EACH ROW
			EXECUTE FUNCTION update_last_updated();', tb1.table_name, tb1.table_name);
	END LOOP;
END;
$$;

-- List triggers in your schema
SELECT event_object_table, trigger_name
FROM information_schema.triggers
WHERE trigger_schema = 'silver';
