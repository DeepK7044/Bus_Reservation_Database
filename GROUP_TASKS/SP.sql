-- Display the Bus_Schedule Details: 
-- Bus_Id,Starting_Point,Destination_Point,Departure_Time,Departure_Date,Available_Seats,Ticket_Price,Rating
-- where  Starting_Point='Ahmedabad_Gita Mandir',Destination_Point='Surat_Surat Central Bus station',Departure_Time AT NIGHT

CREATE PROCEDURE spBus_Schedule
@SOURCE TINYINT,
@Starting_Point TINYINT,
@Destination TINYINT,
@Destination_Point TINYINT,
@Departure_Date DATE,
@Duration_START_Time TIME,
@Duration_END_Time TIME
AS
BEGIN
        SELECT Bus_Id,Starting_Point,Destination_Point,Departure_Time,Departure_Date,Available_Seats,Ticket_Price,Rating FROM TRAVEL_SCHEDULE AS TS
        WHERE TS.[Source]=@SOURCE 
		AND TS.Starting_Point=@Starting_Point
		AND TS.Destination=@Destination
		AND TS.Destination_Point=@Destination_Point
		AND Departure_Date=@Departure_Date
		AND TS.Departure_Time BETWEEN @Duration_START_Time AND @Duration_END_Time
		AND Travel_Status=1
END

EXECUTE spBus_Schedule 16,2,17,10,'2021-08-26','6:00 PM','11:00 PM'



-- PERTICULAR Day-wise USER,Pessanger Booking And other Information:
-- DISPLAY tHE USER_NAME AS(First_Name,Last_Name) WHO BOOKED TICKET AT 22 AUGUST AND ALSO GET Insurance Details
-- And Also show The how many seat that user book and name of all Pessanger ,their Seat_No and Age,BUS Number Plate.

CREATE PROCEDURE spUserPassangerBookingDetails
@Date DATE
AS
BEGIN
		SELECT [USER_NAME]=(UR.First_Name+SPACE(1)+UR.Last_Name),PR.Passenger_Name,PR.Age,PR.Gender,PR.Seat_No,BS.Bus_Plate_Number,BS.Bus_Id FROM TICKETS AS T 
		INNER JOIN USER_INFO AS UR ON T.User_Id=UR.User_Id
		INNER JOIN BOOKING_DETAILS AS BK ON BK.User_Id=T.User_Id
		INNER JOIN PASSENGER AS PR ON PR.User_Id=T.User_Id
		INNER JOIN BUS AS BS ON BS.Bus_Id=PR.Bus_Id
		WHERE BK.Booking_Date=@Date AND T.Insurance=1 
END

EXECUTE spUserPassangerBookingDetails '2021-08-22'

-- Display The Driver Name Who drive bus Which NUMBER_PLATE IS GJ04KI4967 
-- and Also Display Their Starting_Point,Destination_Point,BUS_TYPE,AC/NONAC.

CREATE PROCEDURE spBusScheduleDetails
@Number_Plate VARCHAR(15)
AS
BEGIN
		SELECT (DR.First_Name+' '+DR.Last_Name) AS Driver_Name,DR.Contact_No,TS.Starting_Point,TS.Destination_Point,AC_Type,BS.Bus_Plate_Number,BS.Bus_Type AS BUS_TYPE FROM BUS AS BS 
		INNER JOIN DRIVER AS DR ON BS.Bus_Id=DR.Bus_Id
		INNER JOIN TRAVEL_SCHEDULE AS TS ON TS.Bus_Id=BS.Bus_Id
		WHERE BS.Bus_Plate_Number=@Number_Plate
END

EXECUTE spBusScheduleDetails 'GJ04KI4967'


-------------------------------------WHILE LOOP IN SP----------------------------------------------------

SELECT * FROM TRAVEL_SCHEDULE

CREATE PROCEDURE spSchedule_Status
AS
BEGIN
DECLARE @ID TINYINT
DECLARE @DATE DATE
DECLARE @TIME TIME
DECLARE @COUNT TINYINT
SELECT  @COUNT=(SELECT TOP(1) Schedule_Id FROM TRAVEL_SCHEDULE ORDER BY Schedule_Id DESC)
SET @ID=1
WHILE(@COUNT > @ID)
BEGIN
SELECT @DATE=Departure_Date,@TIME=Departure_Time FROM TRAVEL_SCHEDULE WHERE Schedule_Id=@ID

	IF(DATEDIFF(DD,GETDATE(),@DATE) < 0)
	BEGIN
		UPDATE TRAVEL_SCHEDULE SET Travel_Status=0
		WHERE Schedule_Id=@ID		
	END
	ELSE
		IF(DATEDIFF(HOUR,GETDATE(),@TIME) < 0)
		BEGIN
		UPDATE TRAVEL_SCHEDULE SET Travel_Status=0
		WHERE Schedule_Id=@ID
		END
	
	SET @ID=@ID+1
END
END

EXEC spSchedule_Status



