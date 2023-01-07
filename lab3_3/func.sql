
CREATE OR REPLACE FUNCTION name_surname(inp TEXT, OUT input_name TEXT, OUT input_surname TEXT) AS
$BODY$
DECLARE
    splitted text[];
BEGIN
    splitted:= regexp_split_to_array(inp, ' ');
	IF array_length(splitted, 1) != 2 THEN
		RAISE EXCEPTION 'Неправильная строка ввода';
	ELSE
		input_name:= INITCAP(splitted[1]);
		input_surname:= INITCAP(splitted[2]);
	END IF;
END;
$BODY$
LANGUAGE plpgsql;

SELECT * FROM name_surname('иван')
