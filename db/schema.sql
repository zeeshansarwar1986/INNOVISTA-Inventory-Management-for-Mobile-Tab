-- INNOVISTA Inventory Management: SQLite schema v1
-- Created by Zeeshan Sarwar. Dates are TEXT 'YYYY-MM-DD'. Money and quantities are REAL.
-- Ids are TEXT (generated in the app). Statements are separated by ";" at end of line.
CREATE TABLE IF NOT EXISTS meta(key TEXT PRIMARY KEY, value TEXT);
CREATE TABLE IF NOT EXISTS settings(key TEXT PRIMARY KEY, value TEXT);
CREATE TABLE IF NOT EXISTS products(
 id TEXT PRIMARY KEY, name TEXT NOT NULL, price REAL NOT NULL DEFAULT 0, stock REAL NOT NULL DEFAULT 0,
 cost_price REAL NOT NULL DEFAULT 0, barcode TEXT, unit TEXT, active INTEGER NOT NULL DEFAULT 1,
 created_at TEXT DEFAULT CURRENT_TIMESTAMP, updated_at TEXT DEFAULT CURRENT_TIMESTAMP);
CREATE INDEX IF NOT EXISTS ix_products_name ON products(name);
CREATE TABLE IF NOT EXISTS customers(
 id TEXT PRIMARY KEY, name TEXT NOT NULL, phone TEXT, address TEXT, active INTEGER NOT NULL DEFAULT 1,
 created_at TEXT DEFAULT CURRENT_TIMESTAMP);
CREATE TABLE IF NOT EXISTS sales(
 id TEXT PRIMARY KEY, sale_date TEXT NOT NULL, customer_id TEXT NOT NULL REFERENCES customers(id),
 total REAL NOT NULL DEFAULT 0, paid REAL NOT NULL DEFAULT 0, discount REAL NOT NULL DEFAULT 0, note TEXT,
 created_at TEXT DEFAULT CURRENT_TIMESTAMP);
CREATE INDEX IF NOT EXISTS ix_sales_date ON sales(sale_date);
CREATE INDEX IF NOT EXISTS ix_sales_customer ON sales(customer_id);
CREATE TABLE IF NOT EXISTS sale_items(
 id INTEGER PRIMARY KEY AUTOINCREMENT, sale_id TEXT NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
 line_no INTEGER NOT NULL DEFAULT 0, product_id TEXT NOT NULL REFERENCES products(id),
 qty REAL NOT NULL, price REAL NOT NULL);
CREATE INDEX IF NOT EXISTS ix_items_sale ON sale_items(sale_id);
CREATE INDEX IF NOT EXISTS ix_items_product ON sale_items(product_id);
CREATE TABLE IF NOT EXISTS payments(
 id TEXT PRIMARY KEY, pay_date TEXT NOT NULL, customer_id TEXT NOT NULL REFERENCES customers(id),
 amount REAL NOT NULL, method TEXT, note TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP);
CREATE INDEX IF NOT EXISTS ix_pay_date ON payments(pay_date);
CREATE INDEX IF NOT EXISTS ix_pay_customer ON payments(customer_id);
CREATE TABLE IF NOT EXISTS day_closings(day TEXT PRIMARY KEY, closed INTEGER NOT NULL DEFAULT 1, closed_at TEXT);
CREATE TABLE IF NOT EXISTS closing_stock(
 day TEXT NOT NULL REFERENCES day_closings(day) ON DELETE CASCADE, product_id TEXT NOT NULL, qty REAL NOT NULL,
 PRIMARY KEY(day, product_id));
-- Reserved for the next phases (the app does not write to these yet)
CREATE TABLE IF NOT EXISTS suppliers(id TEXT PRIMARY KEY, name TEXT NOT NULL, phone TEXT, address TEXT, active INTEGER NOT NULL DEFAULT 1);
CREATE TABLE IF NOT EXISTS purchases(
 id TEXT PRIMARY KEY, purchase_date TEXT NOT NULL, supplier_id TEXT REFERENCES suppliers(id),
 total REAL NOT NULL DEFAULT 0, paid REAL NOT NULL DEFAULT 0, note TEXT);
CREATE TABLE IF NOT EXISTS purchase_items(
 id INTEGER PRIMARY KEY AUTOINCREMENT, purchase_id TEXT NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
 product_id TEXT NOT NULL REFERENCES products(id), qty REAL NOT NULL, cost REAL NOT NULL);
CREATE TABLE IF NOT EXISTS expenses(id TEXT PRIMARY KEY, exp_date TEXT NOT NULL, category TEXT, amount REAL NOT NULL, note TEXT);
CREATE TABLE IF NOT EXISTS stock_movements(
 id INTEGER PRIMARY KEY AUTOINCREMENT, moved_at TEXT DEFAULT CURRENT_TIMESTAMP, product_id TEXT NOT NULL,
 qty_change REAL NOT NULL, reason TEXT, ref_table TEXT, ref_id TEXT);
CREATE TABLE IF NOT EXISTS users(
 id TEXT PRIMARY KEY, username TEXT NOT NULL UNIQUE, pass_hash TEXT NOT NULL, role TEXT NOT NULL DEFAULT 'salesman',
 active INTEGER NOT NULL DEFAULT 1);
CREATE TABLE IF NOT EXISTS audit_log(
 id INTEGER PRIMARY KEY AUTOINCREMENT, at TEXT DEFAULT CURRENT_TIMESTAMP, user_id TEXT, action TEXT NOT NULL,
 table_name TEXT, record_id TEXT, detail TEXT);
-- Reporting views
CREATE VIEW IF NOT EXISTS v_customer_balance AS
 SELECT id, name, phone, billed, paid, billed - paid AS balance FROM (
  SELECT c.id, c.name, c.phone,
   COALESCE((SELECT SUM(total) FROM sales s WHERE s.customer_id = c.id), 0) AS billed,
   COALESCE((SELECT SUM(paid) FROM sales s WHERE s.customer_id = c.id), 0)
   + COALESCE((SELECT SUM(amount) FROM payments p WHERE p.customer_id = c.id), 0) AS paid
  FROM customers c);
CREATE VIEW IF NOT EXISTS v_daily_summary AS
 WITH d AS (SELECT sale_date AS day FROM sales UNION SELECT pay_date FROM payments)
 SELECT d.day AS day,
  (SELECT COUNT(*) FROM sales s WHERE s.sale_date = d.day) AS bills,
  (SELECT COALESCE(SUM(si.qty), 0) FROM sale_items si JOIN sales s ON s.id = si.sale_id WHERE s.sale_date = d.day) AS units_sold,
  (SELECT COALESCE(SUM(total), 0) FROM sales WHERE sale_date = d.day) AS sales_amount,
  (SELECT COALESCE(SUM(paid), 0) FROM sales WHERE sale_date = d.day)
  + (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE pay_date = d.day) AS received
 FROM d ORDER BY d.day;
CREATE VIEW IF NOT EXISTS v_daily_product_sales AS
 SELECT s.sale_date AS day, p.name AS product, SUM(si.qty) AS qty, SUM(si.qty * si.price) AS amount
 FROM sale_items si JOIN sales s ON s.id = si.sale_id JOIN products p ON p.id = si.product_id
 GROUP BY s.sale_date, si.product_id;
CREATE VIEW IF NOT EXISTS v_stock_value AS
 SELECT COUNT(*) AS products, COALESCE(SUM(stock), 0) AS units, COALESCE(SUM(stock * price), 0) AS value
 FROM products WHERE active = 1;
