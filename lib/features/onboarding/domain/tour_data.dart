import 'package:flutter/material.dart';
import '../presentation/widgets/tutorial_overlay.dart';

/// Data tour untuk halaman Dashboard
class DashboardTourData {
  /// Langkah-langkah tour dashboard
  static List<TutorialTarget> getSteps({
    GlobalKey? statsKey,
    GlobalKey? sidebarKey,
    GlobalKey? inventoryKey,
    GlobalKey? cashierKey,
    GlobalKey? customersKey,
    GlobalKey? ordersKey,
    GlobalKey? reportsKey,
    GlobalKey? syncKey,
    GlobalKey? searchKey,
    GlobalKey? themeKey,
  }) {
    return [
      TutorialTarget(
        title: 'Selamat Datang di Dashboard! 🏠',
        description: 'Ini adalah pusat kontrol bisnis Anda. '
            'Di sini Anda bisa melihat ringkasan semua aktivitas bisnis '
            'dan mengakses semua fitur dengan cepat.',
        targetKey: null, // Full screen intro
        icon: Icons.dashboard_rounded,
        color: const Color(0xFF6366F1),
        tips: [
          'Pantau statistik bisnis real-time',
          'Akses cepat ke semua menu',
          'Lihat notifikasi penting',
        ],
      ),
      TutorialTarget(
        title: 'Kartu Statistik 📊',
        description:
            'Kartu-kartu ini menampilkan ringkasan penting bisnis Anda: '
            'total produk, pesanan hari ini, pelanggan aktif, dan pendapatan.',
        targetKey: statsKey,
        icon: Icons.analytics_rounded,
        color: const Color(0xFF10B981),
        tips: [
          'Klik kartu untuk detail lengkap',
          'Data diperbarui secara real-time',
          'Warna menunjukkan status (hijau = baik)',
        ],
      ),
      TutorialTarget(
        title: 'Menu Navigasi 📌',
        description: 'Gunakan sidebar ini untuk berpindah antar menu utama. '
            'Klik ikon untuk membuka menu yang diinginkan.',
        targetKey: sidebarKey,
        icon: Icons.menu_rounded,
        color: const Color(0xFF8B5CF6),
        tips: [
          'Sidebar bisa diciutkan/dilebarkan',
          'Menu aktif ditandai dengan highlight',
          'Hover untuk melihat nama menu',
        ],
      ),
      TutorialTarget(
        title: 'Menu Produk 📦',
        description: 'Kelola semua produk Anda di sini. Tambah produk baru, '
            'edit harga, atur stok minimum, dan pantau ketersediaan barang.',
        targetKey: inventoryKey,
        icon: Icons.inventory_2_rounded,
        color: const Color(0xFFF59E0B),
        tips: [
          'Tambah produk dengan foto',
          'Atur kategori untuk organisasi',
          'Peringatan stok rendah otomatis',
        ],
      ),
      TutorialTarget(
        title: 'Menu Kasir ⚡',
        description: 'Proses transaksi penjualan dengan cepat! '
            'Pilih produk, tentukan jumlah, pilih pelanggan, dan checkout.',
        targetKey: cashierKey,
        icon: Icons.point_of_sale_rounded,
        color: const Color(0xFFEC4899),
        tips: [
          'Scan barcode untuk input cepat',
          'Pilih pelanggan untuk harga khusus',
          'Cetak struk otomatis',
        ],
      ),
      TutorialTarget(
        title: 'Menu Pelanggan 👥',
        description: 'Simpan data pelanggan lengkap dengan riwayat pembelian. '
            'Bedakan pelanggan retail dan grosir.',
        targetKey: customersKey,
        icon: Icons.people_rounded,
        color: const Color(0xFF06B6D4),
        tips: [
          'Kelola hutang pelanggan',
          'Lihat riwayat transaksi',
          'Atur harga khusus per pelanggan',
        ],
      ),
      TutorialTarget(
        title: 'Menu Pesanan 📝',
        description: 'Pantau semua pesanan dari proses hingga selesai. '
            'Filter berdasarkan status pembayaran dan tanggal.',
        targetKey: ordersKey,
        icon: Icons.receipt_long_rounded,
        color: const Color(0xFFEF4444),
        tips: [
          'Filter: Lunas, Belum Lunas, Proses',
          'Cetak invoice & surat jalan',
          'Tandai pesanan selesai',
        ],
      ),
      TutorialTarget(
        title: 'Menu Laporan 📈',
        description: 'Analisis performa bisnis dengan berbagai laporan. '
            'Export ke Excel untuk analisis lebih lanjut.',
        targetKey: reportsKey,
        icon: Icons.analytics_rounded,
        color: const Color(0xFF14B8A6),
        tips: [
          'Laporan penjualan harian/bulanan',
          'Laporan stok & produk terlaris',
          'Export PDF & Excel',
        ],
      ),
      TutorialTarget(
        title: 'Pencarian Cepat 🔍',
        description: 'Gunakan fitur pencarian untuk menemukan produk, '
            'pelanggan, atau pesanan dengan cepat.',
        targetKey: searchKey,
        icon: Icons.search_rounded,
        color: const Color(0xFF3B82F6),
        tips: [
          'Ketik nama atau kode produk',
          'Hasil muncul langsung saat mengetik',
          'Tekan Enter untuk pencarian lengkap',
        ],
      ),
      TutorialTarget(
        title: 'Mode Gelap/Terang 🌓',
        description: 'Sesuaikan tampilan sesuai preferensi Anda. '
            'Mode gelap nyaman untuk bekerja di malam hari.',
        targetKey: themeKey,
        icon: Icons.dark_mode_rounded,
        color: const Color(0xFF6366F1),
        tips: [
          'Klik ikon untuk toggle',
          'Pilihan tersimpan otomatis',
          'Mode gelap hemat mata & baterai',
        ],
      ),
      TutorialTarget(
        title: 'Tutorial Selesai! 🎉',
        description: 'Selamat! Anda sudah memahami dasar-dasar Dashboard. '
            'Jelajahi setiap menu untuk tutorial lebih lanjut. '
            'Anda bisa mengulang tutorial ini kapan saja dari Pengaturan.',
        targetKey: null,
        icon: Icons.celebration_rounded,
        color: const Color(0xFF10B981),
        tips: [
          'Coba tambah produk pertama Anda',
          'Input data pelanggan',
          'Lakukan transaksi percobaan',
        ],
      ),
    ];
  }
}

