:setvar DataFolder "C:\REPLACE_WITH_YOUR_PROJECT_PATH\data\raw"

-- Run this script in SQLCMD mode after setting DataFolder to the local raw-data folder.
IF DB_ID('Retail_sales') IS NULL
    CREATE DATABASE Retail_sales;
GO
USE Retail_sales;
GO

IF OBJECT_ID('customer', 'U') IS NULL
BEGIN
    CREATE TABLE customer (
        customer_id INT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        city VARCHAR(50),
        join_date DATE,
        phone VARCHAR(20)
    );
END;

IF OBJECT_ID('Employee', 'U') IS NULL
BEGIN
    CREATE TABLE Employee(
        employee_id INT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        branch VARCHAR(50),
        role VARCHAR(50)
    );
END;

IF OBJECT_ID('product', 'U') IS NULL

BEGIN
CREATE TABLE product(
    product_id INT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(50) NOT NULL,
    brand_id INT,
    cost_price DECIMAL(10,2) NOT NULL,
    sell_price DECIMAL(10,2) NOT NULL,
     supplier_id INT,
    stock_qty INT NOT NULL DEFAULT 0,
    CONSTRAINT chk_price CHECK(sell_price >= cost_price),
    
 
warranty_months INT,
weight DECIMAL(6,2),
color VARCHAR(50),
launch_date DATE
);
End;

IF OBJECT_ID('orders', 'U') IS NULL

BEGIN
CREATE TABLE orders(
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT,
    payment_method VARCHAR(10) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    order_date DATE NOT NULL DEFAULT GETDATE(),

    FOREIGN KEY(customer_id)
    REFERENCES customer(customer_id),

    FOREIGN KEY(employee_id)
    REFERENCES Employee(employee_id),

    CHECK(payment_method IN ('cash','card','wallet'))
);
End;

IF OBJECT_ID('order_items', 'U') IS NULL

BEGIN

CREATE TABLE order_items(
    order_items_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,

    FOREIGN KEY(order_id)
    REFERENCES orders(order_id)
    ON DELETE CASCADE,

    FOREIGN KEY(product_id)
    REFERENCES product(product_id),

    CHECK(quantity > 0)
);
End;

IF OBJECT_ID('brand', 'U') IS NULL

BEGIN
CREATE TABLE brand
(
    brand_id INT  PRIMARY KEY,
    brand_name VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    founded_year INT,
    website VARCHAR(200),
    support_email VARCHAR(100),
    phone VARCHAR(20),
    status VARCHAR(20) DEFAULT 'Active'
);
End;

IF OBJECT_ID('supplier', 'U') IS NULL
BEGIN
    CREATE TABLE supplier
    (
        supplier_id INT PRIMARY KEY,
        supplier_name VARCHAR(100) NOT NULL,
        contact_person VARCHAR(100),
        phone VARCHAR(20),
        email VARCHAR(100),
        city VARCHAR(100),
        country VARCHAR(100),
        address VARCHAR(200),
        rating DECIMAL(4,2),
        contract_start DATE,
        status VARCHAR(20) DEFAULT 'Active'
    );
END;
GO

IF OBJECT_ID('promotion', 'U') IS NULL
BEGIN
    CREATE TABLE promotion
    (
        promotion_id INT PRIMARY KEY,
        promotion_name VARCHAR(100),
        promotion_type VARCHAR(50),
        discount_percent DECIMAL(5,2),
        minimum_order DECIMAL(10,2),
        start_date DATE,
        end_date DATE,
        coupon_code VARCHAR(50),
        usage_limit INT,
        status VARCHAR(20)
    );
END;
GO

IF OBJECT_ID('order_returns', 'U') IS NULL
BEGIN
    CREATE TABLE order_returns
    (
        return_id INT IDENTITY(1,1) PRIMARY KEY,
        order_items_id INT NOT NULL,
        return_date DATE,
        order_id INT,
        customer_id INT,
        return_reason VARCHAR(200),
        return_status VARCHAR(50),
        refund_amount DECIMAL(10,2),
        approved_by VARCHAR(100),
        notes VARCHAR(300)
    );
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_order_returns_orderitems'
)
BEGIN
    ALTER TABLE order_returns
    ADD CONSTRAINT FK_order_returns_orderitems
    FOREIGN KEY (order_items_id)
    REFERENCES order_items(order_items_id);
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_order_returns_orders'
)
BEGIN
    ALTER TABLE order_returns
    ADD CONSTRAINT FK_order_returns_orders
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id);
END;

