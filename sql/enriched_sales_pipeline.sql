-- Enriched sales pipeline for a Looker Studio data source.
-- Adds the sales manager, regional office, and account sector to every
-- pipeline deal so the pipeline can be sliced by team, region, and industry.

SELECT
    p.*,
    t.manager,
    t.regional_office,
    a.sector
FROM crm.sales_pipeline AS p
-- Sales team. LEFT JOIN keeps the deal when no team row matches the sales agent.
LEFT JOIN crm.sales_teams AS t
    ON t.sales_agent = p.sales_agent
-- Account. LEFT JOIN keeps the deal when no account row matches the account.
LEFT JOIN crm.accounts AS a
    ON a.account = p.account
;
