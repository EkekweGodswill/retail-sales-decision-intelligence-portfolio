# Final Project Audit: Retail Sales Report Analysis

## Scope and assessment basis

This audit covers the current raw data layer, PBIP semantic-model source, report definitions, SQL asset, Python assets, and portfolio documentation. It does not replace visual inspection in Power BI Desktop; the report refresh and date-filter testing were completed in Power BI Desktop by the project owner.

## Overall assessment

The project has progressed from a visually promising but analytically unsafe model to a credible portfolio foundation. It now has a governed `DimDate`, a dedicated Measures table, parameterized Power Query sources, authoritative order-level sales measures, and explicit disclosure of incomplete product-line coverage.

It is **not yet GitHub-ready**. The remaining issues primarily concern documentation, reproducibility, cleanup of legacy semantic objects, and making metric definitions impossible to misinterpret.

## Resolved controls

- `orders_data.csv` is the authoritative sales source at one row per order.
- All nine model source queries use `pDataFolder`; obsolete `C:\Users\aa\Downloads\Ecommerce_Project` references are absent from the semantic model.
- `DimDate` is marked as the date table and uses active one-direction relationships to order date and return date.
- Auto date/time is disabled and report definitions contain no `LocalDateTable_*` or automatic Date Hierarchy references.
- A Measures table holds the approved sales, order, customer, return, refund, repeat-customer, and order-line-coverage metrics.
- The report has been reorganized into Executive Overview, Sales Performance, Product Inventory & Promotion Performance, and Customer & Returns Performance.
- Product-line coverage is disclosed as 9.4%, and executive/sales pages state that incomplete order-line data is excluded from enterprise profit totals.

## Remaining issues and required improvements

### Critical: required before public portfolio release

#### 1. Core business documentation is empty

`business_problem.md`, `data_dictionary.md`, `methodology.md`, and `insights.md` contain no content.

**Why it matters:** a hiring manager or reviewer cannot verify the project objective, data grain, transformation decisions, KPI meanings, limitations, or analytical conclusions.

**Improvement:** complete all four documents. State that order headers are authoritative, product-line coverage is 9.4%, returns are analysed by return date, and profit is excluded from enterprise reporting.

#### 2. The repository lacks GitHub essentials

The project has no Git repository, root README, license, or dashboard screenshots.

**Why it matters:** the work cannot yet be reviewed, cloned, understood, or presented professionally on GitHub.

**Improvement:** initialise Git, add a root `README.md`, choose a license, add curated dashboard screenshots, and publish a reproducible folder map. Exclude Power BI cache and local settings, but retain PBIP source and documented sample/raw data policy.

#### 3. Power Query default remains machine-specific

`pDataFolder` is correctly parameterized, but its default value contains a local absolute Windows path.

**Why it matters:** a clone will require manual configuration before refresh, and the checked-in definition exposes an environment-specific path.

**Improvement:** retain the parameter but document configuration in the root README. Before public release, either set it to a clearly documented placeholder or provide a `parameters.example` convention that users replace locally. Do not promise one-click refresh from an unknown machine.

#### 4. SQL asset is not portable and may not match the Power BI model

`Retail_sales_store_project.sql` includes multiple hard-coded `Downloads\Ecommerce_Project` paths. It also uses database naming and column naming conventions that differ from the current CSV/PBIP model, including `order_items_id` versus `order_item_id`.

**Why it matters:** the SQL script can fail on another environment and may lead to an inconsistent data lineage story.

**Improvement:** parameterize or clearly isolate the SQL script as an optional SQL Server implementation. Reconcile schema names with the canonical raw data dictionary, document how to run it, and add a post-load reconciliation query.

### High: complete before claiming analytical maturity

#### 5. Return Rate is not a cohort return rate

`Return Rate %` equals distinct returned order IDs divided by distinct order IDs in the current filter context. With one Date table actively filtering returns by return date and orders by order date, the numerator and denominator use different business events.

**Why it matters:** the number is valid as a period activity indicator but should not be interpreted as the percentage of orders from that period that were returned.

**Improvement:** rename it to `Return Activity Rate %` across executive views, or build a cohort-return measure only after business rules for a valid return window and order/return relationship are agreed. Keep the existing definition note on the Returns page and add a tooltip or subtitle to the Executive Overview card.

#### 6. Legacy and unsafe measures remain in the model

Unused measures remain in `order_items` and `product`, including `profit`, `Gross Margin %`, `Total Profit`, and `Inventory Turnover`. `Order Share %` remains in `orders` outside the Measures table.

**Why it matters:** future report authors can accidentally use an invalid profit/margin measure, and the model appears less governed.

**Improvement:** delete or hide legacy measures after confirming that no visual depends on them. Keep only validated measures in the Measures table. If partial-coverage diagnostic measures are retained, prefix their names with `Partial coverage -` and document their scope.

