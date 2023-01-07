/*
	В таблице пришлось поменять фамилию преподавателя, потому что она женилась
*/
UPDATE schedule.examiners
SET surname = 'Петрова'
WHERE examiner_id = 6;

SELECT * FROM schedule.examiners


/*
	Группу по ошибке перевели на 13 курс. Такого не существует => будет ошибка целостности
*/
UPDATE schedule.groups
SET course = 13
WHERE group_id = 5;

/*
	Группу за сильно плохую учёбу целиком отчислили из МГУ
*/


DELETE FROM schedule.consultation
WHERE consultation_id = 4;

SELECT * FROM schedule.exams
		
