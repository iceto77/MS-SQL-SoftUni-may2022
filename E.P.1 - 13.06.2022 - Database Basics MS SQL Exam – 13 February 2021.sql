CREATE DATABASE Bitbucket

GO

USE Bitbucket

GO

--01 

CREATE TABLE [Users]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Username] VARCHAR(30) NOT NULL,
	[Password] VARCHAR(30) NOT NULL,
	[Email] VARCHAR(50) NOT NULL
)

CREATE TABLE [Repositories]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE [RepositoriesContributors]
(
	[RepositoryId] INT FOREIGN KEY REFERENCES [Repositories]([Id]) NOT NULL,
	[ContributorId] INT FOREIGN KEY REFERENCES [Users]([Id]) NOT NULL,
	PRIMARY KEY([RepositoryId], [ContributorId])
)

CREATE TABLE [Issues]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Title] VARCHAR(255) NOT NULL,
	[IssueStatus] VARCHAR(6) NOT NULL,
	[RepositoryId] INT FOREIGN KEY REFERENCES [Repositories]([Id]) NOT NULL,
	[AssigneeId] INT FOREIGN KEY REFERENCES [Users]([Id]) NOT NULL
)

CREATE TABLE [Commits]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Message] VARCHAR(255) NOT NULL,
	[IssueId] INT FOREIGN KEY REFERENCES [Issues]([Id]),
	[RepositoryId] INT FOREIGN KEY REFERENCES [Repositories]([Id]) NOT NULL,
	[ContributorId] INT FOREIGN KEY REFERENCES [Users]([Id]) NOT NULL
)

CREATE TABLE [Files]
(
	[Id] INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(100) NOT NULL,
	[Size] DECIMAL(18, 2) NOT NULL,
	[ParentId] INT FOREIGN KEY REFERENCES [Files]([Id]),
	[CommitId] INT FOREIGN KEY REFERENCES [Commits]([Id]) NOT NULL
)

--02

INSERT INTO [Files]([Name], [Size], [ParentId], [CommitId])
	VALUES
	('Trade.idk', 2598.0, 1, 1),
	('menu.net', 9238.31, 2, 2),
	('Administrate.soshy', 1246.93, 3, 3),
	('Controller.php', 7353.15, 4, 4),
	('Find.java', 9957.86, 5, 5),
	('Controller.json', 14034.87, 3, 6),
	('Operate.xix', 7662.92, 7, 7)

INSERT INTO [Issues]([Title], [IssueStatus], [RepositoryId], [AssigneeId])
	VALUES
	('Critical Problem with HomeController.cs file', 'open', 1, 4),	
	('Typo fix in Judge.html', 'open', 4, 3),
	('Implement documentation for UsersService.cs', 'closed', 8, 2),
	('Unreachable code in Index.cs', 'open', 9, 8)


--03

UPDATE [Issues]
SET [IssueStatus] = 'closed'
WHERE [AssigneeId] = 6


--04

DELETE
FROM [RepositoriesContributors]
WHERE [RepositoryId] = 3

DELETE 
FROM [Issues]
WHERE [RepositoryId] = 3

--05

  SELECT [Id], 
		 [Message], 
		 [RepositoryId], 
		 [ContributorId]
    FROM [Commits]
ORDER BY [Id], [Message], [RepositoryId], [ContributorId]

--06

  SELECT 
		 [Id],
		 [Name],
		 [Size]
    FROM [Files]
   WHERE [Size] > 1000
	 AND [Name] LIKE '%html%'
ORDER BY [Size] DESC, [Id], [Name]

--07

  SELECT 
		 i.[Id],
		 CONCAT(u.[Username],' : ', i.[Title]) AS 'IssueAssignee'	
    FROM [Issues] AS i
	JOIN [Users] AS u
      ON u.[Id] = i.[AssigneeId]
ORDER BY i.[Id] DESC, i.[AssigneeId]

--08

	SELECT 
			P.[Id],
			P.[Name],
			CONCAT(p.[Size], 'KB') AS 'Size'
	  FROM [Files] AS f
RIGHT JOIN [Files] AS p
		ON f.[ParentId] = p.[Id]
	 WHERE f.[ID] IS NULL
  ORDER BY p.[Id], p.[Name], p.[Size] DESC

--09

SELECT TOP (5)
		  r.[Id],
		  r.[Name],
		  COUNT(c.[Id]) AS 'Commits'
	 FROM [Commits] AS c
LEFT JOIN [Issues] AS i
	   ON i.[Id] = c.[IssueId]
LEFT JOIN [Repositories] AS r
	   ON r.[Id] = c.[RepositoryId]
LEFT JOIN [RepositoriesContributors] AS rc
	   ON rc.[RepositoryId] = r.[Id]
GROUP BY r.[Id], r.[Name]
ORDER BY [Commits] DESC, r.[Id], r.[Name]

--10

  SELECT
		 u.[Username],
		 AVG(f.[Size]) AS 'Size'
	FROM [Users] AS u
	JOIN [Commits] AS c
	  ON c.[ContributorId] = u.[Id]
	JOIN [Files] AS f
	  ON  f.[CommitId] = c.[Id]
GROUP BY u.[Username]
ORDER BY [Size] DESC, u.[Username]

--11

GO

CREATE FUNCTION [udf_AllUserCommits](@username VARCHAR(30))
RETURNS INT
AS
BEGIN
	DECLARE	@userId INT = (
							SELECT [Id]
							FROM [Users]
							WHERE [Username] = @username
						  )
	DECLARE @commitsCount INT = (
								 SELECT COUNT([Id])
								 FROM [Commits]
								 WHERE [ContributorId] = @userId
								)
	RETURN @commitsCount
END

GO
--това не се дава в judge, само за мой тест
SELECT dbo.udf_AllUserCommits('UnderSinduxrein')

--12

GO

CREATE PROC [usp_SearchForFiles] @fileExtension VARCHAR(98)
AS
BEGIN
	SELECT 
			[Id],
			[Name],
			CONCAT([Size], 'KB') AS 'Size'
	FROM [Files] AS f
	WHERE [Name] LIKE CONCAT('%[.]', @fileExtension)
	ORDER BY f.[Id], f.[Name], f.[Size] DESC
END

GO
--това не се дава в judge, само за мой тест
EXEC [dbo].[usp_SearchForFiles] 'txt'