IF NOT EXISTS (
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = 'FK_order_returns_customer'
)
BEGIN
    ALTER TABLE order_returns
    ADD CONSTRAINT FK_order_returns_customer
    FOREIGN KEY (customer_id)
    REFERENCES customer(customer_id);
END;






IF NOT EXISTS (SELECT 1 FROM customer)
BEGIN
  BULK INSERT customer
FROM '$(DataFolder)\customer_data.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIELDQUOTE = '"',
    TABLOCK
);
END;

IF NOT EXISTS (SELECT 1 FROM Employee)
BEGIN
BULK INSERT Employee
FROM '$(DataFolder)\employee_data.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIELDQUOTE = '"',
    TABLOCK
);
End;

IF NOT EXISTS (SELECT 1 FROM product)
BEGIN
BULK INSERT product
FROM '$(DataFolder)\products_data.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIELDQUOTE = '"',
    TABLOCK
);
END;

IF NOT EXISTS (SELECT 1 FROM orders)
BEGIN
BULK INSERT orders
FROM '$(DataFolder)\orders_data.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIELDQUOTE = '"',
    TABLOCK
);
End;

IF NOT EXISTS (SELECT 1 FROM order_items)
BEGIN
BULK INSERT order_items
FROM '$(DataFolder)\order_items_data.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIELDQUOTE = '"',
    TABLOCK
);
End;

IF NOT EXISTS (SELECT 1 FROM brand)
BEGIN
BULK INSERT brand
FROM '$(DataFolder)\brand_data.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIELDQUOTE = '"',
    TABLOCK
);
End;

IF NOT EXISTS (SELECT 1 FROM promotion)
BEGIN
BULK INSERT promotion 
FROM '$(DataFolder)\promotion_data.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIELDQUOTE = '"',
    TABLOCK
);
End;

IF NOT EXISTS (SELECT 1 FROM order_returns)
BEGIN
    BULK INSERT order_returns
    FROM '$(DataFolder)\order_returns_data.csv'
    WITH
    (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        FIELDQUOTE = '"',
        TABLOCK
    );
END;

IF OBJECT_ID('supplier', 'U') IS NULL
BEGIN
    BULK INSERT supplier
    FROM '$(DataFolder)\supplier_data.csv'
    WITH
    (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        FIELDQUOTE = '"',
        TABLOCK
    );
END;
GO

USE Retail_sales;
GO

/* =========================================================
   STEP 6 — RETAIL SALES BUSINESS ANALYSIS
   ========================================================= */


/* =========================================================
   6.1 — TOTAL SALES
   Business Question:
   How much sales value has the business generated?
   ========================================================= */

SELECT
    SUM(total_amount) AS total_sales
FROM orders;


/* =========================================================
   6.2 — TOTAL ORDERS
   Business Question:
   How many orders has the business received?
   ========================================================= */

SELECT
    COUNT(*) AS total_orders
FROM orders;


/* =========================================================
   6.3 — AVERAGE ORDER VALUE
   Business Question:
   How much does the average order spend?
   ========================================================= */

SELECT
    AVG(total_amount) AS average_order_value
FROM orders;


/* =========================================================
   6.4 — EXECUTIVE SALES KPIs
   Business Question:
   What are the key overall sales KPIs?
   ========================================================= */

SELECT
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_sales,
    AVG(total_amount) AS average_order_value
FROM orders;


/* =========================================================
   6.5 — MONTHLY SALES TREND
   Business Question:
   How are sales changing over time?
   ========================================================= */

SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    SUM(total_amount) AS total_sales
FROM orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    sales_year,
    sales_month;


