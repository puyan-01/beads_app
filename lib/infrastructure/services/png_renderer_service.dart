import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../../domain/entities/canvas_document.dart';
import '../../domain/entities/palette.dart';
import '../../domain/services/renderer_service.dart';

class PngRendererService implements RendererService {
  @override
  Future<Uint8List> renderPng(RenderPngCommand command) async {
    final width = command.document.width;
    final height = command.document.height;
    final cellSize = command.cellSize;

    final margin = command.mode == PngExportMode.grid ? cellSize * 2 : 0;
    final canvasW = width * cellSize + margin;
    final canvasH = height * cellSize + margin;

    final out = img.Image(width: canvasW, height: canvasH);
    img.fill(out, color: img.ColorRgb8(255, 255, 255));

    _drawCells(out, command.document, command.palette, cellSize, margin);

    if (command.mode == PngExportMode.grid) {
      _drawGridWithTicks(out, width, height, cellSize, margin);
    }

    return Uint8List.fromList(img.encodePng(out));
  }

  void _drawCells(
    img.Image out,
    CanvasDocument document,
    Palette palette,
    int cellSize,
    int margin,
  ) {
    for (final layer in document.layers) {
      if (!layer.visible) {
        continue;
      }
      for (var y = 0; y < document.height; y++) {
        for (var x = 0; x < document.width; x++) {
          final colorIndex = layer.cells[y * document.width + x];
          if (colorIndex < 0 || colorIndex >= palette.colors.length) {
            continue;
          }
          final c = palette.colors[colorIndex];
          final px = margin + x * cellSize;
          final py = margin + y * cellSize;
          img.fillRect(
            out,
            x1: px,
            y1: py,
            x2: px + cellSize - 1,
            y2: py + cellSize - 1,
            color: img.ColorRgb8(c.r, c.g, c.b),
          );
        }
      }
    }
  }

  void _drawGridWithTicks(
    img.Image out,
    int width,
    int height,
    int cellSize,
    int margin,
  ) {
    final gridColor = img.ColorRgb8(120, 120, 120);
    final borderColor = img.ColorRgb8(30, 30, 30);
    final tickColor = img.ColorRgb8(20, 20, 20);

    final left = margin;
    final top = margin;
    final right = margin + width * cellSize;
    final bottom = margin + height * cellSize;

    for (var x = 0; x <= width; x++) {
      final px = left + x * cellSize;
      img.drawLine(out, x1: px, y1: top, x2: px, y2: bottom, color: gridColor);
      if (x % 5 == 0) {
        img.drawLine(out, x1: px, y1: top - cellSize ~/ 2, x2: px, y2: top, color: tickColor);
      }
    }

    for (var y = 0; y <= height; y++) {
      final py = top + y * cellSize;
      img.drawLine(out, x1: left, y1: py, x2: right, y2: py, color: gridColor);
      if (y % 5 == 0) {
        img.drawLine(out, x1: left - cellSize ~/ 2, y1: py, x2: left, y2: py, color: tickColor);
      }
    }

    img.drawRect(out, x1: left, y1: top, x2: right, y2: bottom, color: borderColor);
  }
}

