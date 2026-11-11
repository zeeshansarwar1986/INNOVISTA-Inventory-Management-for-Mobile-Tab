# INNOVISTA database design (SQLite)

## 1. Where data lives

| Run mode | Storage | Notes |
|---|---|---|
| Android APK (Capacitor) | **SQLite** via `@capacitor-community/sqlite` + a localStorage copy | `www/db.js` defines `window.DBX` |
| Browser / PWA | localStorage (+ `_bak` copy) | `window.DBX` is `null`; same app code |
| Hosted preview | localStorage | cannot use native SQLite |

The app keeps the whole state in one in-memory object `S` and calls `save()` after every change. In the APK, `save()` also calls `DBX.queue(S)`.

## 2. How the sync works (version 1: snapshot)

1. `DBX.boot()` opens the database, creates missing tables (`schema.sql`), and loads `S` from the tables.
2. If the database is empty (first run after an update), the current localStorage data is written into SQLite (automatic migration).
3. If both exist, the newer one wins (`meta.saved_at` against `S.savedAt`).
4. Every change: `DBX.queue(S)` waits 400 ms, then writes **one transaction** that replaces all rows from the snapshot. It also flushes when the app goes to the background. A transaction is all-or-nothing, so a crash cannot leave half-written data.

Honest limits of version 1: it rewrites every table on each save (fine for thousands of rows, slow for hundreds of thousands), it does not fill `stock_movements` or `audit_log`, and foreign keys are declared but `PRAGMA foreign_keys` is not switched on (the app logic keeps integrity; the demo database passes `PRAGMA foreign_key_check`). The adapter was tested here with a real SQLite engine for the SQL and with a mocked plugin for the flow, but **not on a real Android device**.

## 3. Tables

| Table | Purpose |
|---|---|
| `meta` | schema_version, cur (open business day), saved_at |
| `settings` | `cfg` JSON: shop name, password, card titles, thresholds |
| `products` | name, price, stock (+ cost_price, barcode, unit, active for later) |
| `customers` | shopkeepers: name, phone (+ address, active) |
| `sales` | one bill: date, customer, total, paid (+ discount, note) |
| `sale_items` | bill lines: product, qty, price (price frozen at sale time) |
| `payments` | payments received later: date, customer, amount (+ method, note) |
| `day_closings` | one row per closed day |
| `closing_stock` | stock of every product at the end of a closed day |
| `suppliers`, `purchases`, `purchase_items`, `expenses` | reserved: purchases, supplier ledger, expenses |
| `stock_movements` | reserved: audit trail of every stock change |
| `users`, `audit_log` | reserved: roles and who-changed-what |

Views for reports: `v_customer_balance`, `v_daily_summary`, `v_daily_product_sales`, `v_stock_value`. Example:

```sql
SELECT * FROM v_customer_balance WHERE balance > 0 ORDER BY balance DESC;
SELECT * FROM v_daily_summary WHERE day BETWEEN '2026-11-01' AND '2026-11-30';
```

Relations: customers 1-N sales 1-N sale_items N-1 products; customers 1-N payments; day_closings 1-N closing_stock.

## 4. Setup in the APK project

```
npm install            # installs @capacitor-community/sqlite
npx cap add android
npm run android:sync   # copies www and registers the plugin
```
Then build the APK as in README section 4. Open `data/innovista-demo.db` with "DB Browser for SQLite" to look at the tables.

## 5. Recommended next steps (in order)

1. **Test on a real phone** (a cheap Android and a tablet): add bills, force-close the app mid-entry, reboot, compare numbers. Add automatic daily backup before anything else.
2. **Per-operation writes**: replace the snapshot by small transactions (`saveBill`, `editBill`, `receivePayment`, `closeDay`). Each one inserts the bill, its items, the stock change and a `stock_movements` row together. This is the real fix for speed and for the audit trail.
3. **Cost price and purchases**: use `cost_price`, `suppliers`, `purchases`; then profit report (sale price minus cost) and the stock value at cost.
4. **Backend**: FastAPI + PostgreSQL with the same table names; the phone sends changes (with `updated_at` and a device id) when online. Google Sheets sync is then done by the server (service account), not by the phone.
5. **Users and roles**: owner, manager, salesman; log edits and deletes in `audit_log`.
6. **Safety**: encrypt the database (SQLCipher mode of the plugin), hash the app password (not plain text), export a backup file to Google Drive or WhatsApp every day.
7. **Quality**: unit tests for balance and stock rules, a migration test from every old schema version (`meta.schema_version`), and a "restore from backup" test.
8. **Business features** after that: discount and tax, returns, bill numbers, thermal printing, barcode, Urdu interface, low-stock alerts.

## 6. Changing the schema later
Never edit old tables by hand. Add `ALTER TABLE` steps keyed by `meta.schema_version` (v1 to v2 to v3) in `db.js`, run them inside one transaction at boot, and keep `db/schema.sql` as the latest full schema.
