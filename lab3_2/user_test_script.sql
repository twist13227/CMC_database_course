/* user -- test */
SET ROLE test;
SELECT * FROM schedule.exams;
UPDATE schedule.feedbacks SET examiner_surname = NULL;
UPDATE schedule.feedbacks SET feedback = 'Пойдёт. Советую' WHERE exam_id = 1 AND examiner_id = 2;
UPDATE schedule.examiners SET surname = NULL;
SELECT * FROM schedule.examiners LIMIT 10;

UPDATE list_of_examiners SET surname = NULL;
SELECT * FROM list_of_examiners LIMIT 10;

