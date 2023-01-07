
/* Проверки для group_course_trigger */
INSERT INTO schedule.groups (faculty_name, course, group_number)
VALUES ('Physical', 7, 621);
SELECT * FROM schedule.groups ORDER BY course DESC;

UPDATE schedule.groups SET course = 1 WHERE group_id = 21;
SELECT * FROM schedule.groups ORDER BY course DESC;

/* Проверка для surname_trigger */
UPDATE schedule.examiners SET surname = NULL WHERE surname = 'Дандина';
SELECT * FROM schedule.examiners;

/* Проверка для subject_exam_trigger */

BEGIN;
INSERT INTO schedule.timedate(building_name, audience_num, date)
VALUES
('Ломоносовский', 'П3', TIMESTAMP '2020-06-20 11:00:00'),
('Ломоносовский', 'П3', TIMESTAMP '2020-06-21 09:00:00');
INSERT INTO schedule.consultation (timedate_id) VALUES (81);
INSERT INTO schedule.subjects (subject_id, subject_name, faculty_name)
VALUES (150, 'РЯКР', 'Computational Mathematics and Cybernetics');
INSERT INTO schedule.exams (subject_id, timedate_id, consultation_id)
VALUES (15, 82, 41);
SELECT *                                                                 
       FROM (schedule.exams RIGHT JOIN schedule.subjects ON schedule.exams.subject_id = schedule.subjects.subject_id)
        WHERE exam_id IS NULL;     
COMMIT;
