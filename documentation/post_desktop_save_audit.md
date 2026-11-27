# Post-Desktop-Save Audit

## Executive finding

The latest Power BI Desktop save reverted the source-controlled semantic-model and report-definition improvements that had previously been applied. Documentation, SQL portability, Git setup, and raw-data structure remain improved, but the active PBIP source is currently back in its pre-remediation state.

## Critical regressions

1. `DimDate.tmdl` is absent. The model no longer contains the governed Date dimension.
2. `Measures Table.tmdl` is absent. Approved measures are no longer centralized.
3. `expressions.tmdl` is absent. The `pDataFolder` Power Query parameter no longer exists.
4. All nine source queries again reference `C:\Users\aa\Downloads\Ecommerce_Project`.
5. Auto date/time is enabled and nine `LocalDateTable_*` tables exist.
6. Four report visuals still reference LocalDate tables or automatic Date Hierarchies.
7. Six report visuals use `Total Profit`, `Gross Margin %`, or `Inventory Turnover`, despite incomplete order-line coverage.
8. Legacy measures have returned, including an incorrect `Total Orders = SUM(order_id)`, hard-coded `Test Rate`, misspelled `count_retrun`, and misspelled `Reapt Customers`.

## Confirmed retained improvements

- Nine canonical CSVs remain in `data/raw/`.
- Core Markdown documentation is populated.
- A root README, QA checklist, requirements file, screenshot guidance, and `.gitignore` exist.
- The SQL script now uses the SQLCMD `DataFolder` variable rather than a personal download path.
- The project is initialized as a local Git repository.
- The development-only Date Filter Test page is no longer in the visible page order.

## Remaining portfolio issues

1. No license has been selected.
2. No final screenshots have been added.
3. The Git repository has no first commit.
4. Power BI Desktop interaction and refresh QA must be repeated after recovering the model changes.
5. Low-stock policy, return-activity definition, and product-line coverage limitation must remain visible in the final published report and documentation.

## Recovery recommendation

Do not continue dashboard edits on this reverted PBIP source. First restore the governed semantic-model changes in Power BI Desktop or reapply them to the current PBIP source, then save and refresh once. Before further Power BI Desktop work, commit or copy the PBIP folder so Desktop saves cannot overwrite uncommitted source changes.

The immediate priority is recovery, not additional visual redesign.
