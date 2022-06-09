--01. Create Database

CREATE DATABASE [Minions]

USE [Minions]


GO

--02. Create Tables

CREATE TABLE [Minions] (
	[Id] INT PRIMARY KEY, 
	[Name] NVARCHAR(50) NOT NULL, 
	[Age] INT NOT NULL
)

CREATE TABLE [Towns] (
	[Id] INT PRIMARY KEY, 
	[Name] NVARCHAR(70) NOT NULL, 
)

 GO

 --03. Alter Minions Table

 ALTER TABLE [Minions]
 ADD [TownId] INT FOREIGN KEY REFERENCES [Towns]([Id]) NOT NULL

  GO

   ALTER TABLE [Minions]
   ALTER COLUMN [Age] INT

  GO

 --04. Insert Records in Both Tables

 INSERT INTO [Towns]([Id], [Name])
	  VALUES 
	  (1, 'Sofia'),
	  (2, 'Plovdiv'),
	  (3, 'Varna')

INSERT INTO [Minions]([Id], [Name], [Age], [TownId])
	VALUES
	(1, 'Kevin', 22, 1),
	(2, 'Bob', 15, 3),
	(3, 'Steward', NULL, 2)

GO

--05. Truncate Table Minions

TRUNCATE TABLE [Minions]

GO

--06. Drop All Tables

DROP TABLE [Minions]
DROP TABLE [Towns]

GO

-- 07. Create Table People

CREATE TABLE [Peoples] (
	[Id] INT PRIMARY KEY IDENTITY, 
	[Name] NVARCHAR(200) NOT NULL, 
	[Picture] VARBINARY(MAX), 
	CHECK (DATALENGTH([Picture]) <= 2000000),
	[Height] DECIMAL(3, 2), 
	[Weight] DECIMAL(5, 2), 
	[Gender] CHAR(1) NOT NULL, 
	CHECK ([Gender] = 'm' OR [Gender] = 'f'),
	[Birthdate] DATE NOT NULL, 
	[Biography] NVARCHAR(MAX)
)

INSERT INTO [Peoples]([Name], [Height], [Weight], [Gender], [Birthdate])
	VALUES
	('Ivan', 1.72, 77.35, 'm', '1999-04-12'),
	('Pesho', NULL, 88, 'm', '1997-11-02'),
	('Ganka', 1.66, NULL, 'f', '2001-08-04'),
	('Donka', NULL, NULL, 'f', '1998-06-06'),
	('Gosho', 1.77, 123.50, 'm', '1999-04-12')

GO

--08. Create Table Users

CREATE TABLE [Users] (
	[Id] BIGINT PRIMARY KEY IDENTITY, 
	[Username] NVARCHAR(30) UNIQUE NOT NULL, 
	[Password] VARCHAR(26) NOT NULL, 
	[ProfilePicture] VARBINARY(MAX), 
	CHECK (DATALENGTH([ProfilePicture]) <= 900000),
	[LastLoginTime] DATETIME2, 
	[IsDeleted] BIT
)

INSERT INTO [Users]([Username], [Password], [LastLoginTime], [IsDeleted])
	VALUES
	('Ivan', 'a1s2d3', NULL, 0),
	('Pesho', 'z1x2c3', NULL, 0),
	('Ganka', 'q1w2e3', NULL, 0),
	('Donka', 'aq1sw2de3', NULL, 0),
	('Gosho', 'q1azw2sxe3dc', NULL, 1)

GO

--09. Change Primary Key

ALTER TABLE [Users] DROP CONSTRAINT [PK__Users__3214EC071E3D0A2D]

ALTER TABLE [Users]
ADD PRIMARY KEY ([Id], [Username]);

GO

--10. Add Check Constraint

ALTER TABLE [Users]
ADD CHECK (datalength([Password]) > 5)

GO

--11. Set Default Value of a Field

ALTER TABLE [Users]
	ADD DEFAULT GETDATE() FOR [LastLoginTime]

GO

--12. Set Unique Field

ALTER TABLE [Users]
DROP PK__Users;

ALTER TABLE [Users]
ADD PRIMARY KEY ([Id]);

ALTER TABLE [Users]
ADD CHECK (datalength([Username]) > 3)

GO

--13. Movies Database

GO
CREATE DATABASE [Movies]

GO
USE [Movies]


CREATE TABLE [Directors] (
	[Id] INT PRIMARY KEY IDENTITY, 
	[Name] NVARCHAR(200) NOT NULL, 
	[Notes] NVARCHAR(MAX)
)


