-- ============================================================
-- 02 - TABEL ANALISA: kimia_farma.tabel_analisa
-- Sumber : kf_final_transaction + kf_kantor_cabang + kf_product
-- Ganti `rakamin-kf-analytics` dengan Project ID kamu (find & replace)
-- ============================================================
-- Keputusan desain (jelaskan juga di PPT / video):
-- 1. date di CSV berformat M/D/YYYY (STRING) -> diubah jadi DATE pakai PARSE_DATE.
-- 2. Harga (actual_price) diambil dari transaksi. Sudah dicek: 100% sama dengan kf_product.price.
-- 3. persentase_gross_laba mengikuti aturan tier harga dari soal (disimpan sebagai desimal: 0.10 = 10%).
-- 4. nett_sales  = actual_price * (1 - discount_percentage)
--    nett_profit = nett_sales * persentase_gross_laba   (laba dihitung dari harga setelah diskon)
-- 5. kf_inventory TIDAK di-join ke tabel ini: pasangan (branch_id, product_id) di inventory
--    berulang (780.996 baris duplikat), jadi join langsung akan menggandakan baris transaksi
--    dan menggelembungkan nett_sales. Inventory diringkas terpisah di bagian bawah file ini.
-- 6. provinsi_iso ditambahkan (kode ISO 3166-2) supaya Geo Map di Data Studio akurat.
-- ============================================================

CREATE OR REPLACE TABLE `rare-hull-459814-d5.kimia_farma.tabel_analisa` AS
WITH base AS (
  SELECT
    t.transaction_id,
    PARSE_DATE('%m/%d/%Y', t.date)          AS date,
    t.branch_id,
    b.branch_category,
    b.branch_name,
    b.kota,
    b.provinsi,
    b.rating                                AS rating_cabang,
    t.customer_name,
    t.product_id,
    p.product_name,
    p.product_category,
    t.price                                 AS actual_price,
    t.discount_percentage,
    CASE
      WHEN t.price <= 50000  THEN 0.10
      WHEN t.price <= 100000 THEN 0.15
      WHEN t.price <= 300000 THEN 0.20
      WHEN t.price <= 500000 THEN 0.25
      ELSE 0.30
    END                                     AS persentase_gross_laba,
    t.rating                                AS rating_transaksi
  FROM `rare-hull-459814-d5.kimia_farma.kf_final_transaction` AS t
  LEFT JOIN `rare-hull-459814-d5.kimia_farma.kf_kantor_cabang` AS b ON t.branch_id  = b.branch_id
  LEFT JOIN `rare-hull-459814-d5.kimia_farma.kf_product`       AS p ON t.product_id = p.product_id
)
SELECT
  transaction_id,
  date,
  branch_id,
  branch_name,
  kota,
  provinsi,
  rating_cabang,
  customer_name,
  product_id,
  product_name,
  actual_price,
  discount_percentage,
  persentase_gross_laba,
  ROUND(actual_price * (1 - discount_percentage), 2)                          AS nett_sales,
  ROUND(actual_price * (1 - discount_percentage) * persentase_gross_laba, 2)  AS nett_profit,
  rating_transaksi,
  -- kolom tambahan (bukan mandatory, berguna untuk analisis di dashboard)
  branch_category,
  product_category,
  CASE provinsi
      WHEN 'Aceh' THEN 'ID-AC'
      WHEN 'Sumatera Utara' THEN 'ID-SU'
      WHEN 'Sumatera Barat' THEN 'ID-SB'
      WHEN 'Riau' THEN 'ID-RI'
      WHEN 'Kepulauan Riau' THEN 'ID-KR'
      WHEN 'Jambi' THEN 'ID-JA'
      WHEN 'Sumatera Selatan' THEN 'ID-SS'
      WHEN 'Bangka Belitung' THEN 'ID-BB'
      WHEN 'Bengkulu' THEN 'ID-BE'
      WHEN 'Lampung' THEN 'ID-LA'
      WHEN 'DKI Jakarta' THEN 'ID-JK'
      WHEN 'Jawa Barat' THEN 'ID-JB'
      WHEN 'Banten' THEN 'ID-BT'
      WHEN 'Jawa Tengah' THEN 'ID-JT'
      WHEN 'DI Yogyakarta' THEN 'ID-YO'
      WHEN 'Jawa Timur' THEN 'ID-JI'
      WHEN 'Bali' THEN 'ID-BA'
      WHEN 'Nusa Tenggara Barat' THEN 'ID-NB'
      WHEN 'Nusa Tenggara Timur' THEN 'ID-NT'
      WHEN 'Kalimantan Barat' THEN 'ID-KB'
      WHEN 'Kalimantan Tengah' THEN 'ID-KT'
      WHEN 'Kalimantan Selatan' THEN 'ID-KS'
      WHEN 'Kalimantan Timur' THEN 'ID-KI'
      WHEN 'Kalimantan Utara' THEN 'ID-KU'
      WHEN 'Sulawesi Utara' THEN 'ID-SA'
      WHEN 'Gorontalo' THEN 'ID-GO'
      WHEN 'Sulawesi Tengah' THEN 'ID-ST'
      WHEN 'Sulawesi Selatan' THEN 'ID-SN'
      WHEN 'Sulawesi Tenggara' THEN 'ID-SG'
      WHEN 'Sulawesi Barat' THEN 'ID-SR'
      WHEN 'Maluku' THEN 'ID-MA'
      WHEN 'Maluku Utara' THEN 'ID-MU'
      WHEN 'Papua' THEN 'ID-PA'
      WHEN 'Papua Barat' THEN 'ID-PB'
    ELSE NULL
  END                                                                         AS provinsi_iso
FROM base;

-- ============================================================
-- OPSIONAL: ringkasan stok per cabang (untuk analisis tambahan)
-- ============================================================
CREATE OR REPLACE TABLE `rare-hull-459814-d5.kimia_farma.tabel_stok_cabang` AS
SELECT
  i.branch_id,
  b.branch_name,
  b.kota,
  b.provinsi,
  COUNT(DISTINCT i.product_id) AS jumlah_produk,
  SUM(i.opname_stock)          AS total_stok
FROM `rare-hull-459814-d5.kimia_farma.kf_inventory`     AS i
LEFT JOIN `rare-hull-459814-d5.kimia_farma.kf_kantor_cabang` AS b ON i.branch_id = b.branch_id
GROUP BY 1, 2, 3, 4;
