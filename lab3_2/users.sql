REVOKE ALL PRIVILEGES ON SCHEMA schedule FROM test;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA schedule FROM test;
REVOKE ALL PRIVILEGES ON SCHEMA schedule FROM test_view;
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA schedule FROM test_view;
DROP VIEW public.exams_dates;
DROP VIEW public.list_of_examiners;
DROP USER test;
DROP USER test_view;
DROP USER test_role;

CREATE USER test PASSWORD '111';
GRANT USAGE ON SCHEMA schedule TO test;

GRANT SELECT, UPDATE, INSERT ON schedule.exams TO test;
GRANT SELECT (exam_id, examiner_id, subject_name, examiner_surname, feedback, rate), UPDATE (feedback) ON schedule.feedbacks TO test;
GRANT SELECT ON schedule.examiners TO test;

CREATE OR REPLACE VIEW public.list_of_examiners AS
    SELECT surname, name, patronymic
    FROM schedule.examiners;
GRANT SELECT ON list_of_examiners TO test;

CREATE OR REPLACE VIEW public.exams_dates AS
    SELECT faculty, subject_name, date
    FROM schedule.exams
    WHERE faculty = 'Факультет 2'
    WITH LOCAL CHECK OPTION;

CREATE ROLE test_role;
GRANT SELECT, UPDATE (date) ON exams_dates TO test_role;
CREATE USER test_view PASSWORD '111';

GRANT test_role TO test_view;
GRANT USAGE ON SCHEMA schedule to test_view;
GRANT USAGE ON SCHEMA schedule to test;


REVOKE ALL PRIVILEGES ON table FROM user
