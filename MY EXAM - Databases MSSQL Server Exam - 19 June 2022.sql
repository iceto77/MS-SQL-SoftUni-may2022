CREATE DATABASE Zoo

GO

USE Zoo

GO

--01 

CREATE TABLE [Owners]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[PhoneNumber] VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50)
)

CREATE TABLE [AnimalTypes]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[AnimalType] VARCHAR(30) NOT NULL
)

CREATE TABLE [Cages]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[AnimalTypeId] INT FOREIGN KEY REFERENCES [AnimalTypes]([Id]) NOT NULL
)

CREATE TABLE [Animals]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	[BirthDate] DATE NOT NULL,
	[OwnerId] INT FOREIGN KEY REFERENCES [Owners]([Id]),
	[AnimalTypeId] INT FOREIGN KEY REFERENCES [AnimalTypes]([Id]) NOT NULL
)

CREATE TABLE [AnimalsCages]
(
	[CageId] INT FOREIGN KEY REFERENCES [Cages]([Id]) NOT NULL,
	[AnimalId] INT FOREIGN KEY REFERENCES [Animals]([Id]) NOT NULL,
	PRIMARY KEY([CageId], [AnimalId])
)

CREATE TABLE [VolunteersDepartments]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[DepartmentName] VARCHAR(30) NOT NULL
)

CREATE TABLE [Volunteers]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[PhoneNumber] VARCHAR(15) NOT NULL,
	[Address] VARCHAR(50),
	[AnimalId] INT FOREIGN KEY REFERENCES [Animals]([Id]),
	[DepartmentId] INT FOREIGN KEY REFERENCES [VolunteersDepartments]([Id]) NOT NULL
)


--02

INSERT INTO Volunteers([Name], PhoneNumber, [Address], AnimalId, DepartmentId)
	VALUES
	('Anita Kostova', '0896365412', 'Sofia, 5 Rosa str.', 15, 1),
	('Dimitur Stoev', '0877564223', NULL, 42, 4),
	('Kalina Evtimova', '0896321112', 'Silistra, 21 Breza str.', 9, 7),
	('Stoyan Tomov', '0898564100', 'Montana, 1 Bor str.', 18, 8),
	('Boryana Mileva', '0888112233', NULL, 31, 5)

INSERT INTO Animals([Name], BirthDate, OwnerId, AnimalTypeId)
	VALUES
	('Giraffe', '2018-09-21', 21, 1),
	('Harpy Eagle', '2015-04-17', 15, 3),
	('Hamadryas Baboon', '2017-11-02', NULL, 1),
	('Tuatara', '2021-06-30', 2, 4)



--03

UPDATE Animals
SET OwnerId = (SELECT Id FROM Owners WHERE Name = 'Kaloqn Stoqnov')
WHERE OwnerId IS NULL


--04

DELETE
  FROM Volunteers
 WHERE DepartmentId = (SELECT Id 
						 FROM VolunteersDepartments 
					    WHERE DepartmentName = 'Education program assistant')

DELETE
  FROM VolunteersDepartments 
 WHERE DepartmentName = 'Education program assistant'



--05

   SELECT 
		  [Name],
		  PhoneNumber,
		  [Address],
		  AnimalId,
		  DepartmentId
     FROM Volunteers 
 ORDER BY [Name], AnimalId, DepartmentId

--06

   SELECT 
		  a.[Name],
		  t.AnimalType,
		  CONCAT(CASE
					WHEN DATEPART(DAY, a.BirthDate) < 10 THEN CONCAT('0', DATEPART(DAY, a.BirthDate))
					ELSE CONCAT('', DATEPART(DAY,a.BirthDate))
				 END,
				 CASE
			  WHEN DATEPART(MONTH, a.BirthDate) < 10 THEN CONCAT('.0', DATEPART(MONTH, a.BirthDate))
			  ELSE CONCAT('.', DATEPART(MONTH, a.BirthDate))
		  END,
		  CONCAT('.',DATEPART(YEAR, [BirthDate]))) AS BirthDate
     FROM Animals AS a
	 JOIN AnimalTypes AS t
	   ON a.AnimalTypeId = t.Id
 ORDER BY a.[Name]


