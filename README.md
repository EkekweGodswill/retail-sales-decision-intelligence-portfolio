# Retail Sales Report Analysis

## Overview

This Power BI portfolio project analyses retail sales performance, customer activity, returns, inventory, and promotion configuration. It is designed to demonstrate data-quality assessment, semantic-model governance, DAX design, dashboard design, and business communication.

## Business objective

Provide decision makers with a trusted view of order-level sales performance, customer and return activity, delivery status, inventory position, and promotion-related sales.

## Important data scope

- `orders_data.csv` is the authoritative sales source. One row represents one order.
- Product order-line detail covers 470 of 5,000 orders (9.4%) and does not reconcile to order-header totals.
- Product-line profit and margin are therefore excluded from enterprise sales and profit reporting.
- Return activity is analysed by return date. The return-activity rate is not a cohort-based return rate.

## Repository structure

- `data/raw/` — immutable source CSV files.
- `documentation/` — business problem, data dictionary, methodology, insights, data quality, and audit records.
- `powerbi/` — PBIP report and semantic-model source.
- `python/` — reproducible data-profiling utilities.
- `screenshots/` — curated dashboard screenshots for this README.
- `Retail_sales_store_project.sql` — optional SQL Server implementation.

## Report previews

The following screenshots show the four report pages after the Power BI Desktop review:

### Executive Overview

![Executive Overview](screenshots/executive-overview.png)

### Sales Performance

![Sales Performance](screenshots/sales-performance.png)

### Product Inventory & Promotion Performance

![Product Inventory & Promotion Performance](screenshots/product-inventory-promotion-performance.png)

### Customer & Returns Performance

![Customer & Returns Performance](screenshots/customer-returns-performance.png)

## Open the Power BI report

1. Open `powerbi/Retail Sales Report analysis.pbip` in Power BI Desktop.
2. Set the `pDataFolder` parameter to the absolute path of this repository's `data/raw` folder.
3. Refresh the model.
4. Confirm the validation checks in [`documentation/qa_checklist.md`](documentation/qa_checklist.md).

## Core KPIs

- Total Sales
- Total Orders
- Average Order Value
- Average Customer Spend
- Returned Orders
- Return Transactions
- Total Refund Amount
- Return Activity Rate
- Repeat Customers
- Order Line Coverage

## Career and hiring assessment

See [`documentation/career_and_hiring_assessment.md`](documentation/career_and_hiring_assessment.md) for role positioning, evidence-based portfolio and interview materials, and the final hiring-manager assessment.

## Refresh and release checks

Before publishing, refresh all tables, reconcile KPI cards to `documentation/data_quality_report.md`, validate slicer interactions, remove development-only pages, and export final screenshots with no contact details visible.

## Tools

Power BI Desktop, Power Query, DAX, Python, pandas, and optional SQL Server.
