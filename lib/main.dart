import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_page.dart'; // Mengimpor file halaman utama

void main() async {
  // 1. Inisialisasi Hive untuk Flutter
  await Hive.initFlutter();

  // 2. Buka Box Hive untuk menyimpan data mahasiswa
  await Hive.openBox<Map>('mahasiswa_box');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CRUD Hive Mahasiswa',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(
          0xFFFFF8FA,
        ), // Warna soft pink sesuai "Screenshot 2026-06-05 165848.png"
      ),
      home: const MahasiswaPage(), // Mengarah ke kelas di home_page.dart
    );
  }
}
