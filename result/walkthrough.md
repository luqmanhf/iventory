# Walkthrough: Redesain Dark UI, Live Camera Scan, Kuantitas Stok Dinamis & Integrasi Foto Persisten

Implementasi pembaruan menyeluruh untuk aplikasi **Iventory** telah selesai dieksekusi secara penuh sesuai visual referensi [imageplan/](file:///home/maspati/Dokumen/iventory/imageplan/), perbaikan atas keluhan foto statis kardus, serta dua kebutuhan kunci pengguna:
1. **Angka Produksi & Stok Dinamis**: Seluruh kuantitas barang dan metrik ringkasan dapat diedit kapan saja dan langsung terhitung otomatis (*reactive state*).
2. **Foto Hasil Simpan Ditampilkan Permanen**: Foto jepretan kamera disimpan di memori persisten dan ditampilkan baik pada thumbnail maupun layar detail stok di Dashboard dan Inventory.

---

## 1. Rincian Fitur & Pembaruan yang Diimplementasikan

### A. Tampilan Baru Dark Theme Modern (Presisi Sesuai `imageplan/`)

1. **Dashboard Screen** ([dashboard_screen.dart](file:///home/maspati/Dokumen/iventory/lib/features/dashboard/dashboard_screen.dart) — Sesuai [image.png](file:///home/maspati/Dokumen/iventory/imageplan/image.png)):
   - **Header**: Profil avatar pengguna dengan nama **Budi**, tombol toggle dark mode (ikon bulan), dan tombol notifikasi lonceng dengan indikator badge.
   - **Search Bar**: Kotak pencarian melengkung dengan placeholder *"Search..."* dan ikon kaca pembesar.
   - **Kartu Metrik 3 Kolom Dinamis**:
     - `SALE STOCK (i)`: Dihitung secara dinamis dari stok barang siap jual.
     - `LOW STOCK (i)`: Dihitung secara dinamis dari barang dengan stok menipis (<= 100).
     - `TOTAL ITEMS (i)`: Total akumulasi seluruh kuantitas stok di gudang.
   - **Section Dashboard**: Judul *"Dashboard"* dengan badge counter total barang.
   - **Daftar Aktivitas Stok**:
     - Thumbnail foto asli produk (atau pola grid jika belum ada foto).
     - Nama komoditas (*Beras*, *Minyak Goreng*, *Gandum*, *Telur*).
     - Subtitle petugas & waktu update (*Luqman | 8:30 AM*, *Budi Santoso | 1:15 PM*).
     - Checkbox interaktif di sisi kanan.
     - **Klik Item**: Membuka modal detail stok untuk melihat foto ukuran penuh dan mengedit jumlah stok.

2. **Scan Products Screen** ([scan_products_screen.dart](file:///home/maspati/Dokumen/iventory/lib/features/scan/scan_products_screen.dart) — Sesuai [image copy.png](file:///home/maspati/Dokumen/iventory/imageplan/image%20copy.png)):
   - **Header**: Tombol silang `[X]` dan judul *"Scan"*.
   - **Live Camera Viewfinder**:
     - Menggunakan hardware sensor kamera perangkat melalui package resmi `camera`.
     - Tidak lagi menggunakan ilustrasi kubus/kardus statis.
     - Dilengkapi viewport live camera stream, animasi laser pemindai biru, dan bounding box deteksi objek AI YOLOv8.
     - Didukung fallback viewport interaktif jika dijalankan pada simulator/desktop tanpa hardware kamera fisik.
   - **Tombol Aksi Bawah**:
     - Tombol **FOTO** (lebar, `#707BFB`): Mengambil jepretan kamera riil (`takePicture()`), menghitung objek dengan AI YOLOv8, dan memunculkan modal konfirmasi untuk menyimpan foto serta menentukan jumlah stok.
     - Tombol **Lokasi** (`#8D99EE`): Membuka panel sheet audit Anti-Fake GPS ([gps_audit_modal.dart](file:///home/maspati/Dokumen/iventory/lib/features/scan/widgets/gps_audit_modal.dart)) yang menampilkan koordinat satelit GPS, status akurasi, deteksi mock location, tanda tangan digital SHA-256, dan opsi pengujian simulasi fake GPS.

3. **Inventory Screen** ([inventory_screen.dart](file:///home/maspati/Dokumen/iventory/lib/features/inventory/inventory_screen.dart) — Sesuai [image copy 2.png](file:///home/maspati/Dokumen/iventory/imageplan/image%20copy%202.png)):
   - **Header**: Tombol kembali `[<]` dan judul *"Inventory"*.
   - **Filter Chips**: `✓ All Items`, `Low Stock`, `Sale Stock`.
   - **Kartu Metrik 3 Kolom Dinamis**:
     - `OUT OF STOCK (i)`: Jumlah item dengan stok 0.
     - `LOW STOCK (i)`: Jumlah item dengan stok menipis.
     - `TOTAL ITEMS (i)`: Total kuantitas seluruh stok barang aktif.
   - **Section ACTIVE INVENTORY**: Subheader dengan badge total dinamis dan aksi *"Export CSV >"*.
   - **Daftar Kartu Barang**:
     - Thumbnail foto asli produk yang tersimpan di memori.
     - Nama komoditas (*Coca Cola*, *Doritos*, *Lass*, *KitKat*, dan produk hasil scan baru).
     - Detail lokasi gudang dan kategori (*Beverages · Warehouse A*, *Snacks · Warehouse B*, dll.).
     - Detail kemasan dan tanggal kadaluarsa (*450 cases · 12 oz cans · Exp 08/27*).
     - Trailing chevron `>` yang jika diklik membuka dialog edit kuantitas dan tampilan foto penuh.
   - **Fitur Export CSV**: Menghasilkan data format `.csv` dari seluruh inventaris terkini.

---

### B. Kebutuhan 1: Angka Produksi & Kuantitas Stok Dinamis
- Diimplementasikan pada [inventory_repository.dart](file:///home/maspati/Dokumen/iventory/lib/core/repository/inventory_repository.dart) berbasis `ChangeNotifier`.
- Saat pengguna mengedit kuantitas barang melalui stepper `+` / `-` atau input teks di modal [item_detail_edit_modal.dart](file:///home/maspati/Dokumen/iventory/lib/features/inventory/widgets/item_detail_edit_modal.dart):
  1. Method `updateItemQuantity(itemId, newQuantity)` dipanggil.
  2. `notifyListeners()` seketika memicu pembaruan reaktif.
  3. Seluruh angka metrik di Dashboard (`SALE STOCK`, `LOW STOCK`, `TOTAL ITEMS`) dan Inventory (`OUT OF STOCK`, `LOW STOCK`, `TOTAL ITEMS`) otomatis terhitung ulang secara real-time tanpa perlu me-reload aplikasi.

---

### C. Kebutuhan 2: Integrasi & Tampilan Foto Persisten
- Setiap jepretan foto kamera yang diambil di layar Scan disimpan secara fisik ke folder dokumen aplikasi (`/inventory_photos/IMG_<timestamp>.jpg`).
- Path gambar (`imagePath`) ditautkan ke objek data [inventory_item.dart](file:///home/maspati/Dokumen/iventory/lib/core/models/inventory_item.dart).
- **Tampilan Thumbnail**: Thumbnail pada Dashboard dan Inventory menampilkan gambar asli (`Image.file(File(item.imagePath!))`).
- **Tampilan Penuh di Detail Stok**: Modal detail stok menampilkan gambar ukuran besar (200px height) dengan sudut melengkung dan border rapi.
- Disediakan generator sampel foto otomatis pada *seed items* awal sehingga seluruh barang langsung memiliki foto yang siap ditampilkan sejak pertama kali dibuka.

---

## 2. Hasil Verifikasi & Pengujian

### A. Analisis Statis (Flutter Analyzer)
```bash
$ export HOME=/tmp; flutter analyze
Analyzing iventory...
No issues found! (ran in 5.7s)
```
- **0 Errors**, **0 Warnings**, **0 Linter Issues**.

### B. Suite Pengujian Unit & Widget (Flutter Test)
```bash
$ export HOME=/tmp; flutter test
00:00 +0: /test/gps_security_test.dart: Verifies trusted GPS coordinates by default
00:01 +1: /test/gps_security_test.dart: Flags mock location as UNTRUSTED WARNING when Fake GPS is active
00:01 +2: /test/yolo_counter_test.dart: Eliminates overlapping redundant boxes using NMS
00:01 +3: /test/widget_test.dart: Iventory app loads Dark UI Dashboard with dynamic metrics and items
00:01 +4: /test/widget_test.dart: InventoryRepository updates stock quantity dynamically and recalculates metrics
00:01 +5: All tests passed!
```
- **100% Pengujian Berhasil Lolos (All tests passed)**.

---

## 3. Berkas yang Diperbarui & Ditambahkan

```
iventory/
├── lib/
│   ├── main.dart                                                  # Entrypoint dengan Dark Theme
│   ├── core/
│   │   ├── theme/app_theme.dart                                   # Dark Theme palette & style
│   │   ├── models/inventory_item.dart                             # Model data stok dinamis + foto
│   │   ├── repository/inventory_repository.dart                   # Reactive state store & agregasi metrik
│   │   ├── security/gps_security_service.dart                     # Anti-fake GPS & digital signature
│   │   └── ai/yolo_counter_service.dart                           # YOLOv8 object counter & NMS
│   └── features/
│       ├── navigation/main_navigation_shell.dart                  # Bottom navigation 3-tab (Home, Scan, Inventory)
│       ├── dashboard/dashboard_screen.dart                        # Screen 1 (Dashboard Budi)
│       ├── scan/
│       │   ├── scan_products_screen.dart                          # Screen 2 (Live camera viewfinder, FOTO & Lokasi)
│       │   └── widgets/
│       │       ├── gps_audit_modal.dart                           # Modal audit anti-fake GPS
│       │       └── scan_confirm_save_modal.dart                   # Modal konfirmasi hasil pindaian foto
│       └── inventory/
│           ├── inventory_screen.dart                              # Screen 3 (Active inventory & filter chips)
│           └── widgets/
│               └── item_detail_edit_modal.dart                    # Modal detail foto & edit kuantitas stok dinamis
├── android/app/src/main/AndroidManifest.xml                       # Izin CAMERA & GPS
├── pubspec.yaml                                                   # Penambahan dependensi camera
└── test/
    └── widget_test.dart                                           # Widget & dynamic repository unit tests
```