--07

   SELECT TOP (5)
			  o.Name AS [Owner],
			  COUNT(*) AS CountOfAnimals
		 FROM Owners AS o
	LEFT JOIN Animals AS a
		   ON a.OwnerId = o.Id
	 GROUP BY o.Name
	 ORDER BY CountOfAnimals DESC, [Owner]

--08

   SELECT 
		  CONCAT(o.[Name], '-',a.[Name]) AS OwnersAnimals,
		  o.PhoneNumber,
		  c.Id AS CageId
     FROM Owners AS o
	 JOIN Animals AS a
	   ON a.OwnerId = o.Id
	 JOIN AnimalTypes AS t
	   ON a.AnimalTypeId = t.Id
	 JOIN AnimalsCages AS ac
	   ON ac.AnimalId = a.Id
	 JOIN Cages AS c
	   ON ac.CageId = c.Id
	WHERE t.AnimalType = 'Mammals'
 ORDER BY o.[Name], a.[Name] DESC


--09

   SELECT 
		  v.[Name],
		  v.PhoneNumber,
		  TRIM(SUBSTRING(v.[Address], CHARINDEX(',', v.[Address]) + 1,LEN(v.[Address]) - CHARINDEX(',', v.[Address]))) AS [Address]
     FROM Volunteers AS v
LEFT JOIN VolunteersDepartments AS vd
	   ON v.DepartmentId = vd.Id
	WHERE vd.DepartmentName = 'Education program assistant'
	  AND CHARINDEX('Sofia', v.[Address]) > 0
 ORDER BY v.[Name]

--10

   SELECT 
		  a.[Name],
		  DATEPART(YEAR, a.BirthDate) AS BirthYear,
		  t.AnimalType
     FROM Animals AS a
LEFT JOIN AnimalTypes AS t
	   ON a.AnimalTypeId = t.Id
 WHERE OwnerId IS NULL
   AND DATEDIFF(YEAR, a.BirthDate, '01/01/2022')  < 5
   AND t.AnimalType <> 'Birds'
 ORDER BY a.[Name]

--11

GO

CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR(30))
RETURNS INT
AS
BEGIN
	DECLARE	@countOfVolunteers INT = (SELECT COUNT(*)
										FROM Volunteers AS v
										JOIN VolunteersDepartments AS vd
										  ON v.DepartmentId = vd.Id
									   WHERE vd.DepartmentName = @VolunteersDepartment)
		
	RETURN @countOfVolunteers
END

GO
--òîâà íå ñå äàâà â judge, ñàìî çà ìîé òåñò
SELECT dbo.udf_GetVolunteersCountFromADepartment ('Education program assistant')
SELECT dbo.udf_GetVolunteersCountFromADepartment ('Guest engagement')
SELECT dbo.udf_GetVolunteersCountFromADepartment ('Zoo events')

--12

GO

CREATE PROC usp_AnimalsWithOwnersOrNot @AnimalName VARCHAR(30)
AS
BEGIN
	SELECT 
		   a.[Name],
		   CASE
				WHEN OwnerId IS NULL THEN 'For adoption'
				ELSE w.[Name]
		   END AS OwnersName
	  FROM Animals AS a
 LEFT JOIN Owners AS w
		ON a.OwnerId = w.Id
	 WHERE a.[Name] = @AnimalName
END

GO
--òîâà íå ñå äàâà â judge, ñàìî çà ìîé òåñò
EXEC usp_AnimalsWithOwnersOrNot 'Pumpkinseed Sunfish'
EXEC usp_AnimalsWithOwnersOrNot 'Hippo'
EXEC usp_AnimalsWithOwnersOrNot 'Brown bear'

