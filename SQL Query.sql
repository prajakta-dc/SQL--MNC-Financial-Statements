USE [SQL Training]
GO

-- Create a backup copy for each data table
SELECT *
      INTO [dbo].[dimEntityRaw]
      FROM [dbo].[dimEntity]

SELECT *
      INTO [dbo].[FctTableRaw]
      FROM [dbo].[FctTable]

SELECT *
      INTO [dbo].[FctAdjRaw]
      FROM [dbo].[FctAdj]

SELECT *
      INTO [dbo].[AccountRaw]
      FROM [dbo].[Account]

-- Delete two empty columns from dimEntity Table
ALTER TABLE dimEntity
DROP COLUMN UserDefined1, UserDefined2

-- Add columns to dimEntity to group rows into two segments 
ALTER TABLE dimEntity
ADD Company NVARCHAR(255)

-- Update Company column with values 
UPDATE dimEntity
SET Company = 'RemainCo'
WHERE Country = 'USA'

UPDATE dimEntity
SET Company = 'SpinCo'
WHERE Country <> 'USA'


-- TO join later, first make data types of columns USDAmount in FctTable and FctAdj same 
ALTER TABLE FctAdj
ALTER COLUMN USDAmount DECIMAL


SELECT * FROM FctTable

--Select all records from fctAdj and sort records by USDAmount desc. What are the top five largest adjustments in 2014?
SELECT TOP(5) * 
	FROM FctAdj 
WHERE Year = 2014 
ORDER BY USDAmount Desc 


--Select records from fctData where USDAmount is less than zero and sort by USDAmount ascending. How many records are there? What is the smallest amount?
SELECT * 
	FROM FctTable
WHERE USDAmount < 0 
ORDER BY USDAmount ASC

ALTER TABLE [dbo].[Account] 
ADD AccountRollup5 NVARCHAR(255)


UPDATE [dbo].[Account]
	SET [AccountRollup5] = 'BS' 
	WHERE [AccountNumber] < 400000

UPDATE [dbo].[Account]
	SET [AccountRollup5] = 'IS' 
	WHERE [AccountNumber] >= 400000

ALTER TABLE [dbo].[Account] 
	ADD AccountSign NVARCHAR(255)

UPDATE [dbo].[Account]
	SET [AccountSign] = 1
	WHERE [AccountRollup3] IN ('Current Assets','Long-Term Assets','Revenue')

UPDATE [dbo].[Account]
	SET [AccountSign] = -1
	WHERE [AccountRollup3] IN ('Cost of sales','Current Liabilities', 'D&A', 'FX', 'Interest', 'Long-Term Liabilities', 
								'Minority interest', 'Opex', 'Other expense', 'Shareholder’s equity', 'Stock comp', 'Taxes')


ALTER TABLE FctTable ALTER COLUMN USDAmount decimal(18,0)


-- Merge all tables to combine required columns 
-- UNION ALL so that duplicate rows are retained 
CREATE VIEW vwMainData AS
	SELECT D2.AccountNumber, Month, Year, Entity, USDAmount, JEID, Source, Country, Company, AccountDescription, AccountRollup3, AccountRollup4, AccountRollup5
		FROM (SELECT AccountNumber, Month, Year, D1.Entity, USDAmount, JEID, Source, Country, Company
			FROM (SELECT AccountNumber, Month, Year, Entity, USDAmount, NULL AS JEID, NULL AS Source
						FROM FctTable as F1
						UNION ALL 
						SELECT AccountNumber, Month, Year, Entity, USDAmount, JEID, Source
						FROM FctAdj As F2) AS D1
			LEFT JOIN
				dimEntity as E
					ON D1.Entity = E.Entity) AS D2
LEFT JOIN
	Account as A
	ON D2.AccountNumber = A.AccountNumber


SELECT COUNT(*) 
FROM dbo.FctTable

SELECT COUNT(*) 
FROM dbo.FctAdj

-- ViewMainData rows should equal the sum of rows of FctTable and FctAdj
SELECT COUNT(*) 
FROM dbo.vwMainData