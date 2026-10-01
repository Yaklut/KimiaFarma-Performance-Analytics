-- ============================================================
-- 03 - VALIDASI & QUERY ANALISIS (jalankan setelah tabel_analisa jadi)
-- Angka "Harusnya" dihitung dari CSV asli; selisih kecil di desimal itu wajar.
-- ============================================================

-- A. Jumlah baris & tanggal gagal parse.   Harusnya: 672.458 baris, 0 tanggal NULL
SELECT COUNT(*) AS total_baris,
       COUNTIF(date IS NULL) AS tanggal_null,
       COUNT(DISTINCT transaction_id) AS trx_unik,
       MIN(date) AS tgl_awal, MAX(date) AS tgl_akhir          -- 2020-01-01 s/d 2023-12-30
FROM `rare-hull-459814-d5.kimia_farma.tabel_analisa`;

-- B. Cabang/produk yang tidak ter-join.   Harusnya: 0 dan 0
SELECT COUNTIF(branch_name IS NULL) AS cabang_tak_cocok,
       COUNTIF(product_name IS NULL) AS produk_tak_cocok
FROM `rare-hull-459814-d5.kimia_farma.tabel_analisa`;

-- C. Total keseluruhan.   Harusnya: nett_sales ~ Rp 321,17 miliar, nett_profit ~ Rp 91,21 miliar
SELECT SUM(nett_sales) AS total_nett_sales, SUM(nett_profit) AS total_nett_profit
FROM `rare-hull-459814-d5.kimia_farma.tabel_analisa`;

-- D. Pendapatan per tahun (Perbandingan tahun ke tahun)
--    Harusnya nett_sales sekitar: 2020 = 80,44 M | 2021 = 80,04 M | 2022 = 80,58 M | 2023 = 80,12 M
SELECT EXTRACT(YEAR FROM date) AS tahun,
       COUNT(*) AS total_transaksi,
       ROUND(SUM(nett_sales)) AS nett_sales,
       ROUND(SUM(nett_profit)) AS nett_profit,
       ROUND(AVG(rating_transaksi), 2) AS avg_rating_transaksi
FROM `rare-hull-459814-d5.kimia_farma.tabel_analisa`
GROUP BY tahun ORDER BY tahun;

-- E. Top 10 provinsi berdasarkan TOTAL TRANSAKSI
--    Harusnya #1 Jawa Barat = 198.723, #2 Sumatera Utara = 48.178, #3 Jawa Tengah = 46.494
SELECT provinsi, COUNT(DISTINCT transaction_id) AS total_transaksi
FROM `rare-hull-459814-d5.kimia_farma.tabel_analisa`
GROUP BY provinsi ORDER BY total_transaksi DESC LIMIT 10;

-- F. Top 10 provinsi berdasarkan NETT SALES
SELECT provinsi, ROUND(SUM(nett_sales)) AS total_nett_sales
FROM `rare-hull-459814-d5.kimia_farma.tabel_analisa`
GROUP BY provinsi ORDER BY total_nett_sales DESC LIMIT 10;

-- G. Top 5 cabang: rating cabang TERTINGGI tapi rating transaksi TERENDAH
--    Catatan: ada 96 cabang berrating 5.0 (seri), jadi rata-rata rating transaksi dipakai
--    sebagai pemisah. branch_name hanya 3 nilai unik -> identifikasi cabang pakai branch_id + kota.
--    Harusnya: 82157 (Tarakan), 44567 (Batam), 13775 (Tomohon), 31872 (Pangkalpinang), 62707 (Mataram)
SELECT branch_id, kota, provinsi,
       MAX(rating_cabang) AS rating_cabang,
       ROUND(AVG(rating_transaksi), 3) AS avg_rating_transaksi,
       COUNT(*) AS jumlah_transaksi
FROM `rare-hull-459814-d5.kimia_farma.tabel_analisa`
GROUP BY branch_id, kota, provinsi
ORDER BY rating_cabang DESC, avg_rating_transaksi ASC
LIMIT 5;

-- H. Total profit per provinsi (bahan Geo Map)
SELECT provinsi, provinsi_iso, ROUND(SUM(nett_profit)) AS total_profit
FROM `rare-hull-459814-d5.kimia_farma.tabel_analisa`
GROUP BY provinsi, provinsi_iso ORDER BY total_profit DESC;

-- I. Analisis tambahan: kategori produk terlaris (nett sales)
SELECT product_category, ROUND(SUM(nett_sales)) AS nett_sales, COUNT(*) AS trx
FROM `rare-hull-459814-d5.kimia_farma.tabel_analisa`
GROUP BY product_category ORDER BY nett_sales DESC;

-- J. Analisis tambahan: performa per kategori cabang
SELECT branch_category, COUNT(*) AS trx, ROUND(SUM(nett_sales)) AS nett_sales,
       ROUND(AVG(rating_cabang), 2) AS avg_rating_cabang
FROM `rare-hull-459814-d5.kimia_farma.tabel_analisa`
GROUP BY branch_category ORDER BY nett_sales DESC;
