-- 06_looker_data_source.sql
-- Custom query used by the Looker Studio PostgreSQL data source.
-- The Tablas tab only lists the public schema, so this query is required
-- to read crm.sales_pipeline and bring in manager, regional office, and sector.
--
-- Looker calculated fields built on top of this result:
--   Won Deals    = SUM(CASE WHEN deal_stage = "Won" THEN 1 ELSE 0 END)
--   Closed Deals = SUM(CASE WHEN deal_stage IN ("Won", "Lost") THEN 1 ELSE 0 END)
--   Win Rate     = Won Deals / Closed Deals
-- Set Win Rate to a percentage type in Looker.
--
-- Connect with the Supabase session pooler (not the transaction pooler),
-- SSL enabled, and the project's SSL certificate uploaded. Database is postgres.
-- User format: postgres.<project_ref>

SELECT
    p.*,
    t.manager,
    t.regional_office,
    a.sector
FROM crm.sales_pipeline p
LEFT JOIN crm.sales_teams t
    ON t.sales_agent = p.sales_agent
LEFT JOIN crm.accounts a
    ON a.account = p.account;
