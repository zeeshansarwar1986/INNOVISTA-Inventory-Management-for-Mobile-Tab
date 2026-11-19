# فنکشن انڈیکس اور کال گراف (Function Index & Call Flow)

یہ دستاویز **INNOVISTA** ایپلیکیشن کے تمام فنکشنز، ان کے فائل پاتھ، ان کو کال کرنے والے حصوں (Callers) اور وہ جن فنکشنز کو آگے کال کرتے ہیں (Callees)، کی جامع فہرست پیش کرتی ہے۔

---

## 1. فائل: `www/index.html` کے فنکشنز

| فنکشن کا نام | فائل پاتھ | کیا کام کرتا ہے (Urdu Explanation) | اس فنکشن کو کون کال کرتا ہے (Callers) | یہ کن فنکشنز کو کال کرتا ہے (Calls) |
|---|---|---|---|---|
| `logo(n)` | `www/index.html` | دائرے کی شکل میں برانڈ لوگو کا HTML تیار کرتا ہے۔ | `lockView()`, `dash()`, `more()`, `license.js:screen()` | کوئی نہیں |
| `iso(d)` | `www/index.html` | تاریخ کو `YYYY-MM-DD` فارمیٹ میں تبدیل کرتا ہے۔ | `def()`, `nextDay()`, `toHTML()`, `exportXLSX()`, `exportJSON()` | `Date.prototype.toISOString` |
| `nextDay(s)` | `www/index.html` | دی گئی تاریخ کا اگلا دن حسابی طور پر نکالتا ہے۔ | `closeDay()` | `iso()` |
| `def()` | `www/index.html` | ایپ کی ابتدائی خالی اسٹیٹ (State) تیار کرتا ہے۔ | فائل انیشلائزیشن، `applyTheme()`, `rAll()`, `refresh()` | `iso()` |
| `save()` | `www/index.html` | میموری اسٹیٹ `S` کو `localStorage` اور SQLite اڈاپٹر میں محفوظ کرتا ہے۔ | `applyTheme()`, `addProd()`, `addStock()`, `saveBill()`, `addCust()`, `recv()`, `setP()`, `setS()`, `closeDay()`, `rmRange()`, `rAll()`, `applyImp()`, `editBill()`, `delBill()`, `editPay()`, `delPay()`, `editCust()`, `setPw()`, `togg()`, `toggS()`, `accordify()` | `saveUI()`, `DBX.queue()` |
| `saveUI()` | `www/index.html` | فعال ٹیب، منتخب کسٹمر اور اوپن بل کی معلومات براؤزر میں محفوظ کرتا ہے۔ | `save()`, `draw()`, `visibilitychange`, `pagehide` | کوئی نہیں |
| `$(s)` | `www/index.html` | DOM سلیکٹر شارٹ کٹ برائے `document.querySelector`۔ | تمام ویو اور ایونٹ ہینڈلرز | `document.querySelector` |
| `M(n)` | `www/index.html` | اعداد کو مقامی کرنسی اور کاما فارمیٹ میں بدلتا ہے۔ | `dash()`, `inv()`, `sales()`, `custs()`, `sheet()`, `toHTML()`, `recalcInv()`, `pickList()`, `custStats()` | `Number.prototype.toLocaleString` |
| `uid()` | `www/index.html` | منفرد شناخت (Unique ID) تخلیق کرتا ہے۔ | `addProd()`, `addCust()`, `saveBill()`, `recv()`, `applyImp()` | `Date.now()`, `Math.random` |
| `esc(s)` | `www/index.html` | HTML انجیکشن اور XSS حملے سے بچاؤ کیلئے ٹیکسٹ کو محفوظ بناتا ہے۔ | تمام رینڈرنگ ویوز | `String.prototype.replace` |
| `pname(id)` | `www/index.html` | پروڈکٹ آئی ڈی سے اس کا نام معلوم کرتا ہے۔ | `dash()`, `sales()`, `custs()`, `editBill()`, `repData()`, `exportXLSX()` | `Array.prototype.find` |
| `cname(id)` | `www/index.html` | کسٹمر آئی ڈی سے اس کا نام معلوم کرتا ہے۔ | `dash()`, `repData()`, `exportXLSX()`, `editBill()`, `editPay()` | `Array.prototype.find` |
| `billsOf(c)` | `www/index.html` | کسی مخصوص کسٹمر کے تمام سیلز بل فلٹر کرتا ہے۔ | `bal()`, `custs()`, `custStats()`, `repData()`, `exportXLSX()` | `Array.prototype.filter` |
| `paysOf(c)` | `www/index.html` | کسی مخصوص کسٹمر کی تمام موصول شدہ ادائیگیاں فلٹر کرتا ہے۔ | `bal()`, `custs()`, `custStats()`, `repData()`, `exportXLSX()` | `Array.prototype.filter` |
| `bal(c)` | `www/index.html` | کسٹمر کا موجودہ بقایا جات (Balance Due) کیلکولیٹ کرتا ہے۔ | `dash()`, `custs()`, `repData()` | `billsOf()`, `paysOf()` |
| `modal(html)` | `www/index.html` | پاپ اپ ڈائیلاگ ونڈو کھولتا ہے۔ | `form()`, `themeModal()`, `closeDay()`, `sure()`, `impParse()`, `editBill()`, `editPay()`, `addItem()` | کوئی نہیں |
| `close()` | `www/index.html` | پاپ اپ ڈائیلاگ ونڈو بند کرتا ہے۔ | ماڈل کے بٹن، کینسل بٹن، `#modal.onclick` | کوئی نہیں |
| `form(title, fields, cb, ok)` | `www/index.html` | عمومی ان پٹ فارم ماڈل تیار کرتا ہے۔ | `addProd()`, `addStock()`, `addCust()`, `recv()`, `rDate()`, `rMonth()`, `rAll()`, `editCust()`, `openAdmin()` | `modal()`, `esc()`, `close()` |
| `getTheme()` | `www/index.html` | موجودہ منتخب تھیم (white, halfwhite, dark) معلوم کرتا ہے۔ | `applyTheme()`, `toggleTheme()`, `themeModal()`, `themeCard()` | `localStorage.getItem` |
| `applyTheme(t, silent)` | `www/index.html` | تھیم لاگو کرتا ہے (اسٹائل اور میٹا ٹیگ اپ ڈیٹ کرتا ہے)۔ | `toggleTheme()`, `themeModal()`, `themeCard()`, `fixCfg()` | `def()`, `save()`, `toast()`, `draw()` |
| `toggleTheme()` | `www/index.html` | مون بٹن کے ذریعے ڈارک اور لائٹ موڈ کو آپس میں بدلتا ہے۔ | ہیڈر میں مون بٹن کا `onclick` (`themeBtn()`) | `getTheme()`, `applyTheme()` |
| `themeBtn()` | `www/index.html` | اسکرین ہیڈرز کیلئے سادہ مون آئیکون والا برائٹنس بٹن تیار کرتا ہے۔ | `dash()`, `inv()`, `sales()`, `custs()` | `toggleTheme()` |
| `themeModal()` | `www/index.html` | تمام تھیم آپشنز کی لسٹ والا پاپ اپ ماڈل بناتا ہے۔ | ایڈمن پینل یا ایکسٹینڈڈ کنٹرولز | `modal()`, `applyTheme()`, `close()` |
| `themeCard()` | `www/index.html` | سیٹنگز اور ایڈمن پینل کیلئے مکمل تھیم سوئچر کارڈ تیار کرتا ہے۔ | `more()`, `admin0()` | `applyTheme()` |
| `lockView()` | `www/index.html` | ایپ لاک ہونے پر پاس ورڈ اسکرین رینڈر کرتا ہے۔ | `draw()` | `logo()`, `esc()`, `checkPw()`, `draw()` |
| `dayData(d)` | `www/index.html` | کسی مخصوص تاریخ کی مکمل فروخت، یونٹس، وصولی اور اسٹاک کا حساب لگاتا ہے۔ | `dash()`, `exportXLSX()` | `Array.prototype.filter` |
| `dash()` | `www/index.html` | ڈیش بورڈ کی اسکرین (کارڈز، چارٹ، ڈیلی اسٹاک اور سیل شیٹس) رینڈر کرتا ہے۔ | `draw()` | `dayData()`, `bal()`, `logo()`, `esc()`, `themeBtn()`, `sheet()`, `secH()`, `M()` |
| `inv()` | `www/index.html` | انوینٹری مینجمنٹ اور لائیو ایکسل شیٹ اسکرین رینڈر کرتا ہے۔ | `draw()` | `themeBtn()`, `invSheet()`, `addProd()` |
| `invSheet()` | `www/index.html` | انوینٹری کی انٹرایکٹو گرڈ شیٹ فلٹر اور تیار کرتا ہے۔ | `inv()`, سرچ ان پٹ ایونٹ | `sheet()`, `addStock()`, `setP()`, `setS()`, `M()` |
| `recalcInv(id)` | `www/index.html` | ٹیبل سیل ایڈٹ کے بعد قیمت اور ویلیو فوری ری کیلکولیٹ کرتا ہے۔ | `setP()`, `setS()` | `M()` |
| `setP(id, v, el)` | `www/index.html` | پروڈکٹ کی سیلنگ پرائس براہ راست تبدیل کرتا ہے۔ | انوینٹری ٹیبل کا پرائس ان پٹ `onchange` | `save()`, `recalcInv()` |
| `setS(id, v, el)` | `www/index.html` | پروڈکٹ کا اسٹاک براہ راست تبدیل کرتا ہے۔ | انوینٹری ٹیبل کا اسٹاک ان پٹ `onchange` | `save()`, `recalcInv()` |
| `addProd()` | `www/index.html` | نیا آئٹم / پروڈکٹ شامل کرنے کا ماڈل کھولتا ہے۔ | انوینٹری اسکرین کا `+ Product` بٹن | `form()`, `uid()`, `save()`, `draw()` |
| `addStock(id)` | `www/index.html` | موجودہ پروڈکٹ میں نیا اسٹاک جمع کرنے کا ماڈل کھولتا ہے۔ | انوینٹری ٹیبل میں `+` بٹن | `form()`, `pname()`, `save()`, `draw()` |
| `sales()` | `www/index.html` | نیا بل بنانے (POS) کی اسکرین رینڈر کرتا ہے۔ | `draw()` | `themeBtn()`, `esc()`, `addCust()`, `addItem()`, `saveBill()`, `pname()`, `M()` |
| `addItem()` | `www/index.html` | بل میں آئٹم ڈالنے کیلئے سرچ ایبل ڈائیلاگ دکھاتا ہے۔ | سیلز اسکرین کا `+ Add item` بٹن | `modal()`, `pickList()`, `pickMatches()` |
| `pickMatches()` | `www/index.html` | سرچ کوئری کے مطابق پروڈکٹس فلٹر کرتا ہے۔ | `addItem()`, `pickList()` | `Array.prototype.filter` |
| `pickList()` | `www/index.html` | پروڈکٹ پکر کی لسٹ ایچ ٹی ایم ایل بناتا ہے۔ | `addItem()`, `pickSel()` | `pickMatches()`, `esc()`, `M()` |
| `pickSel(id)` | `www/index.html` | لسٹ میں سے منتخب پروڈکٹ کو سلیکٹ کرتا ہے۔ | پکر لسٹ آئٹم پر کلک | `pickList()`, `pname()` |
| `pickAdd()` | `www/index.html` | منتخب آئٹم اور مقدار کی توثیق کر کے بل میں شامل کرتا ہے۔ | پروڈکٹ پکر کا `Add` بٹن | `alert()`, `close()`, `draw()` |
| `saveBill()` | `www/index.html` | موجودہ بل کو فائنل کر کے سیلز میں محفوظ کرتا ہے اور اسٹاک کم کرتا ہے۔ | سیلز اسکرین کا `Save bill` بٹن | `uid()`, `save()`, `draw()` |
| `addCust(fromBill)` | `www/index.html` | نئے دکاندار (Shopkeeper) کو رجسٹر کرتا ہے۔ | کسٹمرز یا سیلز اسکرین کا بٹن | `form()`, `uid()`, `save()`, `draw()` |
| `custs()` | `www/index.html` | دکاندار لیجر (سمارٹ لسٹ یا انفرادی کھاتہ) رینڈر کرتا ہے۔ | `draw()` | `custSheet()`, `themeBtn()`, `addCust()`, `editCust()`, `newBillFor()`, `recv()`, `sheet()` |
| `custStats(c)` | `www/index.html` | دکاندار کی کل سیل، وصولی، بقایا جات اور بلوں کی تعداد گنتا ہے۔ | `custSheet()`, `custs()` | `billsOf()`, `paysOf()` |
| `custSheet()` | `www/index.html` | لیجر لسٹ شیٹ تیار کرتا ہے۔ | `custs()`, سرچ ایونٹ | `custStats()`, `sheet()`, `esc()`, `M()` |
| `newBillFor(id)` | `www/index.html` | کسٹمر کے نام پر فوری نیا بل بنانا شروع کرتا ہے۔ | کسٹمر کھاتہ اسکرین کا `New bill` بٹن | `draw()` |
| `editCust(id)` | `www/index.html` | دکاندار کا نام اور موبائل نمبر ایڈٹ کرتا ہے۔ | کسٹمر کھاتہ اسکرین کا `Edit name or phone` بٹن | `form()`, `save()`, `draw()` |
| `recv(id)` | `www/index.html` | دکاندار سے ادھار رقم وصول کرنے کی انٹری کرتا ہے۔ | کسٹمر کھاتہ اسکرین کا `Receive payment` بٹن | `form()`, `uid()`, `save()`, `draw()` |
| `editBill(id)` | `www/index.html` | پرانے بل کی مقدار، تاریخ اور وصولی ترمیم کرتا ہے۔ | کھاتہ ٹرانزیکشن شیٹ میں `Edit` بٹن | `modal()`, `delBill()`, `save()`, `close()`, `draw()` |
| `delBill(id)` | `www/index.html` | بل ڈیلیٹ کر کے اسٹاک واپس انوینٹری میں ریورس کرتا ہے۔ | `editBill()` ماڈل کے اندر `Delete` بٹن | `sure()`, `save()`, `draw()` |
| `editPay(id)` | `www/index.html` | موصول شدہ رقم کی انٹری ایڈٹ کرتا ہے۔ | کھاتہ ٹرانزیکشن شیٹ میں `Edit` بٹن | `modal()`, `delPay()`, `save()`, `close()`, `draw()` |
| `delPay(id)` | `www/index.html` | وصولی انٹری ڈیلیٹ کر کے بقایا دوبارہ بڑھا دیتا ہے۔ | `editPay()` ماڈل کے اندر `Delete` بٹن | `sure()`, `save()`, `draw()` |
| `more()` | `www/index.html` | سیٹنگز مینو اور ری سیٹ سینٹر اسکرین رینڈر کرتا ہے۔ | `draw()` | `themeCard()`, `resetCard()`, `openAdmin()`, `closeDay()` |
| `openAdmin()` | `www/index.html` | پاس ورڈ چیک کر کے ایڈمن پینل کھولتا ہے۔ | سیٹنگز مینو کا `Admin panel` آپشن | `checkPw()`, `form()`, `draw()` |
| `closeDay()` | `www/index.html` | کاروباری دن بند کر کے انوینٹری کا اگلا دن شروع کرتا ہے۔ | سیٹنگز مینو کا `Close day` آپشن | `modal()`, `nextDay()`, `save()`, `close()`, `draw()` |
| `admin()` | `www/index.html` | ایڈمن پینل اور ڈیٹا سیفٹی سیکشنز تیار کرتا ہے۔ | `draw()` | `admin1()`, `exportXLSX()`, `exportJSON()`, `restoreFile()`, `LIC.card()` |
| `admin0()` | `www/index.html` | ایڈمن پینل کے بیسک فارمز (لاک، شاپ انفارمیشن، تھریش ہولڈ) بناتا ہے۔ | `admin1()` | `themeCard()`, `setPw()`, `save()` |
| `admin1()` | `www/index.html` | ایڈمن پینل میں امپورٹ اور رپورٹنگ سیکشنز کا اضافہ کرتا ہے۔ | `admin()` | `admin0()`, `demoCSV()`, `impFile()`, `runReport()` |
| `accordify()` | `www/index.html` | ایڈمن پینل کے کارڈز کو ایکارڈین (Accordion) بنا کر قابلِ کلک کرتا ہے۔ | `draw()` | `save()` |
| `resetCard()` | `www/index.html` | ری سیٹ سینٹر (ڈیٹ وائز، منتھ وائز، آل ری سیٹ) رینڈر کرتا ہے۔ | `more()` | `tile()`, `rDate()`, `rMonth()`, `rAll()` |
| `sure(t, msg, yes)` | `www/index.html` | خطرناک ایکشنز کیلئے ریڈ الرٹ تصدیقی ماڈل دکھاتا ہے۔ | `rDate()`, `rMonth()`, `rAll()`, `restoreFile()`, `delBill()`, `delPay()` | `modal()`, `close()` |
| `rDate()` | `www/index.html` | کسی ایک مخصوص تاریخ کے بل اور ادائیگیاں صاف کرتا ہے۔ | ری سیٹ سینٹر کا `Reset a date` آپشن | `form()`, `sure()`, `rmRange()` |
| `rMonth()` | `www/index.html` | کسی پورے مہینے کا سیلز ریکارڈ ڈیلیٹ کرتا ہے۔ | ری سیٹ سینٹر کا `Reset a month` آپشن | `form()`, `sure()`, `rmRange()` |
| `rAll()` | `www/index.html` | تصدیق لے کر پوری ایپلیکیشن کا ڈیٹا مکمل ری سیٹ کرتا ہے۔ | ری سیٹ سینٹر کا `Reset entire app` آپشن | `form()`, `def()`, `save()`, `draw()` |
| `rmRange(f)` | `www/index.html` | فلٹر کے تحت بل ڈیلیٹ کر کے اوپن ڈے کا اسٹاک ایڈجسٹ کرتا ہے۔ | `rDate()`, `rMonth()` | `save()`, `draw()` |
| `impFile(el)` | `www/index.html` | کسٹمر کی طرف سے منتخب کردہ CSV فائل لوڈ کرتا ہے۔ | CSV فائل ان پٹ کا `onchange` | `impParse()` |
| `parseCSV(t, sep)` | `www/index.html` | CSV فائل کا متنی ڈیٹا پارس کر کے صفوں اور کالموں میں بدلتا ہے۔ | `impParse()` | کوئی نہیں |
| `impParse(t)` | `www/index.html` | CSV فائل کے کالمز کو خودکار شناخت کر کے امپورٹ ماڈل دکھاتا ہے۔ | `impFile()` | `parseCSV()`, `modal()`, `applyImp()` |
| `applyImp(add)` | `www/index.html` | کسٹمر کے انتخاب کے تحت انوینٹری میں ڈیٹا امپورٹ کر دیتا ہے۔ | امپورٹ ماڈل کے بٹن | `uid()`, `save()`, `close()`, `draw()` |
| `demoCSV()` | `www/index.html` | نمونہ CSV فائل ڈاؤن لوڈ کرواتا ہے۔ | ایڈمن پینل کا بٹن | `dl()` |
| `repData(t, k)` | `www/index.html` | روزانہ سیلز، کسٹمر اسٹیٹمنٹ یا تمام دکانداروں کی رپورٹ کا ڈیٹا مرتب کرتا ہے۔ | `runReport()` | `billsOf()`, `paysOf()`, `bal()`, `cname()`, `pname()` |
| `toCSV(rep)` | `www/index.html` | رپورٹ ڈیٹا کو ایکسل کمپیٹیبل CSV میں تبدیل کرتا ہے۔ | `runReport()` | کوئی نہیں |
| `toHTML(rep, paper)` | `www/index.html` | A4 یا Legal پیپر سائز پر پرنٹ کیلئے HTML پیج بناتا ہے۔ | `runReport()` | `esc()`, `M()` |
| `runReport(kind)` | `www/index.html` | رپورٹ جنریٹ کر کے CSV یا HTML ڈاؤن لوڈ کرتا ہے۔ | ایڈمن پینل کے رپورٹ بٹنز | `repData()`, `toCSV()`, `toHTML()`, `dl()` |
| `dl(name, text)` | `www/index.html` | متنی فائل (CSV/HTML) براؤزر میں ڈاؤن لوڈ کرتا ہے۔ | `demoCSV()`, `runReport()` | `blobDL()`, `modal()`, `close()` |
| `blobDL(n, d, m)` | `www/index.html` | براؤزر میموری بلوب بنا کر اینکر ٹیگ سے ڈاؤن لوڈ کرواتا ہے۔ | `dl()`, `dlBin()` | `URL.createObjectURL` |
| `dlBin(name, data)` | `www/index.html` | بائنری فائل (ایکسل، بیک اپ) ڈاؤن لوڈ کرتا ہے۔ | `exportXLSX()`, `exportJSON()` | `blobDL()` |
| `loadXLSX()` | `www/index.html` | ایکسل لائبریری `xlsx.full.min.js` کو لوڈ کرتا ہے۔ | `exportXLSX()` | `addScript()` |
| `exportXLSX()` | `www/index.html` | 7 مکمل ورک شیٹس پر مشتمل جامع ایکسل فائل ایکسپورٹ کرتا ہے۔ | ایڈمن پینل کا ایکسل ایکسپورٹ بٹن | `loadXLSX()`, `dayData()`, `dlBin()`, `XLSX.*` |
| `exportJSON()` | `www/index.html` | ایپ کے تمام ڈیٹا کا فل بیک اپ JSON فائل کے طور پر محفوظ کرتا ہے۔ | ایڈمن پینل کا بیک اپ بٹن | `dlBin()` |
| `restoreFile(el)` | `www/index.html` | بیک اپ JSON فائل اپ لوڈ کر کے مکمل ڈیٹا بحال کرتا ہے۔ | بیک اپ فائل اپ لوڈ ان پٹ کا `onchange` | `sure()`, `save()`, `draw()` |
| `draw()` | `www/index.html` | مرکزی شیل رینڈرر: موجودہ ٹیب اور اسکرین کو اسکرین پر ڈرا کرتا ہے۔ | ایپلیکیشن بوٹ، تمام سیو اور نیویگیشن ایکشنز | `lockView()`, `dash()`, `inv()`, `sales()`, `custs()`, `more()`, `admin()`, `accordify()`, `saveUI()` |
| `sheet(h, rows, foot, al)` | `www/index.html` | ایکسل طرز کی اسکرولیبل ڈیٹا ٹیبل تیار کرتا ہے۔ | `dash()`, `invSheet()`, `custSheet()`, `custs()` | کوئی نہیں |
| `secH(t, k)` | `www/index.html` | کولاپسیبل سیکشن کا ہیڈر بناتا ہے۔ | `dash()`, `custs()` | `toggS()` |
| `toggS(b, k)` | `www/index.html` | ٹیبل فولڈ سیکشن کو اوپن / کلوز کرتا ہے۔ | سیکشن ہیڈر کا ایرو بٹن | `save()` |
| `togg(b)` | `www/index.html` | کارڈز فولڈ کو اوپن / کلوز کرتا ہے۔ | ڈیش بورڈ ٹاپ رائٹ ایرو بٹن | `save()` |
| `toast(t)` | `www/index.html` | اسکرین پر نیچے عارضی نوٹیفکیشن میسج دکھاتا ہے۔ | `applyTheme()`, `refresh()` | کوئی نہیں |
| `refresh(manual)` | `www/index.html` | اسٹوریج سے ڈیٹا تازہ کر کے ویو ری ڈرا کرتا ہے۔ | ٹائمر، اسٹوریج ایونٹ، پل ٹو ریفریش | `draw()`, `toast()` |
| `hasSub()` | `www/index.html` | چیک کرتا ہے کہ براؤزر میں کرپٹو سبٹل موجود ہے یا نہیں۔ | `setPw()`, `checkPw()` | کوئی نہیں |
| `pwDerive(pw, salt)` | `www/index.html` | PBKDF2 (SHA-256، 100,000 راؤنڈز) کے ذریعے پاس ورڈ ہیش بناتا ہے۔ | `setPw()`, `checkPw()` | `crypto.subtle.*`, `b64()` |
| `setPw(pw)` | `www/index.html` | نیا ماسٹر پاس ورڈ نمکین (salted) ہیش کر کے محفوظ کرتا ہے۔ | ایڈمن پینل میں سیو پاس ورڈ بٹن | `hasSub()`, `pwDerive()`, `save()` |
| `checkPw(pw)` | `www/index.html` | داخل کردہ پاس ورڈ کا ہیش سے موازنہ کر کے توثیق کرتا ہے۔ | `lockView()`, `openAdmin()` | `hasSub()`, `pwDerive()`, `setPw()` |