#### 7. Low-stock policy is hard-coded and undocumented

`Low Stock Product` counts products with `stock_qty < 20`.

**Why it matters:** 20 may be a useful threshold, but it is an undisclosed business assumption rather than a sourced policy.

**Improvement:** either document 20 as a portfolio assumption or implement a What-If parameter called `Low Stock Threshold`. State explicitly that stock is a current snapshot, not an inventory history.

#### 8. Product and promotion filters can be semantically misaligned

The Product Inventory & Promotion page includes product/brand attributes and promotion sales. Product attributes only connect to authoritative sales through the incomplete order-item extract.

**Why it matters:** a product or brand slicer can appear to govern promotion revenue while not representing the full order-level sales population.

**Improvement:** disable interactions between product/brand/category slicers and order-header promotion visuals unless the filter relationship is explicitly valid. Separate the page into an inventory/product section and a promotion-performance section, each with clearly scoped filters.

#### 9. Custom HTML/animated measures add portability and accessibility risk

The supplier table contains several long HTML/CSS measures used for animated backgrounds and page navigation.

**Why it matters:** custom visuals or HTML-rendering dependencies can behave differently in service, export, mobile, and accessibility scenarios. They also increase semantic-model noise.

**Improvement:** prefer native page navigation, themes, buttons, and text boxes. Remove unused animation measures. Retain a custom visual only when it has a documented business benefit and has been tested in the intended publishing environment.

### Medium: quality and maintainability improvements

#### 10. A development-only test page remains visible

The report includes a `Date Filter Test` page.

**Why it matters:** test pages weaken a portfolio presentation and confuse report consumers.

**Improvement:** keep it temporarily during testing, then hide or remove it before publishing. Record the test outcome in the methodology or QA checklist instead.

#### 11. Some pages remain visually dense

Product Inventory & Promotion has 17 visuals and Customer & Returns has 15.

**Why it matters:** density can dilute the main decision, increase cognitive load, and weaken the executive narrative.

**Improvement:** target one business question per page, four KPI cards at most, and approximately five to eight supporting visuals. Move secondary detail into drill-through or tooltip pages.

#### 12. Visual interactions require a documented QA pass

The report uses multiple slicers on every main page. Static source review cannot prove each cross-filter interaction is meaningful.

**Improvement:** use Edit interactions in Power BI Desktop. For every slicer, explicitly set Filter, Highlight, or None for every visual. Capture the decisions in a short QA checklist.

#### 13. Data labels and aggregation semantics need visual-by-visual review

At least one Top Customers visual references both the authoritative `[Total Sales]` measure and raw `orders[total_amount]` in its definition.

**Why it matters:** raw column aggregation can create unclear or duplicated values relative to the governed measure.

**Improvement:** use Measures-table metrics for all business values. Retain raw columns only when a distinct detail-level use is intentional and clearly labelled.

#### 14. Model naming is still mixed

Source tables use lower-case technical names such as `orders`, `returns`, and `product`, while the Measures table follows business-facing naming.

**Improvement:** adopt an explicit naming convention. A preferred option is `Fact Sales`, `Fact Returns`, `Dim Customer`, `Dim Product`, and so on, with source/staging queries hidden from report view. Rename only after checking report dependencies.

#### 15. IDs and contact attributes need report-view governance

The source tables include IDs, phone numbers, email addresses, addresses, and notes.

**Why it matters:** unnecessary personal/contact fields can clutter the Fields pane and may be inappropriate for a public portfolio screenshot.

**Improvement:** hide technical IDs and contact attributes from report view unless they support a defined drill-through or operational detail page. Do not publish identifiable contact data in screenshots.

#### 16. Python analysis assets are incomplete

`data_quality.py` and `exploratory_analysis.py` are empty. `profile_raw_data.py` is the only implemented analysis script.

**Improvement:** either implement the intended scripts with a documented purpose and reproducible outputs, or remove the empty placeholders. Add `requirements.txt` or a concise environment/setup section.

## Recommended release sequence

1. Complete the four core documentation files and a root README.
2. Remove/hide test pages and legacy/unsafe measures.
3. Resolve slicer interactions on the Product Inventory & Promotion page.
4. Document the return-activity definition and low-stock assumption.
5. Make SQL and Power Query configuration reproducible for a new user.
6. Capture polished screenshots with filters cleared and no identifiable contact information visible.
7. Run a final QA checklist: refresh, KPI reconciliation, slicer interactions, page navigation, accessibility/contrast, and export/PDF check.
8. Initialise Git, commit the clean PBIP source, and publish the portfolio repository.

## Release decision

**Status: do not publish publicly yet.** The analytical model is substantially improved and can become portfolio-ready after the documentation, reproducibility, and semantic-model cleanup items above are completed.
