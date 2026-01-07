
/* ============================================================
   06_validation.sql
   Purpose:
   - Validate data quality in core tables
   - Reconcile staging vs core to ensure data completeness
   ============================================================ */

---------------------------------------------------------------
-- 1. VALIDATION: DATA QUALITY CHECKS
---------------------------------------------------------------

-- 1.1 Check for NULL foreign keys in fact table
-- Expect: 0 rows
SELECT *
FROM dbo.sales_pipeline
WHERE account_id IS NULL
   OR product_id IS NULL
   OR sales_agent_id IS NULL;

-- 1.2 Check negative or invalid deal values
-- Expect: 0 rows
SELECT *
FROM dbo.sales_pipeline
WHERE close_value < 0;

-- 1.3 Check invalid date logic (engage_date after close_date)
-- Expect: 0 rows
SELECT *
FROM dbo.sales_pipeline
WHERE engage_date > close_date;

-- 1.4 Check invalid deal_stage values
-- (Adjust allowed values if needed)
SELECT *
FROM dbo.sales_pipeline
WHERE deal_stage NOT IN ('Prospecting', 'Engaging','Won', 'Lost');


---------------------------------------------------------------
-- 2. RECONCILIATION: STAGING VS CORE
---------------------------------------------------------------

-- 2.1 Row count comparison (staging vs core)
SELECT 'stag.accounts' AS table_name, COUNT(*) AS row_count FROM stag.accounts
UNION ALL
SELECT 'dbo.accounts', COUNT(*) FROM dbo.accounts
UNION ALL
SELECT 'stag.products', COUNT(*) FROM stag.products
UNION ALL
SELECT 'dbo.products', COUNT(*) FROM dbo.products
UNION ALL
SELECT 'stag.sales_teams', COUNT(*) FROM stag.sales_teams
UNION ALL
SELECT 'dbo.sales_teams', COUNT(*) FROM dbo.sales_teams
UNION ALL
SELECT 'stag.sales_pipeline', COUNT(*) FROM stag.sales_pipeline
UNION ALL
SELECT 'dbo.sales_pipeline', COUNT(*) FROM dbo.sales_pipeline;

-- 2.2 Accounts present in staging but missing in core
-- Expect: 0 rows
SELECT DISTINCT s.account
FROM stag.accounts s
LEFT JOIN dbo.accounts a
    ON a.account_name = s.account
WHERE a.account_id IS NULL;

-- 2.3 Products present in staging but missing in core
-- Expect: 0 rows
SELECT DISTINCT s.product
FROM stag.products s
LEFT JOIN dbo.products p
    ON p.product_name = s.product
WHERE p.product_id IS NULL;

-- 2.4 Sales agents present in staging but missing in core
-- Expect: 0 rows
SELECT DISTINCT s.sales_agent
FROM stag.sales_teams s
LEFT JOIN dbo.sales_teams t
    ON t.sales_agent_name = s.sales_agent
WHERE t.sales_agent_id IS NULL;

-- 2.5 Sales pipeline records in staging not loaded into core
-- Expect: 0 rows (unless filtered intentionally)
--SELECT sp.opportunity_id,*
--FROM stag.sales_pipeline sp
--LEFT JOIN dbo.sales_pipeline fp
--    ON fp.opportunity_id = sp.opportunity_id
--WHERE fp.opportunity_id IS NULL;

-- 2.5 Sales pipeline records not loaded into core (expected rejects)
-- Expect: 0 rows
SELECT sp.opportunity_id
FROM stag.sales_pipeline sp
LEFT JOIN dbo.sales_pipeline fp
    ON fp.opportunity_id = sp.opportunity_id
LEFT JOIN dbo.sales_pipeline_rejects r
    ON r.opportunity_id = sp.opportunity_id
WHERE fp.opportunity_id IS NULL
  AND r.opportunity_id IS NULL;

-- Reconciliation check: staging = core + rejects
SELECT
    (SELECT COUNT(*) FROM stag.sales_pipeline) AS staging_rows,
    (SELECT COUNT(*) FROM dbo.sales_pipeline) AS core_rows,
    (SELECT COUNT(*) FROM dbo.sales_pipeline_rejects) AS rejected_rows;

-- Identify staging sales_pipeline records with missing references before loading into dbo.sales_pipeline
SELECT
	SUM(CASE WHEN st.sales_agent_id IS NULL THEN 1 ELSE 0 END) AS missing_sales_agent,
	SUM(CASE WHEN p.product_id IS NULL THEN 1 ELSE 0 END) AS missing_product,
	SUM(CASE WHEN a.account_id IS NULL THEN 1 ELSE 0 END) AS missing_account
FROM stag.sales_pipeline sp
	LEFT JOIN dbo.sales_teams st ON st.sales_agent_name = sp.sales_agent
	LEFT JOIN dbo.products p ON p.product_name = sp.product
	LEFT JOIN dbo.accounts a ON a.account_name = sp.account;
