/*
  Load raw CSV data into staging tables
 */

-- Truncate staging table and reload accounts data from CSV
IF EXISTS (SELECT 1 FROM stag.accounts)
BEGIN
    TRUNCATE TABLE stag.accounts;
END
BULK INSERT stag.accounts
FROM 'C:\sales_ops-mini-project\data\accounts.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

-- Truncate staging table and reload products data from CSV
IF EXISTS (SELECT 1 FROM stag.products)
BEGIN
    TRUNCATE TABLE stag.products;
END
BULK INSERT stag.products
FROM 'C:\sales_ops-mini-project\data\products.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

-- Truncate staging table and reload sales_teams data from CSV
IF EXISTS (SELECT 1 FROM stag.sales_teams)
BEGIN
    TRUNCATE TABLE stag.sales_teams;
END
BULK INSERT stag.sales_teams
FROM 'C:\sales_ops-mini-project\data\sales_teams.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);

-- Truncate staging table and reload sales_pipeline data from CSV
IF EXISTS (SELECT 1 FROM stag.sales_pipeline)
BEGIN
    TRUNCATE TABLE stag.sales_pipeline;
END
BULK INSERT stag.sales_pipeline
FROM 'C:\sales_ops-mini-project\data\sales_pipeline.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);