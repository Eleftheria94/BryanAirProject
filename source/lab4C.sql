/* 
Database Technology (732A57) Lab 4-Project
This project was coded by: Eleftheria Chatzitheodoridou (elech646) &
                           Syeda Aqsa Iftikhar (syeif776)
It can be found on: https://gitlab.liu.se/elech646/db/-/tree/master/lab4 
*/

/* CODE STARTS HERE */
/* Use this command if you're running the script on a local MySQL Server:
SET GLOBAL log_bin_trust_function_creators = 1; */

SET FOREIGN_KEY_CHECKS = 0;

/* Drop all the created tables (13) */

DROP TABLE IF EXISTS weekday;
DROP TABLE IF EXISTS weeklyschedule;
DROP TABLE IF EXISTS year;
DROP TABLE IF EXISTS flight;
DROP TABLE IF EXISTS route;
DROP TABLE IF EXISTS ticket;
DROP TABLE IF EXISTS passenger;
DROP TABLE IF EXISTS unpaidreservation;
DROP TABLE IF EXISTS airport;
DROP TABLE IF EXISTS contact;
DROP TABLE IF EXISTS creditcard;
DROP TABLE IF EXISTS reservation;
DROP TABLE IF EXISTS booking;

/* Drop all created procedures (8) */

DROP PROCEDURE IF EXISTS addYear;
DROP PROCEDURE IF EXISTS addDay;
DROP PROCEDURE IF EXISTS addDestination;
DROP PROCEDURE IF EXISTS addRoute;
DROP PROCEDURE IF EXISTS addFlight;
DROP PROCEDURE IF EXISTS addContact;
DROP PROCEDURE IF EXISTS addPayment;
DROP PROCEDURE IF EXISTS addReservation;
DROP PROCEDURE IF EXISTS addPassenger;

/* Drop all functions (2) */

DROP FUNCTION IF EXISTS calculateFreeSeats;
DROP FUNCTION IF EXISTS calculatePrice;

/* Drop triggers */

DROP TRIGGER IF EXISTS UniqueTicketGen;

/* Drop all views */
DROP VIEW IF EXISTS allFlights;

SET FOREIGN_KEY_CHECKS = 1;

/* Question 2: Create your tables and foreign keys in the database using the CREATE TABLE and if necessary the ALTER TABLE queries. Once you are done the database should have the same structure as shown in your relational model. Also, read up on how attributes can be automatically incremented and implement where appropriate. */

CREATE TABLE weekday(
name_of_day VARCHAR(10) NOT NULL,
year INT NOT NULL,
weekday_factor DOUBLE,
CONSTRAINT pk_weekday PRIMARY KEY(name_of_day, year));

CREATE TABLE weeklyschedule(
schedule_id INT NOT NULL AUTO_INCREMENT,
day VARCHAR(10) NOT NULL,
year INT NOT NULL,
route INT NOT NULL,
departure_time TIME NOT NULL,
CONSTRAINT pk_weeklyschedule PRIMARY KEY(schedule_id));

CREATE TABLE year(
year INT NOT NULL,
profit_factor DOUBLE,
CONSTRAINT pk_year PRIMARY KEY(year));

CREATE TABLE flight(
flight_id INT NOT NULL AUTO_INCREMENT,
schedule_id INT NOT NULL,
week_nr INT, 
CONSTRAINT pk_flight PRIMARY KEY(flight_id));

CREATE TABLE route(
route_id INT NOT NULL AUTO_INCREMENT,
departure_airport_code VARCHAR(30) NOT NULL,
arrival_airport_code VARCHAR(30) NOT NULL,
year INT NOT NULL,
route_price DOUBLE,
PRIMARY KEY(route_id));

CREATE TABLE ticket(
reservation_id INT NOT NULL,
passport_nr INT NOT NULL,
ticket_id INT DEFAULT 0 NOT NULL,
CONSTRAINT pk_ticket PRIMARY KEY (passport_nr, reservation_id));

CREATE TABLE passenger(
passport_nr INT NOT NULL,
name VARCHAR(30) NOT NULL,
CONSTRAINT pk_passenger PRIMARY KEY(passport_nr));

CREATE TABLE unpaidreservation(
passport_nr INT NOT NULL,
reservation_id INT NOT NULL,
CONSTRAINT pk_unpaidreservation PRIMARY KEY(passport_nr, reservation_id));

