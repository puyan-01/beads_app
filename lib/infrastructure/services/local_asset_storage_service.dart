import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/services/asset_storage_service.dart';

class LocalAssetStorageService implements AssetStorageService {
  Directory? _root;

  @override
  Future<void> init() async {
    final baseDir = await getApplicationDocumentsDirectory();
    final root = Directory(p.join(baseDir.path, 'beads_assets'));
    if (!root.existsSync()) {
      root.createSync(recursive: true);
    }
    _root = root;
  }

  @override
  Future<String> saveExportPng(
    String projectId,
    Uint8List bytes, {
    required String suffix,
  }) {
    return _writeBytes(
      projectId,
      'exports',
      'export_${DateTime.now().millisecondsSinceEpoch}_$suffix.png',
      bytes,
    );
  }

  @override
  Future<String> saveSourceImage(String projectId, Uint8List bytes) {
    return _writeBytes(projectId, 'source', 'source.png', bytes);
  }

  @override
  Future<String> saveThumbnail(String projectId, Uint8List bytes) {
    return _writeBytes(projectId, 'thumb', 'thumb.png', bytes);
  }

  Future<String> _writeBytes(
    String projectId,
    String folder,
    String name,
    Uint8List bytes,
  ) async {
    final root = _root;
    if (root == null) {
      throw StateError('AssetStorageService not initialized');
    }

    final dir = Directory(p.join(root.path, projectId, folder));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final file = File(p.join(dir.path, name));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}

