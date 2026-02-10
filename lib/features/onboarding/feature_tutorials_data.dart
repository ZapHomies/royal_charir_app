import 'package:flutter/material.dart';
import 'feature_tutorial.dart';

/// Data tutorial untuk semua fitur aplikasi
class FeatureTutorials {
  // ============================================
  // DASHBOARD TUTORIAL
  // ============================================
  static List<TutorialStep> get dashboardTutorial => [
        TutorialStep(
          title: 'Selamat Datang di Dashboard',
          description:
              'Dashboard adalah pusat kontrol bisnis Anda. Di sini Anda bisa melihat ringkasan semua aktivitas bisnis dan mengakses semua fitur dengan cepat.',
          icon: Icons.dashboard_rounded,
          color: const Color(0xFF6366F1),
          visualInstruction: const VisualInstruction(
            icon: Icons.home_rounded,
            label: 'Halaman Utama Aplikasi',
          ),
          tips: [
            'Dashboard menampilkan data real-time',
            'Klik kartu statistik untuk detail',
          ],
        ),
        TutorialStep(
          title: 'Kartu Statistik',
          description:
              'Kartu-kartu di bagian atas menampilkan ringkasan penting: total produk, pesanan hari ini, jumlah pelanggan, dan total pendapatan.',
          icon: Icons.analytics_rounded,
          color: const Color(0xFF10B981),
          visualInstruction: const VisualInstruction(
            icon: Icons.grid_view_rounded,
            label: 'Lihat 4 Kartu Statistik di Atas',
            arrow: Icons.arrow_upward_rounded,
          ),
          detailSteps: [
            'Total Produk - Jumlah produk terdaftar',
            'Pesanan Hari Ini - Transaksi hari ini',
            'Pelanggan - Total pelanggan aktif',
            'Pendapatan - Total penjualan',
          ],
        ),
        TutorialStep(
          title: 'Menu Navigasi Samping',
          description:
              'Gunakan sidebar di sebelah kiri untuk berpindah antar menu. Klik ikon untuk membuka menu yang diinginkan.',
          icon: Icons.menu_rounded,
          color: const Color(0xFF8B5CF6),
          visualInstruction: const VisualInstruction(
            icon: Icons.view_sidebar_rounded,
            label: 'Sidebar Menu di Sisi Kiri',
            arrow: Icons.arrow_back_rounded,
          ),
          detailSteps: [
            'Beranda - Kembali ke dashboard',
            'Kasir - Proses transaksi penjualan',
            'Produk - Kelola inventaris',
            'Pelanggan - Data pelanggan',
            'Pesanan - Riwayat transaksi',
            'Laporan - Analisis bisnis',
          ],
        ),
        TutorialStep(
          title: 'Tombol Aksi Cepat',
          description:
              'Di bagian kanan atas terdapat tombol-tombol untuk aksi cepat seperti menambah produk, pelanggan, atau membuat pesanan baru.',
          icon: Icons.touch_app_rounded,
          color: const Color(0xFFF59E0B),
          visualInstruction: const VisualInstruction(
            icon: Icons.add_circle_rounded,
            label: 'Tombol + untuk Aksi Cepat',
          ),
          tips: [
            'Gunakan shortcut untuk produktivitas',
            'Tombol tersedia di setiap halaman',
          ],
        ),
      ];

