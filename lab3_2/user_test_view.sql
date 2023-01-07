SET ROLE test_view;
UPDATE exams_dates SET faculty = NULL;
SELECT * FROM exams_dates LIMIT 10;
UPDATE exams_dates SET date = '2021-06-05' WHERE faculty = 'Факультет 2';
SELECT * FROM exams_dates LIMIT 10;
