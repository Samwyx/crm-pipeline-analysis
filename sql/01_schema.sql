-- 01_schema.sql
-- Recreates the crm schema used in the Supabase warehouse (project crm-analytics-lab).
-- Definitions match information_schema and pg_indexes on the live database.
--
-- Load order: sales_teams, products, accounts, data_dictionary, then sales_pipeline.
-- accounts.subsidiary_of references accounts.account, so either load parent
-- accounts first or add that foreign key after the load.
--
-- No foreign key is declared from sales_pipeline.product to products.product.
-- 1,480 pipeline rows use 'GTXPro' while the products table uses 'GTX Pro'.
-- See sql/02_data_quality_checks.sql and join via REPLACE(product, ' ', '') instead.

CREATE SCHEMA IF NOT EXISTS crm;

CREATE TABLE crm.sales_teams (
    sales_agent     text PRIMARY KEY,
    manager         text,
    regional_office text
);

CREATE TABLE crm.products (
    product     text PRIMARY KEY,
    series      text,
    sales_price numeric
);

CREATE TABLE crm.accounts (
    account           text PRIMARY KEY,
    sector            text,
    year_established  integer,
    revenue           numeric,
    employees         integer,
    office_location   text,
    subsidiary_of     text REFERENCES crm.accounts (account)
);

CREATE TABLE crm.data_dictionary (
    table_name  text NOT NULL,
    field       text NOT NULL,
    description text,
    PRIMARY KEY (table_name, field)
);

CREATE TABLE crm.sales_pipeline (
    opportunity_id text PRIMARY KEY,
    sales_agent    text REFERENCES crm.sales_teams (sales_agent),
    product        text,
    account        text REFERENCES crm.accounts (account),
    deal_stage     text,
    engage_date    date,
    close_date     date,
    close_value    numeric
);