  // ============================================
  // KASIR/CHECKOUT TUTORIAL
  // ============================================
  static List<TutorialStep> get cashierTutorial => [
        TutorialStep(
          title: 'Cara Menggunakan Kasir',
          description:
              'Menu Kasir digunakan untuk memproses transaksi penjualan dengan cepat dan mudah. Ikuti langkah-langkah berikut.',
          icon: Icons.point_of_sale_rounded,
          color: const Color(0xFF10B981),
          visualInstruction: const VisualInstruction(
            icon: Icons.shopping_cart_checkout_rounded,
            label: 'Proses Transaksi Penjualan',
          ),
        ),
        TutorialStep(
          title: 'Langkah 1: Pilih Produk',
          description:
              'Cari dan pilih produk yang ingin dijual. Anda bisa mencari berdasarkan nama atau kategori.',
          icon: Icons.search_rounded,
          color: const Color(0xFF3B82F6),
          visualInstruction: const VisualInstruction(
            icon: Icons.inventory_2_rounded,
            label: 'Klik Produk untuk Menambahkan',
            arrow: Icons.arrow_downward_rounded,
          ),
          detailSteps: [
            'Gunakan kotak pencarian di atas',
            'Filter berdasarkan kategori',
            'Klik produk untuk menambahkan ke keranjang',
            'Atau scan barcode jika tersedia',
          ],
          tips: [
            'Ketik nama produk untuk pencarian cepat',
            'Produk favorit muncul di atas',
          ],
        ),
        TutorialStep(
          title: 'Langkah 2: Atur Jumlah',
          description:
              'Setelah produk ditambahkan, atur jumlah yang dibeli. Gunakan tombol + dan - atau ketik langsung.',
          icon: Icons.add_shopping_cart_rounded,
          color: const Color(0xFFF59E0B),
          visualInstruction: const VisualInstruction(
            icon: Icons.exposure_rounded,
            label: 'Gunakan + dan - untuk Mengatur Qty',
          ),
          detailSteps: [
            'Klik + untuk menambah jumlah',
            'Klik - untuk mengurangi',
            'Klik angka untuk input manual',
            'Geser ke kiri untuk menghapus item',
          ],
        ),
        TutorialStep(
          title: 'Langkah 3: Pilih Pelanggan',
          description:
              'Pilih pelanggan untuk transaksi. Pelanggan Grosir akan mendapat harga khusus.',
          icon: Icons.person_rounded,
          color: const Color(0xFF8B5CF6),
          visualInstruction: const VisualInstruction(
            icon: Icons.people_rounded,
            label: 'Pilih dari Daftar Pelanggan',
          ),
          detailSteps: [
            'Klik dropdown "Pilih Pelanggan"',
            'Cari nama pelanggan',
            'Pelanggan Grosir = harga grosir otomatis',
            'Atau pilih "Pelanggan Umum"',
          ],
          tips: [
            'Grosir mendapat harga lebih murah',
            'Tambah pelanggan baru jika belum ada',
          ],
        ),
        TutorialStep(
          title: 'Langkah 4: Proses Pembayaran',
          description:
              'Setelah semua item ditambahkan, proses pembayaran dengan memilih metode bayar.',
          icon: Icons.payments_rounded,
          color: const Color(0xFF10B981),
          visualInstruction: const VisualInstruction(
            icon: Icons.receipt_long_rounded,
            label: 'Klik "Bayar" untuk Checkout',
          ),
          detailSteps: [
            'Periksa total belanja',
            'Pilih metode: Tunai atau Hutang',
            'Untuk tunai, masukkan nominal uang',
            'Klik "Proses Pembayaran"',
            'Struk akan otomatis tercetak',
          ],
          tips: [
            'Cek kembalian sebelum proses',
            'Pesanan hutang masuk ke laporan hutang',
          ],
        ),
      ];