CREATE TABLE airport(
airport_code VARCHAR(3) NOT NULL,
airport_name VARCHAR(30) NOT NULL,
country VARCHAR(30) NOT NULL,
CONSTRAINT pk_airport PRIMARY KEY(airport_code));

CREATE TABLE contact(
passport_nr INT NOT NULL,
email VARCHAR(30),
phone_nr BIGINT NOT NULL,
CONSTRAINT pk_contact PRIMARY KEY(passport_nr));

CREATE TABLE creditcard(
card_nr BIGINT NOT NULL,
card_holder VARCHAR(30),
CONSTRAINT pk_creditcard PRIMARY KEY(card_nr));

CREATE TABLE reservation(
reservation_id INT NOT NULL AUTO_INCREMENT, 
contact_passport_nr INT, 
flight_id INT NOT NULL,
number_of_seats INT,
CONSTRAINT pk_reservation PRIMARY KEY(reservation_id));

CREATE TABLE booking(
reservation_id INT NOT NULL,
card_nr BIGINT NOT NULL,
route_price DOUBLE,
CONSTRAINT pk_booking PRIMARY KEY(reservation_id));

/* END OF TABLE CREATION */

ALTER TABLE contact ADD CONSTRAINT fk_contact_passenger FOREIGN KEY (passport_nr) REFERENCES passenger(passport_nr);

ALTER TABLE reservation ADD CONSTRAINT fk_reservation_contact FOREIGN KEY (contact_passport_nr) REFERENCES contact(passport_nr);

ALTER TABLE reservation ADD CONSTRAINT fk_reservation_flight FOREIGN KEY (flight_id) REFERENCES flight(flight_id);

ALTER TABLE booking ADD CONSTRAINT fk_booking_reservation FOREIGN KEY (reservation_id) REFERENCES reservation(reservation_id);

ALTER TABLE booking ADD CONSTRAINT fk_booking_creditcard FOREIGN KEY (card_nr) REFERENCES creditcard(card_nr);

ALTER TABLE ticket ADD CONSTRAINT fk_ticket_passenger FOREIGN KEY (passport_nr) REFERENCES passenger(passport_nr);

ALTER TABLE ticket ADD CONSTRAINT fk_ticket_booking FOREIGN KEY (reservation_id) REFERENCES booking(reservation_id);

ALTER TABLE unpaidreservation ADD CONSTRAINT fk_unpaid_passenger FOREIGN KEY (passport_nr) REFERENCES passenger(passport_nr);

ALTER TABLE unpaidreservation ADD CONSTRAINT fk_unpaid_reservation FOREIGN KEY (reservation_id) REFERENCES reservation(reservation_id);

ALTER TABLE route ADD CONSTRAINT fk_route_departure FOREIGN KEY (departure_airport_code) REFERENCES airport(airport_code);

ALTER TABLE route ADD CONSTRAINT fk_route_arrival FOREIGN KEY (arrival_airport_code) REFERENCES airport(airport_code);

ALTER TABLE route ADD CONSTRAINT fk_route_year FOREIGN KEY (year) REFERENCES year(year);

ALTER TABLE flight ADD CONSTRAINT fk_flight_schedule FOREIGN KEY (schedule_id) REFERENCES weeklyschedule(schedule_id);

ALTER TABLE weekday ADD CONSTRAINT fk_weekday_year FOREIGN KEY (year) REFERENCES year(year);

ALTER TABLE weeklyschedule ADD CONSTRAINT fk_schedule_day FOREIGN KEY (day, year) REFERENCES weekday(name_of_day, year);

ALTER TABLE weeklyschedule ADD CONSTRAINT fk_schedule_route FOREIGN KEY (route) REFERENCES route(route_id);

/* END OF TABLE ALTERATION */

/* Question 3: Write procedures for filling the database with flights, etc. These procedures will work as an interface 
with the front-end. 
 a) Insert a year: Procedure call: addYear(year, factor); */

DELIMITER //
CREATE PROCEDURE addYear(IN year INT, IN factor DOUBLE)
BEGIN
      INSERT INTO year(year, profit_factor)
      VALUES (year, factor);
   /* ON DUPLICATE KEY UPDATE year = year + 1; */
END; //
DELIMITER ;

/* b) Insert a day: Procedure call: addDay(year, day, factor); */

