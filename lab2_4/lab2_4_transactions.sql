-- Невозможность грязного чтения и возможность неповторяющегося чтения в READ (UN)COMMITTED
BEGIN;
SET search_path TO groups;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
                                                        BEGIN;
                                                        SET search_path TO groups;
                                                        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
UPDATE schedule.groups SET course = 3 WHERE faculty_name='Computational Mathematics and Cybernetics';
                                                        SELECT * FROM schedule.groups WHERE (course = 2);
                                        -- Не показывает изменения, т.к. они еще не закомментированы
                                        -- Для uncommited будет так же, ибо в postgres read uncommited работает как read commited
COMMIT;
                                                        SELECT * FROM schedule.groups WHERE (course = 2);
                                        -- Аномалия неповторяющегося чтения


-- Аномалия потерянных изменений
BEGIN;
SET search_path TO groups;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
UPDATE schedule.groups SET course = course + 1 WHERE faculty_name='Computational Mathematics and Cybernetics' ;
                                                        BEGIN;
                                                        SET search_path TO groups;
                                                        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
                                                        DELETE FROM schedule.groups WHERE faculty_name='Computational Mathematics and Cybernetics' AND course = 2;
                                                        --ожидание завершения первого процесса
COMMIT;
SELECT * FROM schedule.groups;
                                                       COMMIT;
SELECT * FROM schedule.groups;
--Изменения из второго процесса потеряны: не удалились ни записи, где курс изначально был 2, ни где он стал 2 после выполнения первого процесса


--Невозможность неповторяющегося чтения и фантомов в REPEATABLE READ
BEGIN;
SET search_path TO groups;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
                                                        BEGIN;
                                                        SET search_path TO groups;
                                                        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
UPDATE schedule.groups SET course = course + 2 WHERE faculty_name = 'Computational Mathematics and Cybernetics' AND course = 2;
DELETE FROM schedule.groups WHERE faculty_name = 'Physical' AND course = 1;
INSERT INTO schedule.groups (faculty_name, course, group_number) VALUES ('Physical', 3, 303);
                                                        SELECT faculty_name, course, group_number from schedule.groups WHERE faculty_name = 'Computational Mathematics and Cybernetics' OR faculty_name = 'Physical';
COMMIT;
                                                        SELECT faculty_name, course, group_number from schedule.groups WHERE faculty_name = 'Computational Mathematics and Cybernetics' OR faculty_name = 'Physical';
                                                        --Выведется то же самое, поскольку есть защита от DELETE и UPDATE
BEGIN;
SET search_path TO groups;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
INSERT INTO schedule.groups (faculty_name, course, group_number) VALUES ('Physical', 3, 303);
COMMIT;
                                                        SELECT faculty_name, course, group_number from schedule.groups WHERE faculty_name = 'Computational Mathematics and Cybernetics' OR faculty_name = 'Physical';
                                                        --Снова вывелось то же самое, несмотря на INSERT, потому что в postgresql на уровне REPEATABLE READ есть защита от фантомных чтений
                                                        --Пример для Serializable и фантомных чтений не пишу, поскольку это просто то же самое с заменой REPEATABE READ на SERIALIZABLE

--Пример для SERIALIZABLE и аномалии сериализации: есть таблица со столбцами class и value.
--Процесс 1: SELECT SUM(value) FROM mytab WHERE class = 1; INSERT INTO %%%.%%% (class, value) VALUES (2, 50)
--Процесс 2: SELECT SUM(value) FROM mytab WHERE class = 2; INSERT INTO %%%.%%% (class, value) VALUES (1, 100)