  // ============================================
  // PRODUK TUTORIAL
  // ============================================
  static List<TutorialStep> get productTutorial => [
        TutorialStep(
          title: 'Kelola Produk',
          description:
              'Menu Produk untuk mengelola semua barang dagangan Anda. Tambah, edit, dan pantau stok produk.',
          icon: Icons.inventory_2_rounded,
          color: const Color(0xFF3B82F6),
          visualInstruction: const VisualInstruction(
            icon: Icons.category_rounded,
            label: 'Daftar Semua Produk',
          ),
        ),
        TutorialStep(
          title: 'Menambah Produk Baru',
          description:
              'Klik tombol + di pojok kanan bawah untuk menambah produk baru.',
          icon: Icons.add_box_rounded,
          color: const Color(0xFF10B981),
          visualInstruction: const VisualInstruction(
            icon: Icons.add_circle_rounded,
            label: 'Klik Tombol + di Kanan Bawah',
            arrow: Icons.arrow_downward_rounded,
          ),
          detailSteps: [
            'Klik tombol + (Floating Action Button)',
            'Atau klik "Tambah Produk" di header',
            'Form input produk akan terbuka',
          ],
        ),
        TutorialStep(
          title: 'Mengisi Data Produk',
          description:
              'Isi semua informasi produk dengan lengkap untuk memudahkan pencarian dan transaksi.',
          icon: Icons.edit_note_rounded,
          color: const Color(0xFFF59E0B),
          visualInstruction: const VisualInstruction(
            icon: Icons.assignment_rounded,
            label: 'Isi Form Data Produk',
          ),
          detailSteps: [
            'Foto Produk - Klik area foto untuk upload',
            'Nama Produk - Nama yang mudah dicari',
            'Kategori - Pilih atau buat baru',
            'Harga Jual - Harga untuk retail',
            'Harga Grosir - Harga untuk grosir',
            'Stok - Jumlah barang tersedia',
            'Satuan - pcs, kg, meter, dll',
            'Stok Minimum - Batas peringatan',
          ],
          tips: [
            'Foto memudahkan identifikasi produk',
            'Nama deskriptif: "Bantal Silikon 40x60"',
          ],
        ),
        TutorialStep(
          title: 'Mengedit Produk',
          description:
              'Klik produk dari daftar untuk melihat detail dan mengedit informasinya.',
          icon: Icons.edit_rounded,
          color: const Color(0xFF8B5CF6),
          visualInstruction: const VisualInstruction(
            icon: Icons.touch_app_rounded,
            label: 'Klik Produk untuk Edit',
          ),
          detailSteps: [
            'Klik produk dari daftar',
            'Detail produk akan terbuka',
            'Klik ikon edit (pensil)',
            'Ubah data yang diperlukan',
            'Klik Simpan',
          ],
        ),
        TutorialStep(
          title: 'Filter & Pencarian',
          description:
              'Gunakan filter dan pencarian untuk menemukan produk dengan cepat.',
          icon: Icons.filter_list_rounded,
          color: const Color(0xFF06B6D4),
          visualInstruction: const VisualInstruction(
            icon: Icons.search_rounded,
            label: 'Kotak Pencarian di Atas',
          ),
          detailSteps: [
            'Ketik nama produk di kotak pencarian',
            'Filter berdasarkan kategori',
            'Filter stok rendah/habis',
            'Urutkan berdasarkan nama/harga/stok',
          ],
          tips: [
            'Warna merah = stok di bawah minimum',
            'Warna kuning = stok menipis',
          ],
        ),
      ];

