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
  });

  final CanvasDocument document;
  final Palette palette;
  final void Function(int x, int y) onTapCell;
  final void Function(int startX, int startY, int endX, int endY) onUpdateSelection;

  @override
  State<BeadCanvas> createState() => _BeadCanvasState();
}

class _BeadCanvasState extends State<BeadCanvas> {
  int? _startX;
  int? _startY;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = widget.document.width;
        final height = widget.document.height;
        final cellSize = math.max(
          6.0,
          math.min(constraints.maxWidth / width, constraints.maxHeight / height),
        );
        final size = Size(width * cellSize, height * cellSize);

        return Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              final cell = _toCell(details.localPosition, cellSize);
              if (cell != null) {
                widget.onTapCell(cell.$1, cell.$2);
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
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bgPaint);

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
      ..color = const Color(0xFFBDBDBD)
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
        ..color = const Color(0x55009688)
        ..style = PaintingStyle.fill;
      final border = Paint()
        ..color = const Color(0xFF00695C)
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