---

## 2. فائل: `www/db.js` کے فنکشنز

| فنکشن کا نام | فائل پاتھ | کیا کام کرتا ہے (Urdu Explanation) | اس فنکشن کو کون کال کرتا ہے (Callers) | یہ کن فنکشنز کو کال کرتا ہے (Calls) |
|---|---|---|---|---|
| `toSQL(S)` | `www/db.js` | ان میموری اسٹیٹ `S` کو SQLite INSERT/UPDATE اسٹیٹمنٹس میں تبدیل کرتا ہے۔ | `DBX.flush()` | `Array.prototype.forEach` |
| `fromRows(r)` | `www/db.js` | SQLite کے ٹیبلز کے ڈیٹا کو دوبارہ جاوا اسکرپٹ اسٹیٹ `S` میں تبدیل کرتا ہے۔ | `DBX.boot()` | `JSON.parse` |
| `DBX.boot()` | `www/db.js` | SQLite ڈیٹا بیس کھولتا ہے، اسکیما بناتا ہے اور پرانا ڈیٹا لوڈ کرتا ہے۔ | ایپلیکیشن بوٹ سیکوئنس (`index.html`) | `fromRows()`, `P.executeSet()`, `P.query()` |
| `DBX.queue(S)` | `www/db.js` | 400ms کا ڈی باؤنس ٹائمر لگا کر سیو کی ریکویسٹ کیو میں ڈالتا ہے۔ | `save()` (`www/index.html`) | `DBX.flush()` |
| `DBX.flush()` | `www/db.js` | کیو میں موجود ڈیٹا کو سنگل ٹرانزیکشن میں SQLite میں رائٹ کرتا ہے۔ | `DBX.queue()`, `visibilitychange`, `pagehide` | `toSQL()`, `P.executeSet()` |