CREATE TABLE [Genres] (
	[Id] INT PRIMARY KEY IDENTITY, 
	[Name] NVARCHAR(50) UNIQUE NOT NULL, 
	[Notes] NVARCHAR(MAX)
)


CREATE TABLE [Categories] (
	[Id] INT PRIMARY KEY IDENTITY, 
	[Name] NVARCHAR(50) UNIQUE NOT NULL, 
	[Notes] NVARCHAR(MAX)
)


CREATE TABLE [Movies] (
	[Id] INT PRIMARY KEY IDENTITY,
	[Title] NVARCHAR(200) NOT NULL, 
	[DirectorId] INT FOREIGN KEY REFERENCES [Directors]([Id]) NOT NULL,
	[CopyrightYear] INT,
	[Length] INT,
	[GenreId] INT FOREIGN KEY REFERENCES [Genres]([Id]),
	[CategoryId] INT FOREIGN KEY REFERENCES [Categories]([Id]),
	[Rating] INT,
	[Notes] NVARCHAR(MAX)
)


INSERT INTO [Directors]([Name], [Notes])
	VALUES
	('Ivan Andonov', 'He is known as a director of famous Bulgarian films such as "Ladies Invite", "Dangerous Charm", "Yesterday" and "Goodbye, Rio", as well as his roles in the films "On the Small Island", "Deviation" and "Ivan Kondarev".'),
	('Andrey Slabakov', NULL),
	('Magardich Halvadjian', 'Magardich Bedros Halvadjian is a Bulgarian director and producer of Armenian origin.'),
	('Vasa Gancheva', NULL),
	('Vladislav Karamfilov', NULL)


INSERT INTO [Genres]([Name], [Notes])
	VALUES
	('Comedy', 'Films with often grotesque characters, characterized by a humorous approach to events. Comedies are divided into subgroups. There is a "family", "youth", "black" comedy.'),
	('Horror', 'These films have a tense atmosphere. Their purpose - to cause anxiety or fear of the viewer. As a rule, there are supernatural forces in horror movies.'),
	('Fiction', 'Films in this genre, as a rule, tell about the "world of the future" or the alternative reality in which life is modernized.'),
	('Adventurous', 'The genre, which is characterized by a clear division of the characters into positive and negative and positive, as a rule, fall into unusual situations where they have to use the mind and ingenuity. Such films always end with a "happy ending".'),
	('Action', 'This genre is characterized by a large number of military operations. As a rule, the main characters fight with their rivals and win.')


INSERT INTO [Categories]([Name], [Notes])
	VALUES
	('Documentary films', NULL),
	('Biographical films', 'A biographical film or biopic (/ˈbaɪoʊpɪk/)[1] is a film that dramatizes the life of a non-fictional or historically-based person or people.'),
	('Western films', 'The American Film Institute defines Western films as those "set in the American West that [embody] the spirit, the struggle, and the demise of the new frontier". '),
	('Animated films', NULL),
	('Feature films', 'A feature film or feature-length film is a narrative film (motion picture or "movie") with a running time long enough to be considered the principal or sole presentation in a commercial entertainment program.')


INSERT INTO [Movies]([Title], [DirectorId], [GenreId], [CategoryId], [CopyrightYear], [Length] )
	VALUES
	('Dangerous charm', 1, 1, NULL, 1984, 82),
	('Yesterday', 1 , NULL, 5, 1987, 84),
	('Improvisation', 2, NULL, 1, 2001, NULL),
	('The profit', 3, NULL, 5, 2000, NULL),
	('Operation "Shmenti Chapels"', 5, 1, 5, 2011, 82)


GO

--14. Car Rental Database

CREATE DATABASE [CarRental]

GO

USE [CarRental]


CREATE TABLE [Categories]  (
	[Id] INT PRIMARY KEY IDENTITY,
	[CategoryName] NVARCHAR(100) NOT NULL, 
	[DailyRate] DECIMAL(6, 2),
	[WeeklyRate] DECIMAL(6, 2),
	[MonthlyRate] DECIMAL(7, 2),
	[WeekendRate] DECIMAL(6, 2)
)

CREATE TABLE [Cars]  (
	[Id] INT PRIMARY KEY IDENTITY,
	[PlateNumber] NVARCHAR(8) NOT NULL, 
	[Manufacturer] NVARCHAR(100) NOT NULL, 
	[Model] NVARCHAR(100) NOT NULL, 
	[CarYear] INT,
	[CategoryId] INT FOREIGN KEY REFERENCES [Categories]([Id]),
	[Doors] INT,
	[Picture] VARBINARY(MAX), 
	[Condition] NVARCHAR(50),
	[Available] BIT NOT NULL
)

