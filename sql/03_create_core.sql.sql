--  DDL for Table accounts
IF EXISTS ( SELECT 1 FROM sys.tables WHERE name = 'accounts' and schema_id = (SELECT schema_id FROM sys.schemas WHERE name='dbo'))
	DROP TABLE dbo.accounts;
CREATE TABLE dbo.accounts
(	
	account_id INT IDENTITY(1,1),
	account_name VARCHAR(100) NOT NULL,
	sector VARCHAR(50),
	year_established SMALLINT,
	revenue DECIMAL(10,2),
	employees INT,
	office_location VARCHAR(50),
	subsidiary_of VARCHAR(100),
	CONSTRAINT PK_accounts PRIMARY KEY CLUSTERED (account_id ASC)
);

--  DDL for Table products
IF EXISTS ( SELECT 1 FROM sys.tables WHERE name = 'products' and schema_id = (SELECT schema_id FROM sys.schemas WHERE name='dbo'))
	DROP TABLE dbo.products;
CREATE TABLE dbo.products
(	
	product_id INT IDENTITY(1,1),
	product_name VARCHAR(100) NOT NULL,
	series VARCHAR(20),
	sales_price DECIMAL(10,2),
	CONSTRAINT PK_products PRIMARY KEY CLUSTERED (product_id ASC)
);

--  DDL for Table sales_teams
IF EXISTS ( SELECT 1 FROM sys.tables WHERE name = 'sales_teams' and schema_id = (SELECT schema_id FROM sys.schemas WHERE name='dbo'))
	DROP TABLE dbo.sales_teams;
CREATE TABLE dbo.sales_teams
(	
	sales_agent_id INT IDENTITY(1,1),
	sales_agent_name VARCHAR(100) NOT NULL,
	manager VARCHAR(100),
	regional_office VARCHAR(100),
	CONSTRAINT PK_sales_teams PRIMARY KEY CLUSTERED (sales_agent_id ASC)
); 

--  DDL for Table sales_pipeline
IF EXISTS ( SELECT 1 FROM sys.tables WHERE name = 'sales_pipeline' and schema_id = (SELECT schema_id FROM sys.schemas WHERE name='dbo'))
	DROP TABLE dbo.sales_pipeline;
CREATE TABLE dbo.sales_pipeline
(	
	opportunity_id CHAR(8) NOT NULL,
	sales_agent_id INT NOT NULL,
	product_id INT NOT NULL,
	account_id INT NOT NULL,
	deal_stage VARCHAR(20),
	engage_date DATE,
	close_date DATE,
	close_value DECIMAL(10,2),
	CONSTRAINT PK_sales_pipeline PRIMARY KEY CLUSTERED (opportunity_id ASC),
    CONSTRAINT FK_sales_pipeline_account
        FOREIGN KEY (account_id) REFERENCES dbo.accounts(account_id),
    CONSTRAINT FK_sales_pipeline_product
        FOREIGN KEY (product_id) REFERENCES dbo.products(product_id),
    CONSTRAINT FK_sales_pipeline_sales_agent
        FOREIGN KEY (sales_agent_id) REFERENCES dbo.sales_teams(sales_agent_id)
); 

-- Add indexes on foreign keys to speed up joins and reporting queries
CREATE INDEX IX_sales_pipeline_account_id
ON dbo.sales_pipeline(account_id);

CREATE INDEX IX_sales_pipeline_product_id
ON dbo.sales_pipeline(product_id);

CREATE INDEX IX_sales_pipeline_sales_agent_id
ON dbo.sales_pipeline(sales_agent_id);