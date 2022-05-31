--01. Find Names of All Employees by First Name

SELECT [FirstName], [LastName]
  FROM [Employees]
 WHERE [FirstName] LIKE 'Sa%'

	-- ƒ–”√ ¬¿–»¿Õ“

SELECT [FirstName], [LastName]
  FROM [Employees]
 WHERE LEFT([FirstName],2) ='Sa'

--02. Find Names of All employees by Last Name 

SELECT [FirstName], [LastName]
  FROM [Employees]
 WHERE [LastName] LIKE '%ei%'

	-- ƒ–”√ ¬¿–»¿Õ“

SELECT [FirstName], [LastName]
  FROM [Employees]
 WHERE CHARINDEX('ei', [LastName]) <> 0

--03. Find First Names of All Employees


SELECT [FirstName]
  FROM [Employees]
 WHERE [DepartmentID] IN (3, 10) 
   AND YEAR([HireDate]) BETWEEN 1995 AND 2005
	--DRUGO RESHENIE

	SELECT [FirstName]
  FROM [Employees]
 WHERE [DepartmentID] IN (3, 10) 
   AND DATEPART(YEAR, [HireDate]) BETWEEN 1995 AND 2005


--04. Find All Employees Except Engineers

SELECT [FirstName], [LastName]
  FROM [Employees]
 WHERE [JobTitle] NOT LIKE '%engineer%'

--05. Find Towns with Name Length

  SELECT [Name]
    FROM [Towns]
   WHERE LEN([Name]) BETWEEN 5 AND 6
ORDER BY [Name]

--06. Find Towns Starting With

  SELECT [TownID], [Name]
    FROM [Towns]
   WHERE [Name] LIKE '[MKBE]%'
ORDER BY [Name]

--07. Find Towns Not Starting With

  SELECT [TownID], [Name]
    FROM [Towns]
   WHERE [Name] LIKE '[^RBD]%'
ORDER BY [Name]

--08. Create View Employees Hired After 2000 Year

CREATE VIEW "V_EmployeesHiredAfter2000" AS
SELECT [FirstName], [LastName]
  FROM [Employees]
 WHERE DATEPART(YEAR, [HireDate]) > 2000
 --·ÂÁ ÚÓ‚‡ ‚ judge
SELECT * FROM v_EmployeesHiredAfter2000

--09. Length of Last Name

SELECT [FirstName], [LastName]
  FROM [Employees]
 WHERE LEN([LastName]) = 5

 --10. Rank Employees by Salary

 SELECT [EmployeeID], [FirstName], [LastName], [Salary]
	    ,DENSE_RANK() OVER   
		(PARTITION BY [Salary] ORDER BY [EmployeeID]) AS [Rank]
   FROM [Employees]
   WHERE [Salary] BETWEEN 10000 AND 50000 
   ORDER BY [Salary] DESC

--11. Find All Employees with Rank 2 *

  SELECT * 
    FROM (
		  SELECT [EmployeeID], [FirstName], [LastName], [Salary]
				 ,DENSE_RANK() OVER   
				 (PARTITION BY [Salary] ORDER BY [EmployeeID]) AS [Rank]
		    FROM [Employees]
		   WHERE [Salary] BETWEEN 10000 AND 50000 
   	     ) 
      AS [Ranking]
   WHERE [Rank] = 2
ORDER BY [Salary] DESC

--12. Countries Holding 'A' 3 or More Times

  SELECT [CountryName] AS "Country Name" 
		 ,[IsoCode] AS "ISO Code"
    FROM [Countries]
   WHERE LOWER([CountryName]) LIKE '%a%a%a%'
ORDER BY [IsoCode]


--13. Mix of Peak and River Names

  SELECT p.[PeakName]
		 ,r.[RiverName]
		 , LOWER(CONCAT(LEFT(P.[PeakName], LEN(p.[PeaknAME]) - 1), r.[RiverName]))
		 AS [MIX]
    FROM [Rivers] AS r
		 ,[Peaks] AS p
   WHERE RIGHT(LOWER(p.[PeakName]), 1) = LEFT(LOWER(r.[RiverName]),1)
ORDER BY [MIX]


--14. Games from 2011 and 2012 year

  SELECT TOP (50) [Name]
				  , CONCAT(DATEPART(YEAR, g.[Start])
				  , CASE
						WHEN DATEPART(MONTH, g.[Start]) < 10 THEN CONCAT('-0', DATEPART(MONTH, g.[Start]))
						ELSE CONCAT('-', DATEPART(MONTH, g.[Start]))
				    END
				  , CASE
						WHEN DATEPART(DAY, g.[Start]) < 10 THEN CONCAT('-0', DATEPART(DAY, g.[Start]))
						ELSE CONCAT('-', DATEPART(DAY, g.[Start]))
				    END) 
				  AS [Start]
    FROM [Games] AS g
   WHERE DATEPART(YEAR, g.[Start]) BETWEEN 2011 AND 20012
ORDER BY [Start], g.[Name]


--15. User Email Providers

  SELECT [Username]
	     , SUBSTRING([Email]
			, CHARINDEX('@', [Email]) + 1
			, LEN([Email]) - CHARINDEX('@', [Email])) 
			AS [Email Provider]
    FROM [Users]
ORDER BY [Email Provider], [Username] 

--16. Get Users with IPAdress Like Pattern
  
  SELECT [Username], [IpAddress]
    FROM [Users]
   WHERE [IpAddress] LIKE '___.1_%._%.___'
ORDER BY [Username] 


--17. Show All Games with Duration and Part of the Day

  SELECT [Name], 
	     CASE
			WHEN DATEPART(HOUR, [Start]) BETWEEN 0 AND 11 THEN 'Morning'
			WHEN DATEPART(HOUR, [Start]) BETWEEN 12 AND 17 THEN 'Afternoon'
		  	ELSE 'Evening'
	     END AS [Part of the Day],
	     CASE
			WHEN [Duration] <= 3 THEN 'Extra Short'
			WHEN [Duration] BETWEEN 4 AND 6 THEN 'Short'
  			WHEN [Duration] > 6 THEN 'Long'
			ELSE 'Extra Long '
	     END AS [Duration]
    FROM [Games] AS g
ORDER BY g.[Name], [Duration], [Part of the Day]

--18. Orders Table

SELECT [ProductName]
		, [OrderDate]
		, DATEADD(DAY, 3, [OrderDate]) AS [Pay Due]
		, DATEADD(MONTH, 1, [OrderDate]) AS [Deliver Due]
  FROM [Orders] 

--19. People Table

CREATE TABLE [People] (
	[Id] INT PRIMARY KEY IDENTITY, 
	[Name] NVARCHAR(50) NOT NULL, 
	[Birthdate] DATETIME2
)

INSERT INTO [People]([Name], [Birthdate])
	VALUES
	('Victor', '2000-12-07 00:00:00.000'),
	('Steven', '1992-09-10 00:00:00.000'),
	('Stephen', '1910-09-19 00:00:00.000'),
	('John', '2010-01-06 00:00:00.000')


SELECT [Name]
	   , DATEDIFF(YEAR, [Birthdate], GETDATE()) AS [Age in Years]
	   , DATEDIFF(MONTH, [Birthdate], GETDATE()) AS [Age in Months]
	   , DATEDIFF(DAY, [Birthdate], GETDATE()) AS [Age in Days]
	   , DATEDIFF(MINUTE, [Birthdate], GETDATE()) AS [Age in Minutes]
  FROM [People]