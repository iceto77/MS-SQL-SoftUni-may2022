CREATE DATABASE Service
GO

USE Service

GO

--01 

CREATE TABLE [Users]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Username] VARCHAR(30) UNIQUE NOT NULL,
	[Password] VARCHAR(50) NOT NULL,
	[Name] VARCHAR(50),
	[Birthdate] DATETIME2,
	[Age] INT 
		CHECK ([Age] BETWEEN 14 AND 110),
	[Email] VARCHAR(50) NOT NULL
)

CREATE TABLE [Departments]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE [Employees]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] VARCHAR(25),
	[LastName] VARCHAR(25),
	[Birthdate] DATETIME2,
	[Age] INT 
		CHECK ([Age] BETWEEN 18 AND 110),
	[DepartmentId] INT FOREIGN KEY REFERENCES [Departments]([Id])
)

CREATE TABLE [Categories]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	[DepartmentId] INT FOREIGN KEY REFERENCES [Departments]([Id]) NOT NULL
)

CREATE TABLE [Status]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Label] VARCHAR(30) NOT NULL
)

CREATE TABLE [Reports]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[CategoryId] INT FOREIGN KEY REFERENCES [Categories]([Id]) NOT NULL,
	[StatusId] INT FOREIGN KEY REFERENCES [Status]([Id]) NOT NULL,
	[OpenDate] DATETIME2 NOT NULL,
	[CloseDate] DATETIME2,
	[Description] VARCHAR(200) NOT NULL,
	[UserId] INT FOREIGN KEY REFERENCES [Users]([Id]) NOT NULL,
	[EmployeeId] INT FOREIGN KEY REFERENCES [Employees]([Id])
)

--02

INSERT INTO [Employees]([FirstName], [LastName], [Birthdate], [DepartmentId])
	VALUES
	('Marlo', 'O''Malley', '1958-9-21', 1),
	('Niki', 'Stanaghan', '1969-11-26', 4),
	('Ayrton', 'Senna', '1960-03-21', 9),
	('Ronnie', 'Peterson', '1944-02-14', 9),
	('Giovanna', 'Amati', '1959-07-20', 5)

INSERT INTO [Reports]([CategoryId], [StatusId], [OpenDate], [CloseDate], [Description], [UserId], [EmployeeId])
	VALUES
	(1, 1, '2017-04-13', NULL , 'Stuck Road on Str.133', 6, 2),
	(6, 3, '2015-09-05', '2015-12-06', 'Charity trail running', 3, 5),
	(14, 2, '2015-09-07', NULL , 'Falling bricks on Str.58', 5, 2),
	(4, 3, '2017-07-03', '2017-07-06', 'Cut off streetlight on Str.11', 1, 1)

--03

UPDATE Reports
   SET CloseDate = GETDATE()
 WHERE CloseDate IS NULL

--04

DELETE
FROM Reports
WHERE StatusId = 4

--05

  SELECT 
		 Description,
		 CONCAT(CASE
					WHEN DATEPART(DAY, OpenDate) < 10 THEN CONCAT('0', DATEPART(DAY, OpenDate))
					ELSE CONCAT('', DATEPART(DAY, OpenDate))
				END,
				CASE
					WHEN DATEPART(MONTH, OpenDate) < 10 THEN CONCAT('-0', DATEPART(MONTH, OpenDate))
					ELSE CONCAT('-', DATEPART(MONTH, OpenDate))
				END,
			  CONCAT('-',DATEPART(YEAR, OpenDate))) AS [Open Date]
    FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate, Description

--06

  SELECT 
		 Description,
		 c.[Name] AS CategoryName
	FROM Reports AS r
	JOIN Categories AS c 
	  ON r.CategoryId = c.Id
   WHERE CategoryId IS NOT NULL
ORDER BY Description, c.[Name]

--07

  SELECT TOP (5)
		 c.Name AS CategoryName,
		 COUNT(r.Id) AS ReportsNumber
    FROM Reports AS r
    JOIN Categories AS c
      ON r.CategoryId = c.Id
