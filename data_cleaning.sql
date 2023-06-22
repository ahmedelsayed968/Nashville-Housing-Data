USE PortfoloProjects;
-- Load data 
SELECT * FROM Nashville_housing;

-- ALTERING Columns
ALTER TABLE Nashville_housing
DROP COLUMN [Unnamed: 0];


-- Set unique id to the table
alter table Nashville_housing
add [Unique ID] int identity(1,1);
CREATE UNIQUE INDEX index1 ON Nashville_housing ([Unique ID] ASC);



ALTER TABLE Nashville_housing
DROP COLUMN [F1];

SELECT * FROM Nashville_housing;

-- Rename the Colume
EXEC sp_rename 'Nashville_housing.Sale Date', 'sale_date','COLUMN';

-- Convert Sale Data to Standard Formate
SELECT sale_date
FROM Nashville_housing;

ALTER TABLE Nashville_housing
ALTER COLUMN sale_date Date;


-- Explore Property Address 
SELECT COUNT(*)
FROM Nashville_housing
WHERE [Property Address] IS NULL; -- 194 null VALUES

-- Fix Null VALUES
SELECT  COUNT(DISTINCT [Parcel ID]) 
FROM Nashville_housing; --65192 Total , Distinct 48697

SELECT [Parcel ID], [Property Address]
FROM Nashville_housing
WHERE [Parcel ID] IN (
	SELECT [Parcel ID] 
	FROM Nashville_housing
	WHERE [Property Address] IS NULL
) AND [Property Address] IS NOT NULL; -- there exists null values in address for persons who actually have existed address in the db

SELECT  FROM Nashville_housing;

-- Populate the address
SELECT a.[Parcel ID] , a.[Property Address], b.[Parcel ID],b.[Property Address], ISNULL(a.[Property Address],b.[Property Address])
FROM Nashville_housing as a
JOIN Nashville_housing as b 
	ON a.[Parcel ID] = b.[Parcel ID]
	AND a.[Unique ID] <> b.[Unique ID]
WHERE a.[Property Address] IS NULL AND b.[Property Address] IS NOT NULL;		

UPDATE a
SET [Property Address] = ISNULL(a.[Property Address],b.[Property Address])
FROM Nashville_housing as a
JOIN Nashville_housing as b 
	ON a.[Parcel ID] = b.[Parcel ID]
	AND a.[Unique ID] <> b.[Unique ID]
WHERE a.[Property Address] IS NULL AND b.[Property Address] IS NOT NULL;	
---------------------------------------------------------------------------------------

SELECT COUNT(*) FROM Nashville_housing WHERE [Property Address] IS NULL; -- 177
SELECT * FROM Nashville_housing WHERE [Property Address] IS NULL; -- almost nulls in all cols :(

--------------------------------------------------------------------------------------------------------


SELECT DISTINCT [Sold As Vacant] FROM Nashville_housing;

SELECT  * FROM Nashville_housing ;

SELECT DISTINCT [Multiple Parcels Involved in Sale] FROM Nashville_housing;


--- Lower case values in cols
UPDATE Nashville_housing
SET [Land Use] = LOWER([Land Use]),
	[Property City] = LOWER([Property City]),
	[City]          = LOWER([City]),
	[Foundation Type] = LOWER([Foundation Type]),
	[Exterior Wall] = LOWER([Exterior Wall]);


SELECT
REPLACE([Tax District],'DISTRICT','') AS [Tax District]
FROM Nashville_housing 
WHERE [Tax District] IS NOT NULL;

UPDATE Nashville_housing
SET [Tax District] = REPLACE([Tax District],'DISTRICT','')
WHERE [Tax District] IS NOT NULL;


UPDATE Nashville_housing
SET [Tax District] = LOWER([Tax District]);

SELECT * FROM Nashville_housing;

UPDATE Nashville_housing
SET [Finished Area] = ROUND([Finished Area],2);

SELECT * FROM Nashville_housing;


---- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER( PARTITION BY [Parcel ID],[Property Address],[sale_date], [Legal Reference] ORDER BY [Unique ID]) Row_num
FROM Nashville_housing
)
DELETE 
FROM RowNumCTE
WHERE Row_num > 1;

-- Check Effect
WITH RowNumCTE AS(
SELECT *,
		ROW_NUMBER() OVER( PARTITION BY [Parcel ID],[Property Address],[sale_date], [Legal Reference] ORDER BY [Unique ID]) Row_num
FROM Nashville_housing
)
SELECT * 
FROM RowNumCTE
WHERE Row_num > 1;
