/* 
	Staging tables store raw CRM data loaded from CSV files
*/
-- Create stag schema
IF NOT EXISTS (
    SELECT 1 
    FROM sys.schemas 
    WHERE name = 'stag'
)
BEGIN
    EXEC('CREATE SCHEMA stag');
END;
GO

-- DDL for stag.accounts table
IF EXISTS ( SELECT 1 FROM sys.tables WHERE name = 'accounts' and schema_id = (SELECT schema_id FROM sys.schemas WHERE name='stag'))
	DROP TABLE stag.accounts;
CREATE TABLE stag.accounts
(
	account           VARCHAR(100),   -- Company name
	sector            VARCHAR(50),    -- Industry
	year_established  SMALLINT,       -- Year established
	revenue           DECIMAL(12,2),  -- Annual revenue (millions USD)
	employees         INT,            -- Number of employees
	office_location   VARCHAR(50),    -- Headquarters location
	subsidiary_of     VARCHAR(100)    -- Parent company
);
GO

-- DDL for stag.products table
IF EXISTS ( SELECT 1 FROM sys.tables WHERE name = 'products' and schema_id = (SELECT schema_id FROM sys.schemas WHERE name='stag'))
	DROP TABLE stag.products;
CREATE TABLE stag.products
(
	product       VARCHAR(100),     -- Product name
	series        VARCHAR(50),      -- Product series
	sales_price   DECIMAL(10,2)     -- Sales price
);
GO

-- DDL for stag.sales_teams table
IF EXISTS ( SELECT 1 FROM sys.tables WHERE name = 'sales_teams' and schema_id = (SELECT schema_id FROM sys.schemas WHERE name='stag'))
	DROP TABLE stag.sales_teams;
CREATE TABLE stag.sales_teams
(
	sales_agent      VARCHAR(100),  -- Sales agent name
	manager          VARCHAR(100),  -- Manager name
	regional_office  VARCHAR(50)    -- Regional office / region
);
GO

-- DDL for stag.sales_pipeline table
IF EXISTS ( SELECT 1 FROM sys.tables WHERE name = 'sales_pipeline' and schema_id = (SELECT schema_id FROM sys.schemas WHERE name='stag'))
	DROP TABLE stag.sales_pipeline;
CREATE TABLE stag.sales_pipeline
(
	opportunity_id   VARCHAR(20),
	sales_agent      VARCHAR(100),
	product          VARCHAR(50),
	account          VARCHAR(100),
	deal_stage       VARCHAR(20),   
	engage_date      DATE,
	close_date       DATE,           
	close_value      DECIMAL(10,2)   
);
GO