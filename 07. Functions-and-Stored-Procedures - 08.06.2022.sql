--01.	Employees with Salary Above 35000
GO

CREATE PROC [usp_GetEmployeesSalaryAbove35000 ]
AS
BEGIN
	 SELECT 
			[FirstName],
			[LastName]
	   FROM [Employees]
	  WHERE [Salary] > 35000
END

GO

EXEC [dbo].[usp_GetEmployeesSalaryAbove35000]

--ако искаме да проемин процедурата се прави така:
GO

CREATE OR ALTER PROC [usp_GetEmployeesSalaryAbove35000 ]
AS
BEGIN
	 SELECT 
			[FirstName],
			[LastName]
	   FROM [Employees]
	  WHERE [Salary] > 35000
END

GO

--02.	Employees with Salary Above Number

CREATE PROC [usp_GetEmployeesSalaryAboveNumber] @minSalary DECIMAL (18,4)
AS
BEGIN
	 SELECT 
			[FirstName],
			[LastName]
	   FROM [Employees]
	  WHERE [Salary] >= @minSalary
END



--03.	Town Names Starting With

GO

CREATE PROC [usp_GetTownsStartingWith] @startingWith NVARCHAR(10)
AS
BEGIN
	SELECT [Name] AS 'Town'
	  FROM [Towns]
	 WHERE [Name] LIKE CONCAT(@startingWith, '%')
END

GO

EXEC [dbo].[usp_GetTownsStartingWith] 'b'

GO

--04.	Employees from Town

GO

CREATE PROC [usp_GetEmployeesFromTown] @townName VARCHAR(50)
AS
BEGIN
	 SELECT 
			[FirstName],
			[LastName]
	   FROM [Employees] AS e
  LEFT JOIN [Addresses] AS a
	     ON e.[AddressID] = a.[AddressID]
  LEFT JOIN [Towns] AS T
	     ON a.[TownID] = t.[TownID]
		 WHERE t.[Name]  =@townName
END

GO

EXEC [dbo].[usp_GetEmployeesFromTown] 'Sofia'

--05.	Salary Level Function

GO

CREATE FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(8)
AS
BEGIN
	DECLARE @salaryLevel VARCHAR(8)
	
	IF @salary < 30000
		BEGIN
			SET @salaryLevel = 'Low'
		END
	ELSE IF @salary BETWEEN 30000 AND 50000
		BEGIN
			SET @salaryLevel = 'Average'
		END
	ELSE IF @salary > 50000
		BEGIN
			SET @salaryLevel = 'High'
		END

	RETURN @salaryLevel
END

GO

 SELECT 
		[Salary],
		[dbo].[ufn_GetSalaryLevel]([Salary]) AS [Salary Level]
   FROM [Employees]

--06.	Employees by Salary Level

GO

CREATE PROC [usp_EmployeesBySalaryLevel] @salaryLevel VARCHAR(8)
AS
BEGIN
	SELECT 
			[FirstName],
			[LastName]
	FROM [Employees]
	WHERE [dbo].[ufn_GetSalaryLevel]([Salary]) = @salaryLevel
END

GO

EXEC [dbo].[usp_EmployeesBySalaryLevel] 'Low'
EXEC [dbo].[usp_EmployeesBySalaryLevel] 'High'

--07.	Define Function

GO