DELIMITER //
CREATE PROCEDURE addDay(IN year INT, 
                        IN day VARCHAR(30), 
                        IN factor DOUBLE)
BEGIN
	   INSERT INTO weekday(name_of_day, year, weekday_factor)
       VALUES (day, year, factor);
END; //
DELIMITER ;

/* c) Insert a destination: Procedure call: addDestination(airport_code, name, country); */

DELIMITER //
CREATE PROCEDURE addDestination(IN airport_code VARCHAR(3), IN name VARCHAR(30), IN country VARCHAR(30))
BEGIN
      INSERT INTO airport(airport_code, airport_name, country)
	  VALUES (airport_code, name, country);
END; //
DELIMITER ;

/* d) Insert a route: Procedure call: addRoute(departure_airport_code, arrival_airport_code, year, routeprice); */

DELIMITER //
CREATE PROCEDURE addRoute(IN departure_airport_code VARCHAR(3), 
						  IN arrival_airport_code VARCHAR(3), 
						  IN year INT, 
                          IN routeprice DOUBLE)
BEGIN
	   INSERT INTO route(departure_airport_code, arrival_airport_code, year, route_price)
       VALUES (departure_airport_code, arrival_airport_code, year, routeprice);
END; //
DELIMITER ;

/* e) Insert a weekly flight: Procedure call: addFlight(departure_airport_code, arrival_airport_code, year, day, departure_time); 
Note that this procedure should add information in both weeklyflights and flights (you can assume there are 52 weeks each year). */ 

DELIMITER //
CREATE PROCEDURE addFlight(IN vdeparture_airport_code VARCHAR(3), 
                           IN varrival_airport_code VARCHAR(3), 
						   IN vyear INT, IN vday VARCHAR(10), 
                           IN vdeparture_time TIME)
BEGIN
	DECLARE vweek_nr INT;
	DECLARE vroute_id INT;
	DECLARE vschedule_id INT;
	
 	SET vweek_nr = 1;
	SET vroute_id = (SELECT route_id 
			        FROM route 
			        WHERE route.year = vyear AND route.departure_airport_code = vdeparture_airport_code AND route.arrival_airport_code = varrival_airport_code);                                                                                                    
	
	INSERT INTO weeklyschedule(day, year, route, departure_time)
	VALUES (vday, vyear, vroute_id, vdeparture_time);

	SET vschedule_id = (SELECT schedule_id 
					   FROM weeklyschedule AS ws
				       WHERE ws.day = vday AND ws.year = vyear AND ws.route = vroute_id AND ws.departure_time = vdeparture_time);
                       
    WHILE vweek_nr <= 52 DO
	   INSERT INTO flight(schedule_id, week_nr)
	   VALUES (vschedule_id, vweek_nr);
	   SET vweek_nr = vweek_nr + 1;
	END WHILE;
END; //
DELIMITER ;
DELIMITER ;

/* Question 4: Write two help-functions that do some of the calculations necessary for the booking procedure:

a) Calculate the number of available seats for a certain flight: 
Function call: calculateFreeSeats(flightnumber); where the output is the number of free (unpaid) seats 
(i.e. an integer) on that certain flight. */

DELIMITER //
CREATE FUNCTION calculateFreeSeats(flightnumber INT) 
RETURNS INT 
BEGIN
    DECLARE booked_seats INT;
    DECLARE free_seats INT;
    
    SET booked_seats = (SELECT COUNT(*)
		                FROM unpaidreservation AS UR, reservation AS R, flight AS F
                        WHERE UR.reservation_id = R.reservation_id AND R.flight_id = F.flight_id AND F.flight_id = flightnumber);
    SET free_seats = 40 - booked_seats;
    RETURN free_seats;
END; //
DELIMITER ;

/* b) Calculate the price of the next seat on a flight: 
Function call: calculatePrice(flightnumber); where the output is the price (i.e. a double) of the next seat 
calculated as shown in 1e. */