/* =========================================================
   6.6 — TOP 5 BEST-SELLING PRODUCTS
   Business Question:
   Which products are customers buying the most?
   ========================================================= */

SELECT TOP 5
    p.product_id,
    p.name AS product_name,
    SUM(oi.quantity) AS total_quantity_sold
FROM product p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.name
ORDER BY
    total_quantity_sold DESC;


/* =========================================================
   6.7 — SALES BY CATEGORY
   Business Question:
   Which product categories generate the most sales?
   ========================================================= */

SELECT
    p.category,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM product p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.category
ORDER BY
    total_sales DESC;


/* =========================================================
   6.8 — SALES BY PAYMENT METHOD
   Business Question:
   How are customers paying?
   ========================================================= */

SELECT
    payment_method,
    COUNT(*) AS number_of_orders,
    SUM(total_amount) AS total_sales
FROM orders
GROUP BY
    payment_method
ORDER BY
    total_sales DESC;


/* =========================================================
   6.9 — TOP 10 CUSTOMERS
   Business Question:
   Who are our most valuable customers?
   ========================================================= */

SELECT TOP 10
    c.customer_id,
    c.name,
    COUNT(o.order_id) AS number_of_orders,
    SUM(o.total_amount) AS total_spending
FROM customer c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.name
ORDER BY
    total_spending DESC;


/* =========================================================
   6.10 — LOW-STOCK PRODUCTS
   Business Question:
   Which products are running low on inventory?
   ========================================================= */

SELECT
    product_id,
    name AS product_name,
    category,
    stock_qty
FROM product
WHERE stock_qty < 10
ORDER BY
    stock_qty ASC;


/* =========================================================
   6.11 — PROFIT BY CATEGORY
   Business Question:
   Which categories generate the most profit?
   ========================================================= */

SELECT
    p.category,
    SUM(
        (oi.unit_price - p.cost_price) * oi.quantity
    ) AS total_profit
FROM product p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.category
ORDER BY
    total_profit DESC;


/* =========================================================
   6.12 — PROFIT MARGIN BY CATEGORY
   Business Question:
   Which categories are the most profitable relative
   to their sales?
   ========================================================= */

SELECT
    p.category,

    SUM(oi.quantity * oi.unit_price) AS total_sales,

    SUM(
        (oi.unit_price - p.cost_price) * oi.quantity
    ) AS total_profit,

    ROUND(
        SUM(
            (oi.unit_price - p.cost_price) * oi.quantity
        ) * 100.0
        / NULLIF(
            SUM(oi.quantity * oi.unit_price),
            0
        ),
        2
    ) AS profit_margin_percent

FROM product p
JOIN order_items oi
    ON p.product_id = oi.product_id

GROUP BY
    p.category

ORDER BY
    profit_margin_percent DESC;


/* =========================================================
   6.13 — PAYMENT METHOD MARKET SHARE
   Business Question:
   What percentage of orders uses each payment method?
   ========================================================= */

SELECT
    payment_method,

    COUNT(*) AS number_of_orders,

    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS order_percentage

FROM orders

GROUP BY
    payment_method

ORDER BY
    number_of_orders DESC;


/* =========================================================
   6.14 — TOP 10 PRODUCTS BY PROFIT PER UNIT
   Business Question:
   Which products generate the highest profit per unit?
   ========================================================= */

SELECT TOP 10
    product_id,
    name AS product_name,
    category,
    cost_price,
    sell_price,

    sell_price - cost_price AS profit_per_unit

FROM product

ORDER BY
    profit_per_unit DESC;


/* =========================================================
   6.15 — TOTAL PROFIT
   Business Question:
   How much profit has the business generated from
   recorded product sales?
   ========================================================= */

SELECT
    SUM(
        (oi.unit_price - p.cost_price) * oi.quantity
    ) AS total_profit

FROM product p
JOIN order_items oi
    ON p.product_id = oi.product_id;


/* =========================================================
   6.16 — PROFIT BY PRODUCT
   Business Question:
   Which individual products contribute the most profit?
   ========================================================= */

