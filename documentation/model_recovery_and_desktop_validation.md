# Model recovery and Power BI Desktop validation

## Applied source fixes

- Added a `pDataFolder` parameter that points to this project's `data/raw` folder.
- Updated all nine import queries to use that parameter. The returns query now reads the authoritative `order_returns_data.csv` source.
- Restored the governed `DimDate` table and active date relationships to `orders[order_date]` and `returns[return_date]`.
- Disabled automatic time-intelligence generation so future date visuals use `DimDate`.
- Added a dedicated `Measures Table` with approved executive KPIs.
- Hid legacy measures that are mathematically wrong, hard-coded, duplicated, or based on the incomplete order-line coverage. The fields remain in the model temporarily so existing visual bindings can be safely replaced.

## Required Power BI Desktop check

The report source currently contains three remaining legacy date-slicer bindings that use `orders[delivery_date]`. Do not carry those fields forward: re-bind each slicer to `DimDate[Year]` in Power BI Desktop. This makes the slicers govern the authorised Sales and Returns date relationships consistently.

1. Close any currently open copy of the report without saving it.
2. Make a normal folder copy of the project as a recovery backup.
3. Open `powerbi/Retail Sales Report analysis.pbip`.
4. In Power Query, confirm `pDataFolder` resolves to this project's `data/raw` folder, then refresh.
5. In Model view, mark `DimDate[Date]` as the date table if the designation is not already retained.
6. Update every visual that still uses a `LocalDateTable_*` field or automatic Date Hierarchy:
   - Trend/month slicer: `DimDate[Year Month]`
   - Drill-down: `DimDate[Year]`, `DimDate[Quarter]`, `DimDate[Month]`
   - Detail/range filters: `DimDate[Date]`
7. Replace legacy measures with fields from `Measures Table`:
   - `Total Orders` -> `Measures Table[Total Orders]`
   - `Test Rate` / old return-rate fields -> `Measures Table[Return Activity Rate %]`
   - product profit, gross margin, and inventory turnover -> remove from executive pages, or label them **partial-coverage analysis**.
8. Confirm one date filter changes both Sales and Returns results. Check 2024 controls: sales `$45,468,185.77`, orders `925`.
9. Save, close Power BI Desktop, and reopen once to confirm the source changes persist.

Do not delete the `LocalDateTable_*` artifacts until no visual field well refers to them. Then remove their relationships and tables from Model view, save, and re-test the report.
