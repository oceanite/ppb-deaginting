// ══════════════════════════════════════════════════════════════════════════════
// Storage Service — Cloudinary Free Tier (Opsi 2, GRATIS 25 GB/bulan)
//
// Setup:
//   1. Daftar di https://cloudinary.com/users/register_free
//   2. Di Dashboard Cloudinary catat: Cloud Name
//   3. Settings → Upload → Upload presets → Add upload preset
//      → Signing mode: Unsigned → Save → catat nama preset
//   4. Isi CLOUD_NAME dan UPLOAD_PRESET di bawah
// ══════════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

// ─── GANTI DENGAN DATA AKUN CLOUDINARY KAMU ──────────────────────────────────
const _cloudName   = 'dkpihrovf';    // contoh: 'logasdos-dev'
const _uploadPreset= 'sjzvh9v4'; // preset unsigned dari dashboard
// ─────────────────────────────────────────────────────────────────────────────

class StorageService {
  final _picker = ImagePicker();
  final _uuid = const Uuid();

  // ── Pick ──────────────────────────────────────────────────────────────────

  Future<File?> pickFromCamera() async {
    final xf = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
      maxWidth: 1080,
    );
    if (xf == null) return null;
    return _copyToAppDir(File(xf.path));
  }

  Future<File?> pickFromGallery() async {
    final xf = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1080,
    );
    if (xf == null) return null;
    return _copyToAppDir(File(xf.path));
  }

  // ── Upload ke Cloudinary ──────────────────────────────────────────────────

  /// Upload foto dan kembalikan secure URL.
  /// Jika Cloudinary belum dikonfigurasi, kembalikan path lokal sebagai fallback.
  Future<String> uploadActivityPhoto({
    required File file,
    required String asdosId,
    void Function(double)? onProgress,
  }) async {
    // Fallback ke path lokal jika belum dikonfigurasi
    if (_cloudName == 'YOUR_CLOUD_NAME') {
      onProgress?.call(1.0);
      return file.path;
    }

    onProgress?.call(0.1);

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final bytes = await file.readAsBytes();
    onProgress?.call(0.3);

    final b64 = base64Encode(bytes);
    onProgress?.call(0.5);

    final resp = await http.post(uri, body: {
      'file': 'data:image/jpeg;base64,$b64',
      'upload_preset': _uploadPreset,
      'folder': 'logasdos/$asdosId',
      'public_id': _uuid.v4(),
    });

    onProgress?.call(1.0);

    if (resp.statusCode != 200) {
      // Jika upload gagal, fallback ke path lokal
      return file.path;
    }

    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    return json['secure_url'] as String;
  }

  Future<void> deletePhotoByUrl(String url) async {
    // Hapus file lokal jika path lokal
    if (!url.startsWith('http')) {
      try {
        final f = File(url);
        if (await f.exists()) await f.delete();
      } catch (_) {}
    }
    // Untuk URL Cloudinary: tidak diimplementasi untuk tugas
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Salin ke direktori permanen agar foto tidak hilang setelah app restart
  Future<File> _copyToAppDir(File source) async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'activity_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }
    final ext =
        p.extension(source.path).isNotEmpty ? p.extension(source.path) : '.jpg';
    final dest = File(p.join(photosDir.path, '${_uuid.v4()}$ext'));
    return source.copy(dest.path);
  }

  bool isLocalPath(String s) => !s.startsWith('http');
}