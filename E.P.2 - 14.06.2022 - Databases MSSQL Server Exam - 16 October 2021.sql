CREATE DATABASE CigarShop

GO

USE CigarShop

GO

--01 

CREATE TABLE [Sizes]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Length] INT NOT NULL
		CHECK ([Length] >= 10 AND [Length] <= 25),
	[RingRange] DECIMAL(3,2) NOT NULL
		CHECK ([RingRange] >= 1.5 AND [RingRange] <= 7.5)
)

CREATE TABLE [Tastes]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[TasteType] VARCHAR(20) NOT NULL,
	[TasteStrength] VARCHAR(15) NOT NULL,
	[ImageURL] NVARCHAR(100) NOT NULL
)

CREATE TABLE [Brands]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[BrandName] VARCHAR(30) UNIQUE NOT NULL,
	[BrandDescription] VARCHAR(MAX)
)

CREATE TABLE [Cigars]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[CigarName] VARCHAR(80) NOT NULL,
	[BrandId] INT FOREIGN KEY REFERENCES [Brands]([Id]) NOT NULL,
	[TastId] INT FOREIGN KEY REFERENCES [Tastes]([Id]) NOT NULL,
	[SizeId] INT FOREIGN KEY REFERENCES [Sizes]([Id]) NOT NULL,
	[PriceForSingleCigar] DECIMAL(18,2) NOT NULL,
	[ImageURL] NVARCHAR(100) NOT NULL
)

CREATE TABLE [Addresses]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Town] VARCHAR(30) NOT NULL,
	[Country] NVARCHAR(30) NOT NULL,
	[Streat] NVARCHAR(100) NOT NULL,
	[ZIP] VARCHAR(20) NOT NULL
)

CREATE TABLE [Clients]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(30) NOT NULL,
	[LastName] NVARCHAR(30) NOT NULL,
	[Email] NVARCHAR(50) NOT NULL,
	[AddressId] INT FOREIGN KEY REFERENCES [Addresses]([Id]) NOT NULL,
)


CREATE TABLE [ClientsCigars]
(
	[ClientId] INT FOREIGN KEY REFERENCES [Clients]([Id]) NOT NULL,
	[CigarId] INT FOREIGN KEY REFERENCES [Cigars]([Id]) NOT NULL,
	PRIMARY KEY([ClientId], [CigarId])
)


--02

INSERT INTO [Cigars]([CigarName], [BrandId], [TastId], [SizeId], [PriceForSingleCigar], [ImageURL])
	VALUES
	('COHIBA ROBUSTO', 9, 1, 5, 15.50, 'cohiba-robusto-stick_18.jpg'),
	('COHIBA SIGLO I', 9, 1, 10, 410.00, 'cohiba-siglo-i-stick_12.jpg'),
	('HOYO DE MONTERREY LE HOYO DU MAIRE', 14, 5, 11, 7.50, 'hoyo-du-maire-stick_17.jpg'),
	('HOYO DE MONTERREY LE HOYO DE SAN JUAN', 14, 4, 15, 32.00, 'hoyo-de-san-juan-stick_20.jpg'),
	('TRINIDAD COLONIALES', 2, 3, 8, 85.21, 'trinidad-coloniales-stick_30.jpg')


INSERT INTO [Addresses]([Town], [Country], [Streat], [ZIP])
	VALUES
	('Sofia', 'Bulgaria', '18 Bul. Vasil levski', '1000'),
	('Athens', 'Greece', '4342 McDonald Avenue', '10435'),
	('Zagreb', 'Croatia', '4333 Lauren Drive', '10000')

--03

UPDATE [Cigars]
SET [PriceForSingleCigar] *= 1.2
WHERE [TastId] = (
					SELECT [Id]
					  FROM [Tastes]
					 WHERE [TasteType] = 'Spicy'
				 )

UPDATE [Brands]
SET [BrandDescription] = 'New description'
WHERE [BrandDescription] IS NULL

--04

DELETE
  FROM [Clients]
 WHERE [AddressId] IN (SELECT [Id]
						FROM [Addresses]
						WHERE [Country] LIKE 'C%')

DELETE 
  FROM [Addresses]
 WHERE [Country] LIKE 'C%'

