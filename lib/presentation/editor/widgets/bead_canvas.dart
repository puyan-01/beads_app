import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/entities/canvas_document.dart';
import '../../../domain/entities/palette.dart';

class BeadCanvas extends StatefulWidget {
  const BeadCanvas({
    super.key,
    required this.document,
    required this.palette,
    required this.onTapCell,
    required this.onUpdateSelection,
    this.onCursor,
    this.onScaleChanged,
  });

  final CanvasDocument document;
  final Palette palette;
  final void Function(int x, int y) onTapCell;
  final void Function(int startX, int startY, int endX, int endY) onUpdateSelection;
  final void Function(int x, int y)? onCursor;
  final void Function(double scalePercent)? onScaleChanged;

  @override
  State<BeadCanvas> createState() => _BeadCanvasState();
}

class _BeadCanvasState extends State<BeadCanvas> {
  int? _startX;
  int? _startY;
  late final TransformationController _transformController;

  @override
  void initState() {
    super.initState();
    _transformController = TransformationController();
    _transformController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformController
      ..removeListener(_onTransformChanged)
      ..dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformController.value.getMaxScaleOnAxis() * 100;
    widget.onScaleChanged?.call(scale);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = widget.document.width;
        final height = widget.document.height;
        final cellSize = math.max(
          8.0,
          math.min(constraints.maxWidth / width, constraints.maxHeight / height),
        );
        final size = Size(width * cellSize, height * cellSize);

        return GestureDetector(
          onDoubleTap: () {
            _transformController.value = Matrix4.identity();
            widget.onScaleChanged?.call(100);
          },
          child: InteractiveViewer(
            transformationController: _transformController,
            minScale: 0.6,
            maxScale: 4,
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  final cell = _toCell(details.localPosition, cellSize);
                  if (cell != null) {
                    widget.onTapCell(cell.$1, cell.$2);
                    widget.onCursor?.call(cell.$1, cell.$2);
                  }
                },
                onPanStart: (details) {
                  final cell = _toCell(details.localPosition, cellSize);
                  if (cell == null) {
                    return;
                  }
                  _startX = cell.$1;
                  _startY = cell.$2;
                  widget.onUpdateSelection(cell.$1, cell.$2, cell.$1, cell.$2);
                  widget.onCursor?.call(cell.$1, cell.$2);
                },
                onPanUpdate: (details) {
                  if (_startX == null || _startY == null) {
                    return;
                  }
                  final cell = _toCell(details.localPosition, cellSize);
                  if (cell == null) {
                    return;
                  }
                  widget.onUpdateSelection(_startX!, _startY!, cell.$1, cell.$2);
                  widget.onCursor?.call(cell.$1, cell.$2);
                },
                onPanEnd: (_) {
                  _startX = null;
                  _startY = null;
                },
                child: CustomPaint(
                  size: size,
                  painter: _BeadCanvasPainter(
                    document: widget.document,
                    palette: widget.palette,
                    cellSize: cellSize,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  (int, int)? _toCell(Offset localPosition, double cellSize) {
    final x = (localPosition.dx / cellSize).floor();
    final y = (localPosition.dy / cellSize).floor();
    if (x < 0 || x >= widget.document.width || y < 0 || y >= widget.document.height) {
      return null;
    }
    return (x, y);
  }
}

class _BeadCanvasPainter extends CustomPainter {
  _BeadCanvasPainter({
    required this.document,
    required this.palette,
    required this.cellSize,
  });

  final CanvasDocument document;
  final Palette palette;
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    final checkerLight = Paint()..color = const Color(0xFFF8FAFC);
    final checkerDark = Paint()..color = const Color(0xFFE5E7EB);
    for (var y = 0; y < document.height; y++) {
      for (var x = 0; x < document.width; x++) {
        final rect = Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize);
        canvas.drawRect(rect, (x + y).isEven ? checkerLight : checkerDark);
      }
    }

    final activeCells = document.activeLayer.cells;

    for (var y = 0; y < document.height; y++) {
      for (var x = 0; x < document.width; x++) {
        final colorIndex = activeCells[y * document.width + x];
        if (colorIndex < 0 || colorIndex >= palette.colors.length) {
          continue;
        }
        final color = palette.colors[colorIndex];
        final paint = Paint()
          ..color = Color.fromARGB(255, color.r, color.g, color.b)
          ..style = PaintingStyle.fill;
        canvas.drawRect(
          Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize),
          paint,
        );
      }
    }

    final gridPaint = Paint()
      ..color = const Color(0xFFCAD3DF)
      ..strokeWidth = 1;

    for (var x = 0; x <= document.width; x++) {
      final dx = x * cellSize;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), gridPaint);
    }

    for (var y = 0; y <= document.height; y++) {
      final dy = y * cellSize;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), gridPaint);
    }

    final selection = document.selection;
    if (selection != null) {
      final selectionPaint = Paint()
        ..color = const Color(0x555B8DEF)
        ..style = PaintingStyle.fill;
      final border = Paint()
        ..color = const Color(0xFF5B8DEF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final rect = Rect.fromLTRB(
        selection.left * cellSize,
        selection.top * cellSize,
        (selection.right + 1) * cellSize,
        (selection.bottom + 1) * cellSize,
      );
      canvas.drawRect(rect, selectionPaint);
      canvas.drawRect(rect, border);
    }
  }

  @override
  bool shouldRepaint(covariant _BeadCanvasPainter oldDelegate) {
    return oldDelegate.document != document || oldDelegate.palette != palette;
  }
}