DELIMITER //
CREATE FUNCTION calculatePrice(flightnumber INT) 
RETURNS DOUBLE 
BEGIN
    DECLARE RoutePrice DOUBLE;
    DECLARE WeekdayFactor DOUBLE;
    DECLARE BookedPassengers INT;
    DECLARE ProfitFactor DOUBLE;
    DECLARE TotalPrice DOUBLE;
    
    SET RoutePrice = (SELECT route_price 
                      FROM route 
                      WHERE route_id = (SELECT route 
			                            FROM weeklyschedule 
										WHERE schedule_id = (SELECT schedule_id
															 FROM flight
                                                             WHERE flight_id = flightnumber)));
	
    SET WeekdayFactor = (SELECT weekday_factor
		                 FROM weekday AS wd
					     JOIN weeklyschedule AS ws ON wd.name_of_day = ws.day AND wd.year = ws.year
						 WHERE schedule_id = (SELECT schedule_id
											  FROM flight
                                              WHERE flight_id = flightnumber));
    
    SET BookedPassengers = 40 - calculateFreeSeats(flightnumber);
    
    SET ProfitFactor = (SELECT profit_factor
						FROM year
                        WHERE year.year = (SELECT year
										   FROM weeklyschedule AS ws
										   WHERE ws.schedule_id = (SELECT schedule_id
																   FROM flight AS F
																   WHERE F.flight_id = flightnumber)));
    
    SET TotalPrice = RoutePrice * WeekdayFactor * ((BookedPassengers + 1)/40) * ProfitFactor;
    RETURN TotalPrice;
END; //
DELIMITER ;

/* Question 5: Create a trigger that issues unique unguessable ticket-numbers (of type integer) for each 
passenger on a reservation once it is paid. An appropriate MySQL function to find unguessable numbers is rand(). */

DELIMITER //
CREATE TRIGGER UniqueTicketGen BEFORE INSERT ON ticket 
FOR EACH ROW
BEGIN
    SET NEW.ticket_id = RAND()*(1000-1)+1;
/* Taken from: 
https://www.techonthenet.com/mysql/functions/rand.php */
END; //
DELIMITER ;

/* Question 6: It is now time to write the stored procedures necessary for creating and handling a reservation 
from the front-end. In addition to the input and output detailed below, see the test-files for appropriate error-messages 
to return in case of unsuccessful payments etc. 

a) Create a reservation on a specific flight. 
Procedure call: addReservation(departure_airport_code, 
                               arrival_airport_code, year, week, day, time, number_of_passengers, 
                               output_reservation_nr); 
where the number_of_passengers is the number of passengers the reservation is for (and only used to check that 
enough unpaid seats are available) and output_reservation_nr is an output-variable and should contain the assigned 
reservation number. */

DELIMITER //
CREATE PROCEDURE addReservation(IN vdeparture_airport_code VARCHAR(3),
                        	    IN varrival_airport_code VARCHAR(3), 
                                IN vyear INT, 
                                IN vweek INT,
			                    IN vday VARCHAR(10), 
                                IN vtime TIME, 
                                IN vnumber_of_passengers INT, 
                                OUT voutput_reservation_nr INT)
BEGIN
DECLARE vflight_id INT;

SET vflight_id = (SELECT DISTINCT flight_id
	             FROM flight f, weeklyschedule ws, route r
                 WHERE f.week_nr = vweek AND f.schedule_id = ws.schedule_id AND ws.day = vday AND ws.year = vyear AND 
                 ws.departure_time = vtime AND ws.route = r.route_id AND r.departure_airport_code = vdeparture_airport_code AND 
                 r.arrival_airport_code = varrival_airport_code AND r.year = vyear);

IF vflight_id IS NULL THEN
		 SELECT "There exist no flight for the given route, date and time" AS "Message";
         /* Alternatively, use:
         SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There exist no flight for the given route, date and time'; */
ELSEIF vnumber_of_passengers > calculateFreeSeats(vflight_id) THEN
	         SELECT "There are not enough seats available on the chosen flight" AS "Message";
             /* Alternatively, use:
             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There are not enough seats available on the chosen flight'; */
ELSE
	  INSERT INTO reservation(flight_id, number_of_seats) 
      VALUES (vflight_id, vnumber_of_passengers);
        
SET voutput_reservation_nr = LAST_INSERT_ID(); /* not recommended on stack overflow, but it works */
        END IF;
END; //
DELIMITER ;

/* b) Add a passenger to a reservation: Procedure call to handle: addPassenger(reservation_nr, passport_number, name); */

DELIMITER //
CREATE PROCEDURE addPassenger(IN vreservation_nr INT, 
                              IN vpassport_number INT, 
                              IN vname VARCHAR(30))
BEGIN
DECLARE vres_id INT;
DECLARE vpassenger_id INT;
DECLARE vpaid_res_id INT;
    
