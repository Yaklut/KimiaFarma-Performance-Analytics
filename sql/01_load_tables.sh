#!/bin/bash
# ============================================================
# 01 - IMPORT 4 CSV KE BIGQUERY (opsional: via Cloud Shell / bq CLI)
# Cara lain: Console -> dataset kimia_farma -> Create table -> Source: Upload
# (upload lewat console maksimal 100 MB per file; file kamu 42 MB dan 88 MB, aman)
# Ganti PROJECT_ID dengan Project ID asli (BUKAN nama "Rakamin_KF_Analytics",
# Project ID biasanya ada tambahan angka/huruf, mis. rakamin-kf-analytics-123456)
# ============================================================
PROJECT_ID="rakamin-kf-analytics"
DS="kimia_farma"

# Catatan: kolom date sengaja dimuat sebagai STRING karena formatnya M/D/YYYY
# (mis. 9/7/2023). BigQuery hanya auto-detect DATE untuk format YYYY-MM-DD.
# Konversi ke DATE dilakukan di 02_create_tabel_analisa.sql

bq load --source_format=CSV --skip_leading_rows=1 \
  ${PROJECT_ID}:${DS}.kf_final_transaction ./kf_final_transaction.csv \
  transaction_id:STRING,date:STRING,branch_id:INTEGER,customer_name:STRING,product_id:STRING,price:INTEGER,discount_percentage:FLOAT,rating:FLOAT

bq load --source_format=CSV --skip_leading_rows=1 \
  ${PROJECT_ID}:${DS}.kf_inventory ./kf_inventory.csv \
  inventory_id:STRING,branch_id:INTEGER,product_id:STRING,product_name:STRING,opname_stock:INTEGER

bq load --source_format=CSV --skip_leading_rows=1 \
  ${PROJECT_ID}:${DS}.kf_kantor_cabang ./kf_kantor_cabang.csv \
  branch_id:INTEGER,branch_category:STRING,branch_name:STRING,kota:STRING,provinsi:STRING,rating:FLOAT

bq load --source_format=CSV --skip_leading_rows=1 \
  ${PROJECT_ID}:${DS}.kf_product ./kf_product.csv \
  product_id:STRING,product_name:STRING,product_category:STRING,price:INTEGER
