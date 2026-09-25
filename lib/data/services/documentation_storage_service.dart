import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

/// Menyimpan file gambar dokumentasi PKL secara nyata ke disk.
///
/// Desktop: disimpan ke folder yang bisa dikonfigurasi user (lihat
/// [DriveBackupService.localDrivePath]). Jika belum diset, jatuh ke folder
/// dokumen aplikasi (path_provider) — bukan path komputer tertentu yang
/// di-hardcode.
/// Mobile: selalu disimpan ke folder dokumen aplikasi (sandboxed), lalu
/// disinkronkan ke Supabase saat koneksi tersedia.
class DocumentationStorageService {
  static const String _subFolder = 'dokumentasi';

  /// Folder default (fallback) tempat foto dokumentasi disimpan jika user
  /// belum mengonfigurasi folder khusus. Tidak hardcode path komputer
  /// tertentu — dihitung dari path_provider sehingga valid di semua device.
  static Future<Directory> defaultFolder() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${docsDir.path}/JejakSaku/$_subFolder');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Menyalin file gambar yang dipilih/diambil user ke folder tujuan
  /// (folder kustom jika diberikan, atau folder default) dan mengembalikan
  /// path absolut file yang benar-benar tersimpan di disk.
  static Future<String> saveImageFile(
    File sourceFile, {
    String? customFolderPath,
  }) async {
    Directory targetDir;
    if (customFolderPath != null && customFolderPath.trim().isNotEmpty) {
      targetDir = Directory(customFolderPath.trim());
      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }
    } else {
      targetDir = await defaultFolder();
    }

    final ext = sourceFile.path.contains('.')
        ? sourceFile.path.split('.').last
        : 'jpg';
    final fileName = 'doc_${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4().substring(0, 8)}.$ext';
    final destPath = '${targetDir.path}/$fileName';

    final savedFile = await sourceFile.copy(destPath);
    return savedFile.path;
  }

  /// Membuka pemilih foto yang sesuai dengan platform:
  /// - Android/iOS: image_picker (kamera atau galeri, sesuai [fromCamera]).
  /// - Desktop (Linux/Windows/macOS)/Web: file_picker (image_picker tidak
  ///   punya implementasi kamera/galeri native di desktop), sehingga user
  ///   memilih file gambar langsung dari sistem file.
  ///
  /// Mengembalikan null jika user membatalkan pemilihan — tidak pernah
  /// mengembalikan file palsu.
  static Future<File?> pickImageFile({bool fromCamera = false}) async {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    if (isMobile) {
      final picker = ImagePicker();
      final XFile? result = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
      );
      if (result == null) return null;
      return File(result.path);
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    final path = result?.files.single.path;
    if (path == null) return null;
    return File(path);
  }

  /// Mengecek apakah file dokumentasi (berdasarkan path yang tersimpan di DB)
  /// masih benar-benar ada di disk. Dipakai untuk menampilkan empty/broken
  /// state yang jujur di galeri, bukan berpura-pura selalu ada.
  static bool fileExists(String path) {
    try {
      return File(path).existsSync();
    } catch (_) {
      return false;
    }
  }
}
