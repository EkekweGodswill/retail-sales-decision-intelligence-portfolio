# Portfolio Audit: Retail Sales Report Analysis

> Historical audit. Several findings in this document were remediated after the audit. See `final_project_audit.md` for the full finding list and `implementation_status.md` for the current remediation record.

## Executive assessment

**Current assessment: promising foundation, not yet portfolio-ready.** The project has a PBIP source structure, a four-page report, a broad set of source entities, and a verified raw-data quality assessment. However, credibility is materially constrained by non-portable data paths, an order-line reconciliation failure, model design that relies on auto date/time tables, weak semantic naming, and several measures that are either incorrect, ambiguous, or placeholders.

The project can become an outstanding portfolio case study by prioritising decision trust over visual novelty: establish an authoritative order-level fact, create a clean star schema, rebuild the metrics layer, and document definitions and validation.

## What is working

- The project is source-controlled as a PBIP rather than only a binary PBIX file.
- The report has four distinct pages: Home, Sales & Profit, Product & Promotion, and Customers & Returns.
- The raw layer now contains nine canonical CSV sources and their copies have been hash-verified against their originals.
- Data profiling found no nulls, exact duplicate rows, invalid numeric values, mixed date formats, or invalid foreign keys in the tested relationships.
- `orders_data.csv` has been confirmed as the authoritative source for sales at the order-header grain.
- Existing report pages include navigation, headline cards, filtering, and purpose-specific analytical visuals.

## Critical findings: resolve before publishing

### 1. Sales grain and reconciliation

`orders_data.csv` is authoritative, yet only 470 of 5,000 orders have an order-item record. All 470 comparable orders have a calculated line total that differs from `orders.total_amount`.

**Impact:** product-level revenue, profit, margin, and inventory measures cannot be represented as company sales performance. Mixing order-header totals and order-line totals would misstate sales.

**Required decision:** retain `FactSales` at one order per row using `orders.total_amount`. Treat order items as incomplete operational detail and label any product or margin analysis as partial coverage until a reconciled line-level source is supplied.

### 2. Non-portable Power Query sources

All primary model queries reference `C:\Users\aa\Downloads\Ecommerce_Project` rather than the project raw-data folder.

**Impact:** refresh will fail on another computer and the PBIP cannot be responsibly shared as a portfolio project.

**Required change:** replace local user paths with a documented Power Query parameter that defaults to the repository's `data/raw` location. Do not use the current personal download path.

### 3. Date-model design

The model has nine hidden `LocalDateTable_*` tables and auto date/time is enabled. Multiple independent local date tables fragment time intelligence and make role-playing dates difficult to manage.

**Impact:** time calculations can be inconsistent and the semantic model is harder to understand and maintain.

**Required change:** disable auto date/time, create one explicit `DimDate`, mark it as the date table, relate it actively to order date and return date, and use inactive relationships plus `USERELATIONSHIP` only for delivery date when required.

### 4. Incorrect or non-production measures

- `Total Orders` uses `SUM(orders[order_id])`, not a count of orders.
- `Test Rate` is a hard-coded `DIVIDE(1000,1200)` placeholder.
- `count_retrun` and `Reapt Customers` contain spelling errors and are not professional semantic names.
- `Return Rate %` divides return rows by the incorrect `Total Orders` measure. It also needs an agreed numerator definition: return transactions, returned orders, or returned unique orders.
- `Total Returned Orders` counts return rows, not distinct orders, so the label can be misleading.
- `Inventory Turnover` divides units sold by current stock quantity. This is a stock-coverage proxy, not inventory turnover, which requires cost of goods sold and average inventory over time.
- `Total Profit`, `profit`, and `Gross Margin %` use incomplete order-item detail. They must not be presented as whole-business profitability.

**Required change:** create a dedicated measures table and rebuild every displayed metric from agreed business definitions. Remove test and decorative measures from the production model.

### 5. Documentation and portfolio narrative

`business_problem.md`, `data_dictionary.md`, `insights.md`, and `methodology.md` are empty.

**Impact:** a reviewer cannot understand the business question, source grain, transformation choices, KPI definitions, assumptions, or limits. This is the largest portfolio-story gap.

**Required change:** complete these documents before publishing. The data-quality report should be linked from the README and its reconciliation limitation should be stated plainly.

