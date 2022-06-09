--01. Records’ Count

SELECT 
	   COUNT(*) AS [Count]
  FROM [WizzardDeposits]

--02. Longest Magic Wand

SELECT 
	   MAX([MagicWandSize]) AS [LongestMagicWand]
  FROM [WizzardDeposits]

--03. Longest Magic Wand Per Deposit Groups

SELECT 
	   [DepositGroup] AS DepositGroup,
	   MAX([MagicWandSize]) AS LongestMagicWand
  FROM [WizzardDeposits]
  GROUP BY [DepositGroup]

--04. * Smallest Deposit Group Per Magic Wand Size

SELECT TOP (2)
		 depi.DepositGroup AS DepositGroup
    FROM 
			(
			SELECT 
				   [DepositGroup] AS DepositGroup,
				   AVG([MagicWandSize]) AS Magic
			  FROM [WizzardDeposits]
			  GROUP BY [DepositGroup]
			) AS depi
ORDER BY depi.[Magic] 

-- друго решение
SELECT 
		[DepositGroup]
  FROM [WizzardDeposits]

--05. Deposits Sum

  SELECT 
	     [DepositGroup] AS DepositGroup,
	     SUM([DepositAmount]) AS TotalSum
    FROM [WizzardDeposits]
GROUP BY [DepositGroup]

--06. Deposits Sum for Ollivander Family

SELECT 
		dg.[DepositGroup],
		dg.[TotalSum]
  FROM	
		  (
		      SELECT 
					 [DepositGroup] AS DepositGroup,
					 SUM([DepositAmount]) AS TotalSum,
					 [MagicWandCreator]
				FROM [WizzardDeposits]
			GROUP BY [DepositGroup], [MagicWandCreator]
		  ) AS dg
 WHERE dg.[MagicWandCreator] = 'Ollivander family'

 -- друго решение

 SELECT 
		 [DepositGroup],
	     SUM([DepositAmount]) AS TotalSum
    FROM [WizzardDeposits]
   WHERE [MagicWandCreator] = 'Ollivander family'
GROUP BY [DepositGroup]

--07. Deposits Filter

 SELECT 
		 [DepositGroup],
	     SUM([DepositAmount]) AS TotalSum
    FROM [WizzardDeposits]
   WHERE [MagicWandCreator] = 'Ollivander family'
GROUP BY [DepositGroup]
HAVING SUM([DepositAmount]) < 150000
ORDER BY TotalSum DESC


--08.  Deposit Charge

  SELECT 
		 [DepositGroup], 
		 [MagicWandCreator], 
		 MIN([DepositCharge]) AS MinDepositCharge
    FROM [WizzardDeposits]
GROUP BY [DepositGroup], [MagicWandCreator]
ORDER BY [MagicWandCreator], [DepositGroup]

--09. Age Groups

  SELECT 
		 [AgeGroup], 
		 COUNT(*) AS WizardCount
    FROM
			(
			  SELECT 
					  [Age],
					  CASE
							WHEN [Age] BETWEEN 0 AND 10 THEN '[0-10]'
							WHEN [Age] BETWEEN 11 AND 20 THEN '[11-20]'
							WHEN [Age] BETWEEN 21 AND 30 THEN '[21-30]'
							WHEN [Age] BETWEEN 31 AND 40 THEN '[31-40]'
							WHEN [Age] BETWEEN 41 AND 50 THEN '[41-50]'
							WHEN [Age] BETWEEN 51 AND 60 THEN '[51-60]'
							WHEN [Age]>= 61 THEN '[61+]'
					  END AS [AgeGroup]
				FROM [WizzardDeposits]
			) AS [AgeGrouping]
GROUP BY [AgeGroup]


--10. First Letter

  SELECT DISTINCT
		 SUBSTRING([FirstName], 1, 1) AS FirstLetter
	FROM [WizzardDeposits]
   WHERE [DepositGroup] = 'Troll Chest'
GROUP BY [FirstName]
ORDER BY FirstLetter

--11. Average Interest 

  SELECT 
		 [DepositGroup],
		 [IsDepositExpired],
		 AVG([DepositInterest]) AS AverageInterest
    FROM [WizzardDeposits]
   WHERE [DepositStartDate] > '01/01/1985'
GROUP BY [DepositGroup], [IsDepositExpired]
ORDER BY [DepositGroup] DESC, [IsDepositExpired]

--12. * Rich Wizard, Poor Wizard

SELECT *
    FROM [WizzardDeposits] AS wd1
	JOIN [WizzardDeposits] AS wd2
	ON wd1.[Id] + 1 = wd2.[Id]
	--недовършена

	-- друг вариант

SELECT 
		SUM(d.[Difference]) AS SumDifference
  FROM
		(
		SELECT 
				 [FirstName] AS [Host Wizard],
				 [DepositAmount] AS [Host Wizard Deposit],
				 LEAD([FirstName]) OVER(ORDER BY [Id]) AS [Guest Wizard],
				 LEAD([DepositAmount]) OVER(ORDER BY [Id]) AS [Guest Wizard Deposit],
				 ([DepositAmount] - LEAD([DepositAmount]) OVER(ORDER BY [Id])) AS [Difference]
		   FROM [WizzardDeposits]
		) AS d

--13. Departments Total Salaries

  SELECT 
		 [DepartmentID],
		 SUM([Salary]) AS TotalSalary
	FROM [Employees]
GROUP BY [DepartmentID]
ORDER BY [DepartmentID]

--14. Employees Minimum Salaries

  SELECT 
		 [DepartmentID],
		 MIN([Salary]) AS MinimumSalary
	FROM [Employees]
   WHERE [DepartmentID] IN (2, 5, 7)
GROUP BY [DepartmentID]

--15. Employees Average Salaries

SELECT *
INTO [EmployeesNew]
FROM [Employees]
WHERE [Salary] > 30000

DELETE 
FROM [EmployeesNew]
WHERE [ManagerID] = 42

UPDATE [EmployeesNew]
SET [Salary] += 5000
WHERE [DepartmentID] = 1

SELECT [DepartmentID],
	   AVG([Salary]) AS AverageSalary
FROM [EmployeesNew]
GROUP BY [DepartmentID]


--16. Employees Maximum Salaries

  SELECT 
		 [DepartmentID],
		 MAX([Salary]) AS MaxSalary
    FROM [Employees]
GROUP BY [DepartmentID]
  HAVING MAX([Salary]) NOT BETWEEN 30000 AND 70000

--17. Employees Count Salaries

SELECT COUNT(*)
  FROM [Employees]
 WHERE [ManagerID] IS NULL


--18. * 3rd Highest Salary

SELECT DISTINCT
				[DepartmentID],
				[Salary] AS ThirdHighestSalary	
		   FROM
				(
				SELECT 
					   [DepartmentID],
					   [Salary],
					   DENSE_RANK() OVER(PARTITION BY [DepartmentID] ORDER BY [Salary] DESC) AS [SalaryRank]
				  FROM [Employees]
				) AS [SalaryRankingQuery]
		  WHERE [SalaryRank] = 3

--19. ** Salary Challenge

SELECT TOP (10)
				[FirstName],
				[LastName],
				[DepartmentID]
		   FROM [Employees] AS e
		  WHERE e.[Salary] > (
							SELECT 
								   AVG([Salary]) AS [AverageSalary]
							  FROM [Employees] AS esub
							 WHERE esub.[DepartmentID] = e.[DepartmentID]
						  GROUP BY [DepartmentID]
							)
	   ORDER BY e.[DepartmentID]