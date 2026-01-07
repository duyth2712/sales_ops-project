BEGIN TRY
    BEGIN TRAN;

-- Insert new accounts from staging
INSERT INTO dbo.accounts (
    account_name,
    sector,
    year_established,
    revenue,
    employees,
    office_location,
    subsidiary_of
)
SELECT DISTINCT
    s.account,
    s.sector,
    s.year_established,
    s.revenue,
    s.employees,
    s.office_location,
    s.subsidiary_of
FROM stag.accounts s
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.accounts a
    WHERE a.account_name = s.account
);

-- Insert new products from staging
INSERT INTO dbo.products (
    product_name,
    series,
    sales_price
)
SELECT DISTINCT
    s.product,
    s.series,
    s.sales_price
FROM stag.products s
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.products p
    WHERE p.product_name = s.product
);

-- Insert new sales_teams from staging
INSERT INTO dbo.sales_teams (
    sales_agent_name,
    manager,
    regional_office
)
SELECT DISTINCT
    s.sales_agent,
    s.manager,
    s.regional_office
FROM stag.sales_teams s
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.sales_teams t
    WHERE t.sales_agent_name = s.sales_agent
);

-- Insert new sales_pipeline from staging
INSERT INTO dbo.sales_pipeline (
    opportunity_id,
    sales_agent_id,
    product_id,
    account_id,
    deal_stage,
    engage_date,
    close_date,
    close_value
)
SELECT
    sp.opportunity_id,
    st.sales_agent_id,
    p.product_id,
    a.account_id,
    sp.deal_stage,
    sp.engage_date,
    sp.close_date,
    sp.close_value
FROM stag.sales_pipeline sp
JOIN dbo.sales_teams st
    ON st.sales_agent_name = sp.sales_agent
JOIN dbo.products p
    ON p.product_name = sp.product
JOIN dbo.accounts a
    ON a.account_name = sp.account
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.sales_pipeline fp
    WHERE fp.opportunity_id = sp.opportunity_id
);


    COMMIT;
END TRY
BEGIN CATCH
    ROLLBACK;
    THROW;
END CATCH;

-- Rebuild sales_pipeline fact table
-- Invalid records (missing business keys) are quarantined into reject table
-- Only fully valid records are loaded into core

CREATE TABLE dbo.sales_pipeline_rejects (
    opportunity_id CHAR(8),
    reason_code VARCHAR(50),
    rejected_at DATETIME DEFAULT GETDATE()
);

INSERT INTO dbo.sales_pipeline_rejects (opportunity_id, reason_code)
SELECT
    opportunity_id,
    CASE
        WHEN account IS NULL THEN 'MISSING_ACCOUNT'
        WHEN product = 'GTXPro' THEN 'INVALID_PRODUCT_NAME'
    END AS reason_code
FROM stag.sales_pipeline
WHERE account IS NULL
   OR product = 'GTXPro';