CREATE TABLE [Employees]  (
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(50) NOT NULL, 
	[LastName] NVARCHAR(50) NOT NULL, 
	[Title] NVARCHAR(200), 
	[Notes] NVARCHAR(MAX)
)

CREATE TABLE [Customers]  (
	[Id] INT PRIMARY KEY IDENTITY,
	[DriverLicenceNumber] NVARCHAR(10) NOT NULL,
	[FullName] NVARCHAR(100) NOT NULL, 
	[Address] NVARCHAR(200) NOT NULL, 
	[City] NVARCHAR(100) NOT NULL, 
	[ZIPCode] NVARCHAR(8),
	[Notes] NVARCHAR(MAX)
)

CREATE TABLE [RentalOrders]  (
	[Id] INT PRIMARY KEY IDENTITY,
	[EmployeeId] INT FOREIGN KEY REFERENCES [Employees]([Id]),
	[CustomerId] INT FOREIGN KEY REFERENCES [Customers]([Id]),
	[CarId] INT FOREIGN KEY REFERENCES [Cars]([Id]),
	[TankLevel] DECIMAL(5, 2),
	[KilometrageStart] INT NOT NULL, 
	[KilometrageEnd] INT NOT NULL, 
	[TotalKilometrage] INT, 
	[StartDate] DATETIME2  NOT NULL,
	[EndDate] DATETIME2  NOT NULL,
	[TotalDays] INT,
	[RateApplied] NVARCHAR(20) NOT NULL,
	[TaxRate] DECIMAL(7, 2) NOT NULL,
	[OrderStatus] NVARCHAR(20) NOT NULL,
	[Notes] NVARCHAR(MAX)
)

INSERT INTO [Categories] ([CategoryName], [DailyRate], [WeeklyRate], [MonthlyRate], [WeekendRate])
	VALUES
	('BMW', 100.00, 500.00, 2500.00, 289.99),
	('Audi', 110.00, 555.00, 2999.00, 309.99),
	('Honda', 90.00, 500.00, NULL, NULL)

INSERT INTO [Cars] ([PlateNumber], [Manufacturer], [Model], [CarYear], [CategoryId], [Doors], [Condition], [Available])
	VALUES
	('РВ1234РВ', 'BMW', '3', 2012, 1, 4, 'Used', 1),
	('С7878СА', 'Audi', 'Quatro', 2002, 2, 2, 'Used', 1),
	('В4444ТА', 'BMW', '5', 2015, 1, 5, 'Used', 1)

INSERT INTO [Employees] ([FirstName], [LastName], [Title], [Notes])
	VALUES
	('Ivan', 'Ivanov', 'Продавач', NULL),
	('Героги', 'Георгиев', 'Монтьор', NULL),
	('Христо', 'Христов', 'Мениджър', NULL)

INSERT INTO [Customers] ([DriverLicenceNumber], [FullName], [Address], [City], [ZIPCode])
	VALUES
	('1235468', 'Ivan Petrov', 'Hristo Botev 8', 'Sofia',  NULL),
	('1212121212', 'Jana Dark', 'Ivan Vazov 13', 'Plovdiv', '4000'),
	('1455567778', 'Boris Andonov', 'ж.к. Възраждане', 'Варна',  NULL)

INSERT INTO [RentalOrders] ([EmployeeId], [CustomerId], [CarId], [TankLevel], [KilometrageStart], [KilometrageEnd], [StartDate], [EndDate], [RateApplied], [TaxRate], [OrderStatus])
	VALUES
	(1, 1, 2, 15.45, 12367, 14002, '2021-11-15', '2021-11-21', 'Dayly', 110.00, 'In progres'),
	(2, 1, 2, 15.45, 12367, 14002, '2022-06-18', '2022-06-19', 'Weekend', 309.99, 'Ready for use'),
	(3, 2, 1, 15.45, 12367, 14002, '2021-01-15', '2021-01-22', 'Weekly', 500.00, 'Finished')

--15. Hotel Database

CREATE DATABASE [Hotel]

GO

USE [Hotel]

CREATE TABLE [Employees]  (
	[Id] INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(50) NOT NULL, 
	[LastName] NVARCHAR(50) NOT NULL, 
	[Title] NVARCHAR(200), 
	[Notes] NVARCHAR(MAX)
)

