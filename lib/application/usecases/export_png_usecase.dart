import '../../domain/services/asset_storage_service.dart';
import '../../domain/services/renderer_service.dart';

class ExportPngInput {
  const ExportPngInput({
    required this.projectId,
    required this.command,
  });

  final String projectId;
  final RenderPngCommand command;
}

class ExportPngUseCase {
  ExportPngUseCase(this._renderer, this._storage);

  final RendererService _renderer;
  final AssetStorageService _storage;

  Future<String> call(ExportPngInput input) async {
    final pngBytes = await _renderer.renderPng(input.command);
    final suffix = input.command.mode == PngExportMode.plain ? 'plain' : 'grid';
    return _storage.saveExportPng(input.projectId, pngBytes, suffix: suffix);
  }
}

