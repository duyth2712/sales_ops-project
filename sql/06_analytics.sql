/*
====================================================
 Sales Operations Analytics
 Purpose:
 - Monitor sales pipeline health
 - Support SLA & performance tracking
 - Provide inputs for Ops dashboards
====================================================
*/

-- 1. Pipeline overview by deal stage
-- How many opportunities are in each stage and their total value
SELECT
    deal_stage, 
    COUNT(*) AS opportunity_count,
    SUM(close_value) AS total_pipeline_value
FROM dbo.sales_pipeline
GROUP BY deal_stage
ORDER BY opportunity_count DESC;


-- 2. Win rate (conversion rate)
-- Percentage of opportunities that are closed as Won
SELECT
    CAST(
        COUNT(CASE WHEN deal_stage = 'Won' THEN 1 END) * 100.0
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS win_rate_percent
FROM dbo.sales_pipeline;


-- 3. Revenue contribution by product
-- Identify which products generate the most revenue
SELECT
    p.product_name,
    COUNT(*) AS won_deals,
    SUM(sp.close_value) AS total_revenue
FROM dbo.sales_pipeline sp
JOIN dbo.products p
    ON p.product_id = sp.product_id
WHERE sp.deal_stage = 'Won'
GROUP BY p.product_name
ORDER BY total_revenue DESC;


-- 4. Sales agent performance
-- Evaluate sales agent productivity and revenue contribution
SELECT
    st.sales_agent_name,
    COUNT(*) AS total_opportunities,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN 1 ELSE 0 END) AS won_deals,
    SUM(CASE WHEN sp.deal_stage = 'Won' THEN sp.close_value ELSE 0 END) AS revenue
FROM dbo.sales_pipeline sp
JOIN dbo.sales_teams st
    ON st.sales_agent_id = sp.sales_agent_id
GROUP BY st.sales_agent_name
ORDER BY revenue DESC;


-- 5. Average sales cycle duration (SLA indicator)
-- Measure how long it takes to close a deal
SELECT
    AVG(DATEDIFF(DAY, engage_date, close_date)) AS avg_sales_cycle_days
FROM dbo.sales_pipeline
WHERE close_date IS NOT NULL
  AND engage_date IS NOT NULL;


----------------------------------------------------
-- 6. Pipeline aging analysis
-- Identify open opportunities that are taking too long
SELECT
    deal_stage,
    COUNT(*) AS open_opportunities,
    AVG(DATEDIFF(DAY, engage_date, GETDATE())) AS avg_days_open
FROM dbo.sales_pipeline
WHERE deal_stage NOT IN ('Won', 'Lost')
GROUP BY deal_stage
ORDER BY avg_days_open DESC;


----------------------------------------------------
-- 7. Data quality impact (Rejected vs Loaded)
----------------------------------------------------
-- Show impact of data quality issues on pipeline volume
SELECT
    'Loaded to core' AS record_type,
    COUNT(*) AS record_count
FROM dbo.sales_pipeline

UNION ALL

SELECT
    'Rejected records' AS record_type,
    COUNT(*) AS record_count
FROM dbo.sales_pipeline_rejects;