SET vres_id = (SELECT reservation_id 
              FROM reservation 
			  WHERE reservation_id = vreservation_nr);
IF vres_id IS NOT NULL THEN
       SET vpaid_res_id = (SELECT reservation_id 
                          FROM booking 
                          WHERE reservation_id = vreservation_nr);
IF vpaid_res_id IS NULL THEN
        SET vpassenger_id = (SELECT passport_nr
                            FROM passenger 
                            WHERE passport_nr = vpassport_number);
IF vpassenger_id IS NULL THEN
            INSERT INTO passenger(passport_nr, name) 
            VALUES (vpassport_number, vname);
END IF;

            INSERT INTO unpaidreservation(passport_nr, reservation_id)
            VALUES (vpassport_number, vreservation_nr);
ELSE
       SELECT "The booking has already been payed and no further passengers can be added" AS "Message";
       /* Alternatively, use:
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The booking has already been payed and no further passengers can be added'; */
END IF;

ELSE
       SELECT "The given reservation number does not exist" AS "Message";
       /* Alternatively, use:
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The given reservation number does not exist'; */
END IF;
END; //
DELIMITER ;

/* c) Add a contact: Procedure call to handle: addContact(reservation_nr, passport_number, email, phone); 
where the contact already must be added as a passenger to the reservation. */

DELIMITER //
CREATE PROCEDURE addContact(IN vreservation_nr INT, 
                            IN vpassport_number INT, 
                            IN vemail VARCHAR(30), 
                            IN vphone BIGINT(20))
BEGIN
    DECLARE vres_id INT;
    DECLARE vcontact_id INT;

    SET vres_id = (SELECT reservation_id
                  FROM reservation 
                  WHERE reservation_id = vreservation_nr);
    SET vcontact_id = (SELECT DISTINCT p.passport_nr 
	                FROM passenger p, unpaidreservation ur 
                      WHERE p.passport_nr = vpassport_number AND ur.passport_nr = vpassport_number AND ur.reservation_id = vreservation_nr);
   IF vres_id IS NULL THEN 
	    SELECT "The given reservation number does not exist" AS "Message";
        /* Alternatively, use:
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The given reservation number does not exist'; */
   ELSEIF vcontact_id IS NULL THEN
	            SELECT "The person is not a passenger of the reservation" AS "Message";
                /* Alternatively, use:
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The person is not a passenger of the reservation'; */
   ELSE 
          INSERT INTO contact(passport_nr, email, phone_nr) 
          VALUES (vpassport_number, vemail, vphone); 
     UPDATE reservation SET contact_passport_nr = vpassport_number WHERE reservation_id = vreservation_nr;     
   END IF;
END; //
DELIMITER ;

/* d) Add a payment: Procedure call to handle: addPayment (reservation_nr, cardholder_name, credit_card_number); 
This procedure should, if the reservation has a contact and there are enough unpaid seats on the plane, 
add payment information to the reservation and save the amount to be drawn from the credit card in the database. 
If the conditions above are not fulfilled the appropriate error message should be shown. */

DELIMITER //
CREATE PROCEDURE addPayment(IN vreservation_nr INT, 
                            IN vcardholder_name VARCHAR(30), 
                            IN vcredit_card_number BIGINT(20))
BEGIN
    DECLARE vres_id INT;
    DECLARE vcontact_res INT;
    DECLARE vflight_id INT;
    DECLARE vavailable_seats INT;
    DECLARE vtotal_price DOUBLE;
    
    SET vres_id = (SELECT reservation_id
                  FROM reservation 
                  WHERE reservation_id = vreservation_nr);
    IF vres_id IS NOT NULL THEN
	     SET vcontact_res = (SELECT contact_passport_nr 
                            FROM reservation 
                            WHERE reservation_id = vres_id);
    IF vcontact_res IS NOT NULL THEN
	         SET vflight_id = (SELECT flight_id 
                              FROM reservation 
                              WHERE reservation_id = vreservation_nr AND contact_passport_nr = vcontact_res);
			 SET vavailable_seats = (SELECT number_of_seats 
                                    FROM reservation 
                                    WHERE reservation_id = vreservation_nr AND contact_passport_nr = vcontact_res AND flight_id = vflight_id);
    IF calculateFreeSeats(vflight_id) > 0 THEN
	                    INSERT INTO creditcard(card_nr, card_holder) 
                        VALUES (vcredit_card_number, vcardholder_name);
         SET vtotal_price = calculatePrice(vflight_id);
         INSERT INTO booking(reservation_id, card_nr, route_price) 
         VALUES (vreservation_nr, vcredit_card_number, vtotal_price);
         INSERT INTO ticket(passport_nr, reservation_id) SELECT passport_nr, reservation_id 
                                                         FROM unpaidreservation 
                                                         WHERE reservation_id = vreservation_nr;
    ELSE
         DELETE FROM unpaidreservation WHERE reservation_id = vreservation_nr;
         DELETE FROM reservation WHERE reservation_id = vreservation_nr;
         SELECT "There are not enough seats available on the flight anymore, deleting reservation" AS "Message";
         /* Alternatively, use:
         SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'There are not enough seats available on the flight anymore, deleting reservation'; */
    END IF;
 ELSE
        SELECT "The reservation has no contact yet" AS "Message";
        /* Alternatively, use:
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The reservation has no contact yet'; */
 END IF;
