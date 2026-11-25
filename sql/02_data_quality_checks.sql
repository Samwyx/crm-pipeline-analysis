-- 02_data_quality_checks.sql
-- Surfaces every known quality issue in the crm schema.
-- These rows were left as-is in the warehouse so the checks stay reproducible.

-- Which product values in the pipeline do not exist in products?
-- Expected: 1,480 rows of 'GTXPro' (products has 'GTX Pro').
SELECT
    p.product AS pipeline_product,
    COUNT(*) AS pipeline_rows
FROM crm.sales_pipeline p
LEFT JOIN crm.products pr
    ON pr.product = p.product
WHERE pr.product IS NULL
GROUP BY p.product
ORDER BY pipeline_rows DESC;

-- After removing spaces, do those typo values match a products row?
-- Expected: all 1,480 'GTXPro' rows match 'GTX Pro'.
SELECT
    p.product AS pipeline_product,
    pr.product AS products_product,
    COUNT(*) AS pipeline_rows
FROM crm.sales_pipeline p
LEFT JOIN crm.products pr
    ON REPLACE(pr.product, ' ', '') = REPLACE(p.product, ' ', '')
WHERE p.product IS DISTINCT FROM pr.product
GROUP BY p.product, pr.product
ORDER BY pipeline_rows DESC;

-- How many accounts have the sector typo 'technolgy'?
-- Expected: 12 accounts.
SELECT
    account,
    sector,
    office_location
FROM crm.accounts
WHERE sector = 'technolgy'
ORDER BY account;

-- How many accounts have the office location typo 'Philipines'?
-- Expected: 1 account (Bioholding).
SELECT
    account,
    sector,
    office_location
FROM crm.accounts
WHERE office_location = 'Philipines';

-- How many pipeline rows are missing account, engage_date, close_date, or close_value,
-- and in which deal stages?
-- Expected: account 1,425 (1,088 Engaging, 337 Prospecting);
-- engage_date 500 (all Prospecting);
-- close_date and close_value 2,089 each (1,589 Engaging, 500 Prospecting).
SELECT
    deal_stage,
    COUNT(*) AS deals,
    COUNT(*) FILTER (WHERE account IS NULL) AS account_nulls,
    COUNT(*) FILTER (WHERE engage_date IS NULL) AS engage_date_nulls,
    COUNT(*) FILTER (WHERE close_date IS NULL) AS close_date_nulls,
    COUNT(*) FILTER (WHERE close_value IS NULL) AS close_value_nulls
FROM crm.sales_pipeline
GROUP BY deal_stage
ORDER BY deals DESC;

-- Confirm that close_date and close_value nulls occur only on open deals,
-- and that every Lost deal has close_value 0 (so SUM(close_value) equals won revenue).
SELECT
    COUNT(*) FILTER (WHERE close_date IS NULL AND deal_stage IN ('Won', 'Lost')) AS closed_missing_close_date,
    COUNT(*) FILTER (WHERE close_value IS NULL AND deal_stage IN ('Won', 'Lost')) AS closed_missing_close_value,
    COUNT(*) FILTER (WHERE account IS NULL AND deal_stage IN ('Won', 'Lost')) AS closed_missing_account,
    COUNT(*) FILTER (WHERE deal_stage = 'Lost' AND close_value IS DISTINCT FROM 0) AS lost_with_nonzero_value,
    SUM(close_value) AS sum_close_value_all_rows,
    SUM(close_value) FILTER (WHERE deal_stage = 'Won') AS won_revenue
FROM crm.sales_pipeline;

-- Which sales agents have no deals at all?
-- Expected: Carl Lin, Carol Thompson, Elizabeth Anderson, Mei-Mei Johns, Natalya Ivanova.
SELECT
    t.sales_agent,
    t.manager,
    t.regional_office
FROM crm.sales_teams t
LEFT JOIN crm.sales_pipeline p
    ON p.sales_agent = t.sales_agent
WHERE p.opportunity_id IS NULL
ORDER BY t.sales_agent;