SELECT TOP 10
    p.product_id,
    p.name AS product_name,
    p.category,

    SUM(oi.quantity) AS quantity_sold,

    SUM(
        (oi.unit_price - p.cost_price) * oi.quantity
    ) AS total_profit

FROM product p
JOIN order_items oi
    ON p.product_id = oi.product_id

GROUP BY
    p.product_id,
    p.name,
    p.category

ORDER BY
    total_profit DESC;


/* =========================================================
   6.17 — CUSTOMER ORDER FREQUENCY
   Business Question:
   Which customers order most frequently?
   ========================================================= */

SELECT TOP 10
    c.customer_id,
    c.name,
    COUNT(o.order_id) AS number_of_orders,
    SUM(o.total_amount) AS total_spending

FROM customer c
JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.name

ORDER BY
    number_of_orders DESC;


/* =========================================================
   6.18 — CUSTOMERS WHO HAVE NOT ORDERED RECENTLY
   Business Question:
   Which existing customers may be becoming inactive?
   ========================================================= */

SELECT
    c.customer_id,
    c.name,
    MAX(o.order_date) AS last_order_date

FROM customer c

JOIN orders o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.name

HAVING
    MAX(o.order_date) < DATEADD(MONTH, -3, GETDATE())

ORDER BY
    last_order_date ASC;


/* =========================================================
   6.19 — PRODUCTS WITH HIGH STOCK
   Business Question:
   Which products may be overstocked?
   ========================================================= */

SELECT
    product_id,
    name AS product_name,
    category,
    stock_qty

FROM product

WHERE stock_qty > 100

ORDER BY
    stock_qty DESC;


/* =========================================================
   6.20 — CATEGORY SALES AND PROFIT SUMMARY
   Business Question:
   How does each category perform financially?
   ========================================================= */

SELECT
    p.category,

    SUM(oi.quantity) AS units_sold,

    SUM(oi.quantity * oi.unit_price) AS total_sales,

    SUM(
        (oi.unit_price - p.cost_price) * oi.quantity
    ) AS total_profit,

    ROUND(
        SUM(
            (oi.unit_price - p.cost_price) * oi.quantity
        ) * 100.0
        / NULLIF(
            SUM(oi.quantity * oi.unit_price),
            0
        ),
        2
    ) AS profit_margin_percent

FROM product p
JOIN order_items oi
    ON p.product_id = oi.product_id

GROUP BY
    p.category

ORDER BY
    total_sales DESC;


/* =========================================================
   6.21 — MONTHLY SALES AND ORDER PERFORMANCE
   Business Question:
   How does sales performance change each month?
   ========================================================= */

SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,

    COUNT(*) AS total_orders,

    SUM(total_amount) AS total_sales,

    AVG(total_amount) AS average_order_value

FROM orders

GROUP BY
    YEAR(order_date),
    MONTH(order_date)

ORDER BY
    sales_year,
    sales_month;


/* =========================================================
   6.22 — TOP 10 PRODUCTS BY SALES VALUE
   Business Question:
   Which products generate the most sales value?
   ========================================================= */

SELECT TOP 10
    p.product_id,
    p.name AS product_name,
    p.category,

    SUM(oi.quantity) AS quantity_sold,

    SUM(
        oi.quantity * oi.unit_price
    ) AS total_sales

FROM product p
JOIN order_items oi
    ON p.product_id = oi.product_id

GROUP BY
    p.product_id,
    p.name,
    p.category

ORDER BY
    total_sales DESC;


/* =========================================================
   6.23 — LOW-STOCK PRODUCTS WITH SALES HISTORY
   Business Question:
   Which low-stock products are actually selling?
   ========================================================= */

SELECT
    p.product_id,
    p.name AS product_name,
    p.category,
    p.stock_qty,

    COALESCE(
        SUM(oi.quantity),
        0
    ) AS quantity_sold

FROM product p

LEFT JOIN order_items oi
    ON p.product_id = oi.product_id

WHERE p.stock_qty < 10

GROUP BY
    p.product_id,
    p.name,
    p.category,
    p.stock_qty

ORDER BY
    quantity_sold DESC;


