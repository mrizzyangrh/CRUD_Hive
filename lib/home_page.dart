import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MahasiswaPage extends StatefulWidget {
  const MahasiswaPage({super.key});

  @override
  State<MahasiswaPage> createState() => _MahasiswaPageState();
}

class _MahasiswaPageState extends State<MahasiswaPage> {
  // Controller untuk menangkap teks input dari Form
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();

  // Referensi ke Box Hive yang sudah dibuka di main.dart
  late final Box<Map> _mahasiswaBox;

  @override
  void initState() {
    super.initState();
    _mahasiswaBox = Hive.box<Map>('mahasiswa_box');
  }

  // State flag untuk mendeteksi mode (Tambah data atau Edit data)
  bool _isEditing = false;
  int? _selectedKey; // Menyimpan index data yang sedang di-update

  // ==================== FEATURE: TAMBAH & EDIT DATA ====================
  void _simpanData() {
    final String nim = _nimController.text.trim();
    final String nama = _namaController.text.trim();

    if (nim.isEmpty || nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('NIM dan Nama wajib diisi!')),
      );
      return;
    }

    // Struktur data berupa Map (Field: NIM, Nama) sesuai "Screenshot 2026-06-05 165848.png"
    final Map<String, String> dataMahasiswa = {'nim': nim, 'nama': nama};

    if (_isEditing && _selectedKey != null) {
      // Sesuai Konsep "Screenshot 2026-06-05 165858.png": Box.putAt(index, dataBaru)
      _mahasiswaBox.putAt(_selectedKey!, dataMahasiswa);
      setState(() {
        _isEditing = false;
        _selectedKey = null;
      });
    } else {
      // Feature: Tambah Data Baru
      _mahasiswaBox.add(dataMahasiswa);
    }

    // Bersihkan kembali form input
    _nimController.clear();
    _namaController.clear();
    setState(() {}); // Refresh UI setelah aksi selesai
  }

  // Fungsi untuk memicu pengisian form otomatis saat tombol edit diklik ("Screenshot 2026-06-05 165858.png")
  void _setFormUntukEdit(int index, Map data) {
    setState(() {
      _isEditing = true;
      _selectedKey = index;
      _nimController.text = data['nim'] ?? '';
      _namaController.text = data['nama'] ?? '';
    });
  }

  // ==================== FEATURE: HAPUS DATA ====================
  void _hapusData(int index) {
    // Menampilkan Dialog Konfirmasi seperti di "Screenshot 2026-06-05 165858.png"
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Yakin ingin menghapus data?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog jika batal
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.purple),
              ),
            ),
            TextButton(
              onPressed: () {
                // Sesuai Konsep "Screenshot 2026-06-05 165858.png": box.deleteAt(index);
                _mahasiswaBox.deleteAt(index);
                Navigator.of(context).pop(); // Tutup dialog setelah hapus
                setState(() {}); // Refresh UI
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CRUD Hive Mahasiswa',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form Input Field NIM
            TextField(
              controller: _nimController,
              decoration: const InputDecoration(
                labelText: 'NIM',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Form Input Field Nama
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tombol Dinamis: Bisa berubah menjadi 'Simpan' atau 'Update' ("Screenshot 2026-06-05 165858.png")
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: _simpanData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFFEEFF5,
                  ), // Warna tombol ungu/pink soft sesuai tampilan UI
                  foregroundColor: Colors.purple,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Color(0xFFF8BBD0)),
                  ),
                ),
                child: Text(_isEditing ? 'Update' : 'Simpan'),
              ),
            ),
            const SizedBox(height: 24),

            // ==================== FEATURE: TAMPIL DATA (READ) ====================
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _mahasiswaBox.listenable(),
                builder: (context, Box box, _) {
                  if (box.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada data mahasiswa.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  // Menggunakan ListView.builder() sesuai perintah di "Screenshot 2026-06-05 165848.png"
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: (context, index) {
                      final data = box.getAt(index) as Map;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: const Color(
                          0xFFFDF0F5,
                        ), // Background item list soft pink pastel
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(
                            data['nama'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            data['nim'] ?? '',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tombol Edit Data ("Screenshot 2026-06-05 165858.png")
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 20,
                                  color: Colors.black54,
                                ),
                                onPressed: () => _setFormUntukEdit(index, data),
                              ),
                              // Tombol Hapus Data ("Screenshot 2026-06-05 165858.png")
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: Colors.black54,
                                ),
                                onPressed: () => _hapusData(index),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