/// Data tour untuk input produk
class ProductTourData {
  static List<TutorialTarget> getSteps({
    GlobalKey? imageKey,
    GlobalKey? nameKey,
    GlobalKey? categoryKey,
    GlobalKey? priceKey,
    GlobalKey? stockKey,
    GlobalKey? saveKey,
  }) {
    return [
      TutorialTarget(
        title: 'Cara Menambah Produk 📦',
        description: 'Mari pelajari cara menambahkan produk baru ke sistem. '
            'Ikuti langkah-langkah berikut untuk input produk dengan benar.',
        targetKey: null,
        icon: Icons.add_box_rounded,
        color: const Color(0xFF6366F1),
        tips: [
          'Siapkan foto produk',
          'Tentukan kategori yang sesuai',
          'Pastikan harga sudah benar',
        ],
      ),
      TutorialTarget(
        title: 'Langkah 1: Foto Produk 📸',
        description: 'Klik area ini untuk menambahkan foto produk. '
            'Foto yang menarik memudahkan identifikasi produk saat transaksi.',
        targetKey: imageKey,
        icon: Icons.camera_alt_rounded,
        color: const Color(0xFF8B5CF6),
        tips: [
          'Gunakan foto berkualitas baik',
          'Background polos lebih baik',
          'Ukuran maksimal 5MB',
        ],
      ),
      TutorialTarget(
        title: 'Langkah 2: Nama Produk ✏️',
        description: 'Masukkan nama produk yang jelas dan mudah dicari. '
            'Nama ini akan muncul di kasir dan laporan.',
        targetKey: nameKey,
        icon: Icons.edit_rounded,
        color: const Color(0xFFF59E0B),
        tips: [
          'Gunakan nama yang deskriptif',
          'Contoh: "Bantal Silikon Premium 40x60"',
          'Hindari singkatan yang membingungkan',
        ],
      ),
      TutorialTarget(
        title: 'Langkah 3: Kategori 🏷️',
        description: 'Pilih kategori dari dropdown atau buat kategori baru. '
            'Kategori membantu mengorganisir produk dengan baik.',
        targetKey: categoryKey,
        icon: Icons.category_rounded,
        color: const Color(0xFF10B981),
        tips: [
          'Pilih dari kategori yang ada',
          'Atau buat kategori baru',
          'Contoh: Bantal, Guling, Kasur',
        ],
      ),
      TutorialTarget(
        title: 'Langkah 4: Harga 💰',
        description: 'Atur harga jual dan harga grosir. '
            'Harga grosir digunakan untuk pelanggan dengan tipe Grosir.',
        targetKey: priceKey,
        icon: Icons.payments_rounded,
        color: const Color(0xFFEC4899),
        tips: [
          'Harga jual = harga normal/eceran',
          'Harga grosir = harga khusus quantity',
          'Masukkan angka tanpa titik/koma',
        ],
      ),
      TutorialTarget(
        title: 'Langkah 5: Stok 📊',
        description: 'Set jumlah stok awal dan stok minimum. '
            'Sistem akan memberi peringatan saat stok menipis.',
        targetKey: stockKey,
        icon: Icons.inventory_rounded,
        color: const Color(0xFF06B6D4),
        tips: [
          'Stok = jumlah barang tersedia',
          'Min. Stok = batas peringatan',
          'Pilih satuan yang sesuai',
        ],
      ),
      TutorialTarget(
        title: 'Langkah 6: Simpan ✅',
        description:
            'Setelah semua data terisi, klik tombol ini untuk menyimpan. '
            'Produk akan langsung tersedia di menu Kasir.',
        targetKey: saveKey,
        icon: Icons.save_rounded,
        color: const Color(0xFF10B981),
        tips: [
          'Pastikan data sudah benar',
          'Wajib: Nama, Kategori, Harga, Stok',
          'Produk bisa diedit kapan saja',
        ],
      ),
    ];
  }
}

