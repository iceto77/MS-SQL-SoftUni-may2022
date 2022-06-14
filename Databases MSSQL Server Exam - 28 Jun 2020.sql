CREATE DATABASE ColonialJourney

GO

USE ColonialJourney

GO


--01 

CREATE TABLE [Planets]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL
)

CREATE TABLE [Spaceports]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[PlanetId] INT FOREIGN KEY REFERENCES [Planets]([Id]) NOT NULL
)

CREATE TABLE [Spaceships]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[Manufacturer] VARCHAR(30) NOT NULL,
	[LightSpeedRate] INT DEFAULT 0
)

CREATE TABLE [Colonists]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(20) NOT NULL,
	[LastName] VARCHAR(20) NOT NULL,
	[Ucn] VARCHAR(10) UNIQUE NOT NULL,
	[BirthDate] DATE NOT NULL
)

CREATE TABLE [Journeys]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[JourneyStart] DATETIME NOT NULL,
	[JourneyEnd] DATETIME NOT NULL,
	[Purpose] VARCHAR(11),
	CHECK ([Purpose] = 'Medical' OR [Purpose] = 'Technical' OR [Purpose] = 'Educational' OR [Purpose] = 'Military'),
	[DestinationSpaceportId] INT FOREIGN KEY REFERENCES [Spaceports]([Id]) NOT NULL,
	[SpaceshipId] INT FOREIGN KEY REFERENCES [Spaceships]([Id]) NOT NULL
)

CREATE TABLE [TravelCards]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[CardNumber] CHAR(11) UNIQUE NOT NULL,
	[JobDuringJourney] VARCHAR(8),
	CHECK ([JobDuringJourney] = 'Pilot' OR [JobDuringJourney] = 'Engineer' OR [JobDuringJourney] = 'Trooper' 
												OR [JobDuringJourney] = 'Cleaner' OR [JobDuringJourney] = 'Cook'),
	[ColonistId] INT FOREIGN KEY REFERENCES [Colonists]([Id]) NOT NULL,
	[JourneyId] INT FOREIGN KEY REFERENCES [Journeys]([Id]) NOT NULL
)

--02

INSERT INTO [Planets]([Name])
	VALUES
	('Mars'),
	('Earth'),
	('Jupiter'),
	('Saturn')

INSERT INTO [Spaceships]([Name], [Manufacturer], [LightSpeedRate])
	VALUES
	('Golf', 'VW', 3),
	('WakaWaka', 'Wakanda', 4),
	('Falcon9', 'SpaceX', 1),
	('Bed', 'Vidolov', 6)

--03

UPDATE [Spaceships]
SET [LightSpeedRate] += 1 
WHERE [Id] BETWEEN 8 AND 12

--04

DELETE
FROM [TravelCards]
WHERE [JourneyId] BETWEEN 1 AND 3

DELETE 
FROM [Journeys]
WHERE [Id] BETWEEN 1 AND 3

--05

  SELECT 
		 j.[Id],
		 CONCAT(CASE
					WHEN DATEPART(DAY, j.[JourneyStart]) < 10 THEN CONCAT('0', DATEPART(DAY, j.[JourneyStart]))
					ELSE CONCAT('', DATEPART(DAY, j.[JourneyStart]))
				END,
				CASE
					WHEN DATEPART(MONTH, j.[JourneyStart]) < 10 THEN CONCAT('/0', DATEPART(MONTH, j.[JourneyStart]))
					ELSE CONCAT('/', DATEPART(MONTH, j.[JourneyStart]))
				END,
				CONCAT('/',DATEPART(YEAR, j.[JourneyStart]))) AS [JourneyStart],
		 CONCAT(CASE
					WHEN DATEPART(DAY, j.[JourneyEnd]) < 10 THEN CONCAT('0', DATEPART(DAY, j.[JourneyEnd]))
					ELSE CONCAT('', DATEPART(DAY, j.[JourneyEnd]))
				END,
				CASE
					WHEN DATEPART(MONTH, j.[JourneyEnd]) < 10 THEN CONCAT('/0', DATEPART(MONTH, j.[JourneyEnd]))
					ELSE CONCAT('/', DATEPART(MONTH, j.[JourneyEnd]))
				END,
				CONCAT('/',DATEPART(YEAR, j.[JourneyEnd]))) AS [JourneyEnd]
    FROM [Journeys] AS j
   WHERE j.[Purpose] = 'Military'
