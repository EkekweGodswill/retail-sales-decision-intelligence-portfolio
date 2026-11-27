# Methodology

## Source handling

Raw CSV files are retained unchanged in `data/raw`. Power BI queries use the `pDataFolder` parameter to locate the raw-data folder. No cleaning overwrites the raw source.

## Model design

The model uses `orders` as the authoritative order-level sales fact and `returns` as a return-activity fact. `DimDate` is the governed calendar and actively filters order date and return date. Customer, employee, promotion, product, brand, and supplier tables provide descriptive context.

## Quality controls

The pandas profiling process checks row counts, field types, missing values, duplicate rows, date validity, numeric validity, candidate keys, and selected relationships. Sales, orders, returns, refunds, and order-line coverage are reconciled to independent raw-data controls.

## Material limitations

- Only 470 of 5,000 orders have order-item data.
- Comparable order-line totals do not reconcile to order-header totals.
- Product profit, gross margin, and inventory turnover are not reported as enterprise KPIs.
- Return activity uses return date, while sales uses order date. The return-activity rate is not a cohort return rate.
- Low stock uses a portfolio assumption of fewer than 20 units and represents a current-stock snapshot.
