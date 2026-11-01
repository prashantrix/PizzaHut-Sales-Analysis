# Pizza Hut Sales Analysis

SQL Server KPI analysis and a two-page Power BI dashboard on one year of pizza sales (1 Jan - 31 Dec 2015, 358 trading days).

## Data

Four tables, included as CSVs in [`pizza_sales/`](pizza_sales):

| Table | Rows | Contents |
|---|---|---|
| `orders` | 21,350 | one row per order (`order_id`, `date`, `time`) |
| `order_details` | 48,620 | one row per order line (`order_id`, `pizza_id`, `quantity`) |
| `pizzas` | 96 | one row per pizza and size (`pizza_id`, `size`, `price`) |
| `pizza_types` | 32 | pizza name, category, ingredients |

The data has no currency field, so revenue is shown without a currency symbol.

Counts are easy to mix up, so this project uses three separate terms:

| Term | Definition | Value |
|---|---|---|
| Orders | rows in `orders` | 21,350 |
| Order lines | rows in `order_details` | 48,620 |
| Pizzas sold | `SUM(quantity)` | 49,574 |

## Key findings

Every figure below is produced by a query in [`pizza.sql`](pizza.sql).

| Finding | Result | Query |
|---|---|---|
| Total revenue | 817,860.05 | KPI 2 |
| Average pizzas sold per day | 138.47 | KPI 11 |
| Top 3 pizzas by revenue | Thai Chicken 43,434.25, Barbecue Chicken 42,768.00, California Chicken 41,409.50 | KPI 12 |
| Top 3 pizzas by units sold | Classic Deluxe 2,453, Barbecue Chicken 2,432, Hawaiian 2,422 | KPI 6 |
| Revenue share by category | Classic 26.91%, Supreme 25.46%, Chicken 23.96%, Veggie 23.68% | KPI 13 |
| Most-ordered size | Large, 18,956 pizzas (38.2% of pizzas sold) | KPI 5 |
| Busiest hours | 12:00-13:59 and 17:00-18:59 hold 9,710 of 21,350 orders (45.5%) | KPI 8 |
| Busiest weekday | Friday, 3,538 orders (Sunday is lowest at 2,624) | Support A |
| Highest revenue month | July, 72,557.90 (October is lowest at 64,027.60) | Support B |

Observations:

- Classic leads on both units (14,888) and revenue share. Chicken sells the fewest pizzas (11,050, 22.3% of units) but earns 23.96% of revenue, because it has the highest revenue per pizza sold (about 17.73, against 14.78 for Classic).
- Monthly revenue stays between 64.0K and 72.6K, so seasonality in this data is mild.
- Brie Carre is the lowest-revenue pizza at 11,588.50.

## SQL

[`pizza.sql`](pizza.sql) holds, in order:

1. **Data validation:** row counts, duplicate order IDs, orphan keys between tables, NULL checks. All pass on this data.
2. **15 KPI queries** using joins, subqueries, `RANK()`, `SUM() OVER`, and percentage-of-total windows.
3. **Two supporting queries** (orders by weekday, revenue by month) behind the weekday and month findings.

[`Pizza_Analysis.pdf`](Pizza_Analysis.pdf) shows the original queries with their result screenshots.

## Dashboard

[`pizza_hut.pbix`](pizza_hut.pbix) (Power BI, DAX and Power Query) has two pages:

- **Overview:** quantity, revenue and order KPIs, sales by pizza, sales by month, current vs last month, sales by category.
- **Performance:** top and bottom 5 pizzas by revenue, pizzas ordered by name, orders by weekday, with category and size filters.

## Tools

SQL Server (T-SQL), Power BI (DAX, Power Query).

## Author

Prashant Kashyap | [LinkedIn](https://linkedin.com/in/prashantrix) | [GitHub](https://github.com/prashantrix)
