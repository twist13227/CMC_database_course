DROP INDEX IF EXISTS schedule.text_index;
DROP INDEX IF EXISTS schedule.array_index;
DROP INDEX IF EXISTS schedule.json_index;
DROP INDEX IF EXISTS schedule.multi_index;
-- 1)массивы
EXPLAIN ANALYZE SELECT * FROM schedule.exams WHERE ARRAY[101]::int[] <@ groups;
/* 
"QUERY PLAN"
"Seq Scan on exams  (cost=0.00..51017.35 rows=168471 width=275) (actual time=2.540..889.974 rows=166667 loops=1)"
"  Filter: ('{101}'::integer[] <@ groups)"
"  Rows Removed by Filter: 833333"
"Planning Time: 3.319 ms"
"Execution Time: 1083.483 ms"
*/

CREATE INDEX array_index ON schedule.exams USING GIN(groups);
--шустро создаётся
EXPLAIN ANALYZE SELECT * FROM schedule.exams WHERE ARRAY[101]::int[] <@ groups;
/*
"QUERY PLAN"
"Bitmap Heap Scan on exams  (cost=1557.62..42180.45 rows=168467 width=275) (actual time=48.163..354.855 rows=166667 loops=1)"
"  Recheck Cond: ('{101}'::integer[] <@ groups)"
"  Heap Blocks: exact=38516"
"  ->  Bitmap Index Scan on array_index  (cost=0.00..1515.50 rows=168467 width=0) (actual time=36.519..36.521 rows=166667 loops=1)"
"        Index Cond: ('{101}'::integer[] <@ groups)"
"Planning Time: 7.521 ms"
"Execution Time: 547.685 ms"
*/


-- 2)json
EXPLAIN ANALYZE SELECT * FROM schedule.examiners NATURAL JOIN schedule.feedbacks 
WHERE student_info @> '{"Факультет": "Факультет 1", "Курс": 1, "Группа": 101}'::jsonb;
/*
"QUERY PLAN"
"Gather  (cost=8776.83..4704411.53 rows=100000 width=345) (actual time=38355.771..38384.061 rows=1 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Hash Join  (cost=7776.83..4693411.53 rows=41667 width=345) (actual time=38339.792..38348.694 rows=0 loops=3)"
"        Hash Cond: (feedbacks.examiner_id = examiners.examiner_id)"
"        ->  Parallel Seq Scan on feedbacks  (cost=0.00..4680689.33 rows=41667 width=293) (actual time=35403.914..38050.865 rows=0 loops=3)"
"              Filter: (student_info @> '{""Курс"": 1, ""Группа"": 101, ""Факультет"": ""Факультет 1""}'::jsonb)"
"              Rows Removed by Filter: 33333333"
"        ->  Parallel Hash  (cost=4358.59..4358.59 rows=147059 width=60) (actual time=243.655..243.659 rows=83333 loops=3)"
"              Buckets: 65536  Batches: 8  Memory Usage: 3552kB"
"              ->  Parallel Seq Scan on examiners  (cost=0.00..4358.59 rows=147059 width=60) (actual time=0.012..124.446 rows=83333 loops=3)"
"Planning Time: 5.184 ms"
"Execution Time: 38384.101 ms"
*/
CREATE INDEX json_index ON schedule.feedbacks USING GIN(student_info);
--создавался 25 минут, но это таблица на 100 млн...
EXPLAIN ANALYZE SELECT * FROM schedule.examiners NATURAL JOIN schedule.feedbacks 
WHERE student_info @> '{"Факультет": "Факультет 1", "Курс": 1, "Группа": 101}'::jsonb;
/*
"QUERY PLAN"
"Gather  (cost=9867.83..722665.12 rows=100000 width=345) (actual time=263.443..272.441 rows=1 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Hash Join  (cost=8867.83..711665.12 rows=41667 width=345) (actual time=258.926..260.306 rows=0 loops=3)"
"        Hash Cond: (feedbacks.examiner_id = examiners.examiner_id)"
"        ->  Parallel Bitmap Heap Scan on feedbacks  (cost=1091.00..698942.92 rows=41667 width=293) (actual time=3.752..3.755 rows=0 loops=3)"
"              Recheck Cond: (student_info @> '{""Курс"": 1, ""Группа"": 101, ""Факультет"": ""Факультет 1""}'::jsonb)"
"              Heap Blocks: exact=1"
"              ->  Bitmap Index Scan on json_index  (cost=0.00..1066.00 rows=100000 width=0) (actual time=3.586..3.588 rows=1 loops=1)"
"                    Index Cond: (student_info @> '{""Курс"": 1, ""Группа"": 101, ""Факультет"": ""Факультет 1""}'::jsonb)"
"        ->  Parallel Hash  (cost=4358.59..4358.59 rows=147059 width=60) (actual time=243.874..243.878 rows=83333 loops=3)"
"              Buckets: 65536  Batches: 8  Memory Usage: 3584kB"
"              ->  Parallel Seq Scan on examiners  (cost=0.00..4358.59 rows=147059 width=60) (actual time=0.023..122.341 rows=83333 loops=3)"
"Planning Time: 4.817 ms"
"Execution Time: 272.523 ms"
*/


