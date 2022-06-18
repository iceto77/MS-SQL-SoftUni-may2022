CREATE DATABASE TripService

GO

USE TripService

GO

--01 

CREATE TABLE [Cities]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	[CountryCode] CHAR(2) NOT NULL
)

CREATE TABLE [Hotels]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30) NOT NULL,
	[CityId] INT FOREIGN KEY REFERENCES [Cities]([Id]) NOT NULL,
	[EmployeeCount] INT NOT NULL,
	[BaseRate] DECIMAL (15,2)
)

CREATE TABLE [Rooms]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Price] DECIMAL (15,2) NOT NULL,
	[Type] NVARCHAR(20) NOT NULL,
	[Beds] INT NOT NULL,
	[HotelId] INT FOREIGN KEY REFERENCES [Hotels]([Id]) NOT NULL
)

CREATE TABLE [Trips]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[RoomId] INT FOREIGN KEY REFERENCES [Rooms]([Id]) NOT NULL,
	[BookDate] DATE NOT NULL,
	[ArrivalDate] DATE NOT NULL,
	CHECK ([BookDate] < [ArrivalDate]),
	[ReturnDate] DATE NOT NULL,
	CHECK ([ArrivalDate] < [ReturnDate]),
	[CancelDate] DATE
)

CREATE TABLE [Accounts]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(50) NOT NULL,
	[MiddleName] NVARCHAR(20),
	[LastName] NVARCHAR(50) NOT NULL,
	[CityId] INT FOREIGN KEY REFERENCES [Cities]([Id]) NOT NULL,
	[BirthDate] DATE NOT NULL,
	[Email] VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE [AccountsTrips]
(
	[AccountId] INT FOREIGN KEY REFERENCES [Accounts]([Id]) NOT NULL,
	[TripId] INT FOREIGN KEY REFERENCES [Trips]([Id]) NOT NULL,
	[Luggage] INT NOT NULL,
	CHECK([Luggage] >= 0),
	PRIMARY KEY([AccountId], [TripId])
)


--02