CREATE OR ALTER FUNCTION [ufn_IsWordComprised](@setOfLetters VARCHAR(50), @word VARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @trueFalse BIT = 0
	DECLARE @i INT = 1	

	WHILE @i <= LEN(@word)
		BEGIN
			DECLARE @sign CHAR(1) = LOWER(SUBSTRING(@word, @i, 1))	
			IF CHARINDEX(@sign, @setOfLetters) = 0
				BEGIN
					SET @trueFalse = 0
				END
			ELSE
				BEGIN
					SET @trueFalse = 1
				END
			IF @trueFalse = 0
				BEGIN
					RETURN 0
				END	
			SET @trueFalse = 0	
			SET @i += 1
		END
	RETURN  1
END

GO

SELECT [dbo].[ufn_IsWordComprised]('oistmiahf', 'Sofia')
SELECT [dbo].[ufn_IsWordComprised]('oistmiahf', 'halves')


--08.	* Delete Employees and Departments

GO

CREATE PROC usp_DeleteEmployeesFromDepartment (@departmentId INT) 
AS
BEGIN

DELETE FROM [EmployeesProjects]
      WHERE [EmployeeID] IN 
			(SELECT [EmployeeID]
			   FROM [Employees]
			  WHERE [DepartmentID] = @departmentId
			)

UPDATE [Employees] 
   SET [ManagerID] = NULL
 WHERE [ManagerID] IN 
		(SELECT [EmployeeID]
		   FROM [Employees]
		  WHERE [DepartmentID] = @departmentId
		)

 ALTER TABLE [Departments]
ALTER COLUMN [ManagerID] INT

UPDATE [Departments]
   SET [ManagerID] = NULL
 WHERE [ManagerID] IN
		(SELECT [EmployeeID]
		   FROM [Employees]
		  WHERE [DepartmentID] = @departmentId
		)

DELETE FROM [Employees]
	  WHERE [DepartmentID] = @departmentId

DELETE FROM [Departments]
      WHERE [DepartmentID] = @departmentId

SELECT COUNT([EmployeeID])
  FROM [Employees]
 WHERE [DepartmentID] = @departmentId
END

GO

EXEC [dbo].[usp_DeleteEmployeesFromDepartment] 2
 
--09.	Find Full Name

GO

CREATE PROC [usp_GetHoldersFullName] 
AS
BEGIN
	SELECT CONCAT([FirstName], ' ', [LastName] ) AS 'Full Name'
	  FROM [AccountHolders]
END

GO

EXEC [dbo].[usp_GetHoldersFullName] 

--10.	People with Balance Higher Than

GO

CREATE OR ALTER PROC [usp_GetHoldersWithBalanceHigherThan](@limitBalance DECIMAL (18,4)) 
AS
BEGIN
	  SELECT 
			 [FirstName],
			 [LastName]
		FROM
			 (
				SELECT 
					   CONCAT(ah.[FirstName], ' ', [LastName]) AS 'FullName',
					   ah.[FirstName],
					   ah.[LastName],
					   a.[Balance]
				  FROM [AccountHolders] as ah
			 LEFT JOIN [Accounts] AS a
					ON a.[AccountHolderId] = ah.[Id]
			 ) AS [BalanceQuery]
	GROUP BY [FirstName], [LastName]
	  HAVING SUM([Balance]) > @limitBalance
	ORDER BY [FirstName], [LastName]
END

GO

EXEC [dbo].[usp_GetHoldersWithBalanceHigherThan] 10000.00

--11.	Future Value Function

GO
CREATE OR ALTER FUNCTION [ufn_CalculateFutureValue] (@sum DECIMAL(18,4), @yearlyInterestRate FLOAT, @numberOfYears INT)
RETURNS DECIMAL (18,4)
AS
BEGIN
	DECLARE @fv DECIMAL (18,4)
	SET  @fv = ROUND(@sum * POWER(1 + @yearlyInterestRate, @numberOfYears), 4) 
	RETURN @fv
END

G0

SELECT dbo.[ufn_CalculateFutureValue] (1000, 0.1, 5)

--12.	Calculating Interest

GO

CREATE OR ALTER PROC [usp_CalculateFutureValueForAccount](@accountId INT, @interestRate FLOAT) 
AS
BEGIN
   SELECT TOP 1
		  ah.[Id] AS [Account Id],
		  ah.[FirstName] AS [First Name],
		  ah.[LastName] AS [Last Name],
		  a.[Balance] AS [Current Balance],
		  [dbo].[ufn_CalculateFutureValue](a.[Balance], @interestRate, 5) AS [Balance in 5 years]
	 FROM [AccountHolders] AS ah
 JOIN [Accounts] AS a
	   ON ah.[Id] = a.[AccountHolderId]
	WHERE ah.[Id] = @accountId
END

GO

EXEC [dbo].[usp_CalculateFutureValueForAccount] 1, 0.1

--13.	*Scalar Function: Cash in User Games Odd Rows

GO

CREATE FUNCTION [ufn_CashInUsersGames](@gameName NVARCHAR(50))
RETURNS TABLE
AS RETURN
	(
	SELECT SUM([Cash]) AS SumCash
	FROM
		(
			SELECT 
					ug.[Cash], 
					ROW_NUMBER() OVER (ORDER BY ug.[Cash] DESC) AS [RowNumber]
				FROM [UsersGames] AS ug
		LEFT JOIN [Games] AS g
				ON ug.[GameId] = g.[Id]
			WHERE g.[Name] = @gameName
		) AS [RowNumberSubquery]
	WHERE [RowNumber] % 2 <> 0
	)


SELECT * FROM [ufn_CashInUsersGames]('Love in a mist')