ORDER BY j.[JourneyStart]

--06

  SELECT 
		 c.[Id] AS 'Id',
		 CONCAT(c.[FirstName], ' ', c.[LastName]) AS 'FullName'
	FROM [TravelCards] AS tc
	JOIN [Journeys] AS j
	  ON tc.[JourneyId] = j.[Id]
	JOIN [Colonists] AS c
	  ON c.[Id] = tc.[ColonistId]
   WHERE [JobDuringJourney] = 'Pilot'
ORDER BY c.[Id]

--07

SELECT COUNT(*) AS 'Count'
 FROM [TravelCards] AS tc
 JOIN [Journeys] AS j
   ON tc.[JourneyId] = j.[Id]
WHERE j.[Purpose] = 'Technical'

--08

  SELECT 
		 s.[Name],
		 s.[Manufacturer]
	FROM [TravelCards] AS tc
	JOIN [Colonists] AS c
	  ON tc.[ColonistId] = c.[Id]
	JOIN [Journeys] AS j
	  ON j.[Id] = tc.[JourneyId]
	JOIN [Spaceships] AS s
	  ON j.[SpaceshipId] = s.[Id]
   WHERE tc.[JobDuringJourney] = 'Pilot' 
	 AND c.[BirthDate] > '1989/01/01'
ORDER BY s.[Name]

--09

   SELECT 
		  p.[Name],
		  COUNT(*)
	 FROM [Journeys] AS j
LEFT JOIN [Spaceports] AS s
	   ON s.[Id] = j.[DestinationSpaceportId]
LEFT JOIN [Planets] AS p
	   ON p.[Id] = s.[PlanetId]
 GROUP BY p.[Name]
 ORDER BY COUNT(p.[Name]) DESC, p.[Name]

 --10

SELECT *
  FROM
	   (
	   SELECT 
			  tc.[JobDuringJourney],
			  CONCAT(c.[FirstName], ' ', c.[LastName]) AS 'FullName',
			  DENSE_RANK() OVER(PARTITION BY tc.[JobDuringJourney] ORDER BY c.[BirthDate]) AS 'JobRank'
		 FROM [Colonists] AS c
		 JOIN [TravelCards] AS tc
		   ON tc.[ColonistId] = c.[Id]
	   ) AS [RankingQuery]
 WHERE [JobRank] = 2


--11

GO

CREATE FUNCTION [udf_GetColonistsCount](@planetName VARCHAR (30))
RETURNS INT
AS
BEGIN
	DECLARE	@countOfColonists INT = (
									  SELECT COUNT(*)
										FROM [Planets] AS p
										JOIN [Spaceports] AS s
										ON s.[PlanetId] = p.[Id]
										JOIN [Journeys] AS j
										ON j.[DestinationSpaceportId] = s.[Id]
										JOIN [TravelCards] AS tc
										  ON tc.[JourneyId] = j.[Id]
									   WHERE p.[Name] = @planetName)
	RETURN @countOfColonists
END

GO
--без това в judge
SELECT [dbo].[udf_GetColonistsCount]('Otroyphus')

--12

GO

CREATE PROC [usp_ChangeJourneyPurpose] @JourneyId INT, @NewPurpose VARCHAR(11)
AS
BEGIN
	BEGIN TRY
		IF (@JourneyId > 
				   (SELECT TOP (1)
							   [Id]
						  FROM [Journeys]
					  ORDER BY [Id] DESC))
			THROW 50001, 'The journey does not exist!', 1;
		ELSE IF (@NewPurpose = 
					(SELECT [Purpose]
					   FROM [Journeys]
					  WHERE [Id] = @JourneyId))
			THROW 50001, 'You cannot change the purpose!', 1;
		ELSE 	UPDATE [Journeys]
				   SET [Purpose] = @NewPurpose
				 WHERE [Id] = @JourneyId
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE();
	END CATCH  
END

GO
--без това в judge
EXEC [dbo].[usp_ChangeJourneyPurpose] 4, 'Technical'
EXEC [dbo].[usp_ChangeJourneyPurpose] 2, 'Educational'
EXEC [dbo].[usp_ChangeJourneyPurpose] 196, 'Technical'