  // ============================================
  // PELANGGAN TUTORIAL
  // ============================================
  static List<TutorialStep> get customerTutorial => [
        TutorialStep(
          title: 'Kelola Pelanggan',
          description:
              'Menu Pelanggan untuk menyimpan data pelanggan dan melihat riwayat transaksi mereka.',
          icon: Icons.people_rounded,
          color: const Color(0xFF06B6D4),
          visualInstruction: const VisualInstruction(
            icon: Icons.contacts_rounded,
            label: 'Daftar Semua Pelanggan',
          ),
        ),
        TutorialStep(
          title: 'Jenis Pelanggan',
          description:
              'Ada dua jenis pelanggan: Retail (eceran) dan Grosir. Pelanggan Grosir mendapat harga khusus.',
          icon: Icons.group_rounded,
          color: const Color(0xFF8B5CF6),
          visualInstruction: const VisualInstruction(
            icon: Icons.category_rounded,
            label: 'Retail vs Grosir',
          ),
          detailSteps: [
            'RETAIL - Pelanggan eceran, harga normal',
            'GROSIR - Pelanggan besar, harga grosir',
            'Harga otomatis berubah saat checkout',
          ],
          tips: [
            'Tentukan jenis saat menambah pelanggan',
            'Bisa diubah kapan saja',
          ],
        ),
        TutorialStep(
          title: 'Menambah Pelanggan',
          description:
              'Klik tombol + untuk menambah pelanggan baru dengan data lengkap.',
          icon: Icons.person_add_rounded,
          color: const Color(0xFF10B981),
          visualInstruction: const VisualInstruction(
            icon: Icons.add_circle_rounded,
            label: 'Klik + untuk Tambah',
          ),
          detailSteps: [
            'Klik tombol + di kanan bawah',
            'Isi nama pelanggan (wajib)',
            'Pilih jenis: Retail atau Grosir',
            'Isi nomor telepon (opsional)',
            'Isi alamat (opsional)',
            'Klik Simpan',
          ],
        ),
        TutorialStep(
          title: 'Melihat Hutang Pelanggan',
          description: 'Pantau hutang pelanggan dan riwayat pembayaran mereka.',
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFFEF4444),
          visualInstruction: const VisualInstruction(
            icon: Icons.money_off_rounded,
            label: 'Lihat Saldo Hutang',
          ),
          detailSteps: [
            'Klik pelanggan dari daftar',
            'Lihat total hutang di detail',
            'Tab "Hutang" = daftar transaksi belum lunas',
            'Klik "Bayar Hutang" untuk pelunasan',
          ],
          tips: [
            'Warna merah = ada hutang belum lunas',
            'Kirim reminder via WhatsApp',
          ],
        ),
      ];

  // ============================================
  // PESANAN TUTORIAL
  // ============================================
  static List<TutorialStep> get orderTutorial => [
        TutorialStep(
          title: 'Kelola Pesanan',
          description:
              'Menu Pesanan menampilkan semua transaksi penjualan. Filter berdasarkan status pembayaran dan tanggal.',
          icon: Icons.receipt_long_rounded,
          color: const Color(0xFFF59E0B),
          visualInstruction: const VisualInstruction(
            icon: Icons.list_alt_rounded,
            label: 'Riwayat Semua Transaksi',
          ),
        ),
        TutorialStep(
          title: 'Filter Pesanan',
          description:
              'Gunakan filter untuk melihat pesanan berdasarkan status: Semua, Lunas, atau Belum Lunas.',
          icon: Icons.filter_alt_rounded,
          color: const Color(0xFF3B82F6),
          visualInstruction: const VisualInstruction(
            icon: Icons.tune_rounded,
            label: 'Tombol Filter di Atas',
          ),
          detailSteps: [
            'Semua - Tampilkan semua pesanan',
            'Lunas - Pesanan sudah dibayar',
            'Belum Lunas - Pesanan hutang',
            'Filter tanggal - Pilih rentang waktu',
          ],
        ),
        TutorialStep(
          title: 'Detail Pesanan',
          description:
              'Klik pesanan untuk melihat detail item, total, dan status pembayaran.',
          icon: Icons.info_rounded,
          color: const Color(0xFF8B5CF6),
          visualInstruction: const VisualInstruction(
            icon: Icons.receipt_rounded,
            label: 'Klik untuk Lihat Detail',
          ),
          detailSteps: [
            'Klik pesanan dari daftar',
            'Lihat semua item yang dibeli',
            'Lihat pelanggan dan tanggal',
            'Total pembayaran dan status',
            'Opsi: Cetak struk, Batalkan',
          ],
        ),
        TutorialStep(
          title: 'Cetak Struk/Invoice',
          description: 'Cetak ulang struk atau invoice untuk pesanan tertentu.',
          icon: Icons.print_rounded,
          color: const Color(0xFF10B981),
          visualInstruction: const VisualInstruction(
            icon: Icons.local_printshop_rounded,
            label: 'Tombol Cetak di Detail Pesanan',
          ),
          detailSteps: [
            'Buka detail pesanan',
            'Klik ikon printer',
            'Pilih format: Struk atau Invoice',
            'Preview dan cetak',
          ],
          tips: [
            'Invoice cocok untuk grosir',
            'Struk untuk retail',
          ],
        ),
      ];

  // ============================================
  // LAPORAN TUTORIAL
  // ============================================
  static List<TutorialStep> get reportTutorial => [
        TutorialStep(
          title: 'Menu Laporan',
          description:
              'Analisis performa bisnis dengan berbagai jenis laporan. Export ke Excel untuk analisis lebih lanjut.',
          icon: Icons.bar_chart_rounded,
          color: const Color(0xFF14B8A6),
          visualInstruction: const VisualInstruction(
            icon: Icons.analytics_rounded,
            label: 'Pusat Laporan Bisnis',
          ),
        ),
        TutorialStep(
          title: 'Jenis Laporan',
          description:
              'Tersedia beberapa jenis laporan untuk analisis bisnis yang komprehensif.',
          icon: Icons.assessment_rounded,
          color: const Color(0xFF6366F1),
          visualInstruction: const VisualInstruction(
            icon: Icons.library_books_rounded,
            label: 'Pilih Jenis Laporan',
          ),
          detailSteps: [
            'Laporan Penjualan - Pendapatan harian/bulanan',
            'Laporan Stok - Nilai dan pergerakan stok',
            'Produk Terlaris - Produk paling banyak terjual',
            'Laporan Hutang - Daftar piutang pelanggan',
            'Laporan Keuangan - Ringkasan profit/loss',
          ],
        ),
        TutorialStep(
          title: 'Filter Periode',
          description:
              'Pilih rentang tanggal untuk melihat laporan periode tertentu.',
          icon: Icons.date_range_rounded,
          color: const Color(0xFFF59E0B),
          visualInstruction: const VisualInstruction(
            icon: Icons.calendar_month_rounded,
            label: 'Pilih Tanggal Mulai & Akhir',
          ),
          detailSteps: [
            'Klik "Dari Tanggal" - Tanggal mulai',
            'Klik "Sampai Tanggal" - Tanggal akhir',
            'Atau pilih preset: Hari ini, Minggu ini, Bulan ini',
            'Klik "Terapkan" untuk filter',
          ],
        ),
        TutorialStep(
          title: 'Export Laporan',
          description:
              'Export laporan ke file Excel atau PDF untuk dokumentasi dan analisis lebih lanjut.',
          icon: Icons.file_download_rounded,
          color: const Color(0xFF10B981),
          visualInstruction: const VisualInstruction(
            icon: Icons.table_chart_rounded,
            label: 'Klik Export untuk Download',
          ),
          detailSteps: [
            'Pilih jenis laporan yang diinginkan',
            'Atur periode/filter',
            'Klik tombol "Export"',
            'Pilih format: Excel (.xlsx) atau PDF',
            'File akan tersimpan di folder Download',
          ],
          tips: [
            'Excel cocok untuk analisis lanjutan',
            'PDF cocok untuk cetak/arsip',
          ],
        ),
      ];

  // ============================================
  // BAHAN BAKU TUTORIAL
  // ============================================
  static List<TutorialStep> get materialTutorial => [
        TutorialStep(
          title: 'Kelola Bahan Baku',
          description:
              'Menu ini untuk mengelola bahan baku produksi. Pantau stok kain, silicon, spon, dan bahan lainnya.',
          icon: Icons.layers_rounded,
          color: const Color(0xFFEC4899),
          visualInstruction: const VisualInstruction(
            icon: Icons.inventory_rounded,
            label: 'Daftar Bahan Produksi',
          ),
        ),
        TutorialStep(
          title: 'Menambah Bahan',
          description: 'Klik tombol + untuk mendaftarkan bahan baku baru.',
          icon: Icons.add_circle_rounded,
          color: const Color(0xFF10B981),
          visualInstruction: const VisualInstruction(
            icon: Icons.add_box_rounded,
            label: 'Tambah Bahan Baru',
          ),
          detailSteps: [
            'Klik tombol + di kanan bawah',
            'Isi nama bahan (contoh: Kain Katun)',
            'Pilih satuan: meter, kg, lembar, dll',
            'Isi stok awal',
            'Set stok minimum untuk peringatan',
            'Isi harga per satuan (opsional)',
            'Isi nama supplier (opsional)',
            'Klik Simpan',
          ],
        ),
        TutorialStep(
          title: 'Menambah/Mengurangi Stok',
          description:
              'Catat penambahan stok (pembelian) atau pengurangan (pemakaian produksi).',
          icon: Icons.swap_vert_rounded,
          color: const Color(0xFFF59E0B),
          visualInstruction: const VisualInstruction(
            icon: Icons.exposure_rounded,
            label: 'Klik + atau - pada Item',
          ),
          detailSteps: [
            'Klik tombol + = Bahan Masuk (pembelian)',
            'Klik tombol - = Bahan Keluar (produksi)',
            'Isi jumlah yang masuk/keluar',
            'Isi catatan alasan (opsional)',
            'Klik Simpan',
          ],
          tips: [
            'Catat setiap pembelian bahan',
            'Catat pemakaian untuk produksi',
            'Riwayat tercatat otomatis',
          ],
        ),
        TutorialStep(
          title: 'Peringatan Stok',
          description:
              'Sistem akan memberi peringatan saat stok bahan di bawah minimum.',
          icon: Icons.warning_rounded,
          color: const Color(0xFFEF4444),
          visualInstruction: const VisualInstruction(
            icon: Icons.notification_important_rounded,
            label: 'Warna Merah = Stok Rendah',
          ),
          tips: [
            'Set stok minimum yang realistis',
            'Perhatikan lead time supplier',
            'Segera order saat muncul peringatan',
          ],
        ),
      ];

  // ============================================
  // SYNC & BACKUP TUTORIAL
  // ============================================
  static List<TutorialStep> get syncTutorial => [
        TutorialStep(
          title: 'Backup & Sinkronisasi',
          description:
              'Menu penting untuk mengamankan data bisnis Anda. Backup rutin sangat disarankan!',
          icon: Icons.cloud_sync_rounded,
          color: const Color(0xFF3B82F6),
          visualInstruction: const VisualInstruction(
            icon: Icons.backup_rounded,
            label: 'Amankan Data Bisnis Anda',
          ),
          tips: [
            'WAJIB backup minimal seminggu sekali',
            'Simpan backup di USB/cloud',
            'Jangan simpan hanya di komputer ini',
          ],
        ),
        TutorialStep(
          title: 'Buat Backup',
          description: 'Export seluruh database ke file untuk backup keamanan.',
          icon: Icons.save_rounded,
          color: const Color(0xFF10B981),
          visualInstruction: const VisualInstruction(
            icon: Icons.file_download_rounded,
            label: 'Klik "Backup Database"',
          ),
          detailSteps: [
            'Klik "Backup Database"',
            'Pilih lokasi penyimpanan',
            'Beri nama file dengan tanggal',
            'Contoh: backup_2026-02-10.db',
            'Simpan ke USB atau folder cloud',
          ],
          tips: [
            'Simpan 3 versi backup terakhir',
            'Backup sebelum update aplikasi',
          ],
        ),
        TutorialStep(
          title: 'Restore Backup',
          description: 'Pulihkan data dari file backup jika terjadi masalah.',
          icon: Icons.restore_rounded,
          color: const Color(0xFFEF4444),
          visualInstruction: const VisualInstruction(
            icon: Icons.upload_file_rounded,
            label: 'HATI-HATI: Akan Mengganti Data',
          ),
          detailSteps: [
            'Klik "Restore Database"',
            'Pilih file backup (.db)',
            'PERINGATAN: Data saat ini akan hilang!',
            'Konfirmasi restore',
            'Tunggu proses selesai',
            'Restart aplikasi',
          ],
          tips: [
            'Backup dulu data saat ini!',
            'Pastikan file backup valid',
            'Gunakan untuk migrasi ke PC baru',
          ],
        ),
        TutorialStep(
          title: 'Export Data Selektif',
          description: 'Export data tertentu saja tanpa mengganggu database.',
          icon: Icons.file_copy_rounded,
          color: const Color(0xFF8B5CF6),
          visualInstruction: const VisualInstruction(
            icon: Icons.checklist_rounded,
            label: 'Pilih Data yang Ingin Export',
          ),
          detailSteps: [
            'Klik "Export Data"',
            'Pilih jenis data: Produk, Pelanggan, dll',
            'Pilih format: JSON atau Excel',
            'Klik Export',
            'File tersimpan di Download',
          ],
          tips: [
            'Cocok untuk kirim data ke cabang lain',
            'Excel bisa diedit di spreadsheet',
          ],
        ),
      ];
}
