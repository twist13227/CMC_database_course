/* 1. Данный запрос выводит минимальную и максимальную цену полёта на самолете
и информацию о соответствующем полёте */

(SELECT b.book_ref AS booking_number,
	   ti.passenger_name AS pas_name,
	   f.departure_airport AS departure,
       f.arrival_airport AS arrival,
	   tif.fare_conditions AS seat_class,
	   tif.amount AS ticket_cost  
FROM   bookings as b
       JOIN tickets ti ON b.book_ref = ti.book_ref
	   JOIN ticket_flights tif ON ti.ticket_no = tif.ticket_no 
	   JOIN flights f ON tif.flight_id = f.flight_id
	   JOIN 
	        (
				SELECT MIN(amount) as min_cost
				FROM ticket_flights
				WHERE amount <> 0
			) AS min_table
		ON min_table.min_cost = tif.amount	
LIMIT 1) 
UNION
(SELECT b.book_ref AS booking_number,
	   ti.passenger_name AS pas_name,
	   f.departure_airport AS departure,
       f.arrival_airport AS arrival,
	   tif.fare_conditions AS seat_class,
	   tif.amount AS ticket_cost  
FROM   bookings as b
       JOIN tickets ti ON b.book_ref = ti.book_ref
	   JOIN ticket_flights tif ON ti.ticket_no = tif.ticket_no 
	   JOIN flights f ON tif.flight_id = f.flight_id
	   JOIN 
	        (
				SELECT MAX(amount) as max_cost
				FROM ticket_flights
				WHERE amount <> 0
			) AS max_table
		ON max_table.max_cost = tif.amount	
LIMIT 1);

/* 2. Данный запрос выводит среднюю цену билета для каждого класса обслуживания*/

SELECT t.fare_conditions AS seat_class,
	   ROUND(AVG(t.amount), 3) AS medium
FROM ticket_flights as t
GROUP BY seat_class
	   
/* 3. Данный запрос является таблом прилёта для аэропорта Домодедово **с возможностью
задать время, начиная от которого идет отсчет табла*(доп)**/
SELECT f.flight_no AS numb,
       f.departure_airport AS departure,
	   a.airport_name AS departure_name,
	   f.scheduled_arrival AS arrival_time,
	   f.status AS stat
FROM   flights AS f
	   JOIN airports a ON a.airport_code = f.departure_airport
WHERE  f.arrival_airport = 'DME' AND f.status != 'Arrived' AND f.status != 'Departed'
AND f.scheduled_arrival > timestamp with time zone '2017-8-25 05:00:00+03'
ORDER BY arrival_time
LIMIT 30;


/* 4. Данный запрос показывает, сколько мест есть в каждом классе у разных моделей самолётов*/

SELECT aircrafts.model AS model,
       seats.fare_conditions AS seat_class,
	   COUNT(*) AS amount
FROM seats 
	 JOIN aircrafts ON aircrafts.aircraft_code = seats.aircraft_code
GROUP BY model, seat_class
ORDER BY model;


/*5. Даныый запрос показывает, за какую минимальную цену можно улететь из Москвы в разные аэропорты(доп)*/ 
SELECT f1.arrival_airport as arrival, MIN(amount) as min_cost
FROM ticket_flights as tif1
	 JOIN flights f1 ON tif1.flight_id = f1.flight_id
	 JOIN airports ai ON f1.departure_airport = ai.airport_code
WHERE tif1.amount <> 0  AND ai.city = 'Москва' AND (f1.scheduled_departure > bookings.now())
GROUP BY arrival;