--05

  SELECT 
		 [CigarName], 
		 [PriceForSingleCigar], 
		 [ImageURL]
    FROM [Cigars]
ORDER BY [PriceForSingleCigar], [CigarName] DESC

--06

  SELECT 
		 c.[Id],
		 c.[CigarName],
		 c.[PriceForSingleCigar],
		 t.[TasteType],
		 t.[TasteStrength]
    FROM [Cigars] AS c
	JOIN [Tastes] AS t
	  ON c.[TastId] = t.[Id]
   WHERE [TastId] IN (2, 3)
ORDER BY [PriceForSingleCigar] DESC

--07

  SELECT 
		 c.[Id],
		 CONCAT(c.[FirstName], ' ', c.[LastName]) AS ClientName,
		 c.[Email]
    FROM [Clients] AS c
	LEFT JOIN [ClientsCigars] AS cc
      ON cc.[ClientId] = c.[Id]
   WHERE cc.[CigarId] IS NULL
ORDER BY ClientName

--08

SELECT TOP (5)
		 c.[CigarName], 
		 c.[PriceForSingleCigar], 
		 c.[ImageURL]
    FROM [Cigars] AS c
	JOIN [Sizes] AS s
      ON c.[SizeId] = s.[Id]
   WHERE s.[Length] >= 12 AND (c.[CigarName] LIKE '%ci%'
		 OR c.[PriceForSingleCigar] > 50) AND s.[RingRange] > 2.55
ORDER BY c.[CigarName], c.[PriceForSingleCigar] DESC


--09

  SELECT 
		 CONCAT(c.FirstName, ' ', c.LastName) AS FullName,
		 a.Country,
		 a.ZIP,
		 CONCAT('$', (SELECT MAX(PriceForSingleCigar) 
					    FROM Cigars AS cg
					    JOIN ClientsCigars AS cc
					      ON cg.Id = cc.CigarId
					     AND cc.ClientId = c.Id)) AS CigarPrice
    FROM Clients AS c
	JOIN Addresses AS a
      ON a.Id = c.AddressId
   WHERE  ISNUMERIC(a.ZIP) = 1
ORDER BY FullName


--10

  SELECT 
		 cl.[LastName],
		 AVG(s.[Length]) AS CiagrLength,
		 CEILING(AVG(s.[RingRange])) AS CiagrRingRange
    FROM [Clients] AS cl
	JOIN [ClientsCigars] AS cc
      ON cl.[Id] = cc.[ClientId]
	JOIN [Cigars] AS ci
      ON ci.[Id] = cc.[CigarId]
	JOIN [Sizes] AS s
      ON s.[Id] = ci.[SizeId]
GROUP BY cl.[LastName]
ORDER BY CiagrLength DESC

--11

GO

CREATE FUNCTION [udf_ClientWithCigars](@name NVARCHAR(30))
RETURNS INT
AS
BEGIN
	DECLARE	@totalCigar int;
	SET @totalCigar = (SELECT COUNT(*)
						FROM ClientsCigars
						WHERE ClientId IN (SELECT Id
											FROM Clients
											WHERE FirstName = @name))
	RETURN @totalCigar 
END

GO
--това не се дава в judge, само за мой тест
SELECT dbo.udf_ClientWithCigars('Betty')

--12

GO

CREATE PROC [usp_SearchByTaste] @taste VARCHAR(20)
AS
BEGIN
 SELECT 
		CigarName,
		CONCAT('$', c.PriceForSingleCigar) AS Price,
		TasteType,
		B.BrandName AS BrandName,
		CONCAT(s.[Length], ' cm') AS CigarLength,
		CONCAT(s.RingRange, ' cm') AS CigarRingRange
   FROM Cigars AS c
   JOIN Tastes AS t
	 ON c.TastId = T.Id
   JOIN Sizes AS s
	 ON c.SizeId = s.Id
   JOIN Brands AS b
	 ON c.BrandId = b.Id
  WHERE t.TasteType = @taste
ORDER BY CigarLength, CigarRingRange DESC
END

GO
--това не се дава в judge, само за мой тест
EXEC [dbo].[usp_SearchByTaste] 'Woody'