INSERT INTO [Accounts]([FirstName], [MiddleName], [LastName], [CityId], [BirthDate], [Email])
	VALUES
	('John', 'Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
	('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
	('Ivan', 'Petrovich', 'Pavlov',	59, '1849-09-26', 'i_pavlov@softuni.bg'),
	('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO [Trips]([RoomId], [BookDate], [ArrivalDate], [ReturnDate], [CancelDate])
	VALUES
	(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
	(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
	(103, '2013-07-17', '2013-07-23', '2013-07-24',	NULL),
	(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
	(109, '2017-08-07', '2017-08-28', '2017-08-29',	NULL)


--03

UPDATE [Rooms]
SET [Price] *= 1.14
WHERE [HotelId] IN (5, 7, 9)


--04

DELETE
FROM [AccountsTrips]
WHERE [AccountId] = 47

--05

  SELECT 
	     a.[FirstName],
	     a.[LastName],
	     CONCAT(CASE
				WHEN DATEPART(MONTH, a.[BirthDate]) < 10 THEN CONCAT('0', DATEPART(MONTH, a.[BirthDate]))
				ELSE CONCAT('', DATEPART(MONTH, a.[BirthDate]))
			  END,
			  CASE
				WHEN DATEPART(DAY, a.[BirthDate]) < 10 THEN CONCAT('-0', DATEPART(DAY, a.[BirthDate]))
				ELSE CONCAT('-', DATEPART(DAY, a.[BirthDate]))
			  END,
			  CONCAT('-',DATEPART(YEAR, a.[BirthDate]))) AS [BirthDate],
	     c.[Name] AS Hometown,
	     a.[Email]
    FROM [Accounts] AS a
    JOIN [Cities] AS c
      ON a.[CityId] = c.[Id]
   WHERE [Email] LIKE 'E%'
ORDER BY c.[Name]

--06

   SELECT c.[Name],
		  COUNT(h.[Name]) AS 'Hotels'
     FROM [Hotels] AS h
LEFT JOIN [Cities] AS c
	   ON h.[CityId] = c.[Id]
 GROUP BY c.[Name]
 ORDER BY [Hotels] DESC, c.[Name]

--07

  SELECT 
		 [AccountId],
		 [FullName],
		 MAX([TripDuration]) AS 'LongestTrip',
		 MIN([TripDuration]) AS 'ShortestTrip'
    FROM
		 (
		  SELECT 
				 at.[AccountId],
				 CONCAT(a.[FirstName], ' ', a.[LastName]) AS 'FullName',
				 DATEDIFF(DAY, t.[ArrivalDate], t.[ReturnDate]) AS 'TripDuration'
			FROM [Trips] AS t
			JOIN [AccountsTrips] AS at
			  ON at.[TripId] = t.[Id]
			JOIN [Accounts] AS a
			  ON at.[AccountId] = a.[Id]
		   WHERE a.[MiddleName] IS NULL
		     AND T.[CancelDate] IS NULL
		 ) AS [AccountsTripDurationQuery]
GROUP BY  [FullName], [AccountId]
ORDER BY [LongestTrip] DESC, [ShortestTrip]

--08

SELECT TOP (10)
		 c.[Id],
		 c.[Name] AS 'City',
		 c.[CountryCode] AS 'Country',
		 COUNT(a.[Id]) AS 'Accounts'
    FROM [Cities] AS c
	JOIN [Accounts] AS a 
      ON a.[CityId] = c.[Id]
GROUP BY c.[Name], c.[Id], c.[CountryCode]
ORDER BY [Accounts] DESC

--09

  SELECT 
		  [Id],
		  [Email],
		  [City],
		  COUNT([Id]) AS 'Trips'
	FROM ( 
		  SELECT 
				 a.[Id] AS 'Id', 
				 a.[Email] AS 'Email',
				 c.[Name] AS 'City'
			FROM [Accounts] AS A
			JOIN [Cities] AS c
			  ON c.[Id] = a.[CityId]
			JOIN [AccountsTrips] AS at
			  ON at.[AccountId] = a.[Id]
			JOIN [Trips] AS t
			  ON t.[Id] = at.[TripId]
			JOIN [Rooms] AS r
			  ON r.[Id] = t.[RoomId]
			JOIN [Hotels] AS h
			  ON h.[Id] = R.[HotelId]
			WHERE a.[CityId] = h.[CityId]
		  ) AS [CurrentTripQuery]
GROUP BY [City], [Email], [Id]
ORDER BY [Trips] DESC, [Id]

--10

  SELECT 
		 at.TripId,
		 CONCAT(a.FirstName, ' ', ISNULL(MiddleName+' ',''), a.LastName) AS [Full Name],
		 ac.[Name] AS [From],
		 hc.[Name] AS [To],
		 CASE
			WHEN t.[CancelDate] IS NULL THEN CONCAT(DATEDIFF(DAY, t.[ArrivalDate], t.[ReturnDate]), ' days')
			ELSE 'Canceled'
		 END AS 'Duration'
	FROM AccountsTrips AS at       
	JOIN Accounts AS a 
	  ON at.AccountId = a.[Id]
    JOIN Trips AS t 
	  ON at.TripId = t.Id
	JOIN Cities AS ac
	  ON a.CityId = ac.Id
	JOIN Rooms AS r
	  ON t.RoomId = r.Id
	JOIN Hotels AS h
	  ON r.HotelId = h.Id
	JOIN Cities AS hc
	  ON h.CityId = hc.Id
ORDER BY [Full Name], at.TripId

--11

GO

CREATE OR ALTER FUNCTION [udf_GetAvailableRoom](@hotelId INT, @date DATE, @people INT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @roomInfo NVARCHAR(MAX)
	DECLARE @roomIsFree INT = (
				 SELECT TOP (1)
							CASE
								WHEN  @date >= t.ArrivalDate AND @date <= t.ReturnDate THEN 0
								ELSE 1
							END 
					   FROM Rooms AS r
					   JOIN Trips AS t ON t.RoomId = r.Id
					  WHERE HotelId = @hotelId AND Beds >= @people
				   ORDER BY 1  )


	IF @roomIsFree = 0 
		SET @roomInfo = 'No rooms available';
	ELSE
		SET @roomInfo = (	
						SELECT 
								CONCAT('Room ', [roomID],': ', [roomType], ' (', [bedsInRoom], ' beds) - $',[totalPrice])
						  FROM (
								  SELECT TOP (1)
											 r.Id AS roomID,
											 r.Type AS roomType,
											 r.Beds AS bedsInRoom,
											 (h.BaseRate + r.Price) *  @people AS totalPrice
			 							FROM Rooms AS r
										JOIN Trips AS t ON t.RoomId = r.Id
										JOIN Hotels AS h ON r.HotelId = h.Id
										WHERE HotelId = @hotelId AND Beds >= @people AND (DATEDIFF(DAY, @date, t.ArrivalDate ) > 0 OR DATEDIFF(DAY, t.ReturnDate, @date) > 0)
									ORDER BY totalPrice DESC
								) AS [infoSumQuery]
	);
	IF @roomInfo IS NULL
		SET @roomInfo = 'No rooms available';	

	RETURN @roomInfo
END

GO
--това не се дава в judge, само за мой тест
SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)
SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3)

--12

GO

CREATE OR ALTER PROC [usp_SwitchRoom] @TripId INT, @TargetRoomId INT
AS
BEGIN
	BEGIN TRY
		IF(SELECT HotelId
			FROM Rooms AS r
			JOIN Hotels AS h ON r.HotelId = h.Id
			AND r.Id = @TargetRoomId) <> (
										 SELECT HotelId
										   FROM Trips AS t
										   JOIN Rooms AS r ON t.RoomId = r.Id
										   JOIN Hotels AS h ON r.HotelId = h.Id
										    AND t.Id = @TripId)
			THROW 50001, 'Target room is in another hotel!', 1;
		IF (SELECT Beds
			  FROM Rooms
			 WHERE ID = @TargetRoomId) < (SELECT COUNT(*)
								 FROM AccountsTrips AS at
								WHERE TripId = @TripId)
			THROW 50001, 'Not enough beds in target room!', 1;
		UPDATE Trips
		   SET RoomId = @TargetRoomId
		 WHERE Id = @TripId
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE();
	END CATCH  
END

GO
--това не се дава в judge, само за мой тест
EXEC dbo.usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10
EXEC dbo.usp_SwitchRoom 10, 7
EXEC dbo.usp_SwitchRoom 10, 8