CREATE TABLE [Customers]  (
	[AccountNumber] INT PRIMARY KEY,
	[FirstName] NVARCHAR(50) NOT NULL, 
	[LastName] NVARCHAR(50) NOT NULL, 
	[PhoneNumber] NVARCHAR(10) NOT NULL, 
	[EmergencyName] NVARCHAR(100), 
	[EmergencyNumber] NVARCHAR(10), 
	[Notes] NVARCHAR(MAX)
)

CREATE TABLE [RoomStatus]  (
	[Id] INT PRIMARY KEY IDENTITY,
	[RoomStatus] NVARCHAR(50) NOT NULL, 
	[Notes] NVARCHAR(MAX)
)

CREATE TABLE [RoomTypes]  (
	[Id] INT PRIMARY KEY IDENTITY,
	[RoomType] NVARCHAR(50) NOT NULL, 
	[Notes] NVARCHAR(MAX)
)

CREATE TABLE [BedTypes]  (
	[Id] INT PRIMARY KEY IDENTITY,
	[BedType] NVARCHAR(50) NOT NULL, 
	[Notes] NVARCHAR(MAX)
)

CREATE TABLE [Rooms]  (
	[Id] INT PRIMARY KEY IDENTITY,
	[RoomNumber] NVARCHAR(5) NOT NULL, 
	[RoomType] INT FOREIGN KEY REFERENCES [RoomTypes]([Id]),
	[BedType] INT FOREIGN KEY REFERENCES [BedTypes]([Id]),
	[Rate] INT,
	[RoomStatus] INT FOREIGN KEY REFERENCES [RoomStatus]([Id]),
	[Notes] NVARCHAR(MAX)
)

CREATE TABLE [Payments]  (
	[Id] INT PRIMARY KEY IDENTITY,
	[EmployeeId] INT FOREIGN KEY REFERENCES [Employees]([Id]),
	[PaymentDate] DATETIME2 NOT NULL,
	[AccountNumber] INT FOREIGN KEY REFERENCES [Customers]([AccountNumber]),
	[FirstDateOccupied] DATETIME2 NOT NULL,
	[LastDateOccupied] DATETIME2,
	[TotalDays] INT, 
	[AmountCharged] DECIMAL(8, 2),
	[TaxRate] DECIMAL(8, 2),
	[TaxAmount] DECIMAL(8, 2),
	[PaymentTotal] DECIMAL(8, 2),
	[Notes] NVARCHAR(MAX)
)

CREATE TABLE [Occupancies]  (
	[Id] INT PRIMARY KEY IDENTITY,
	[EmployeeId] INT FOREIGN KEY REFERENCES [Employees]([Id])  NOT NULL,
	[DateOccupied] DATETIME2 NOT NULL,
	[AccountNumber] INT FOREIGN KEY REFERENCES [Customers]([AccountNumber]) NOT NULL,
	[RoomNumber] INT FOREIGN KEY REFERENCES [Rooms]([Id]) NOT NULL,
	[RateApplied] INT,
	[PhoneCharge] DECIMAL(8, 2),
	[Notes] NVARCHAR(MAX)
)

INSERT INTO [Employees] ([FirstName], [LastName], [Title], [Notes])
	VALUES
	('Ivan', 'Ivanov', 'Пиколо', 'Гомес'),
	('Героги', 'Георгиев', 'Рецепционист', NULL),
	('Христо', 'Христов', 'Мениджър', NULL)

INSERT INTO [Customers] ([AccountNumber], [FirstName], [LastName], [PhoneNumber], [EmergencyName], [EmergencyNumber])
	VALUES
	(1267890, 'Чичо', 'Гошо', '089999999', NULL, NULL),
	(2857462, 'Pesho', 'Peshov', '089999777', 'Chicho Gosho', '089999999'),
	(33334890, 'Niko', 'Liverpool', '08988888', NULL, NULL)

INSERT INTO [RoomStatus] ([RoomStatus], [Notes])
	VALUES
	('Free', NULL),
	('For cleaning', 'Ваня и Пена трябва да сменят чаршафите и консумативите'),
	('Blocked', NULL)

INSERT INTO [RoomTypes] ([RoomType], [Notes])
	VALUES
	('Normal', NULL),
	('Normal+', '2 beds'),
	('Lux', NULL)

INSERT INTO [BedTypes] ([BedType], [Notes])
	VALUES
	('Normal', NULL),
	('Normal and a half', '2 beds in one'),
	('Double', NULL)

