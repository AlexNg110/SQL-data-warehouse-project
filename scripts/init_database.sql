/*
=============================================
Create Database and Schemas
=============================================
Script purpose:
  This script creates a new database named 'DataWarehouse'.
  Another codebase is used if checking the existence of a database with the same name is necessary.
  If the database exists, it is dropped and recreated.
  Then three schemas 'bronze', 'silver', 'gold' are created within the data base.
*/

-- Check if 'DataWarehouse' database exists, drop it
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Create 'DataWarehouse' database
CREATE DATABASE DataWarehouse;

USE DataWarehouse;
GO

-- Create schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