---

## 3. فائل: `www/license.js` کے فنکشنز

| فنکشن کا نام | فائل پاتھ | کیا کام کرتا ہے (Urdu Explanation) | اس فنکشن کو کون کال کرتا ہے (Callers) | یہ کن فنکشنز کو کال کرتا ہے (Calls) |
|---|---|---|---|---|
| `b64u(b)` | `www/license.js` | بائٹس کو URL-safe Base64 میں بدلتا ہے۔ | `seed()`, تصدیقی لاجک | کوئی نہیں |
| `unb(s)` | `www/license.js` | URL-safe Base64 کو بائٹ ارے میں ڈی کوڈ کرتا ہے۔ | `verify()` | `atob()` |
| `b32(by)` | `www/license.js` | بائٹس کو Crockford Base32 میں انکوڈ کرتا ہے۔ | `deviceId()` | کوئی نہیں |
| `norm(s)` | `www/license.js` | ڈیوائس آئی ڈی سے مشتبہ کیریکٹرز صاف کرتا ہے۔ | `verify()` | کوئی نہیں |
| `seed()` | `www/license.js` | کیپیسیٹر سے ہارڈویئر آئی ڈی یا براؤزر کیلئے رینڈم سیڈ حاصل کرتا ہے۔ | `deviceId()` | `Capacitor.Plugins.Device.getId()` |
| `deviceId()` | `www/license.js` | ہارڈویئر فنگر پرنٹ کا SHA-256 ہیش لے کر 16 ہندسوں کا ڈیوائس کوڈ بناتا ہے۔ | `screen()`, `visibilitychange` | `seed()`, `crypto.subtle.digest()`, `b32()` |
| `clockOk()` | `www/license.js` | چیک کرتا ہے کہ صارف نے ڈیوائس کی تاریخ پیچھے تو نہیں کی۔ | `verify()`, `screen()`, `visibilitychange` | `localStorage.*` |
| `verify(key, dev)` | `www/license.js` | پبلک کی کے ذریعے ECDSA P-256 ڈیجیٹل دستخط کی تصدیق کرتا ہے۔ | `screen()`, `visibilitychange` | `crypto.subtle.importKey()`, `crypto.subtle.verify()` |
| `copy(t)` | `www/license.js` | ڈیوائس آئی ڈی کو کلپ بورڈ میں کاپی کرتا ہے۔ | ایکٹیویشن اسکرین کا `Copy ID` بٹن | `navigator.clipboard.writeText`, `old()` |
| `screen(dev, msg)` | `www/license.js` | غیر رجسٹرڈ ڈیوائس کیلئے لائسنس ایکٹیویشن اسکرین دکھاتا ہے۔ | `LIC.ensure()` | `deviceId()`, `verify()`, `clockOk()`, `copy()` |
| `LIC.ensure()` | `www/license.js` | بوٹ کے وقت لائسنس کی موجودگی اور درستگی کی جانچ کرتا ہے۔ | ایپلیکیشن بوٹ سیکوئنس (`index.html`) | `deviceId()`, `verify()`, `screen()` |
| `LIC.card()` | `www/license.js` | ایڈمن پینل کیلئے لائسنس کی معلومات کا کارڈ پیش کرتا ہے۔ | `admin()` (`www/index.html`) | کوئی نہیں |

