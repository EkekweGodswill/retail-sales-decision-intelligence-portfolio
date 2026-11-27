# Release QA Checklist

## Refresh and model

- Set `pDataFolder` to the local `data/raw` path and refresh all tables successfully.
- Confirm the model contains no `LocalDateTable_*` fields or broken visual fields.
- Confirm `DimDate[Date]` remains marked as the date table.
- Confirm Date filters change both sales and return visuals as intended.

## KPI reconciliation

- Total Sales: $250,468,770.96.
- Total Orders: 5,000.
- Average Order Value: $50,093.75.
- Returned Orders: 425.
- Return Transactions: 1,000.
- Total Refund Amount: $2,551,653.41.
- Order Line Coverage: 9.4%.

## Report experience

- Test every slicer with Filter, Highlight, or None interactions intentionally configured.
- Verify Product Inventory & Promotion filters do not imply product-level coverage of authoritative sales.
- Verify all visible KPI titles and tooltips state the correct business meaning.
- Verify no contact details, raw notes, technical IDs, or test pages appear in portfolio screenshots.
- Test page navigation, desktop layout, contrast, and exported PDF readability.

## Publish readiness

- Complete the README and all documentation files.
- Capture dashboard screenshots in `screenshots/`.
- Review the repository diff and ensure raw files have not been modified.
- Initialise and commit the project to Git before publishing.