ELSE
        SELECT "The given reservation number does not exist" AS "Message";
        /* Alternatively, use:
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The given reservation number does not exist'; */
    END IF;
END; //
DELIMITER ;

/* Question 7: Create a view allFlights containing all flights in your database with the following information: 
departure_city_name, destination_city_name, departure_time, departure_day, departure_week, departure_year, nr_of_free_seats, 
current_price_per_seat. See the testcode for an example of how it can look like. */

CREATE VIEW allFlights(departure_city_name, 
                       destination_city_name, 
                       departure_time, 
                       departure_day, 
                       departure_week, 
                       departure_year, 
                       nr_of_free_seats,  
                       current_price_per_seat) AS
SELECT dep_airport.airport_name AS "departure_city_name", 
       arr_airport.airport_name AS "destination_city_name", 
       ws.departure_time AS "departure_time", 
       ws.day AS "departure_day",  
       f.week_nr AS "departure_week", 
       ws.year AS "departure_year",
       calculateFreeSeats(f.flight_id) AS "nr_of_free_seats", 
       ROUND(calculatePrice(f.flight_id), 3) AS "current_price_per_seat"
FROM weeklyschedule AS ws, flight AS f, route AS r, airport AS dep_airport, airport AS arr_airport
WHERE ws.schedule_id = f.schedule_id AND ws.route = r.route_id AND r.departure_airport_code = dep_airport.airport_code AND r.arrival_airport_code = arr_airport.airport_code;

/* Question 8: Answer the following theoretical questions:
a) How can you protect the credit card information in the database from hackers? */

/* Answer: The first thing that comes to mind since credit card information is admittedly sensitive is to encrypt the data. 
The next step would be to enforce passwords to the database and allow access only to authorized personnel. 
As an additional step, one could use database firewalls that would not only take care of unauthorized access, 
but also log the connections made and take appropriate action in case of attack or fraud. However, the latter could be taken 
care of Fraud Analysts. */

/* b) Give three advantages of using stored procedures in the database (and thereby execute them on the server) 
instead of writing the same functions in the front-end of the system (in for example java-script on a web-page)? */

/* Answer: 
1) Increased productivity/reusability: Stored procedures can be used by multiple applications and there is no need to 
write code multiple times for the same thing.
2) Security: As we discussed above, if the database is protected by authorized personnel then direct access to tables 
can be avoided. Only database maintainers can grant permissions to specific users, thus enhancing security by directing 
data manipulation through stored procedures.
3) Faster performance: Stored procedures are compiled once and are stored in an executable form during one session. 
Therefore, we achieve faster and higher performance. */

/* Question 9: Open two MySQL sessions. We call one of them A and the other one B. Write START TRANSACTION; in both terminals.
a) In session A, add a new reservation. */

/* To open 2 sessions on MySQL Workbench: Home > double-click on MySQL Connections > uncomment and type the following to test */

/*SESSION A: */ 
/*START TRANSACTION;
CALL addYear(2010, 2.3);
CALL addDay(2010, "Monday", 1);
CALL addDestination("MIT", "Minas Tirith", "Mordor");
CALL addDestination("HOB", "Hobbiton", "The Shire");
CALL addRoute("MIT", "HOB", 2010, 2000);
CALL addFlight("MIT", "HOB",  2010, "Monday", "09:00:00");
CALL addReservation("MIT", "HOB", 2010, 1, "Monday", "09:00:00", 3, @a); 
SELECT * 
FROM reservation; */

