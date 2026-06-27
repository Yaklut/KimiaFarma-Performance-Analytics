# Kimia Farma Performance Analytics 2020–2023
**Project-Based Virtual Internship — Big Data Analytics**
PT. Kimia Farma x Rakamin Academy | April–May 2025

---

## Project Overview

Kimia Farma, one of Indonesia's largest pharmaceutical companies, needed a data-driven approach to evaluate business performance across its branches nationwide. This project involved importing multi-source datasets into Google BigQuery, building an integrated analysis table using SQL, and delivering a performance analytics dashboard covering 2020–2023.

---

## 🎯 Objectives

- Import and integrate 4 datasets into Google BigQuery
- Build a unified analysis table using SQL JOINs and CASE WHEN logic
- Analyze sales performance, profitability, and service quality across branches
- Identify regional trends and deliver strategic recommendations

---

## 🗂️ Dataset Structure

| File | Description |
|------|-------------|
| kf_final_transaction.csv | Transaction data (date, product, discount, transaction rating) |
| kf_product.csv | Product information (name, category, price) |
| kf_inventory.csv | Stock opname per branch |
| kf_kantor_cabang.csv | Branch details (location, branch rating) |

---

## 🛠️ Tools Used

- **Google BigQuery** — Dataset import, SQL query execution, table creation
- **Google Looker Studio** — Interactive dashboard and data visualization
- **SQL** — Data integration, profit margin calculation, multi-table JOINs

---

## 🔧 SQL Query

The following query builds the master analysis table by joining all 4 datasets and calculating nett sales and profit margins by price tier:

```sql
WITH transaksi AS (
  SELECT
    transaction_id, date, branch_id, customer_name,
    product_id, price AS original_price,
    discount_percentage, rating AS rating_transaksi
  FROM `kimia_farma.kf_final_transaction`
),
produk AS (
  SELECT product_id, product_name, price AS actual_price
  FROM `kimia_farma.kf_product`
),
cabang AS (
  SELECT branch_id, branch_name, kota, provinsi, rating AS rating_cabang
  FROM `kimia_farma.kf_kantor_cabang`
),
gabungan_transaksi AS (
  SELECT
    t.transaction_id, t.date, t.branch_id,
    c.branch_name, c.kota, c.provinsi, c.rating_cabang,
    t.customer_name, t.product_id, p.product_name,
    p.actual_price, t.discount_percentage,
    CASE
      WHEN p.actual_price <= 50000 THEN 0.10
      WHEN p.actual_price > 50000 AND p.actual_price <= 100000 THEN 0.15
      WHEN p.actual_price > 100000 AND p.actual_price <= 300000 THEN 0.20
      WHEN p.actual_price > 300000 AND p.actual_price <= 500000 THEN 0.25
      WHEN p.actual_price > 500000 THEN 0.30
      ELSE 0
    END AS persentase_gross_laba,
    p.actual_price * (1 - t.discount_percentage / 100.0) AS nett_sales,
    (p.actual_price * (1 - t.discount_percentage / 100.0)) *
    CASE
      WHEN p.actual_price <= 50000 THEN 0.10
      WHEN p.actual_price > 50000 AND p.actual_price <= 100000 THEN 0.15
      WHEN p.actual_price > 100000 AND p.actual_price <= 300000 THEN 0.20
      WHEN p.actual_price > 300000 AND p.actual_price <= 500000 THEN 0.25
      WHEN p.actual_price > 500000 THEN 0.30
      ELSE 0
    END AS nett_profit,
    t.rating_transaksi
  FROM transaksi t
  LEFT JOIN produk p ON t.product_id = p.product_id
  LEFT JOIN cabang c ON t.branch_id = c.branch_id
)
SELECT * FROM gabungan_transaksi;
```

---

## 📊 Dashboard Summary

**Key Metrics (2020–2023):**
- Total Transactions: 672,500+
- Nett Sales: Rp346.96 Million
- Nett Profit: Rp98.54 Million
- Total Customers: 264,600+
- Total Products: 150

**Top 10 Provinces by Nett Sales:**
1. Jawa Barat — Rp102.5 Million
2. Sumatera Utara — Rp24.8 Million
3. Jawa Tengah — Rp24 Million
4. Jawa Timur — Rp18 Million
5. Sulawesi Utara — Rp17.2 Million

**Top 10 Provinces by Transaction Volume:**
1. Jawa Barat — 198,700 transactions
2. Sumatera Utara — 48,200
3. Jawa Tengah — 46,500
4. Jawa Timur — 34,800
5. Sulawesi Utara — 33,300

---

## 💡 Key Insights

- Nett sales remained stable between Rp6.5M–Rp8M monthly from January 2020 to July 2023, indicating consistent revenue generation
- Jawa Barat dominates both transaction volume (198,700) and nett sales (Rp102.5M), showing strong value-volume synergy
- 5 branches with maximum branch rating (5.0) show low transaction ratings (~3.9), indicating a mismatch between service quality perception and actual customer experience
- Margin between nett sales and profit suggests room for cost efficiency improvements across mid-tier branches

---

## ✅ Recommendations

**1. Regional Focus Strategy**
Concentrate sales campaigns in mid-tier provinces (Jawa Timur, Sulawesi Utara) to close the performance gap with Jawa Barat.

**2. Branch Service Quality Improvement**
Investigate transaction flow at high-rated branches with low transaction ratings. Provide additional staff training or technology enhancements to align service delivery with branch reputation.

**3. Profit Margin Optimization**
Focus on operational efficiency and cost reduction strategies, particularly in branches showing stable sales but lower-than-average profit margins.

**4. Inventory Management**
Leverage stock opname data from kf_inventory to align product availability with high-demand regions and peak transaction periods.

---

## 👤 Author

**Refa Defanda Witanto**
International Relations, Universitas Brawijaya
[LinkedIn](https://www.linkedin.com/in/refa-defanda/) | refadfnda@gmail.com