/* =========================================================
   6.24 — OVERALL BUSINESS PERFORMANCE SUMMARY
   Business Question:
   What is the overall financial and operational picture?
   ========================================================= */

SELECT

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(o.total_amount) AS total_sales,

    AVG(o.total_amount) AS average_order_value,

    SUM(oi.quantity) AS total_units_sold,

    SUM(
        (oi.unit_price - p.cost_price) * oi.quantity
    ) AS total_profit

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN product p
    ON oi.product_id = p.product_id;


/* =========================================================
   END OF STEP 6
   ========================================================= */

     SELECT
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_sales,
    AVG(total_amount) AS average_order_value
FROM orders;

SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_sales,
    AVG(total_amount) AS average_order_value
FROM orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    sales_year,
    sales_month;

SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM orders;

SELECT TOP 10
    p.product_id,
    p.name AS product_name,
    p.category,
    SUM(oi.quantity) AS quantity_sold
FROM product p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.name,
    p.category
ORDER BY
    quantity_sold DESC;

    SELECT
    p.name AS product_name,
    p.category,
    COUNT(DISTINCT p.product_id) AS product_records,
    SUM(oi.quantity) AS total_units_sold
FROM product p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.name,
    p.category
HAVING COUNT(DISTINCT p.product_id) > 1
ORDER BY
    total_units_sold DESC;

    SELECT TOP 10
    p.name AS product_name,
    p.category,
    SUM(oi.quantity) AS quantity_sold,
    SUM(oi.quantity * oi.unit_price) AS total_sales
FROM product p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.name,
    p.category
ORDER BY
    total_sales DESC;

    SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    SUM((oi.unit_price - p.cost_price) * oi.quantity) AS total_profit,
    ROUND(
        SUM((oi.unit_price - p.cost_price) * oi.quantity) * 100.0
        / NULLIF(SUM(oi.quantity * oi.unit_price), 0),
        2
    ) AS profit_margin_percent
FROM product p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.category
ORDER BY
    total_sales DESC;

    SELECT TOP 5 *
FROM customer;

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'customer'
ORDER BY ORDINAL_POSITION;

SELECT TOP 10
    c.customer_id,
    c.name AS customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS average_order_value
FROM customer c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.name
ORDER BY
    total_spent DESC;

    SELECT TOP 10
    c.customer_id,
    c.name AS customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS average_order_value
FROM customer c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.name
ORDER BY
    total_orders DESC,
    total_spent DESC;

   SELECT
    c.customer_id,
    c.name AS customer_name,
    MAX(o.order_date) AS last_order_date,
    DATEDIFF(
        DAY,
        MAX(o.order_date),
        (SELECT MAX(order_date) FROM orders)
    ) AS days_since_last_order
FROM customer c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.name
HAVING
    DATEDIFF(
        DAY,
        MAX(o.order_date),
        (SELECT MAX(order_date) FROM orders)
    ) >= 90
ORDER BY
    days_since_last_order DESC;

    SELECT
    c.customer_id,
    c.name AS customer_name,
    c.city,
    c.join_date
FROM customer c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.join_date;

SELECT TOP 1 *
FROM product;
SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'product'
ORDER BY ORDINAL_POSITION;
SELECT
    product_id,
    name AS product_name,
    category,
    stock_qty
FROM product
WHERE stock_qty <= 10
ORDER BY stock_qty ASC;

SELECT
    p.product_id,
    p.name AS product_name,
    p.category,
    p.stock_qty,
    COALESCE(SUM(oi.quantity), 0) AS total_units_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_sales
FROM product p
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
WHERE p.stock_qty <= 10
GROUP BY
    p.product_id,
    p.name,
    p.category,
    p.stock_qty
ORDER BY
    total_units_sold DESC;

    SELECT TOP 5 *
FROM Employee;

SELECT TOP 5 *
FROM orders;

SELECT
    e.employee_id,
    e.name AS employee_name,
    e.role,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_sales,
    AVG(o.total_amount) AS average_order_value
FROM Employee e
JOIN orders o
    ON e.employee_id = o.employee_id