INSERT INTO [Rooms] ([RoomNumber], [RoomType], [BedType], [Rate], [RoomStatus])
	VALUES
	('101', 1, 1, NULL, 1),
	('102', 1, 2, NULL, 2),
	('120', 2, 1, NULL, 3)

INSERT INTO [Payments] ([EmployeeId], [PaymentDate], [AccountNumber], [FirstDateOccupied], [LastDateOccupied], [TotalDays], [AmountCharged], [TaxRate], [TaxAmount], [PaymentTotal])
	VALUES
	(2, '2020-12-30', 2857462 , '2021-02-01', NULL, 5, 202.50, NULL,  500.50, 1020.75),
	(2, '2020-06-13', 33334890 , '2021-06-14', '2021-06-19', NULL, 2002.50, 5,  1500.00, 4340.00),
	(2, '2021-05-03', 2857462 , '2021-06-01', NULL, 10, 1202.50, NULL,  2500.00, 35020.89)

INSERT INTO [Occupancies] ([EmployeeId], [DateOccupied], [AccountNumber], [RoomNumber])
	VALUES
	(3, '2021-06-01', 2857462, 2),
	(3, '2021-08-05', 2857462, 1),
	(1, '2021-02-26', 33334890, 2)


--16. Create SoftUni Database

CREATE DATABASE [SoftUni]

GO

USE [SoftUni]

CREATE TABLE [Towns](
	[Id]  INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE [Addresses](
	[Id]  INT PRIMARY KEY IDENTITY,
	[AddressText] NVARCHAR(100) NOT NULL,
	[TownID] INT FOREIGN KEY REFERENCES [Towns]([Id]) 
)

CREATE TABLE [Departments](
	[Id]  INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE [Employees](
	[Id]  INT PRIMARY KEY IDENTITY,
	[FirstName] NVARCHAR(50) NOT NULL,
	[MiddleName] NVARCHAR(50) NULL,
	[LastName] NVARCHAR(50) NOT NULL,
	[JobTitle] NVARCHAR(50) NOT NULL,
	[DepartmentID] INT FOREIGN KEY REFERENCES [Departments]([Id]) NOT NULL,
	[ManagerID] INT FOREIGN KEY REFERENCES [Employees]([Id]) NULL,
	[HireDate] [smalldatetime] NOT NULL,
	[Salary] DECIMAL(7, 2) NOT NULL,
	[AddressID] INT FOREIGN KEY REFERENCES [Addresses]([Id]) NULL
)

--17. Backup Database

DO IT!!

--18. Basic Insert

INSERT INTO [Towns]([Name])
     VALUES
           ('Sofia'),
           ('Plovdiv'),
           ('Varna'),
           ('Burgas')

INSERT INTO [Departments]([Name], [ManagerID])
     VALUES
           ('Engineering', NULL), 
		   ('Sales', NULL), 
		   ('Marketing', NULL), 
		   ('Software Development', NULL), 
		   ('Quality Assurance', NULL)

INSERT INTO [Employees]([FirstName],[MiddleName], [LastName] ,[JobTitle] ,[DepartmentID], [HireDate], [Salary])
     VALUES
           ('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013-02-01', 3500.00),
		   ('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004-03-02', 4000.00) 

--19. Basic Select All Fields

SELECT *
FROM [Towns]

SELECT *
FROM [Departments]

SELECT *
FROM [Employees]


--20. Basic Select All Fields and Order Them

  SELECT *
	FROM [Towns]
ORDER BY [Name]

  SELECT *
	FROM [Departments]
ORDER BY [Name]

  SELECT *
	FROM [Employees]
ORDER BY [Salary] DESC

--21. Basic Select Some Fields

  SELECT [Name]
	FROM [Towns]
ORDER BY [Name]

  SELECT [Name]
	FROM [Departments]
ORDER BY [Name]

  SELECT 
		 [FirstName], 
		 [LastName], 
		 [JobTitle],
		 [Salary]
	FROM [Employees]
ORDER BY [Salary] DESC

--22. Increase Employees Salary

UPDATE [Employees]
SET [Salary] = [Salary] * 1.1

  SELECT [Salary]
	FROM [Employees]

--23. Decrease Tax Rate

USE [Hotel]

UPDATE [Payments]
SET [TaxRate] =  [TaxRate] * 0.97

SELECT [TaxRate]
  FROM [Payments]

--24. Delete All Records

TRUNCATE TABLE [Occupancies]

SELECT *
FROM [Occupancies]