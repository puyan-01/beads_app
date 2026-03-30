import 'dart:typed_data';

abstract class AssetStorageService {
  Future<void> init();
  Future<String> saveSourceImage(String projectId, Uint8List bytes);
  Future<String> saveThumbnail(String projectId, Uint8List bytes);
  Future<String> saveExportPng(
    String projectId,
    Uint8List bytes, {
    required String suffix,
  });
}

