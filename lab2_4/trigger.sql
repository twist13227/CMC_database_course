DROP FUNCTION examiner_time_trigger() CASCADE;
DROP VIEW info_table;
CREATE VIEW info_table AS 
			SELECT * 
			FROM schedule.exams NATURAL JOIN schedule.exams_examiners NATURAL JOIN schedule.timedate;
CREATE FUNCTION examiner_time_trigger() RETURNS trigger AS $examiner_time_trigger$
    BEGIN
PERFORM count(*)
		FROM info_table
        WHERE examiner_id = NEW.examiner_id AND info_table.date IN (SELECT date FROM info_table
																   WHERE exam_id =  NEW.exam_id);
		IF ((SELECT count(*)
        FROM info_table
        WHERE examiner_id = NEW.examiner_id AND info_table.date IN (SELECT date FROM info_table
																   WHERE exam_id =  NEW.exam_id)) > 1) THEN
		RAISE 'Timestamp error.';
        END IF;
		RETURN NULL;
    END
$examiner_time_trigger$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER examiner_time_trigger AFTER INSERT ON schedule.exams_examiners FOR EACH ROW EXECUTE FUNCTION examiner_time_trigger();

INSERT INTO schedule.exams_examiners(exam_id, examiner_id) VALUES (19,10);

SELECT * FROM schedule.exams NATURAL JOIN schedule.exams_examiners NATURAL JOIN schedule.timedate
