-- Insert new accounts
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
LEFT JOIN dbo.accounts a
    ON a.account_name = s.account
WHERE a.account_id IS NULL;

-- Insert new products
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
LEFT JOIN dbo.products p
    ON REPLACE(LOWER(p.product_name), ' ', '') = REPLACE(LOWER(s.product), ' ', '')
WHERE p.product_id IS NULL;


-- Insert new sales agents
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
LEFT JOIN dbo.sales_teams t
    ON t.sales_agent_name = s.sales_agent
WHERE t.sales_agent_id IS NULL;

-- Insert new sales_pipeline
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
FROM (
    SELECT *,
           REPLACE(LOWER(product), ' ', '') AS canonical_product
    FROM stag.sales_pipeline
) sp
JOIN dbo.sales_teams st
    ON st.sales_agent_name = sp.sales_agent
JOIN (
    SELECT product_id,
           REPLACE(LOWER(product_name), ' ', '') AS canonical_product
    FROM dbo.products
) p
    ON sp.canonical_product = p.canonical_product
JOIN dbo.accounts a
    ON a.account_name = sp.account
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.sales_pipeline fp
    WHERE fp.opportunity_id = sp.opportunity_id
);

select * from dbo.sales_pipeline