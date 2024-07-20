-- Objective 1--
SELECT   c.country, SUM(o.quantity * i.price_in_GBP) AS total_revenue
FROM retail_online.customers AS c
LEFT JOIN retail_online.orders AS o
ON c.customer_id = o.customer_id
LEFT JOIN retail_online.items AS i ON o.item_id = i.item_id
WHERE c.country != 'United Kingdom'
GROUP BY
c.country
ORDER BY
total_revenue DESC
LIMIT 10;

-- Objective 2--
USE retail_online;
WITH TopCountries AS (
    SELECT
        c.country,
        SUM(o.quantity * i.price_in_GBP) AS total_revenue
    FROM
        customers AS c
    INNER JOIN
        orders AS o ON c.customer_id = o.customer_id
    INNER JOIN
        items AS i ON o.item_id = i.item_id
    WHERE
        c.country != 'United Kingdom'
    GROUP BY
        c.country
    ORDER BY
        total_revenue DESC
    LIMIT 10
),
-- Step 2: Find the Highest-Selling Item in Each of the Top 10 Countries
CountryTopItems AS (
    SELECT
        c.country,
        i.item_id,
        i.description,
        SUM(o.quantity) AS item_quantity_sold
    FROM
        customers AS c
    INNER JOIN
        orders AS o ON c.customer_id = o.customer_id
    INNER JOIN
        items AS i ON o.item_id = i.item_id
    WHERE
        c.country IN (SELECT country FROM TopCountries)
    GROUP BY
        c.country, i.item_id
),
-- Step 3: Select the Top Selling Item for Each Country
TopSellingItems AS (
    SELECT
        cti.country,
        cti.item_id AS highest_selling_item,
	cti.description,
        cti.item_quantity_sold,
        ROW_NUMBER() OVER (PARTITION BY cti.country ORDER BY cti.item_quantity_sold DESC) AS row_num
    FROM
        CountryTopItems AS cti
)
SELECT
    tsi.country,
    tsi.highest_selling_item,
    tsi.description,
    tsi.item_quantity_sold,
    tc.total_revenue
FROM
    TopSellingItems AS tsi
INNER JOIN
    TopCountries AS tc ON tsi.country = tc.country
WHERE
    tsi.row_num = 1
ORDER BY
    tc.total_revenue DESC;
    
    -- Objective 3 --
    
    WITH TopCountries AS (
    SELECT
        c.country,
        SUM(o.quantity * i.price_in_GBP) AS total_revenue
    FROM
        customers AS c
    INNER JOIN
        orders AS o ON c.customer_id = o.customer_id
    INNER JOIN
        items AS i ON o.item_id = i.item_id
    WHERE
        c.country != 'United Kingdom'
    GROUP BY
        c.country
    ORDER BY
        total_revenue DESC
    LIMIT 10
),
CountryTopItems AS (
    SELECT
        c.country,
        i.item_id,
        i.description,
        i.price_in_GBP AS unit_price,
        SUM(o.quantity) AS item_quantity_sold,
        SUM(o.quantity * i.price_in_GBP) AS item_total_revenue
    FROM
        customers AS c
    INNER JOIN
        orders AS o ON c.customer_id = o.customer_id
    INNER JOIN
        items AS i ON o.item_id = i.item_id
    WHERE
        c.country IN (SELECT country FROM TopCountries)
    GROUP BY
        c.country, i.item_id, i.description, i.price_in_GBP
),
TopSellingItems AS (
    SELECT
        cti.country,
        cti.item_id AS highest_selling_item,
        cti.description,
        cti.unit_price,
        cti.item_quantity_sold,
        cti.item_total_revenue,
        ROW_NUMBER() OVER (PARTITION BY cti.country ORDER BY cti.item_quantity_sold DESC) AS row_num
    FROM
        CountryTopItems AS cti
),
FinalResults AS (
    SELECT
        tsi.country,
        tsi.highest_selling_item,
        tsi.description,
        tsi.unit_price,
        tsi.item_quantity_sold,
        tsi.item_total_revenue,
        cur.currency_name,
        tsi.unit_price * cur.exchange_rate AS unit_price_local_currency,
        tsi.item_total_revenue * cur.exchange_rate AS total_revenue_local_currency,
        tc.total_revenue
    FROM
        TopSellingItems AS tsi
    INNER JOIN
        TopCountries AS tc ON tsi.country = tc.country
    INNER JOIN
        countries AS co ON tsi.country = co.country
    INNER JOIN
        currencies AS cur ON co.currency_code = cur.currency_code
    WHERE
        tsi.row_num = 1
)
SELECT
    country,
    highest_selling_item,
    description,
    unit_price AS price_per_unit,
    unit_price_local_currency,
	currency_name,
	item_quantity_sold,
    total_revenue_local_currency
FROM
    FinalResults
ORDER BY
    total_revenue DESC;