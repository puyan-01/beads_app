import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../application/usecases/apply_edit_operation_usecase.dart';
import '../../../application/usecases/export_png_usecase.dart';
import '../../../application/usecases/import_image_usecase.dart';
import '../../../application/usecases/save_project_usecase.dart';
import '../../../domain/entities/canvas_document.dart';
import '../../../domain/entities/edit_operation.dart';
import '../../../domain/entities/palette.dart';
import '../../../domain/repositories/project_repository.dart';
import '../../../domain/services/asset_storage_service.dart';
import '../../../domain/services/renderer_service.dart';
import '../editor_models.dart';
import 'editor_state.dart';

final editorControllerProvider =
    StateNotifierProvider.autoDispose.family<EditorController, EditorState, ProjectSnapshot>((
  ref,
  initialSnapshot,
) {
  return EditorController(
    initialSnapshot: initialSnapshot,
    applyUseCase: ref.read(applyEditOperationUseCaseProvider),
    importUseCase: ref.read(importImageUseCaseProvider),
    saveUseCase: ref.read(saveProjectUseCaseProvider),
    exportUseCase: ref.read(exportPngUseCaseProvider),
    assetStorage: ref.read(assetStorageProvider),
  );
});

class EditorController extends StateNotifier<EditorState> {
  EditorController({
    required ProjectSnapshot initialSnapshot,
    required ApplyEditOperationUseCase applyUseCase,
    required ImportImageUseCase importUseCase,
    required SaveProjectUseCase saveUseCase,
    required ExportPngUseCase exportUseCase,
    required AssetStorageService assetStorage,
  })  : _initialSnapshot = initialSnapshot,
        _applyUseCase = applyUseCase,
        _importUseCase = importUseCase,
        _saveUseCase = saveUseCase,
        _exportUseCase = exportUseCase,
        _assetStorage = assetStorage,
        super(
          EditorState(
            project: initialSnapshot.project,
            document: initialSnapshot.document,
            palette: initialSnapshot.palette,
            currentTool: EditTool.paint,
            selectedColorIndex: 0,
            sourceImagePath: initialSnapshot.sourceImagePath,
          ),
        );

  final ProjectSnapshot _initialSnapshot;
  final ApplyEditOperationUseCase _applyUseCase;
  final ImportImageUseCase _importUseCase;
  final SaveProjectUseCase _saveUseCase;
  final ExportPngUseCase _exportUseCase;
  final AssetStorageService _assetStorage;
  Timer? _autoSaveTimer;

  ProjectSnapshot get initialSnapshot => _initialSnapshot;

  void setTool(EditTool tool) {
    state = state.copyWith(currentTool: tool, clearMessage: true);
  }

  void setSelectedColor(int index) {
    state = state.copyWith(selectedColorIndex: index, clearMessage: true);
  }

  void setZoom(double zoom) {
    state = state.copyWith(zoomLevel: zoom);
  }

  void setCursor(int x, int y) {
    state = state.copyWith(currentX: x, currentY: y);
  }

  void tapCell(int x, int y) {
    setCursor(x, y);

    final operation = switch (state.currentTool) {
      EditTool.paint => EditOperation.paint(x: x, y: y, colorIndex: state.selectedColorIndex),
      EditTool.erase => EditOperation.erase(x: x, y: y),
      EditTool.picker => EditOperation.pick(x: x, y: y),
      EditTool.select => EditOperation.select(startX: x, startY: y, endX: x, endY: y),
      EditTool.move => EditOperation.paint(x: x, y: y, colorIndex: state.selectedColorIndex),
    };

    if (state.currentTool == EditTool.picker) {
      final picked = _applyUseCase.readCell(state.document, x, y);
      if (picked >= 0) {
        state = state.copyWith(selectedColorIndex: picked, currentTool: EditTool.paint);
      }
      return;
    }

    final nextDoc = _applyUseCase(state.document, operation);
    _updateDocument(nextDoc);
  }

  void updateSelection(int startX, int startY, int endX, int endY) {
    final nextDoc = _applyUseCase(
      state.document,
      EditOperation.select(startX: startX, startY: startY, endX: endX, endY: endY),
    );
    state = state.copyWith(document: nextDoc, clearMessage: true);
  }

  void moveSelection(int dx, int dy) {
    final nextDoc = _applyUseCase(state.document, EditOperation.moveSelection(dx: dx, dy: dy));
    _updateDocument(nextDoc);
  }

  Future<void> importImage(Uint8List bytes, {ImportConfig? config}) async {
    state = state.copyWith(isBusy: true, message: '正在转换图片...');
    try {
      final imagePath = await _assetStorage.saveSourceImage(state.project.id, bytes);

      final targetWidth = config?.outputWidth ?? state.document.width;
      final targetHeight = config?.outputHeight ?? state.document.height;
      final maxColors = config?.maxColors ?? state.palette.colors.length;
      final palette = _limitPalette(state.palette, maxColors);

      final converted = await _importUseCase(
        ImportImageInput(
          sourceBytes: bytes,
          targetWidth: targetWidth,
          targetHeight: targetHeight,
          palette: palette,
          layerId: state.document.activeLayerId,
        ),
      );

      final nextProject = state.project.copyWith(
        updatedAt: DateTime.now(),
        canvasWidth: targetWidth,
        canvasHeight: targetHeight,
      );
      state = state.copyWith(
        project: nextProject,
        document: converted,
        palette: palette,
        isBusy: false,
        message: '图片已转为拼豆图',
        sourceImagePath: imagePath,
        saveState: SaveState.dirty,
      );
      await save(showMessage: false);
      state = state.copyWith(message: '图片导入完成');
    } catch (error) {
      state = state.copyWith(isBusy: false, message: '导入失败: $error');
    }
  }

  Palette _limitPalette(Palette palette, int maxColors) {
    final safe = maxColors.clamp(2, palette.colors.length);
    return Palette(id: palette.id, name: palette.name, colors: palette.colors.take(safe).toList());
  }

  Future<void> save({bool showMessage = true}) async {
    final nextProject = state.project.copyWith(
      updatedAt: DateTime.now(),
      activeLayerId: state.document.activeLayerId,
    );

    state = state.copyWith(project: nextProject, saveState: SaveState.saving);

    await _saveUseCase(
      ProjectSnapshot(
        project: nextProject,
        document: state.document,
        palette: state.palette,
        sourceImagePath: state.sourceImagePath,
      ),
    );

    state = state.copyWith(
      saveState: SaveState.saved,
      message: showMessage ? '已保存' : state.message,
    );
  }

  Future<String?> export(PngExportMode mode) async {
    state = state.copyWith(isBusy: true, message: '正在导出 PNG...');
    try {
      final path = await _exportUseCase(
        ExportPngInput(
          projectId: state.project.id,
          command: RenderPngCommand(
            document: state.document,
            palette: state.palette,
            mode: mode,
          ),
        ),
      );
      state = state.copyWith(isBusy: false, message: '导出成功: $path');
      return path;
    } catch (error) {
      state = state.copyWith(isBusy: false, message: '导出失败: $error');
      return null;
    }
  }

  void _updateDocument(CanvasDocument nextDoc) {
    final nextProject = state.project.copyWith(updatedAt: DateTime.now());
    state = state.copyWith(
      project: nextProject,
      document: nextDoc,
      clearMessage: true,
      saveState: SaveState.dirty,
    );

    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(milliseconds: 800), () {
      unawaited(save(showMessage: false));
    });
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
