-- 05_pipeline_trends.sql
-- Stage mix, monthly won revenue, and product revenue (with the GTXPro typo normalized).

-- How many deals sit in each stage?
-- Expected: Won 4,238, Lost 2,473, Engaging 1,589, Prospecting 500 (2,089 still open).
SELECT
    deal_stage,
    COUNT(*) AS deals
FROM crm.sales_pipeline
GROUP BY deal_stage
ORDER BY deals DESC;

-- How does won revenue and won deal count move by month?
-- Expected: peaks in 2017-03 ($1,134,672), 2017-06 ($1,338,466), 2017-09 ($1,235,264),
-- and 2017-12 ($1,131,573), with dips the month after each quarter end.
SELECT
    DATE_TRUNC('month', close_date)::date AS month,
    COUNT(*) AS won_deals,
    SUM(close_value) AS won_revenue
FROM crm.sales_pipeline
WHERE deal_stage = 'Won'
GROUP BY DATE_TRUNC('month', close_date)
ORDER BY month;

-- Which products drive won revenue, after normalizing 'GTXPro' to 'GTX Pro'?
-- Expected: GTX Pro $3,510,578 (35.1% of won revenue) from 729 won deals.
-- GTX Pro plus GTX Plus Pro are 61.4% of won revenue.
SELECT
    pr.product,
    pr.series,
    pr.sales_price,
    COUNT(*) FILTER (WHERE p.deal_stage = 'Won') AS won_deals,
    COUNT(*) FILTER (WHERE p.deal_stage IN ('Won', 'Lost')) AS closed_deals,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE p.deal_stage = 'Won')
        / NULLIF(COUNT(*) FILTER (WHERE p.deal_stage IN ('Won', 'Lost')), 0),
        1
    ) AS win_rate_pct,
    SUM(p.close_value) FILTER (WHERE p.deal_stage = 'Won') AS won_revenue,
    ROUND(AVG(p.close_value) FILTER (WHERE p.deal_stage = 'Won'), 0) AS avg_won_deal,
    ROUND(
        100.0 * SUM(p.close_value) FILTER (WHERE p.deal_stage = 'Won')
        / SUM(SUM(p.close_value) FILTER (WHERE p.deal_stage = 'Won')) OVER (),
        1
    ) AS pct_of_won_revenue
FROM crm.sales_pipeline p
LEFT JOIN crm.products pr
    ON REPLACE(pr.product, ' ', '') = REPLACE(p.product, ' ', '')
GROUP BY pr.product, pr.series, pr.sales_price
ORDER BY won_revenue DESC;
