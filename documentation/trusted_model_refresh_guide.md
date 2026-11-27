# Trusted model refresh guide

## What was rebuilt

- All nine import queries use the `pDataFolder` parameter; no query uses the former downloaded-folder path.
- `order_returns_data.csv` is the returns source.
- The model uses `DimDate` as the single conformed date table. Its active relationships filter `orders[order_date]` and `returns[return_date]`.
- Automatic date/time generation is disabled, and the model no longer references any `LocalDateTable_*` or `DateTableTemplate_*` table.
- `Measures Table` is the governed reporting layer. Its Total Orders measure uses `DISTINCTCOUNT(orders[order_id])`.
- Legacy measures and calculated product profit metrics are hidden. They are retained temporarily only to avoid silently removing existing report bindings.
- Dimension and fact primary keys are identified in the semantic model.

## First controlled refresh

1. Open `powerbi/Retail Sales Report analysis.pbip`.
2. If Power Query requests a path, set `pDataFolder` to the project's `data/raw` folder. Do not move or edit raw CSV files.
3. Refresh the model. Resolve any visual errors by replacing fields with the corresponding approved `Measures Table` measure.
4. Confirm `DimDate[Date]` is the marked date column in Model view.
5. Test `DimDate[Year] = 2024`:
   - Total Sales: `$45,468,185.77`
   - Total Orders: `925`
   - Returns visuals must change as well.
6. Keep `product` profit, margin, and turnover out of executive reporting. If retained for exploration, label the page **Partial-coverage analysis** because order-line coverage is 9.4%.
7. Save, close, and reopen Power BI Desktop once. Confirm the model source still contains the parameter and `DimDate` before making further dashboard edits.

## Visual replacements

Use these approved measures for executive cards and charts:

- Sales: `Total Sales`, `Total Orders`, `Average Order Value`
- Customers: `Customers with Orders`, `Average Customer Spend`, `Repeat Customers`
- Returns: `Returned Orders`, `Return Transactions`, `Return Activity Rate %`, `Total Refund Amount`
- Promotion: `Promotion Revenue`, `Promotion Order Count`, `Average Orders per Promotion`
- Inventory: `Low Stock Products (Threshold: 20)`

Use `DimDate[Year Month]` for monthly trend axes and `DimDate[Year]` for year slicers. Do not use a Date Hierarchy or `delivery_date` as the executive reporting date filter.
