--Функция, которая выдаёт расписание экзаменов на факультете по его названию.
CREATE OR REPLACE FUNCTION faculty_exams(faculty TEXT) RETURNS table(subj text, gr integer[], "date" date) AS
$BODY$
DECLARE
    curs CURSOR FOR SELECT * FROM schedule.exams;
    exist bool = FALSE;
BEGIN
    FOR r in curs LOOP
        IF r.faculty = $1 THEN
            RETURN QUERY SELECT r.subject_name, r.groups, r.date;
            exist = TRUE;
        END IF;
    END LOOP;
    IF NOT exist THEN
        RAISE EXCEPTION 'Неправильное имя факультета или экзамены еще не вбиты в систему.';
    END IF;
    RETURN;
END;
$BODY$
LANGUAGE plpgsql;

SELECT * FROM faculty_exams('Факультет 5') ORDER BY date;
SELECT * FROM faculty_exams('AAAA');
