# Data Quality Report

## Scope and method

This read-only assessment profiles the nine CSV files in `data/raw/` with Python 3.13 and pandas 3.1.1. Raw files were not altered. It checks shape, inferred data types, nulls, exact duplicate records, date validity and format, numeric validity, IQR outliers, candidate keys, and selected relationship checks.

## Overall result

All files load successfully. Every field has zero missing values and every file has zero exact duplicate rows. The date fields use the same `YYYY-MM-DD` format and have no invalid dates. Numeric fields contain no non-numeric values and no IQR outliers. These structural checks are positive, but the order-header and order-line data cannot currently be reconciled and must not be combined into a single sales total.

## Dataset inventory

| File | Rows | Columns | Candidate business key | Column names and inferred pandas data types |
| --- | ---: | ---: | --- | --- |
| `brand_data.csv` | 20 | 8 | `brand_id` | `brand_id` int64; `brand_name`, `country`, `website`, `support_email`, `status` string; `founded_year`, `phone` int64 |
| `customer_data.csv` | 100 | 5 | `customer_id` | `customer_id`, `phone` int64; `name`, `city`, `join_date` string |
| `employee_data.csv` | 100 | 4 | `employee_id` | `employee_id` int64; `name`, `branch`, `role` string |
| `order_items_data.csv` | 1,500 | 5 | `order_item_id` | `order_item_id`, `order_id`, `product_id`, `quantity` int64; `unit_price` float64 |
| `order_returns_data.csv` | 1,000 | 10 | `return_id` | `return_id`, `order_items_id`, `order_id`, `customer_id` int64; `refund_amount` float64; remaining fields string |
| `orders_data.csv` | 5,000 | 10 | `order_id` | `order_id`, `customer_id`, `employee_id`, `promotion_id` int64; `total_amount`, `shipping_cost` float64; remaining fields string |
| `products_data.csv` | 100 | 12 | `product_id` | identifiers, `stock_qty`, `warranty_months` int64; pricing and `weight` float64; remaining fields string |
| `promotion_data.csv` | 30 | 10 | `promotion_id` | `promotion_id`, `discount_percent`, `usage_limit` int64; `minimum_order` float64; remaining fields string |
| `supplier_data.csv` | 50 | 11 | `supplier_id` | `supplier_id`, `phone` int64; `rating` float64; remaining fields string |

Other unique columns exist in several small tables, such as email address or phone number. They are not recommended as model keys because uniqueness alone does not establish a stable business identifier.

## Completeness and duplicates

- Missing values: 0 in every column of every file.
- Exact duplicate records: 0 in every file.
- `status` has only one distinct value in `brand_data.csv`, `promotion_data.csv`, and `supplier_data.csv`. It should remain only if it is expected to vary in future refreshes; otherwise it has no current analytical value.

## Dates

All detected date fields use `YYYY-MM-DD`, parse correctly, and contain no inconsistent formats:

- Customer join dates: 2023-09-25 to 2026-07-26.
- Order and delivery dates: 2024-08-12 to 2026-08-12.
- Return dates: 2024-08-14 to 2026-08-12.
- Product launch dates: 2021-09-11 to 2026-07-25.
- Promotion dates: starts 2024-08-18 to 2026-08-05; all end dates are 2026-08-13.
- Supplier contract starts: 2021-10-19 to 2026-07-08.

No delivery precedes its corresponding order. No promotion end date precedes its start date. The single shared promotion end date is unusual enough to validate with the data owner; it may be intentional, but it limits promotion-period analysis.

## Numeric checks and unusual values

All numeric fields converted successfully. No negative or non-numeric values were detected in the profiled monetary, quantity, percentage, rating, stock, warranty, weight, or year fields. No values were flagged as IQR outliers.

Observed ranges include:

- Order quantity: 1 to 10.
- Order-item unit price: 52.04 to 4,997.48.
- Header total amount: 100.33 to 99,913.27.
- Shipping cost: 20.09 to 299.91.
- Product cost price: 109.29 to 2,983.75; sell price: 161.46 to 4,357.05.
- Refund amount: 62.99 to 4,994.41.
- Promotion discount: 6% to 50%.
- Supplier rating: 3.06 to 4.99.

`phone` is inferred as an integer in several files. It should be imported as text in Power Query so leading zeros and formatting cannot be lost.

## Relationship and reconciliation findings

| Check | Result | Assessment |
| --- | ---: | --- |
| Order lines with an unknown order | 0 | Valid relationship |
| Returns with an unknown order item | 0 | Valid relationship |
| Orders without any order lines | 4,530 of 5,000 | Material completeness issue |
| Orders with lines whose calculated line total differs from `total_amount` | 470 of 470 comparable orders | Material reconciliation issue |
| Delivery before order | 0 | Valid sequence |
| Promotion end before start | 0 | Valid sequence |

The returns field `order_items_id` maps to the order-line identifier `order_item_id`, but the inconsistent pluralized name should be standardized in the clean layer.

## Confirmed business decision

`orders_data.csv` is the authoritative sales source. Sales reporting will therefore use one row per order and `total_amount` as the authoritative sales amount. `order_items_data.csv` may support product-level analysis only after its incomplete coverage and unreconciled amounts are addressed; it must not be combined with header sales totals.

## Suitability for Power BI

The source is suitable for a staged Power BI model after cleaning because it has stable identifier fields, complete values, valid foreign-key references, and consistent dates. It is suitable for a trusted sales model at the order-header grain, using `orders_data.total_amount`. It is not suitable for line-item sales aggregation because 90.6% of order headers have no matching line items and the comparable header and line totals conflict.

## Recommended cleaning decisions (do not implement yet)

1. Use `orders_data` as the sales fact at order-header grain. Keep `total_amount` as the authoritative sales measure.
2. Keep order items separate and exclude their calculated revenue from sales totals until a complete, reconcilable line-item extract is supplied.
3. In Power Query, set all identifiers and phone numbers to text where preserving display format matters. Keep surrogate/business IDs as text consistently across related tables if that matches their source-system definition.
4. Convert all ISO date strings to the Date type. Use a dedicated Date table later rather than auto date/time.
5. Rename `order_items_id` to `order_item_id` only in the cleaned query, retaining the raw source column unchanged.
6. Validate whether the common promotion end date and single-valued status columns are intended.
7. Add refresh-time quality checks for line coverage, header-to-line reconciliation, and referential integrity before loading the semantic model.