GROUP BY
    e.employee_id,
    e.name,
    e.role
ORDER BY
    total_sales DESC;

    SELECT TOP 10
    e.employee_id,
    e.name AS employee_name,
    e.role,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_sales,
    AVG(o.total_amount) AS average_order_value
FROM Employee e
JOIN orders o
    ON e.employee_id = o.employee_id
GROUP BY
    e.employee_id,
    e.name,
    e.role
ORDER BY
    total_orders DESC,
    total_sales DESC;
    SELECT
    e.role,
    COUNT(DISTINCT e.employee_id) AS employee_count,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_sales,
    AVG(o.total_amount) AS average_order_value
FROM Employee e
JOIN orders o
    ON e.employee_id = o.employee_id
GROUP BY
    e.role
ORDER BY
    total_sales DESC;
    SELECT
    e.role,
    COUNT(DISTINCT e.employee_id) AS employee_count,
    SUM(o.total_amount) AS total_sales,
    ROUND(
        SUM(o.total_amount) / COUNT(DISTINCT e.employee_id),
        2
    ) AS sales_per_employee,
    ROUND(
        COUNT(o.order_id) * 1.0 / COUNT(DISTINCT e.employee_id),
        2
    ) AS orders_per_employee
FROM Employee e
JOIN orders o
    ON e.employee_id = o.employee_id
GROUP BY
    e.role
ORDER BY
    sales_per_employee DESC;

    SELECT
    COUNT(*) AS total_returns
FROM order_returns;
SELECT
    COUNT(*) AS total_returns,
    (SELECT COUNT(*) FROM orders) AS total_orders,
    ROUND(
        COUNT(*) * 100.0 /
        NULLIF((SELECT COUNT(*) FROM orders), 0),
        2
    ) AS return_rate_percent
FROM order_returns;
SELECT
    return_reason,
    COUNT(*) AS total_returns
FROM order_returns
GROUP BY
    return_reason
ORDER BY
    total_returns DESC;

  SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'order_returns'
ORDER BY ORDINAL_POSITION;

SELECT TOP 10
    p.product_id,
    p.name AS product_name,
    p.category,
    COUNT(*) AS total_returns
FROM order_returns r
JOIN order_items oi
    ON r.order_items_id = oi.order_items_id
JOIN product p
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.name,
    p.category
ORDER BY
    total_returns DESC;
SELECT TOP 10
    p.name AS product_name,
    p.category,
    SUM(oi.quantity) AS units_sold,
    COUNT(r.return_id) AS total_returns,
    ROUND(
        COUNT(r.return_id) * 100.0 /
        NULLIF(SUM(oi.quantity), 0),
        2
    ) AS return_rate_percent
FROM product p
JOIN order_items oi
    ON p.product_id = oi.product_id
LEFT JOIN order_returns r
    ON oi.order_items_id = r.order_items_id
GROUP BY
    p.name,
    p.category
ORDER BY
    return_rate_percent DESC;

    SELECT
    p.name AS product_name,
    p.category,
    r.return_reason,
    COUNT(*) AS total_returns
FROM order_returns r
JOIN order_items oi
    ON r.order_items_id = oi.order_items_id
JOIN product p
    ON oi.product_id = p.product_id
GROUP BY
    p.name,
    p.category,
    r.return_reason
ORDER BY
    p.name,
    total_returns DESC;

    SELECT
    COUNT(*) AS total_returns,
    SUM(refund_amount) AS total_refund_amount,
    AVG(refund_amount) AS average_refund_amount
FROM order_returns;

SELECT
    return_reason,
    COUNT(*) AS total_returns,
    SUM(refund_amount) AS total_refunds,
    AVG(refund_amount) AS average_refund
FROM order_returns
GROUP BY
    return_reason
ORDER BY
    total_refunds DESC;

    SELECT
    return_status,
    COUNT(*) AS total_returns,
    SUM(refund_amount) AS total_refunds,
    AVG(refund_amount) AS average_refund
FROM order_returns
GROUP BY
    return_status