## High-priority model improvements

1. Rename business-facing tables to `FactSales`, `FactReturns`, `DimCustomer`, `DimEmployee`, `DimPromotion`, `DimProduct`, `DimBrand`, and `DimSupplier`. Keep source/staging names separate from model-facing names.
2. Use single-direction dimension-to-fact relationships. Avoid ambiguous paths, including the parallel customer and order relationships around returns, unless an explicit analysis requirement needs them.
3. Hide technical IDs and raw source columns from report view. Keep keys visible only where they help drill-through or reconciliation.
4. Set identifiers and phone numbers to text where their formatting must be preserved. Set currencies and percentages with intentional formats and controlled decimals.
5. Rename `order_items_id` to `order_item_id` in the clean returns query only; do not edit the raw file.
6. Add a visible data-quality check view for order-line coverage and key integrity. It is more credible to disclose incomplete product coverage than to conceal it.

## Recommended KPI contract

Create and document one definition for each KPI before writing DAX:

- Sales: `SUM(FactSales[Total Amount])`.
- Orders: `DISTINCTCOUNT(FactSales[Order ID])`.
- Average order value: Sales divided by Orders.
- Customers: distinct customers with at least one order in the current filter context.
- Sales per customer: Sales divided by Customers.
- Refund amount: sum of return refund amounts.
- Returned orders: distinct return order IDs, subject to the agreed return-status inclusion rule.
- Return rate: returned orders divided by orders, with date basis explicitly stated.
- Delivery lead time: average delivery date minus order date, excluding invalid or missing dates.

Do not publish profit, gross margin, product revenue, product sales rank, or inventory turnover as enterprise performance KPIs until the line-level extract reconciles to the authoritative sales source.

## Report experience audit

The current report has strong coverage but is visually dense: the three analytical pages contain 16 to 18 visuals each, including five cards per page, multiple slicers, navigation, and several chart types. The Home page has only four visuals.

**Recommendation:** redesign around a clear executive question per page rather than visual count.

- **Executive overview:** sales trend, order volume, customer activity, return/refund risk, and three headline drivers.
- **Sales performance:** time trend, payment/delivery status, employee or branch contribution, and order-value distribution.
- **Customer and returns:** repeat customers, cohort/join-date lens, return rate and refund trend, return reasons and statuses.
- **Product and promotion:** clearly labelled partial-coverage analysis only, or remove from the executive storyline until reconciled.

Use a consistent visual hierarchy: one decision headline, 3–5 supporting visuals, limited slicers, descriptive titles, and tooltip definitions. Avoid custom HTML navigation/background measures as a substitute for native page navigation and a clean report theme; they increase maintenance burden without adding business insight.

## Validation required before release

1. Reconcile total sales, orders, customers, refunds, and return counts to independently calculated controls.
2. Test all measures with no filter, one period, one customer, one promotion, and a no-data selection.
3. Confirm all model relationships are one-to-many in the intended direction and have no accidental many-to-many or bidirectional filtering.
4. Refresh from a clean path on a second machine or a clean project copy.
5. Inspect every page at standard desktop resolution and validate cross-filtering, navigation, tooltips, titles, and accessibility contrast.
6. Export a PDF or screenshots for the GitHub README and verify every displayed KPI has a documented definition.

## Delivery standard for an outstanding portfolio project

The published repository should contain:

- A concise README with business objective, dashboard preview, key outcomes, tools, and limitations.
- The completed business problem, data dictionary, methodology, insights, and data-quality documents.
- The PBIP project with portable source configuration and a clean semantic model.
- A data folder policy that preserves raw inputs and treats processed outputs as reproducible.
- A KPI dictionary and validation evidence.
- A clear disclosure that `orders_data.csv` is authoritative and product-line analysis has incomplete order coverage.

## Sequenced remediation plan

**Stage 1 — Trust:** portable source parameter, clean star schema, single date table, corrected measures, and reconciliation controls.

**Stage 2 — Decision quality:** rebuild the four pages around executive questions, use only validated KPIs, and label incomplete product coverage.

**Stage 3 — Portfolio polish:** complete the project narrative, publish screenshots, provide data refresh steps, and perform a final independent validation pass.

No Power BI model, raw data, or dashboard visual has been changed as part of this audit.
