DROP FUNCTION group_course_trigger() CASCADE;
DROP FUNCTION surname_trigger() CASCADE;
DROP FUNCTION subject_exam_trigger() CASCADE;

    /*Триггер, который при попытке добавить группу с курсом, выше чем максимальный ставит именно его(6). И который позволяет только повысить курс у группы на один(в конце года), ибо уменьшить курс или повысить на 2 курса невозможно */
CREATE FUNCTION group_course_trigger() RETURNS trigger AS $group_course_trigger$
    BEGIN
        IF NOT TG_OP = 'INSERT' THEN
            IF NEW.course < OLD.course THEN
                NEW.course := OLD.course + 1;
            END IF;

            IF NEW.course > OLD.course + 1 THEN
                NEW.course := OLD.course + 1;
            END IF;
        END IF;

        IF NEW.course >= 7 THEN
            NEW.course := 6;
        END IF;

        RETURN NEW;
    END;
$group_course_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER group_course_trigger BEFORE INSERT OR UPDATE on schedule.groups
    FOR EACH ROW EXECUTE FUNCTION group_course_trigger();

    /*Триггер, который не даёт поменять фамилию на NULL(поскольку такое невозможно, а ошибки бывают разные)*/
CREATE FUNCTION surname_trigger() RETURNS trigger AS $surname_trigger$
    BEGIN
        IF NEW.surname IS NULL THEN
            RETURN NULL;
        END IF;

        RETURN NEW;
    END;
$surname_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER surname_trigger BEFORE UPDATE ON schedule.examiners
    FOR EACH ROW EXECUTE FUNCTION surname_trigger();

    /*Триггер, который выдаёт специализированную ошибку, если после транзакции в таблице оказался предмет, по которому должен быть экзамен, но в БД его по ошибке не внесли, либо внесли ошибочно*/
CREATE FUNCTION subject_exam_trigger() RETURNS trigger AS $subject_exam_trigger$
    BEGIN
PERFORM count(*)
        FROM (schedule.exams RIGHT JOIN schedule.subjects ON schedule.exams.subject_id = schedule.subjects.subject_id)
        WHERE exam_id IS NULL;
        IF ((SELECT count(*)
        FROM (schedule.exams RIGHT JOIN schedule.subjects ON schedule.exams.subject_id = schedule.subjects.subject_id)
        WHERE exam_id IS NULL) > 0) THEN
        RAISE 'No exam for inserted subject.';
        END IF;
        RETURN NULL;
    END
$subject_exam_trigger$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER subject_exam_trigger AFTER INSERT ON schedule.subjects DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION subject_exam_trigger();

CREATE FUNCTION examiner_time_trigger() RETURNS trigger AS $examiner_time_trigger$
    BEGIN
        WITH info_table AS (SELECT * FROM schedule.exams NATURAL JOIN schedule.exams_examiners NATURAL JOIN schedule.timedate);
             new_time AS (SELECT date FROM some_comolex_table WHERE exam_id = NEW.exam_id
        /*FROM (schedule.exams NATURAL JOIN schedule.exams_examiners NATURAL JOIN schedule.timedate)
        WHERE schedule.exams_examiners.examiner_id = NEW.examiner_id; */
PERFORM count(*)
        IF ((SELECT count(*)
        FROM info_table
        WHERE examiner_id = NEW.examiner_id AND date = new_time.date) > 1) THEN
        RAISE 'Timestamp error.';
        END IF;
        RETURN NULL;
    END
$examiner_time_trigger$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER examiner_time_trigger AFTER INSERT ON schedule.exams_examiners FOR EACH ROW EXECUTE FUNCTION examiner_time_trigger();

CREATE FUNCTION examiner_time_trigger() RETURNS trigger AS $examiner_time_trigger$
    BEGIN
        WITH info_table AS (SELECT * FROM schedule.exams NATURAL JOIN schedule.exams_examiners NATURAL JOIN schedule.timedate),
        	 new_time AS (SELECT date FROM info_table WHERE exam_id = NEW.exam_id)
		SELECT * FROM info_table, new_time;
        IF ((SELECT count(*)
        FROM info_table, new_time
        WHERE examiner_id = NEW.examiner_id AND info_table.date = new_time.date) > 1) THEN
        RAISE 'Timestamp error.';
        END IF;
        RETURN NULL;
    END
$examiner_time_trigger$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER examiner_time_trigger AFTER INSERT ON schedule.exams_examiners FOR EACH ROW EXECUTE FUNCTION examiner_time_trigger();
