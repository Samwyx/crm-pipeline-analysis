-- 04_agent_performance.sql
-- Per-agent won deals, lost deals, win rate on closed deals only, and won revenue.

-- How does each sales agent perform, ranked by won revenue?
-- Win rate uses only Won and Lost deals, so open pipeline does not shrink the rate.
-- The LEFT JOIN keeps five agents with no deals visible (revenue 0, win rate null).
-- Among agents with deals, win rates span 55.0% to 70.4%, while won revenue
-- spans $123,431 (Violet Mclelland) to $1,153,214 (Darcel Schlecht, 349 of 553 closed).
SELECT
    t.sales_agent,
    t.manager,
    t.regional_office,
    COUNT(*) FILTER (WHERE p.deal_stage = 'Won') AS won_deals,
    COUNT(*) FILTER (WHERE p.deal_stage = 'Lost') AS lost_deals,
    COUNT(*) FILTER (WHERE p.deal_stage IN ('Won', 'Lost')) AS closed_deals,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE p.deal_stage = 'Won')
        / NULLIF(COUNT(*) FILTER (WHERE p.deal_stage IN ('Won', 'Lost')), 0),
        1
    ) AS win_rate_pct,
    COALESCE(SUM(p.close_value) FILTER (WHERE p.deal_stage = 'Won'), 0) AS won_revenue,
    ROUND(AVG(p.close_value) FILTER (WHERE p.deal_stage = 'Won'), 0) AS avg_won_deal
FROM crm.sales_teams t
LEFT JOIN crm.sales_pipeline p
    ON p.sales_agent = t.sales_agent
GROUP BY t.sales_agent, t.manager, t.regional_office
ORDER BY won_revenue DESC, t.sales_agent;

-- How does performance roll up by manager?
-- Expected: Melvin Marxen leads at $2,251,930. Dustin Brinkmann is second by won
-- count (747) but last by revenue ($1,094,363) because of a $1,465 average deal.
SELECT
    t.manager,
    COUNT(*) FILTER (WHERE p.deal_stage = 'Won') AS won_deals,
    COUNT(*) FILTER (WHERE p.deal_stage IN ('Won', 'Lost')) AS closed_deals,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE p.deal_stage = 'Won')
        / NULLIF(COUNT(*) FILTER (WHERE p.deal_stage IN ('Won', 'Lost')), 0),
        1
    ) AS win_rate_pct,
    SUM(p.close_value) FILTER (WHERE p.deal_stage = 'Won') AS won_revenue,
    ROUND(AVG(p.close_value) FILTER (WHERE p.deal_stage = 'Won'), 0) AS avg_won_deal
FROM crm.sales_pipeline p
JOIN crm.sales_teams t
    ON t.sales_agent = p.sales_agent
GROUP BY t.manager
ORDER BY won_revenue DESC;

-- How does performance roll up by regional office?
-- Expected: West $3,568,647 (1,438 won, average $2,482). Central closed more
-- deals (1,629) but only $3,346,293, with a lower $2,054 average.
SELECT
    t.regional_office,
    COUNT(*) FILTER (WHERE p.deal_stage = 'Won') AS won_deals,
    COUNT(*) FILTER (WHERE p.deal_stage IN ('Won', 'Lost')) AS closed_deals,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE p.deal_stage = 'Won')
        / NULLIF(COUNT(*) FILTER (WHERE p.deal_stage IN ('Won', 'Lost')), 0),
        1
    ) AS win_rate_pct,
    SUM(p.close_value) FILTER (WHERE p.deal_stage = 'Won') AS won_revenue,
    ROUND(AVG(p.close_value) FILTER (WHERE p.deal_stage = 'Won'), 0) AS avg_won_deal
FROM crm.sales_pipeline p
JOIN crm.sales_teams t
    ON t.sales_agent = p.sales_agent
GROUP BY t.regional_office
ORDER BY won_revenue DESC;
