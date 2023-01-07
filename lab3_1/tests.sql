SELECT * FROM schedule.exams 
WHERE faculty = 'Факультет 5000'

SELECT count(*) FROM schedule.examiners
SELECT count(*) FROM schedule.feedbacks
SELECT count(*) FROM schedule.exams
SELECT * FROM schedule.feedbacks LIMIT 100

SELECT AVG(rate) FROM schedule.feedbacks WHERE examiner_id = 123456
SELECT * FROM schedule.feedbacks WHERE examiner_id = 100000