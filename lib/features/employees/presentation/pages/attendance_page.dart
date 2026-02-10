import 'package:flutter/material.dart';

/// Halaman rekap absensi (placeholder)
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekap Absensi'),
      ),
      body: const Center(
        child: Text('Halaman rekap absensi akan segera hadir'),
      ),
    );
  }
}
