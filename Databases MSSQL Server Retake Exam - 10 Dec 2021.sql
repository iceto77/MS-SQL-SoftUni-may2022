CREATE DATABASE Airport

GO

USE Airport

GO

--01 

CREATE TABLE [Passengers]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[FullName] VARCHAR(100) UNIQUE NOT NULL,
	[Email] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE [Pilots]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(30) UNIQUE NOT NULL,
	[LastName] VARCHAR(30) UNIQUE NOT NULL,
	[Age] TINYINT NOT NULL
		CHECK ([Age] BETWEEN 21 AND 62),
	[Rating] FLOAT
		CHECK ([Rating] BETWEEN 0 AND 10 OR [Rating] IS NULL)
)

CREATE TABLE [AircraftTypes]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[TypeName] VARCHAR(30) UNIQUE NOT NULL
)

CREATE TABLE [Aircraft]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Manufacturer] VARCHAR(25) NOT NULL,
	[Model] VARCHAR(30) NOT NULL,
	[Year] INT NOT NULL,
	[FlightHours] INT,
	[Condition] CHAR(1) NOT NULL,
	[TypeId] INT FOREIGN KEY REFERENCES [AircraftTypes]([Id]) NOT NULL
)

CREATE TABLE [PilotsAircraft]
(
	[AircraftId] INT FOREIGN KEY REFERENCES [Aircraft]([Id]) NOT NULL,
	[PilotId] INT FOREIGN KEY REFERENCES [Pilots]([Id]) NOT NULL,
	PRIMARY KEY([AircraftId], [PilotId])
)

CREATE TABLE [Airports]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[AirportName] VARCHAR(70) UNIQUE NOT NULL,
	[Country] VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE [FlightDestinations]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[AirportId] INT FOREIGN KEY REFERENCES [Airports]([Id]) NOT NULL,
	[Start] DATETIME NOT NULL,
	[AircraftId] INT FOREIGN KEY REFERENCES [Aircraft]([Id]) NOT NULL,
	[PassengerId] INT FOREIGN KEY REFERENCES [Passengers]([Id]) NOT NULL,
	[TicketPrice] DECIMAL(18,2) NOT NULL DEFAULT 15
)

--02

INSERT INTO [Passengers] ([FullName], [Email])
SELECT 
		CONCAT(FirstName, ' ',LastName) AS [FullName],
		CONCAT(FirstName,LastName,'@gmail.com') AS [Email]
FROM Pilots
WHERE [Id] BETWEEN 5 AND 15

--03

UPDATE Aircraft
SET Condition = 'A'
WHERE Condition IN ('C', 'B')
AND (FlightHours IS NULL OR FlightHours <= 100)
AND  [Year] >= 2013

--04

DELETE 
FROM Passengers
WHERE LEN(FullName) <= 10

--05

  SELECT 
		 Manufacturer,
		 Model,
		 FlightHours, 
		 Condition
    FROM Aircraft
ORDER BY FlightHours DESC

--06

  SELECT 
		 FirstName,
		 LastName,
		 Manufacturer,
		 Model,
		 FlightHours
    FROM Pilots AS p
	JOIN PilotsAircraft AS ap
	  ON ap.PilotId = p.Id
	JOIN Aircraft AS a
	  ON ap.AircraftId = a.Id
   WHERE FlightHours IS NOT NULL AND FlightHours <= 304
ORDER BY FlightHours DESC, FirstName

--07

SELECT TOP (20)
				fd.[Id] AS DestinationId,
				fd.[Start],
				p.FullName,
				a.AirportName,
				fd.TicketPrice
		   FROM FlightDestinations AS fd
		   JOIN Passengers AS p
		     ON fd.PassengerId = p.Id
		   JOIN Airports AS a
		     ON fd.AirportId = a.Id
		  WHERE DATEPART(DAY, [Start]) % 2 = 0
	   ORDER BY fd.TicketPrice DESC, a.AirportName

--08

  SELECT 
		 AircraftId,
		 Manufacturer,
		 FlightHours,
		 COUNT(*) AS FlightDestinationsCount,
		 ROUND(AVG(TicketPrice), 2) AS AvgPrice
    FROM Aircraft AS ac
	JOIN FlightDestinations AS fd
      ON fd.AircraftId = ac.Id
GROUP BY AircraftId, Manufacturer, FlightHours  
  HAVING COUNT(*) >= 2
ORDER BY FlightDestinationsCount DESC, AircraftId

--09

   SELECT
		  FullName,
		  COUNT(AircraftId) AS CountOfAircraft,
		  SUM(TicketPrice) AS TotalPayed
	 FROM Passengers AS p
LEFT JOIN FlightDestinations AS fd
	   ON fd.PassengerId = p.Id
	WHERE SUBSTRING(FullName, 2, 1) = 'a'
 GROUP BY FullName
   HAVING COUNT(AircraftId) > 1
 ORDER BY FullName

--10

  SELECT
		 ap.AirportName,
		 fd.[Start] as DayTime,
		 fd.TicketPrice,
		 p.FullName,
		 ac.Manufacturer,
		 ac.Model
    FROM FlightDestinations AS fd
	JOIN Passengers AS p
      ON fd.PassengerId = p.Id
	JOIN Aircraft AS ac
      ON fd.AircraftId = ac.Id
	JOIN Airports AS ap
      ON fd.AirportId = ap.Id
   WHERE DATEPART(HOUR, fd.[Start]) BETWEEN 6 AND 20
	 AND fd.TicketPrice > 2500
ORDER BY ac.Model

--11

GO

CREATE FUNCTION [udf_FlightDestinationsByEmail](@email VARCHAR(30))
RETURNS INT
AS
BEGIN
	DECLARE	@count INT = (SELECT COUNT(*)
					  FROM FlightDestinations AS fd
					  JOIN Passengers AS p
					    ON fd.PassengerId = p.Id
					  WHERE p.Email = @email)
	RETURN @count
END

GO
--това не се дава в judge, само за мой тест
SELECT dbo.udf_FlightDestinationsByEmail ('PierretteDunmuir@gmail.com')

--12

GO

CREATE PROC [usp_SearchByAirportName] @airportName VARCHAR(70)
AS
BEGIN
	 SELECT
			ap.AirportName, 
			p.FullName,
			CASE
				WHEN fd.TicketPrice < 401 THEN 'Low'
				WHEN fd.TicketPrice  BETWEEN 401 AND 1500 THEN 'Medium'
				WHEN fd.TicketPrice > 1500 THEN 'High'
			END AS LevelOfTickerPrice,
			ac.Manufacturer,
			ac.Condition,
			at.TypeName
	   FROM Airports AS ap
  LEFT JOIN FlightDestinations AS fd
		 ON fd.AirportId = ap.Id
  LEFT JOIN Passengers AS P
		 ON fd.PassengerId = p.Id
  LEFT JOIN Aircraft AS ac
		 ON fd.AircraftId = ac.Id
  LEFT JOIN AircraftTypes AS at
		 ON ac.TypeId = at.Id
	  WHERE ap.AirportName = @airportName
   ORDER BY ac.Manufacturer, p.FullName
END

GO
--това не се дава в judge, само за мой тест
EXEC usp_SearchByAirportName 'Sir Seretse Khama International Airport'
