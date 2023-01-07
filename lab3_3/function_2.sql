DROP FUNCTION examiners_rate(text, integer);
CREATE OR REPLACE FUNCTION examiners_rate(facult TEXT, s_gr integer) RETURNS table(exmn_id bigint, exmn_surname TEXT, average numeric) AS
$BODY$
DECLARE
    curs CURSOR FOR SELECT * FROM schedule.exams WHERE (faculty = facult) AND (s_gr = ANY(groups));
    exist bool = FALSE;
	cur_id integer;
BEGIN
    FOR r in curs LOOP
        FOREACH cur_id IN ARRAY r.examiners_ids LOOP
            RETURN QUERY SELECT examiner_id, examiner_surname, round(AVG(rate), 3) FROM schedule.feedbacks WHERE examiner_id = cur_id GROUP BY examiner_id, examiner_surname;
            exist = TRUE;
        END LOOP;
    END LOOP;
    IF NOT exist THEN
        RAISE EXCEPTION 'Либо у вас нет экзаменов, либо вы дали неправильную информацию о себе';
    END IF;
    RETURN;
END;
$BODY$
LANGUAGE plpgsql;

SELECT * FROM examiners_rate('Факультет 3', 301);
