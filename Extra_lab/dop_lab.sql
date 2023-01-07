--changes in scheme
ALTER TABLE schedule.exams DROP CONSTRAINT exam_subject;
ALTER TABLE schedule.exams ADD CONSTRAINT exam_subject FOREIGN KEY(subject_id) 
	REFERENCES schedule.subjects ON DELETE CASCADE;
ALTER TABLE schedule.exams RENAME TO real_exams;
CREATE VIEW schedule.exams AS
	SELECT * FROM schedule.real_exams NATURAL JOIN schedule.subjects;
-- end of changes in scheme

-- trigger for new view
CREATE OR REPLACE FUNCTION update_view() RETURNS trigger AS $update_view$
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            DELETE FROM schedule.real_exams WHERE exam_id = OLD.exam_id;
            IF NOT FOUND THEN RETURN NULL; END IF;
			RETURN OLD;
        ELSEIF (TG_OP = 'UPDATE') THEN
            UPDATE schedule.real_exams SET 
			subject_id = NEW.subject_id,
			timedate_id = NEW.timedate_id,
			consultation_id = NEW.consultation_id
			WHERE exam_id = OLD.exam_id;
			IF NOT FOUND THEN RETURN NULL; END IF;
			UPDATE schedule.subjects SET
			subject_name = NEW.subject_name,
			faculty_name = NEW.faculty_name
			WHERE subject_id = OLD.subject_id;
            IF NOT FOUND THEN RETURN NULL; END IF;
            RETURN NEW;
        ELSEIF (TG_OP = 'INSERT') THEN
            INSERT INTO schedule.real_exams(subject_id, timedate_id, consultation_id)
			VALUES(NEW.subject_id, NEW.timedate_id, NEW.consultation_id);
            RETURN NEW;
		ELSEIF (TG_OP = 'TRUNCATE') THEN
			TRUNCATE schedule.subjects;
			TRUNCATE schedule.real_exams;
		ELSE RETURN NULL;
        END IF;
		RETURN NULL;
    END;
$update_view$ LANGUAGE plpgsql;
CREATE TRIGGER view_update
INSTEAD OF INSERT OR UPDATE OR DELETE ON schedule.exams
    FOR EACH ROW EXECUTE FUNCTION update_view();

--end of trigger for new view
--trigger for checking if examiner can take an exam
CREATE OR REPLACE FUNCTION examiner_subject_trigger() RETURNS trigger AS $examiner_subject_trigger$
    BEGIN
PERFORM count(*)
		FROM schedule.exams NATURAL JOIN schedule.examiners_subjects
		WHERE examiner_id = NEW.examiner_id AND exam_id = NEW.exam_id;
		IF ((SELECT count(*)
      	FROM schedule.exams NATURAL JOIN schedule.examiners_subjects
		WHERE examiner_id = NEW.examiner_id AND exam_id = NEW.exam_id) = 0)
		THEN RAISE 'Это невозможно';
		END IF;
		RETURN NULL;
    END
$examiner_subject_trigger$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS examiner_subject_trigger ON schedule.exams_examiners CASCADE;

CREATE CONSTRAINT TRIGGER examiner_subject_trigger AFTER INSERT ON schedule.exams_examiners
	FOR EACH ROW EXECUTE FUNCTION examiner_subject_trigger();
--end of trigger for checking if examiner can take an exam

--tests for trigger1
INSERT INTO schedule.subjects(subject_name, faculty_name)
	VALUES ('Линейная алгебра','Physical');
INSERT INTO schedule.exams(subject_id, timedate_id, consultation_id) VALUES (23,7,7);
SELECT * FROM schedule.exams;

DELETE FROM schedule.exams WHERE subject_id = 23;
SELECT * FROM schedule.exams;

TRUNCATE schedule.exams CASCADE;
SELECT * FROM schedule.real_exams;

UPDATE schedule.exams SET subject_name = 'ADAD' WHERE subject_id = 1;
SELECT * FROM schedule.exams;

UPDATE schedule.exams SET consultation_id = 10 WHERE exam_id = 2;
SELECT * FROM schedule.exams;

--end of tests for trigger 1

--tests for trigger 2
SELECT * FROM schedule.examiners_subjects;
SELECT * FROM schedule.exams NATURAL JOIN schedule.examiners_subjects
		WHERE examiner_id = 10 AND exam_id = 19;
INSERT INTO schedule.exams_examiners(exam_id, examiner_id) VALUES (19,10);
SELECT * FROM schedule.exams NATURAL JOIN schedule.examiners_subjects
		WHERE examiner_id = 10 AND exam_id = 20;
INSERT INTO schedule.exams_examiners(exam_id, examiner_id) VALUES (20,10);	
INSERT INTO schedule.examiners_subjects(examiner_id, subject_id) VALUES (10, 11);
INSERT INTO schedule.exams_examiners(exam_id, examiner_id) VALUES (20,10);
INSERT INTO schedule.exams_examiners(exam_id, examiner_id) VALUES (25,10);
--end of tests for trigger 2

--other tests
INSERT INTO schedule.subjects(subject_name, faculty_name)
	VALUES ('Линейная алгебра','Physical');
INSERT INTO schedule.real_exams(subject_id, timedate_id, consultation_id) VALUES (23, 7, 7);
DELETE FROM schedule.subjects WHERE subject_id = 23;
DELETE FROM schedule.examiners WHERE examiner_id = 5;
SELECT * FROM schedule.examiners_subjects;
SELECT * FROM schedule.exams;
--end of other tests