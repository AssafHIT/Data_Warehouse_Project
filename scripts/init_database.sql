USE master;
GO
-- Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;


-- Create 'DataWarehouse' Database
USE Master;

Create Database DataWarehouse;

USE DataWarehouse;

Create Schema bronze;

Create Schema silver;

Create Schema gold;

