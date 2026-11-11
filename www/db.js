// INNOVISTA SQLite adapter. Created by Zeeshan Sarwar.
// Native (Capacitor + @capacitor-community/sqlite): window.DBX is defined and the app persists to SQLite.
// Browser / PWA: window.DBX is null and the app keeps using localStorage.
(function(){
var SCHEMA=[
"CREATE TABLE IF NOT EXISTS meta(key TEXT PRIMARY KEY, value TEXT)",
"CREATE TABLE IF NOT EXISTS settings(key TEXT PRIMARY KEY, value TEXT)",
"CREATE TABLE IF NOT EXISTS products(\n id TEXT PRIMARY KEY, name TEXT NOT NULL, price REAL NOT NULL DEFAULT 0, stock REAL NOT NULL DEFAULT 0,\n cost_price REAL NOT NULL DEFAULT 0, barcode TEXT, unit TEXT, active INTEGER NOT NULL DEFAULT 1,\n created_at TEXT DEFAULT CURRENT_TIMESTAMP, updated_at TEXT DEFAULT CURRENT_TIMESTAMP)",
"CREATE INDEX IF NOT EXISTS ix_products_name ON products(name)",
"CREATE TABLE IF NOT EXISTS customers(\n id TEXT PRIMARY KEY, name TEXT NOT NULL, phone TEXT, address TEXT, active INTEGER NOT NULL DEFAULT 1,\n created_at TEXT DEFAULT CURRENT_TIMESTAMP)",
"CREATE TABLE IF NOT EXISTS sales(\n id TEXT PRIMARY KEY, sale_date TEXT NOT NULL, customer_id TEXT NOT NULL REFERENCES customers(id),\n total REAL NOT NULL DEFAULT 0, paid REAL NOT NULL DEFAULT 0, discount REAL NOT NULL DEFAULT 0, note TEXT,\n created_at TEXT DEFAULT CURRENT_TIMESTAMP)",
"CREATE INDEX IF NOT EXISTS ix_sales_date ON sales(sale_date)",
"CREATE INDEX IF NOT EXISTS ix_sales_customer ON sales(customer_id)",
"CREATE TABLE IF NOT EXISTS sale_items(\n id INTEGER PRIMARY KEY AUTOINCREMENT, sale_id TEXT NOT NULL REFERENCES sales(id) ON DELETE CASCADE,\n line_no INTEGER NOT NULL DEFAULT 0, product_id TEXT NOT NULL REFERENCES products(id),\n qty REAL NOT NULL, price REAL NOT NULL)",
"CREATE INDEX IF NOT EXISTS ix_items_sale ON sale_items(sale_id)",
"CREATE INDEX IF NOT EXISTS ix_items_product ON sale_items(product_id)",
"CREATE TABLE IF NOT EXISTS payments(\n id TEXT PRIMARY KEY, pay_date TEXT NOT NULL, customer_id TEXT NOT NULL REFERENCES customers(id),\n amount REAL NOT NULL, method TEXT, note TEXT, created_at TEXT DEFAULT CURRENT_TIMESTAMP)",
"CREATE INDEX IF NOT EXISTS ix_pay_date ON payments(pay_date)",
"CREATE INDEX IF NOT EXISTS ix_pay_customer ON payments(customer_id)",
"CREATE TABLE IF NOT EXISTS day_closings(day TEXT PRIMARY KEY, closed INTEGER NOT NULL DEFAULT 1, closed_at TEXT)",
"CREATE TABLE IF NOT EXISTS closing_stock(\n day TEXT NOT NULL REFERENCES day_closings(day) ON DELETE CASCADE, product_id TEXT NOT NULL, qty REAL NOT NULL,\n PRIMARY KEY(day, product_id))",
"CREATE TABLE IF NOT EXISTS suppliers(id TEXT PRIMARY KEY, name TEXT NOT NULL, phone TEXT, address TEXT, active INTEGER NOT NULL DEFAULT 1)",
"CREATE TABLE IF NOT EXISTS purchases(\n id TEXT PRIMARY KEY, purchase_date TEXT NOT NULL, supplier_id TEXT REFERENCES suppliers(id),\n total REAL NOT NULL DEFAULT 0, paid REAL NOT NULL DEFAULT 0, note TEXT)",
"CREATE TABLE IF NOT EXISTS purchase_items(\n id INTEGER PRIMARY KEY AUTOINCREMENT, purchase_id TEXT NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,\n product_id TEXT NOT NULL REFERENCES products(id), qty REAL NOT NULL, cost REAL NOT NULL)",
"CREATE TABLE IF NOT EXISTS expenses(id TEXT PRIMARY KEY, exp_date TEXT NOT NULL, category TEXT, amount REAL NOT NULL, note TEXT)",
"CREATE TABLE IF NOT EXISTS stock_movements(\n id INTEGER PRIMARY KEY AUTOINCREMENT, moved_at TEXT DEFAULT CURRENT_TIMESTAMP, product_id TEXT NOT NULL,\n qty_change REAL NOT NULL, reason TEXT, ref_table TEXT, ref_id TEXT)",
"CREATE TABLE IF NOT EXISTS users(\n id TEXT PRIMARY KEY, username TEXT NOT NULL UNIQUE, pass_hash TEXT NOT NULL, role TEXT NOT NULL DEFAULT 'salesman',\n active INTEGER NOT NULL DEFAULT 1)",
"CREATE TABLE IF NOT EXISTS audit_log(\n id INTEGER PRIMARY KEY AUTOINCREMENT, at TEXT DEFAULT CURRENT_TIMESTAMP, user_id TEXT, action TEXT NOT NULL,\n table_name TEXT, record_id TEXT, detail TEXT)",
"CREATE VIEW IF NOT EXISTS v_customer_balance AS\n SELECT id, name, phone, billed, paid, billed - paid AS balance FROM (\n  SELECT c.id, c.name, c.phone,\n   COALESCE((SELECT SUM(total) FROM sales s WHERE s.customer_id = c.id), 0) AS billed,\n   COALESCE((SELECT SUM(paid) FROM sales s WHERE s.customer_id = c.id), 0)\n   + COALESCE((SELECT SUM(amount) FROM payments p WHERE p.customer_id = c.id), 0) AS paid\n  FROM customers c)",
"CREATE VIEW IF NOT EXISTS v_daily_summary AS\n WITH d AS (SELECT sale_date AS day FROM sales UNION SELECT pay_date FROM payments)\n SELECT d.day AS day,\n  (SELECT COUNT(*) FROM sales s WHERE s.sale_date = d.day) AS bills,\n  (SELECT COALESCE(SUM(si.qty), 0) FROM sale_items si JOIN sales s ON s.id = si.sale_id WHERE s.sale_date = d.day) AS units_sold,\n  (SELECT COALESCE(SUM(total), 0) FROM sales WHERE sale_date = d.day) AS sales_amount,\n  (SELECT COALESCE(SUM(paid), 0) FROM sales WHERE sale_date = d.day)\n  + (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE pay_date = d.day) AS received\n FROM d ORDER BY d.day",
"CREATE VIEW IF NOT EXISTS v_daily_product_sales AS\n SELECT s.sale_date AS day, p.name AS product, SUM(si.qty) AS qty, SUM(si.qty * si.price) AS amount\n FROM sale_items si JOIN sales s ON s.id = si.sale_id JOIN products p ON p.id = si.product_id\n GROUP BY s.sale_date, si.product_id",
"CREATE VIEW IF NOT EXISTS v_stock_value AS\n SELECT COUNT(*) AS products, COALESCE(SUM(stock), 0) AS units, COALESCE(SUM(stock * price), 0) AS value\n FROM products WHERE active = 1"
];
var DB='innovista';
function toSQL(S){
 var q=[],now=new Date().toISOString(),i,j,t;
 ['sale_items','sales','payments','closing_stock','day_closings','customers','products'].forEach(function(t){q.push(['DELETE FROM '+t,[]])});
 S.products.forEach(function(p){q.push(['INSERT INTO products(id,name,price,stock,updated_at) VALUES(?,?,?,?,?)',[p.id,p.name,+p.price||0,+p.stock||0,now]])});
 S.customers.forEach(function(c){q.push(['INSERT INTO customers(id,name,phone) VALUES(?,?,?)',[c.id,c.name,c.phone||'']])});
 S.sales.forEach(function(s){q.push(['INSERT INTO sales(id,sale_date,customer_id,total,paid) VALUES(?,?,?,?,?)',[s.id,s.date,s.cust,+s.total||0,+s.paid||0]]);
  s.items.forEach(function(it,n){q.push(['INSERT INTO sale_items(sale_id,line_no,product_id,qty,price) VALUES(?,?,?,?,?)',[s.id,n,it.pid,+it.qty||0,+it.price||0]])})});
 S.pays.forEach(function(p){q.push(['INSERT INTO payments(id,pay_date,customer_id,amount) VALUES(?,?,?,?)',[p.id,p.date,p.cust,+p.amt||0]])});
 Object.keys(S.days||{}).forEach(function(d){var D=S.days[d];q.push(['INSERT INTO day_closings(day,closed,closed_at) VALUES(?,?,?)',[d,D.closed?1:0,now]]);
  Object.keys(D.closing||{}).forEach(function(pid){q.push(['INSERT INTO closing_stock(day,product_id,qty) VALUES(?,?,?)',[d,pid,+D.closing[pid]||0]])})});
 q.push(['INSERT OR REPLACE INTO meta(key,value) VALUES(?,?)',['schema_version','1']]);
 q.push(['INSERT OR REPLACE INTO meta(key,value) VALUES(?,?)',['cur',S.cur]]);
 q.push(['INSERT OR REPLACE INTO meta(key,value) VALUES(?,?)',['saved_at',S.savedAt||now]]);
 q.push(['INSERT OR REPLACE INTO settings(key,value) VALUES(?,?)',['cfg',JSON.stringify(S.cfg)]]);
 return q}
function fromRows(r){
 var m={};r.meta.forEach(function(x){m[x.key]=x.value});
 var cfg={};r.settings.forEach(function(x){if(x.key=='cfg')cfg=JSON.parse(x.value)});
 var items={};r.sale_items.slice().sort(function(a,b){return a.line_no-b.line_no}).forEach(function(x){(items[x.sale_id]=items[x.sale_id]||[]).push({pid:x.product_id,qty:x.qty,price:x.price})});
 var days={};r.day_closings.forEach(function(d){days[d.day]={closing:{},closed:!!d.closed}});
 r.closing_stock.forEach(function(c){if(!days[c.day])days[c.day]={closing:{},closed:true};days[c.day].closing[c.product_id]=c.qty});
 return {cur:m.cur,savedAt:m.saved_at,cfg:cfg,
  products:r.products.map(function(p){return{id:p.id,name:p.name,price:p.price,stock:p.stock}}),
  customers:r.customers.map(function(c){return{id:c.id,name:c.name,phone:c.phone||''}}),
  sales:r.sales.map(function(s){return{id:s.id,date:s.sale_date,cust:s.customer_id,items:items[s.id]||[],total:s.total,paid:s.paid}}),
  pays:r.payments.map(function(p){return{id:p.id,date:p.pay_date,cust:p.customer_id,amt:p.amount}}),
  days:days}}
if(typeof module!=='undefined')module.exports={SCHEMA:SCHEMA,toSQL:toSQL,fromRows:fromRows};
if(typeof window==='undefined')return;
var P=window.Capacitor&&Capacitor.isNativePlatform&&Capacitor.isNativePlatform()&&Capacitor.Plugins&&Capacitor.Plugins.CapacitorSQLite;
if(!P){window.DBX=null;return}
var timer=null,running=false,pending=null;
var X=window.DBX={mode:'sqlite',ok:null,err:'',
 boot:async function(){
  try{await P.createConnection({database:DB,version:1,encrypted:false,mode:'no-encryption',readonly:false})}catch(e){}
  await P.open({database:DB,readonly:false});
  await P.executeSet({database:DB,transaction:true,set:SCHEMA.map(function(s){return{statement:s,values:[]}})});
  var g=async function(sql){var r=await P.query({database:DB,statement:sql,values:[]});return r.values||[]};
  var meta=await g('SELECT key,value FROM meta');
  if(!meta.some(function(x){return x.key=='cur'}))return null;
  var r={meta:meta};
  for(var t of ['settings','products','customers','sales','sale_items','payments','day_closings','closing_stock'])r[t]=await g('SELECT * FROM '+t);
  X.ok=true;return fromRows(r)},
 queue:function(S){pending=JSON.stringify(S);clearTimeout(timer);timer=setTimeout(X.flush,400)},
 flush:async function(){if(running||pending==null)return;var snap=JSON.parse(pending);pending=null;running=true;
  try{await P.executeSet({database:DB,transaction:true,set:toSQL(snap).map(function(x){return{statement:x[0],values:x[1]}})});X.ok=true;X.err=''}
  catch(e){X.ok=false;X.err=String(e&&e.message||e);console.error(e)}
  running=false;if(pending!=null)X.flush()}};
addEventListener('pagehide',function(){X.flush()});
document.addEventListener('visibilitychange',function(){if(document.hidden)X.flush()});
})();
