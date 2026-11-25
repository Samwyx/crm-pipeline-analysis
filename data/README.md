# Data

Source: [innocentmfa/crm-sales-opportunities](https://www.kaggle.com/datasets/innocentmfa/crm-sales-opportunities) on Kaggle.

This folder includes the full dimension tables and a sample of the fact table:

- `accounts.csv`: 85 accounts (complete)
- `products.csv`: 7 products (complete)
- `sales_teams.csv`: 35 sales agents (complete)
- `data_dictionary.csv`: 21 field descriptions (complete). The first column is named `Table` in the Kaggle file. It was loaded into Postgres as `table_name`.
- `sales_pipeline_sample.csv`: the first 200 of 8,800 opportunity rows. The full pipeline file is not stored here. Download it from the Kaggle dataset linked above.

Load these files into the `crm` schema created by `sql/01_schema.sql`. See the root README for the load order and the product-name mismatch that prevents a product foreign key.
