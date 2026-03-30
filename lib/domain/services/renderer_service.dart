import 'dart:typed_data';

import '../entities/canvas_document.dart';
import '../entities/palette.dart';

enum PngExportMode { plain, grid }

class RenderPngCommand {
  const RenderPngCommand({
    required this.document,
    required this.palette,
    required this.mode,
    this.cellSize = 16,
  });

  final CanvasDocument document;
  final Palette palette;
  final PngExportMode mode;
  final int cellSize;
}

abstract class RendererService {
  Future<Uint8List> renderPng(RenderPngCommand command);
}