-- 3)несколько таблиц и несколько полей
EXPLAIN ANALYZE SELECT * FROM schedule.examiners JOIN schedule.feedbacks USING (examiner_id) WHERE examiner_id = 1000 AND date > '2020-06-25';
/*
"QUERY PLAN"
"Nested Loop  (cost=1000.42..4785872.25 rows=71 width=345) (actual time=1673.748..30615.604 rows=71 loops=1)"
"  ->  Index Scan using examiners_pkey on examiners  (cost=0.42..8.44 rows=1 width=60) (actual time=1.120..1.177 rows=1 loops=1)"
"        Index Cond: (examiner_id = 1000)"
"  ->  Gather  (cost=1000.00..4785863.10 rows=71 width=293) (actual time=1672.619..30614.203 rows=71 loops=1)"
"        Workers Planned: 2"
"        Workers Launched: 2"
"        ->  Parallel Seq Scan on feedbacks  (cost=0.00..4784856.00 rows=30 width=293) (actual time=1353.110..30590.586 rows=24 loops=3)"
"              Filter: ((date > '2020-06-25'::date) AND (examiner_id = 1000))"
"              Rows Removed by Filter: 33333310"
"Planning Time: 0.896 ms"
"Execution Time: 30615.789 ms"
*/
CREATE INDEX multi_index ON schedule.feedbacks(examiner_id, date)
--создавался 1.5 минуты
EXPLAIN ANALYZE SELECT * FROM schedule.examiners JOIN schedule.feedbacks USING (examiner_id) WHERE examiner_id = 1000 AND date > '2020-06-25';
/*
"QUERY PLAN"
"Nested Loop  (cost=0.99..299.13 rows=71 width=345) (actual time=1.587..48.977 rows=71 loops=1)"
"  ->  Index Scan using examiners_pkey on examiners  (cost=0.42..8.44 rows=1 width=60) (actual time=0.137..0.141 rows=1 loops=1)"
"        Index Cond: (examiner_id = 1000)"
"  ->  Index Scan using multi_index on feedbacks  (cost=0.57..289.99 rows=71 width=293) (actual time=1.440..48.594 rows=71 loops=1)"
"        Index Cond: ((examiner_id = 1000) AND (date > '2020-06-25'::date))"
"Planning Time: 1.553 ms"
"Execution Time: 49.149 ms"
*/

-- 4)Секционирование таблицы
EXPLAIN ANALYZE SELECT * FROM schedule.feedbacks WHERE date = '2020-06-18';
/*
"QUERY PLAN"
"Gather  (cost=1000.00..5017355.93 rows=3356666 width=293) (actual time=0.990..31289.537 rows=3341400 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on feedbacks  (cost=0.00..4680689.33 rows=1398611 width=293) (actual time=0.354..30794.964 rows=1113800 loops=3)"
"        Filter: (date = '2020-06-18'::date)"
"        Rows Removed by Filter: 32219533"
"Planning Time: 0.068 ms"
"Execution Time: 35653.893 ms"
*/

