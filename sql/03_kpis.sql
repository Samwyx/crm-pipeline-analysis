-- 03_kpis.sql
-- Headline KPIs for the portfolio dashboard and README.

-- What is total won revenue, won/lost/open volume, and win rate on closed deals only?
-- Expected: $10,005,534 won revenue, 4,238 Won, 2,473 Lost, 1,589 Engaging,
-- 500 Prospecting, 6,711 closed, 63.15% win rate.
-- Open deals are excluded from the win-rate denominator so they do not pull the rate down.
SELECT
    COUNT(*) AS total_deals,
    COUNT(*) FILTER (WHERE deal_stage = 'Won') AS won_deals,
    COUNT(*) FILTER (WHERE deal_stage = 'Lost') AS lost_deals,
    COUNT(*) FILTER (WHERE deal_stage = 'Engaging') AS engaging_deals,
    COUNT(*) FILTER (WHERE deal_stage = 'Prospecting') AS prospecting_deals,
    COUNT(*) FILTER (WHERE deal_stage IN ('Won', 'Lost')) AS closed_deals,
    SUM(close_value) FILTER (WHERE deal_stage = 'Won') AS won_revenue,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE deal_stage = 'Won')
        / NULLIF(COUNT(*) FILTER (WHERE deal_stage IN ('Won', 'Lost')), 0),
        2
    ) AS win_rate_pct
FROM crm.sales_pipeline;

-- What is the average and median won deal size, and how long do won deals take to close?
-- Expected: average $2,360.91, median $1,117, average 51.8 days (median 57),
-- close dates from 2017-03-01 to 2017-12-31.
SELECT
    COUNT(*) AS won_deals,
    ROUND(AVG(close_value), 2) AS avg_won_deal,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY close_value)::numeric, 2) AS median_won_deal,
    MIN(close_value) AS min_won_deal,
    MAX(close_value) AS max_won_deal,
    ROUND(AVG(close_date - engage_date), 1) AS avg_days_engage_to_close,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY close_date - engage_date) AS median_days_engage_to_close,
    MIN(close_date) AS first_close_date,
    MAX(close_date) AS last_close_date
FROM crm.sales_pipeline
WHERE deal_stage = 'Won';