/* SESSION B: */
/*START TRANSACTION;
SELECT * 
FROM reservation;
UPDATE reservation SET number_of_seats = 19 WHERE reservation_id = 1; */

/* b) Is this reservation visible in session B? Why? Why not? */

/* Answer:  The reservation is of course not visible in Session B since we have not commited the changes made in Session A. 
Only after changes are commited (and thus, made permanent) in Session A, can we see them in a new transaction B.*/

/* c) What happens if you try to modify the reservation from A in B? Explain what happens and why this happens and how 
this relates to the concept of isolation of transactions. */

/* Answer: When we try to modify the reservation from Session A in Session B, e.g. change the year, we can see that 
running the query is not possible. This is related to the concept of isolation in databases. More specifically, 
database transactions need to complete their tasks independently from other transactions, which means that we cannot 
make any changes in Session B until transactions in Session A have commited their actions first. */

/* Question 10: Is your BryanAir implementation safe when handling multiple concurrent transactions? 
Let two customers try to simultaneously book more seats than what are available on a flight and see what happens. 
This is tested by executing the testscripts available on the course-page using two different MySQL sessions. 
Note that you should not use explicit transaction control unless this is your solution on 10c.

a) Did overbooking occur when the scripts were executed? If so, why? If not, why not? */

/* Answer: It did not occur. Since the booking process started in Session A before Session B, the operations that run 
on both terminals use common tables. In our case, the insertion of rows in certain tables fails due to duplication issues 
making, thus, the process stop and prevent overbooking. But even if that didn't happen, on an implementational level, we 
would still have gotten 0 overbookings since there is a protecting condition that checks the number of available seats 
in a particular flight before proceding to the payment option for the current booking. */

/* b) Can an overbooking theoretically occur? If an overbooking is possible, in what order must the lines of code in your 
procedures/functions be executed. */

/* Answer: Yes, it can if operations for both terminals run exactly at the same time. Once we pass the check condition 
mentioned in part a) on both terminals for 2 (or more) reservations, then overbooking can occur. */

/* c) Try to make the theoretical case occur in reality by simulating that multiple sessions call the procedure at 
the same time. To specify the order in which the lines of code are executed use the MySQL query SELECT sleep(5); 
which makes the session sleep for 5 seconds. Note that it is not always possible to make the theoretical case occur, 
if not, motivate why. */

/* Answer: A possible way to make the theoretical case occur would be to run the test script provided in two separate 
transactions. Notice that since we did not commit our changes before creating Session B, the addPayment procedure is able 
to complete the payment for both reservations. In order to cause an overbooking to occur, we would have to commit both 
transactions. It is also worth mentioning that despite using the query SELECT sleep(5); in the beginning of the addPassenger 
procedure to trigger the overbooking, we were not able to make it possible. */

/* d) Modify the testscripts so that overbookings are no longer possible using (some of) the commands START TRANSACTION, 
COMMIT, LOCK TABLES, UNLOCK TABLES, ROLLBACK, SAVEPOINT, and SELECT…FOR UPDATE. Motivate why your solution solves the issue, 
and test that this also is the case using the sleep implemented in 10c. Note that it is not ok that one of the sessions ends 
up in a deadlock scenario. Also, try to hold locks on the common resources for as short time as possible to allow multiple 
sessions to be active at the same time. */

/* Answer: A way to prevent overbookings in our test script is to use LOCK TABLES before the addPayment procedure. 
More specifically, we can start the first transaction and then the addPayment procedure will be done. Next, we call 
UNLOCK TABLES and COMMIT the modifications made in the first transaction. This way, when the second transaction starts it 
will detect only 19 free seats and abort the payment. This is a win-win for us since we will have prevented overbooking. */

/* Secondary Index: 
We can perform secondary indexing on a non-key that is unordered. Possible attributes that could fit this criterion 
are 'ticket_id' on the *ticket* relation or 'name' on the *passenger* relation. The logic goes as follows: an airline normally 
deals with many passengers. These passengers are bound to share the same name. Therefore, we could use a secondary index with 
the name field and point it to the block containing the corresponding row. This will make the secondary index be sorted according
to name which in turn, will allow for more efficient binary search. Please see the .drawio file in our GitLab folder for a visual 
representation.  */