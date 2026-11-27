# Data Dictionary

## Authoritative fact tables

- `orders`: one row per order. Key: `order_id`. Authoritative fields: `total_amount`, `order_date`, `customer_id`, `employee_id`, `promotion_id`, `payment_method`, `delivery_status`, and `shipping_cost`.
- `returns`: one row per return transaction. Key: `return_id`. Fields include `order_id`, `customer_id`, `return_date`, `return_reason`, `return_status`, and `refund_amount`.

## Descriptive tables

- `customer`: customer identity, city, and join date. Key: `customer_id`.
- `employee`: employee branch and role. Key: `employee_id`.
- `promotion`: promotion type, discount configuration, and period. Key: `promotion_id`.
- `product`: product inventory and commercial attributes. Key: `product_id`.
- `brand`: brand attributes. Key: `brand_id`.
- `supplier`: supplier attributes. Key: `supplier_id`.
- `DimDate`: governed calendar used for order and return analysis. Key: `Date`.

## Limited-scope table

- `order_items`: one row per order item. Key: `order_item_id`. It covers 470 orders only and cannot be used for enterprise sales, profit, margin, or inventory-turnover totals.

## KPI definitions

- Total Sales: sum of `orders[total_amount]`.
- Total Orders: distinct count of `orders[order_id]`.
- Average Order Value: Total Sales divided by Total Orders.
- Returned Orders: distinct count of `returns[order_id]`.
- Return Transactions: count of return rows.
- Total Refund Amount: sum of `returns[refund_amount]`.
- Return Activity Rate: Returned Orders divided by Total Orders in the active report context.
- Order Line Coverage: distinct orders in `order_items` divided by Total Orders.