/// Data tour untuk menu Bahan
class MaterialTourData {
  static List<TutorialTarget> getSteps() {
    return [
      TutorialTarget(
        title: 'Kelola Bahan Baku 🧵',
        description: 'Menu ini untuk mengelola bahan baku produksi. '
            'Pantau stok kain, silicon, spon, dan bahan lainnya.',
        targetKey: null,
        icon: Icons.layers_rounded,
        color: const Color(0xFFEC4899),
        tips: [
          'Catat semua bahan yang digunakan',
          'Pantau stok minimum',
          'Hitung nilai inventaris bahan',
        ],
      ),
      TutorialTarget(
        title: 'Tambah Bahan Baru ➕',
        description: 'Klik tombol + untuk menambah bahan baru. '
            'Isi nama, satuan, stok awal, dan harga per satuan.',
        targetKey: null,
        icon: Icons.add_circle_rounded,
        color: const Color(0xFF10B981),
        tips: [
          'Satuan: meter, kg, lembar, dll',
          'Catat supplier untuk referensi',
          'Set stok minimum untuk peringatan',
        ],
      ),
      TutorialTarget(
        title: 'Atur Stok Bahan 📦',
        description:
            'Gunakan tombol + dan - untuk menambah atau mengurangi stok. '
            'Cocok untuk mencatat pembelian atau pemakaian bahan.',
        targetKey: null,
        icon: Icons.swap_vert_rounded,
        color: const Color(0xFFF59E0B),
        tips: [
          '+ untuk bahan masuk (pembelian)',
          '- untuk bahan keluar (produksi)',
          'Riwayat perubahan tercatat',
        ],
      ),
    ];
  }
}

/// Data tour untuk Sync & Backup
class SyncTourData {
  static List<TutorialTarget> getSteps() {
    return [
      TutorialTarget(
        title: 'Backup & Sinkronisasi 🔄',
        description: 'Amankan data bisnis Anda dengan backup rutin. '
            'Sinkronkan data antar komputer dalam perusahaan yang sama.',
        targetKey: null,
        icon: Icons.cloud_sync_rounded,
        color: const Color(0xFF3B82F6),
        tips: [
          'Backup rutin sangat penting!',
          'Simpan di USB/cloud untuk keamanan',
          'Sinkronkan antar perangkat',
        ],
      ),
      TutorialTarget(
        title: 'Export Data 📤',
        description:
            'Pilih data yang ingin diexport: produk, pelanggan, pesanan, dll. '
            'Export dalam format JSON atau database lengkap.',
        targetKey: null,
        icon: Icons.upload_file_rounded,
        color: const Color(0xFF10B981),
        tips: [
          'Export Selektif = pilih data tertentu',
          'Export Lengkap = seluruh database',
          'Simpan ke USB/folder bersama',
        ],
      ),
      TutorialTarget(
        title: 'Import & Gabungkan 📥',
        description:
            'Import data dari komputer lain TANPA menghapus data yang ada. '
            'Data baru akan ditambahkan, yang sudah ada dilewati.',
        targetKey: null,
        icon: Icons.merge_rounded,
        color: const Color(0xFF8B5CF6),
        tips: [
          'Data lama TIDAK akan hilang',
          'Hanya data baru yang ditambahkan',
          'Cocok untuk sinkronisasi antar toko',
        ],
      ),
      TutorialTarget(
        title: 'Restore Database ⚠️',
        description: 'HATI-HATI! Ini akan mengganti SELURUH database. '
            'Gunakan hanya untuk memulihkan dari backup lengkap.',
        targetKey: null,
        icon: Icons.restore_rounded,
        color: const Color(0xFFEF4444),
        tips: [
          'Data saat ini akan HILANG!',
          'Buat backup dulu sebelum restore',
          'Gunakan untuk migrasi ke PC baru',
        ],
      ),
    ];
  }
}
