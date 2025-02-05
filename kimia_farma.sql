--Membuat tabel baru untuk menyimpan hasil tabel analisa
CREATE OR REPLACE TABLE `rakamin-kf-analytics-449018.kimia_farma.kf_tabel_analisa` AS
--Memilih kolom yang akan ada di tabel analisa
SELECT
    transaction_id,             --kode id transaksi                  
    date,                       --tanggal transaksi dilakukan
    branch_id,                  --kode id cabang Kimia Farma     
    branch_name,                --nama cabang Kimia Farma     
    kota,                       --kota cabang Kimia Farma
    provinsi,                   --provinsi cabang Kimia Farma     
    product_id,                 --kode produk obat     
    product_name,               --nama obat      
    customer_name,              --nama customer yang melakukan transaksi     
    actual_price,               --harga obat     
    discount_percentage,        --presentase diskon yang diberikan pada obat     
    transaction_rating,         --penilaian konsumen terhadap transaksi yang dilakukan
    branch_rating,              --penilaian konsumen terhadap cabang Kimia Farma              
    persentase_gross_laba,      --presentase laba yang diterima dari obat
    nett_sales,                 --harga setelah diskon
    (actual_price * persentase_gross_laba) - (actual_price - nett_sales) AS nett_profit,    --keuntungan Kimia Farma
    opname_stock                --stok obat yang tersedia
FROM (
  SELECT
     ft.transaction_id,                  
     ft.date,                            
     ft.branch_id,                       
     cb.branch_name,                     
     cb.kota,                            
     cb.provinsi,                        
     ft.product_id,                      
     cp.product_name,                    
     ft.customer_name,                   
     ft.price AS actual_price,           
     ft.discount_percentage,             
     ft.rating AS transaction_rating,    
     cb.rating AS branch_rating,         
     ci.opname_stock,                    
     --Menghitung presentase_gross_laba
     CASE
        WHEN ft.price <= 50000 THEN 0.10
        WHEN ft.price > 50000 AND ft.price <= 100000 THEN 0.15
        WHEN ft.price > 100000 AND ft.price <= 300000 THEN 0.20
        WHEN ft.price > 300000 AND ft.price <= 500000 THEN 0.25
        ELSE 0.30 
      END AS persentase_gross_laba,
  
     -- Menghitung harga setelah diskon 
     (ft.price - (ft.price * (ft.discount_percentage))) AS nett_sales

   -- Mengambil data dari tabel transaksi  
  FROM `rakamin-kf-analytics-449018.kimia_farma.kf_final_transaction` AS ft

  -- Menggabungkan dengan tabel produk untuk mendapatkan informasi produk
  LEFT JOIN `rakamin-kf-analytics-449018.kimia_farma.kf_product` AS cp ON ft.product_id = cp.product_id

  -- Menggabungkan dengan tabel kantor cabang dan produk untuk mendapatkan informasi stok opname
  LEFT JOIN (
  SELECT DISTINCT product_id, branch_id, MAX(opname_stock) AS opname_stock
  FROM `rakamin-kf-analytics-449018.kimia_farma.kf_inventory`
  GROUP BY product_id, branch_id) AS ci ON ft.product_id = ci.product_id AND ft.branch_id = ci.branch_id

  -- Menggabungkan dengan tabel kantor cabang untuk mendapatkan informasi cabang
  LEFT JOIN `rakamin-kf-analytics-449018.kimia_farma.kf_kantor_cabang` AS cb ON ft.branch_id = cb.branch_id
)

--Mengurutkan data dari tanggal terlama dengan net sales dan net profit tertinggi
ORDER BY date ASC, nett_sales, nett_profit DESC
;
