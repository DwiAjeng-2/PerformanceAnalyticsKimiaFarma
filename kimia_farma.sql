--Membuat tabel baru untuk menyimpan hasil tabel analisa
CREATE TABLE `rakamin-kf-analytics-449018.kimia_farma.kf_tabel_analisa` AS
--Memilih kolom yang akan ada di tabel analisa
SELECT
    ft.transaction_id,                  --kode id transaksi          
    ft.date,                            --tanggal transaksi dilakukan
    ft.branch_id,                       --kode id cabang Kimia Farma 
    cb.branch_name,                     --nama cabang Kimia Farma
    cb.kota,                            --kota cabang Kimia Farma
    cb.provinsi,                        --provinsi cabang Kimia Farma
    ft.product_id,                      --kode produk obat 
    cp.product_name,                    --nama obat 
    ft.customer_name,                   --nama customer yang melakukan transaksi 
    ft.price AS actual_price,           --harga obat
    ft.discount_percentage,             --presentase diskon yang diberikan pada obat
    ft.rating AS transaction_rating,    --penilaian konsumen terhadap transaksi yang dilakukan
    cb.rating AS branch_rating,         --penilaian konsumen terhadap cabang Kimia Farma
    ci.opname_stock,                    --stok obat pada cabang yang masih tersedia
    -- Menghitung persentase gross laba berdasarkan ketentuan harga
    CASE
        WHEN ft.price <= 50000 THEN 0.1   
        WHEN ft.price > 50000 AND ft.price <= 100000 THEN 0.15  
        WHEN ft.price > 100000 AND ft.price <= 300000 THEN 0.20 
        WHEN ft.price > 300000 AND ft.price <= 500000 THEN 0.25 
        ELSE 0.30                                              
    END AS persentase_gross_laba,

    -- Menghitung harga setelah diskon
    ft.price - (ft.price * ft.discount_percentage) AS nett_sales,

    -- Menghitung laba bersih (nett profit)
    (ft.price - (ft.price * ft.discount_percentage)) *
    (CASE
        WHEN ft.price <= 50000 THEN 0.10
        WHEN ft.price > 50000 AND ft.price <= 100000 THEN 0.15
        WHEN ft.price > 100000 AND ft.price <= 300000 THEN 0.20
        WHEN ft.price > 300000 AND ft.price <= 500000 THEN 0.25
        ELSE 0.30
    END) AS nett_profit

 -- Mengambil data dari tabel transaksi
FROM `rakamin-kf-analytics-449018.kimia_farma.kf_final_transaction` AS ft

-- Menggabungkan dengan tabel produk untuk mendapatkan informasi produk
LEFT JOIN `rakamin-kf-analytics-449018.kimia_farma.kf_product` AS cp ON ft.product_id = cp.product_id

-- Menggabungkan dengan tabel inventori untuk mendapatkan jumlah stok
LEFT JOIN `rakamin-kf-analytics-449018.kimia_farma.kf_inventory` AS ci ON ft.product_id = ci.product_id AND ft.branch_id = ci.branch_id

-- Menggabungkan dengan tabel kantor cabang untuk mendapatkan informasi cabang
LEFT JOIN `rakamin-kf-analytics-449018.kimia_farma.kf_kantor_cabang` AS cb ON ft.branch_id = cb.branch_id;
