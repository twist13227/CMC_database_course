/*
	Расписание экзаменов для 2 курса факультета ВМК.
*/

WITH exams_info AS (
	SELECT *
	FROM schedule.exams
	NATURAL JOIN schedule.exams_examiners
	NATURAL JOIN schedule.examiners
	NATURAL JOIN schedule.groups_exams
	NATURAL JOIN schedule.groups
	NATURAL JOIN schedule.subjects
	NATURAL JOIN schedule.timedate
)
SELECT group_number AS "Номер группы",
subject_name AS "Предмет",
building_name AS "Корпус",
audience_num AS "Аудитория",
to_char(date, 'DD.MM.YYYY') AS "Время начала",
consultation_id AS "Консультация",
count(1) AS "Количество принимающих"
FROM exams_info
WHERE faculty_name = 'Computational Mathematics and Cybernetics' AND course = 2
GROUP BY group_number,subject_name,audience_num, building_name, date, consultation_id
ORDER BY group_number;

/*
	Информация для преподавателей, в какой день и куда им приходить
	принимать экзамен.
*/
WITH examiners_info AS (
	SELECT *
	FROM schedule.exams
	NATURAL JOIN schedule.exams_examiners
	NATURAL JOIN schedule.examiners
	NATURAL JOIN schedule.timedate
)
SELECT surname, name, building_name, audience_num, date
FROM examiners_info
ORDER BY surname;

/*
	Количество экзаменов нв первом курсе у каждого факультета.
*/
WITH info AS(
	SELECT faculty_name, subject_id, course
	FROM schedule.subjects
	NATURAL JOIN schedule.exams
	NATURAL JOIN schedule.groups_exams
	NATURAL JOIN schedule.groups
	GROUP BY faculty_name, subject_id, course
)
SELECT faculty_name, count(*)
FROM info
WHERE course = 1
GROUP BY faculty_name;