ORDER BY
    total_returns DESC;

    SELECT
    payment_method,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_sales,
    AVG(total_amount) AS average_order_value,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS order_share_percent
FROM orders
GROUP BY
    payment_method
ORDER BY
    total_sales DESC;

    SELECT
    (SELECT SUM(total_amount) FROM orders) AS orders_total_sales,
    (SELECT SUM(quantity * unit_price) FROM order_items) AS order_items_total_sales;

    SELECT TOP 20
    o.order_id,
    o.total_amount AS order_total,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS item_total,
    o.total_amount - COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS difference
FROM orders o
LEFT JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    o.order_id,
    o.total_amount
ORDER BY
    ABS(
        o.total_amount -
        COALESCE(SUM(oi.quantity * oi.unit_price), 0)
    ) DESC;

    SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN oi.order_id IS NULL THEN 1
            ELSE 0
        END
    ) AS orders_without_items,

    SUM(
        CASE
            WHEN oi.order_id IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS orders_with_items

FROM orders o
LEFT JOIN (
    SELECT DISTINCT order_id
    FROM order_items
) oi
    ON o.order_id = oi.order_id;

    WITH order_totals AS (
    SELECT
        o.order_id,
        o.total_amount AS order_total,
        COALESCE(
            SUM(oi.quantity * oi.unit_price),
            0
        ) AS item_total
    FROM orders o
    LEFT JOIN order_items oi
        ON o.order_id = oi.order_id
    GROUP BY
        o.order_id,
        o.total_amount
)
SELECT
    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN item_total = 0 THEN 1
            ELSE 0
        END
    ) AS orders_with_no_items,

    SUM(
        CASE
            WHEN item_total > 0
             AND ABS(order_total - item_total) > 0.01
            THEN 1
            ELSE 0
        END
    ) AS orders_with_value_mismatch,

    SUM(
        CASE
            WHEN item_total > 0
             AND ABS(order_total - item_total) <= 0.01
            THEN 1
            ELSE 0
        END
    ) AS orders_that_reconcile

FROM order_totals;

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'promotion'
ORDER BY ORDINAL_POSITION;

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'orders'
ORDER BY ORDINAL_POSITION;

SELECT
    p.promotion_id,
    p.promotion_name,
    p.promotion_type,
    p.discount_percent,
    p.minimum_order,
    p.start_date,
    p.end_date,
    p.status,
    COUNT(o.order_id) AS orders_using_promotion,
    SUM(o.total_amount) AS recorded_order_sales
FROM promotion p
LEFT JOIN orders o
    ON p.promotion_id = o.promotion_id
GROUP BY
    p.promotion_id,
    p.promotion_name,
    p.promotion_type,
    p.discount_percent,
    p.minimum_order,
    p.start_date,
    p.end_date,
    p.status
ORDER BY
    orders_using_promotion DESC;

    SELECT
    p.category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT CASE
        WHEN o.promotion_id IS NOT NULL THEN o.order_id
    END) AS promoted_orders,
    ROUND(
        COUNT(DISTINCT CASE
            WHEN o.promotion_id IS NOT NULL THEN o.order_id
        END) * 100.0
        / NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS promotion_usage_percent,
    ROUND(
        AVG(CASE
            WHEN o.promotion_id IS NOT NULL
            THEN pr.discount_percent
        END),
        2
    ) AS average_discount_percent
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
JOIN product p
    ON oi.product_id = p.product_id
LEFT JOIN promotion pr
    ON o.promotion_id = pr.promotion_id
GROUP BY
    p.category
ORDER BY
    average_discount_percent DESC;

    SELECT
    p.category,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.quantity * p.cost_price) AS total_cost,
    SUM(oi.quantity * oi.unit_price) AS total_sales,
    SUM((oi.unit_price - p.cost_price) * oi.quantity) AS total_profit,
    ROUND(
        SUM((oi.unit_price - p.cost_price) * oi.quantity) * 100.0
        / NULLIF(SUM(oi.quantity * oi.unit_price), 0),
        2
    ) AS profit_margin_percent
FROM product p
JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY profit_margin_percent ASC;
