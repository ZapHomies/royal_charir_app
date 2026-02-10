import 'package:flutter/material.dart';

/// Model untuk setiap langkah onboarding
class OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String? lottieAsset;
  final List<String> tips;

  const OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.lottieAsset,
    this.tips = const [],
  });
}

/// Data onboarding untuk aplikasi Royal Charir
class OnboardingData {
  static const List<OnboardingStep> steps = [
    OnboardingStep(
      title: 'Selamat Datang di Royal Charir! 👋',
      description: 'Aplikasi manajemen inventaris dan penjualan yang dirancang '
          'khusus untuk membantu bisnis Anda berkembang. '
          'Mari kita jelajahi fitur-fitur unggulan bersama!',
      icon: Icons.store_rounded,
      color: Color(0xFF6366F1),
      tips: [
        '✨ Mudah digunakan',
        '📊 Laporan lengkap',
        '💰 Kelola keuangan',
        '📦 Pantau stok real-time',
      ],
    ),
    OnboardingStep(
      title: 'Dashboard Cerdas 📊',
      description: 'Lihat ringkasan bisnis Anda dalam satu pandangan! '
          'Dashboard menampilkan statistik penting seperti total produk, '
          'pesanan hari ini, dan pelanggan aktif.',
      icon: Icons.dashboard_rounded,
      color: Color(0xFF10B981),
      tips: [
        '📈 Statistik real-time',
        '🔔 Notifikasi stok rendah',
        '💵 Total pendapatan harian',
        '📋 Pesanan terbaru',
      ],
    ),
    OnboardingStep(
      title: 'Kasir Super Cepat ⚡',
      description: 'Proses transaksi penjualan dengan cepat dan mudah! '
          'Cukup pilih produk, tentukan jumlah, dan checkout. '
          'Mendukung berbagai metode pembayaran.',
      icon: Icons.point_of_sale_rounded,
      color: Color(0xFFF59E0B),
      tips: [
        '🛒 Tambah produk cepat',
        '💳 Multi metode bayar',
        '🧾 Cetak struk otomatis',
        '👥 Pilih pelanggan',
      ],
    ),
    OnboardingStep(
      title: 'Kelola Produk dengan Mudah 📦',
      description: 'Tambah, edit, dan kelola semua produk Anda di satu tempat. '
          'Lengkap dengan foto, kategori, harga grosir, dan pengaturan stok minimum.',
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF8B5CF6),
      tips: [
        '📸 Foto produk',
        '🏷️ Kategori otomatis',
        '💲 Harga eceran & grosir',
        '⚠️ Peringatan stok rendah',
      ],
    ),
    OnboardingStep(
      title: 'Kelola Bahan Baku 🧵',
      description:
          'Pantau persediaan bahan baku seperti kain, silicon, spon, dan lainnya. '
          'Dapatkan notifikasi saat stok menipis agar produksi tetap lancar.',
      icon: Icons.layers_rounded,
      color: Color(0xFFEC4899),
      tips: [
        '📦 Catat semua bahan',
        '📉 Monitor stok minimum',
        '💰 Hitung nilai inventaris',
        '🏭 Info supplier',
      ],
    ),
    OnboardingStep(
      title: 'Data Pelanggan Terorganisir 👥',
      description: 'Simpan data pelanggan lengkap dengan riwayat transaksi. '
          'Bedakan pelanggan retail dan grosir dengan harga khusus masing-masing.',
      icon: Icons.people_rounded,
      color: Color(0xFF06B6D4),
      tips: [
        '📇 Database pelanggan',
        '🏪 Retail & Grosir',
        '📜 Riwayat pembelian',
        '💳 Kelola hutang',
      ],
    ),
    OnboardingStep(
      title: 'Pesanan & Hutang Terkendali 📝',
      description: 'Kelola semua pesanan dari mulai proses hingga selesai. '
          'Pantau status pembayaran dan hutang pelanggan dengan mudah.',
      icon: Icons.receipt_long_rounded,
      color: Color(0xFFEF4444),
      tips: [
        '📋 Status pesanan jelas',
        '💰 Cicilan & hutang',
        '✅ Tandai lunas otomatis',
        '📊 Filter & pencarian',
      ],
    ),
    OnboardingStep(
      title: 'Laporan Bisnis Lengkap 📈',
      description: 'Analisis performa bisnis dengan berbagai laporan: '
          'penjualan, stok, keuntungan, dan banyak lagi. '
          'Export ke Excel untuk analisis lebih lanjut!',
      icon: Icons.analytics_rounded,
      color: Color(0xFF14B8A6),
      tips: [
        '📊 Grafik interaktif',
        '📅 Filter tanggal',
        '📥 Export Excel',
        '🖨️ Cetak laporan',
      ],
    ),
    OnboardingStep(
      title: 'Backup & Sinkronisasi 🔄',
      description: 'Amankan data bisnis Anda dengan backup rutin. '
          'Sinkronkan data antar perangkat tanpa kehilangan informasi penting.',
      icon: Icons.cloud_sync_rounded,
      color: Color(0xFF3B82F6),
      tips: [
        '💾 Backup otomatis',
        '🔄 Import & gabungkan',
        '📤 Export selektif',
        '🔒 Data aman',
      ],
    ),
    OnboardingStep(
      title: 'Siap Memulai! 🚀',
      description: 'Selamat! Anda sudah siap menggunakan Royal Charir. '
          'Jika ada pertanyaan, kunjungi menu Bantuan atau hubungi tim support kami. '
          'Sukses untuk bisnis Anda!',
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFF6366F1),
      tips: [
        '✅ Mulai tambah produk',
        '👥 Input data pelanggan',
        '💼 Lakukan transaksi pertama',
        '📊 Pantau perkembangan bisnis',
      ],
    ),
  ];
}
