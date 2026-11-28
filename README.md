# Stock & Inventory Management System (Intranet Edition)

A complete, production-ready **Stock & Inventory Management System** built with **Classic ASP.NET Web Forms (C# / .NET Framework 4.8)** and **MySQL**, designed to run completely offline on an office intranet PC via **IIS / Localhost** and managed via **SQLyog**.

---

## 🏛️ System Architecture & Technology Stack

| Layer | Technology | Details |
|---|---|---|
| **Frontend** | HTML5, CSS3, Vanilla JavaScript | **100% Offline / Zero CDN Dependencies**. Corporate intranet styling, responsive layout, SVG icons, client-side overdraft warnings, live table filtering. |
| **Backend** | ASP.NET Web Forms (C# / .NET 4.8) | `.aspx` pages, `.aspx.cs` code-behinds, and modular `App_Code` business logic layer. |
| **Data Access** | ADO.NET with `MySql.Data` | Fully parameterized queries (SQL-injection immune), `MySqlConnection`, `MySqlCommand`, and atomic `MySqlTransaction` row-locking for stock consistency. |
| **Database** | MySQL (5.7+ / 8.0+) | Tables `Items` & `Transactions`, foreign keys, indexes, check constraints, and reporting view `v_ActiveStockTracker`. |
| **GUI DB Client** | **SQLyog** (or HeidiSQL) | Compatible `.sql` script with clean batch execution delimiters and sample records. |
| **Hosting** | Windows IIS / IIS Express | Local intranet deployment accessible via `http://localhost` and intranet IP (`http://192.168.x.x`). |

---

## 📂 Project Directory Structure

```text
StockInventorySystem/
├── App_Code/
│   ├── DbHelper.cs               # Central ADO.NET helper for MySQL connections & commands
│   ├── ItemRepository.cs         # Item Master CRUD, duplicate PartNo checks, dashboard KPIs
│   └── TransactionRepository.cs  # Atomic stock movements (MySqlTransaction), overdraft check, CSV export
├── bin/
│   └── MySql.Data.dll            # Official MySQL ADO.NET Connector assembly (.NET Framework)
├── Content/
│   └── site.css                  # Self-contained intranet CSS (zero external CDNs or web fonts)
├── Database/
│   └── InventoryDB.sql           # SQLyog-ready MySQL database schema and sample seed records
├── Scripts/
│   └── app.js                   # Client-side validation, live item auto-fill preview, instant search
├── Default.aspx                  # Module 1: Dashboard, KPI summary cards & recent movements
├── Default.aspx.cs
├── ItemMaster.aspx               # Module 2: Item Master entry form, duplicate blocker & item grid
├── ItemMaster.aspx.cs
├── TransactionMaster.aspx        # Module 3: Transaction Master & Active Stock Tracking
├── TransactionMaster.aspx.cs
├── TransactionDetails.aspx       # Module 4: Transaction Details & Date Range Search + CSV Export
├── TransactionDetails.aspx.cs
├── Site.Master                   # Persistent top header & responsive tab navigation
├── Site.Master.cs
├── Web.config                    # MySQL connection strings & IIS configuration
└── README.md                     # Intranet setup and operations guide
```

---

## 🚀 Quick-Start Setup Guide

### 1. Database Setup via SQLyog

1. Open **SQLyog** and connect to your local MySQL instance:
   - **MySQL Host Address:** `127.0.0.1` or `localhost`
   - **Username:** `root` (or your MySQL user)
   - **Password:** *(Your MySQL password)*
   - **Port:** `3306`
2. In SQLyog, click **File** &rarr; **Open Query / SQL Script** (or press `Ctrl + O`).
3. Select `Database/InventoryDB.sql` from this project folder.
4. Click the **Execute Query** button (or press `F5`).
5. SQLyog will execute the script and output:
   - Database `InventoryDB` created.
   - Tables `Items` and `Transactions` created with foreign keys and indexes.
   - Reporting view `v_ActiveStockTracker` created.
   - 10 sample items (with in-stock, low-stock, and out-of-stock statuses) and 15 realistic historical transactions inserted.
6. In SQLyog's left Object Browser, right-click and select **Refresh Object Browser** (`F5`) to confirm `InventoryDB` is visible.

---

### 2. Configure Database Connection (`Web.config`)

Open `Web.config` in the root folder and verify the connection string:

```xml
<connectionStrings>
  <add name="InventoryDbConn"
       connectionString="Server=localhost;Port=3306;Database=InventoryDB;Uid=root;Pwd=YourPasswordHere;AllowZeroDateTime=True;ConvertZeroDateTime=True;SslMode=none;CharSet=utf8mb4;"
       providerName="MySql.Data.MySqlClient" />
</connectionStrings>
```

> **Note on MySQL 8.0 Authentication:** If your MySQL 8.0 user uses `caching_sha2_password`, you can either leave it as is or execute this one-line command in SQLyog if you encounter an authentication plugin handshake error:
> ```sql
> ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'YourPasswordHere';
> FLUSH PRIVILEGES;
> ```

---

### 3. Deploying to Windows IIS for Office Intranet Access

#### Step A: Ensure IIS & ASP.NET 4.8 Features are Enabled
1. Press `Win + R`, type `optionalfeatures.exe`, and press **Enter**.
2. Expand **Internet Information Services**:
   - Check **Web Management Tools** &rarr; **IIS Management Console**.
   - Expand **World Wide Web Services** &rarr; **Application Development Features**:
     - Check **.NET Extensibility 4.8** (or 4.7/4.5).
     - Check **ASP.NET 4.8** (or 4.7/4.5).
     - Check **ISAPI Extensions** and **ISAPI Filters**.
3. Click **OK** and let Windows install the components.

#### Step B: Add Application in IIS Manager
1. Press `Win + R`, type `inetmgr`, and press **Enter** to open **IIS Manager**.
2. In the left panel, expand your server name &rarr; **Sites** &rarr; right-click **Default Web Site**.
3. Select **Add Application...**:
   - **Alias:** `inventory` (or `StockInventory`)
   - **Application Pool:** Select **DefaultAppPool** (or **ASP.NET v4.0**). Verify it is set to **.NET CLR Version: v4.0** and **Integrated** pipeline.
   - **Physical path:** Browse to:
     `C:\Users\Admin\.gemini\antigravity\scratch\StockInventorySystem`
4. Click **OK**.

#### Step C: Folder Security Permissions
1. Right-click the `StockInventorySystem` folder in Windows File Explorer &rarr; **Properties** &rarr; **Security** tab.
2. Click **Edit...** &rarr; **Add...**.
3. Enter `IIS_IUSRS` and click **Check Names**, then click **OK**.
4. Grant **Read & execute**, **List folder contents**, and **Read** permissions.
5. Click **Apply** and **OK**.

#### Step D: Test on Localhost and Office Intranet
- **Localhost access:** Open your browser and navigate to:
  ```text
  http://localhost/inventory/
  ```
- **Intranet access from other office PCs:** Find your host PC's local IP address (open Command Prompt and run `ipconfig`, e.g. `192.168.1.50`). Colleague workstations can access:
  ```text
  http://192.168.1.50/inventory/
  ```

#### Step E: Windows Firewall Configuration (for Intranet Access)
If other intranet PCs cannot connect to your host PC:
1. Open **Windows Defender Firewall with Advanced Security**.
2. Click **Inbound Rules** &rarr; **New Rule...**.
3. Select **Port** &rarr; **TCP** &rarr; Specific local ports: `80` (and `8080` if used).
4. Select **Allow the connection** &rarr; Check **Private / Domain** &rarr; Name it **IIS Intranet Web Service** &rarr; Click **Finish**.

---

## 🖥️ Module-by-Module Capabilities

### 1. Main Dashboard (`Default.aspx`)
- **Real-Time KPI Cards:**
  - **Total Unique Items:** Live count of registered SKUs.
  - **Total Stock Quantity:** Sum of all physical units in inventory.
  - **Total Inventory Value:** Sum of `UnitPrice * CurrentQuantity`.
  - **Low Stock Alerts:** Items with fewer than 10 units in stock.
- **Attention Banner:** Automatically triggers if any items hit low-stock or out-of-stock thresholds, providing a one-click link to restock.
- **Module Navigation Hub:** 4 quick-access cards to jump directly to any functional tab.
- **Recent Movements Table:** Displays the 10 most recent stock movements with badges for movement types and order sources.

### 2. Item Master (`ItemMaster.aspx`)
- **Item Registration Form:**
  - `PartNo`: Primary business key. **Duplicate Part Numbers are blocked** with a clear validation alert.
  - `ItemName`: Description and part title.
  - `UnitPrice`: Decimal cost per unit ($\ge 0$).
  - `Location`: Storage bin, rack, or shelf coordinate.
  - `CurrentQuantity`: Initial opening stock (subsequent changes are managed exclusively through transactions to preserve audit integrity).
- **Edit Mode:** Click "Edit" on any row to modify Item Name, Unit Price, or Storage Location. The primary key (`PartNo`) is protected as read-only.
- **Instant Search:** Search items in real-time by Part Number, Item Name, or Location without page reloads.

### 3. Transaction Master & Active Stock Tracking (`TransactionMaster.aspx`)
- **Stock Movement Recording:**
  - Linked directly to the Item Master via a dropdown.
  - **Live Auto-Fill Preview:** Selecting an item automatically loads its storage location, current available balance, and unit cost into the preview box.
  - **Supported Movement Types:**
    - `Stock In` (Receipt / Inbound replenishment)
    - `Stock Out` (Issue / Consumption)
    - `Adjustment` (Physical audit discrepancies with Add or Deduct direction)
  - **Mandatory Order Source Options:** Exact values required by business operations:
    - **`SAP`** (Enterprise PO / Transfer)
    - **`E-mail`** (Department Authorization)
    - **`Personal Request`** (Direct Staff Voucher)
- **Overdraft Protection & Atomicity:**
  - Prevents `Stock Out` transactions if requested quantity exceeds available stock.
  - Wrapped inside a MySQL `MySqlTransaction` with row-level locking (`SELECT ... FOR UPDATE`) so balances and logs never desynchronize.
- **Active Stock Tracker:** A live grid below the form showing updated quantities, stock status pills (`In Stock`, `Low Stock`, `Out of Stock`), and last movement timestamp.

### 4. Transaction Details & Date Range Search (`TransactionDetails.aspx`)
- **Comprehensive Audit Trail:** Complete history of every stock event with `TransactionID`, `TransactionDate`, `PartNo`, `ItemName`, `Location`, `TransactionType`, `Quantity`, `OrderSource`, `BalanceAfterTransaction`, and `ReferenceRemarks`.
- **Flexible Filters:**
  - **From Date** and **To Date** pickers with client/server validation preventing inverted dates.
  - Keyword search for Part Number, Item Name, or Location.
  - Filter by Order Source (`All`, `SAP`, `E-mail`, `Personal Request`).
  - Filter by Movement Type (`All`, `Stock In`, `Stock Out`, `Adjustment`).
- **Offline CSV / Excel Export:** One-click download generating a clean, standard CSV file with UTF-8 BOM encoding for seamless opening in Microsoft Excel on offline intranet workstations.

---

## 🔒 Intranet & Security Features
- **Zero Internet / CDN Dependencies:** All CSS, styles, system fonts, and JavaScript reside completely within the project folders. Works seamlessly on isolated air-gapped office networks.
- **SQL Injection Immune:** 100% of database interactions utilize ADO.NET parameterized queries (`MySqlParameter`).
- **Data Integrity:** Foreign key constraint `fk_trans_items_partno` prevents orphaned transaction records, with `ON UPDATE CASCADE ON DELETE RESTRICT`.
- **Cross-Site Request Forgery Protection:** ASP.NET ViewState MAC and event validation enabled by default.