CREATE TABLE sections_feedbacks (
    feedback_id BIGSERIAL,
    exam_id bigint,
    subject_name text,
    "date" date,
    examiner_id bigint,
    examiner_surname text,
    feedback text,
    rate integer,
    student_info jsonb
) PARTITION BY RANGE (date);

CREATE TABLE first_decade PARTITION OF sections_feedbacks
    FOR VALUES FROM ('2020-06-01') TO ('2020-06-10');

CREATE TABLE second_decade PARTITION OF sections_feedbacks
    FOR VALUES FROM ('2020-06-10') TO ('2020-06-20');

CREATE TABLE third_decade PARTITION OF sections_feedbacks
    FOR VALUES FROM ('2020-06-20') TO ('2020-07-01');

INSERT INTO sections_feedbacks(feedback_id, exam_id, subject_name, "date", examiner_id, examiner_surname, feedback, rate, student_info)
SELECT * FROM schedule.feedbacks;

EXPLAIN ANALYZE SELECT * FROM sections_feedbacks WHERE date = '2020-06-18';
/*
"QUERY PLAN"
"Gather  (cost=1000.00..1723722.07 rows=297282 width=160) (actual time=1.326..18768.156 rows=3341400 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Append  (cost=0.00..1692993.87 rows=123868 width=160) (actual time=0.388..18341.902 rows=1113800 loops=3)"
"        ->  Parallel Seq Scan on second_decade  (cost=0.00..1692374.53 rows=123868 width=160) (actual time=0.384..15386.676 rows=1113800 loops=3)"
"              Filter: (date = '2020-06-18'::date)"
"              Rows Removed by Filter: 10006100"
"Planning Time: 1.493 ms"
"Execution Time: 23136.370 ms"
*/

-- 5)полнотекстовый поиск
EXPLAIN ANALYZE SELECT feedback FROM schedule.feedbacks 
WHERE to_tsvector('russian', feedback) @@ to_tsquery('russian', 'докапывается | похороны');
/*
"QUERY PLAN"
"Gather  (cost=1000.00..15198106.00 rows=997500 width=64) (actual time=1.509..156735.521 rows=9090909 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Seq Scan on feedbacks  (cost=0.00..15097356.00 rows=415625 width=64) (actual time=2.327..155864.935 rows=3030303 loops=3)"
"        Filter: (to_tsvector('russian'::regconfig, feedback) @@ '''докапыва'' | ''похорон'''::tsquery)"
"        Rows Removed by Filter: 30303030"
"Planning Time: 0.429 ms"
"Execution Time: 167309.234 ms"
*/
CREATE INDEX text_index ON schedule.feedbacks USING GIN(to_tsvector('russian', feedback));
-- создавался ~9 минут, но это таблица на 100 млн.
EXPLAIN ANALYZE SELECT feedback FROM schedule.feedbacks 
WHERE to_tsvector('russian', feedback) @@ to_tsquery('russian', 'докапывается | похороны');
/*
"QUERY PLAN"
"Gather  (cost=10202.62..12975447.21 rows=997500 width=64) (actual time=1318.794..175712.725 rows=9090909 loops=1)"
"  Workers Planned: 2"
"  Workers Launched: 2"
"  ->  Parallel Bitmap Heap Scan on feedbacks  (cost=9202.62..12874697.21 rows=415625 width=64) (actual time=1312.645..154785.165 rows=3030303 loops=3)"
"        Recheck Cond: (to_tsvector('russian'::regconfig, feedback) @@ '''докапыва'' | ''похорон'''::tsquery)"
"        Rows Removed by Index Recheck: 29956354"
"        Heap Blocks: exact=5374 lossy=1255695"
"        ->  Bitmap Index Scan on text_index  (cost=0.00..8953.25 rows=997500 width=0) (actual time=1305.721..1305.727 rows=9090909 loops=1)"
"              Index Cond: (to_tsvector('russian'::regconfig, feedback) @@ '''докапыва'' | ''похорон'''::tsquery)"
"Planning Time: 1.109 ms"
"Execution Time: 165942.660 ms"
*/
