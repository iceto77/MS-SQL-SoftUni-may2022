CREATE DATABASE Bakery

GO

USE Bakery

GO

--01 

CREATE TABLE [Countries]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) UNIQUE
)

CREATE TABLE [Customers]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(25),
	[LastName] NVARCHAR(25),
	[Gender] VARCHAR(1) 
		CHECK ([Gender] = 'M' OR [Gender] = 'F'),
	[Age] INT,
	[PhoneNumber] CHAR(10),
	[CountryId] INT FOREIGN KEY REFERENCES [Countries]([Id])
)

CREATE TABLE [Products]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) UNIQUE,
	[Description] NVARCHAR(250),
	[Recipe] NVARCHAR(MAX),
	[Price] DECIMAL(18,2)
		CHECK ([Price] >= 0)
)

CREATE TABLE [Feedbacks]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Description] NVARCHAR(255),
	[Rate] DECIMAL(18,2),
		CHECK ([Rate] >= 0 AND [Rate] <= 10),
	[ProductId] INT FOREIGN KEY REFERENCES [Products]([Id]),
	[CustomerId] INT FOREIGN KEY REFERENCES [Customers]([Id])
)

CREATE TABLE [Distributors]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) UNIQUE,
	[AddressText] NVARCHAR(30),
	[Summary] NVARCHAR(200),
	[CountryId] INT FOREIGN KEY REFERENCES [Countries]([Id])
)

CREATE TABLE [Ingredients]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(30),
	[Description] NVARCHAR(200),
	[OriginCountryId] INT FOREIGN KEY REFERENCES [Countries]([Id]),
	[DistributorId] INT FOREIGN KEY REFERENCES [Distributors]([Id])
)

CREATE TABLE [ProductsIngredients]
(
	[ProductId] INT FOREIGN KEY REFERENCES [Products]([Id]) NOT NULL,
	[IngredientId] INT FOREIGN KEY REFERENCES [Ingredients]([Id]) NOT NULL,
	PRIMARY KEY([ProductId], [IngredientId])
)


--02

INSERT INTO [Distributors]([Name], [CountryId], [AddressText], [Summary])
	VALUES
	('Deloitte & Touche', 2, '6 Arch St #9757', 'Customizable neutral traveling'),
	('Congress Title', 13, '58 Hancock St', 'Customer loyalty'),
	('Kitchen People', 1, '3 E 31st St #77', 'Triple-buffered stable delivery'),
	('General Color Co Inc', 21, '6185 Bohn St #72', 'Focus group'),
	('Beck Corporation', 23, '21 E 64th Ave', 'Quality-focused 4th generation hardware')

				

INSERT INTO [Customers]([FirstName], [LastName], [Age], [Gender], [PhoneNumber], [CountryId])
	VALUES
	('Francoise', 'Rautenstrauch', 15, 'M', '0195698399', 5),
	('Kendra', 'Loud', 22, 'F', '0063631526', 11),
	('Lourdes', 'Bauswell', 50, 'M', '0139037043', 8),
	('Hannah', 'Edmison', 18, 'F', '0043343686', 1),
	('Tom', 'Loeza', 31, 'M', '0144876096', 23),
	('Queenie', 'Kramarczyk', 30, 'F', '0064215793', 29),
	('Hiu', 'Portaro', 25, 'M', '0068277755', 16),
	('Josefa', 'Opitz', 43, 'F', '0197887645', 17)

						
--03

UPDATE Ingredients
   SET DistributorId  = 35
 WHERE [Name] IN ('Bay Leaf', 'Paprika', 'Poppy')

UPDATE Ingredients
   SET OriginCountryId  = 14
 WHERE OriginCountryId = 8

--04

DELETE
FROM Feedbacks
WHERE CustomerId = 14 OR ProductId = 5

--05

  SELECT 
		 [Name],
		 Price,
		 Description
    FROM Products
ORDER BY Price DESC, [Name]