GROUP BY c.Name
ORDER BY ReportsNumber DESC, CategoryName 

--08

  SELECT 
		 u.Username,
		 c.Name AS CategoryName
	FROM Reports AS r
	JOIN Users AS u
	  ON r.UserId = u.Id
	JOIN Categories AS C
	  ON r.CategoryId = c.Id
   WHERE DATEPART(MONTH, u.Birthdate) = DATEPART(MONTH, r.OpenDate)
	 AND DATEPART(DAY, u.Birthdate) = DATEPART(DAY, r.OpenDate)
ORDER BY u.Username, CategoryName

--09
 	

SELECT 
		  CONCAT(e.FirstName, ' ', e.LastName) as FullName, 
		  COUNT(u.Id) AS UsersCount 
	 FROM Employees AS e
LEFT JOIN Reports AS r 
	   ON r.EmployeeId = e.Id 
LEFT JOIN Users AS u 
	   ON r.UserId = u.Id
 GROUP BY e.FirstName, e.LastName
 ORDER BY UsersCount DESC, FullName



--10

   SELECT 
		  CASE
		 	 WHEN e.FirstName IS NULL THEN 'None'
		 	 ELSE CONCAT(e.FirstName, ' ', e.LastName) 
		  END AS Employee,
		  ISNULL(d.[Name],'None') AS Department,
		  c.[Name] AS Category,
		  r.[Description],
		  CONCAT(CASE
		  			WHEN DATEPART(DAY, r.OpenDate) < 10 THEN CONCAT('0', DATEPART(DAY, r.OpenDate))
		  			ELSE CONCAT('', DATEPART(DAY, r.OpenDate))
		  		END,
		  		CASE
		  			WHEN DATEPART(MONTH, r.OpenDate) < 10 THEN CONCAT('.0', DATEPART(MONTH, r.OpenDate))
		  			ELSE CONCAT('.', DATEPART(MONTH, r.OpenDate))
		  		END,
		  		CONCAT('.',DATEPART(YEAR, r.OpenDate))) AS [OpenDate],
		  s.Label AS [Status],
		  ISNULL(u.[Name],'None') AS [User]
     FROM Reports AS r
LEFT JOIN Employees AS e
	   ON r.EmployeeId = e.Id
LEFT JOIN Departments AS d
	   ON e.DepartmentId = d.Id
LEFT JOIN Categories AS c
	   ON r.CategoryId = c.Id
LEFT JOIN [Status] AS s
	   ON r.StatusId = s.Id
LEFT JOIN Users AS u
	   ON r.UserId = u.Id
 ORDER BY e.FirstName DESC, e.LastName DESC, Department, Category, r.[Description], OpenDate, [Status], [User]

--11

GO

CREATE FUNCTION [udf_HoursToComplete](@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
AS
BEGIN
	DECLARE	@result INT
	IF @StartDate IS NOT NULL AND @EndDate IS NOT NULL
			SET @result	= DATEDIFF(HOUR, @StartDate, @EndDate)
		ELSE
			SET @result	= 0								
	RETURN @result
END

GO
--това не се дава в judge, само за мой тест
SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours
   FROM Reports


--12

GO

CREATE PROC [usp_AssignEmployeeToReport] @EmployeeId INT, @ReportId INT
AS
BEGIN
	BEGIN TRY
		IF (SELECT DepartmentId
			 FROM Employees
			WHERE ID = @EmployeeId) = (SELECT c.DepartmentId
										 FROM Reports AS r
										 JOIN Categories AS c
										   ON r.CategoryId = c.Id
										WHERE r.Id = @ReportId)
			BEGIN
				UPDATE Reports
				   SET EmployeeId = @EmployeeId
				 WHERE ID = @ReportId
			END
		ELSE
			THROW 50001, 'Employee doesn''t belong to the appropriate department!', 1;
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE();
	END CATCH 
END

GO
--това не се дава в judge, само за мой тест
EXEC usp_AssignEmployeeToReport 30, 1
EXEC usp_AssignEmployeeToReport 17, 2




SELECT ISNULL(NULL,'TEST')