--06

  SELECT 
		 ProductId,
		 Rate,
		 [Description],
		 CustomerId,
		 Age,
		 Gender
    FROM Feedbacks AS f
	JOIN Customers AS c 
	  ON f.CustomerId = c.Id
   WHERE Rate < 5
ORDER BY ProductId DESC, Rate

--07

    SELECT 
			CONCAT(c.FirstName, ' ', c.LastName)  AS CustomerName,
			c.PhoneNumber,
			Gender
	  FROM Feedbacks AS f
RIGHT JOIN Customers AS c 
		ON c.Id = f.CustomerId
	 WHERE f.Id IS NULL
  ORDER BY f.CustomerId

--08

  SELECT 
		 FirstName,
		 Age,
		 PhoneNumber
    FROM Customers AS cu
	JOIN Countries AS co
      ON cu.CountryId = co.Id
   WHERE (Age >= 21 AND FirstName LIKE '%an%' )OR (PhoneNumber LIKE '%38' AND co.Name <> 'Greece')
ORDER BY FirstName, Age DESC

--09

  SELECT d.Name,
			i.Name,
			p.Name,
			AVG(f.Rate)
		 --DistributorName,
		 --IngredientName,
		 --ProductName,
		 --AverageRate
    FROM Distributors AS d
	JOIN Ingredients AS i ON i.DistributorId = d.Id
	JOIN ProductsIngredients AS pri ON pri.IngredientId = i.Id
	JOIN Products AS p ON pri.ProductId = p.Id
	JOIN Feedbacks AS f ON f.ProductId = p.Id
GROUP BY d.Name, i.Name, p.Name
  HAVING AVG(f.Rate) BETWEEN 5 AND 8
ORDER BY d.Name, i.Name, p.Name

--10

   SELECT 
		  CountryName,
		  DisributorName
    FROM
		  (SELECT 
				  CountryName,
				  DisributorName,
				  DENSE_RANK() OVER (PARTITION BY CountryName ORDER BY CountOfIngr DESC) AS TestRank
			 FROM
				  (		SELECT 
							   c.[Name] AS CountryName,
							   d.[Name] AS DisributorName,
							   COUNT(i.DistributorId) AS CountOfIngr
						  FROM Distributors AS d
					 LEFT JOIN Ingredients AS i ON i.DistributorId = d.Id
					 LEFT JOIN Countries AS c ON d.CountryId = c.Id
					  GROUP BY i.DistributorId, d.[Name], c.[Name]) AS TestQuery
		 GROUP BY CountOfIngr, CountryName, DisributorName) AS SecondQuery
   WHERE TestRank = 1
ORDER BY CountryName, DisributorName

--11

GO

CREATE VIEW v_UserWithCountries  AS
SELECT 
		CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
		c.Age,
		c.Gender,
		cntr.[Name] AS CountryName
FROM Customers AS c
JOIN Countries AS cntr ON c.CountryId = cntr.Id

GO

--това не се дава в judge, само за мой тест
SELECT TOP 5 *
  FROM v_UserWithCountries
 ORDER BY Age

--12

GO

CREATE OR ALTER TRIGGER tr_SetDeleteProducts
    ON Products
    INSTEAD OF DELETE
AS
BEGIN
	DELETE FROM ProductsIngredients
	WHERE ProductId IN 
						(SELECT 
								p.Id 
							FROM Products AS p
							JOIN deleted AS d
							ON p.Id = d.Id)

	DELETE FROM Feedbacks
	WHERE ProductId IN 
						(SELECT 
								P.Id 
							FROM Products AS p
							JOIN deleted AS d
							ON p.Id = d.Id)	

	DELETE FROM Products
	WHERE Id  IN 
					(SELECT 
							p.Id
					FROM Products AS p
					JOIN deleted AS d
						ON p.Id = d.Id)
END

--това не се дава в judge, само за мой тест

DELETE FROM Products WHERE Id = 7
