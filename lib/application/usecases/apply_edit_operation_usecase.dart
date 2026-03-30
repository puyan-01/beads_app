import '../../domain/entities/canvas_document.dart';
import '../../domain/entities/edit_operation.dart';
import '../../domain/entities/selection_rect.dart';

class ApplyEditOperationUseCase {
  CanvasDocument call(CanvasDocument doc, EditOperation operation) {
    switch (operation.type) {
      case EditTool.paint:
        return _setCell(doc, operation.x!, operation.y!, operation.colorIndex!);
      case EditTool.erase:
        return _setCell(doc, operation.x!, operation.y!, -1);
      case EditTool.picker:
        return doc;
      case EditTool.select:
        final selection = SelectionRect(
          left: operation.startX!,
          top: operation.startY!,
          right: operation.endX!,
          bottom: operation.endY!,
        ).normalize();
        return doc.copyWith(selection: selection);
      case EditTool.move:
        return _moveSelection(doc, operation.dx!, operation.dy!);
    }
  }

  int readCell(CanvasDocument doc, int x, int y) {
    if (!_inBounds(doc, x, y)) {
      return -1;
    }
    return doc.activeLayer.cells[_index(doc.width, x, y)];
  }

  CanvasDocument _setCell(CanvasDocument doc, int x, int y, int value) {
    if (!_inBounds(doc, x, y)) {
      return doc;
    }

    final active = doc.activeLayer;
    final cells = List<int>.from(active.cells);
    cells[_index(doc.width, x, y)] = value;

    final layers = doc.layers
        .map((layer) => layer.id == active.id ? layer.copyWith(cells: cells) : layer)
        .toList();

    return doc.copyWith(layers: layers);
  }

  CanvasDocument _moveSelection(CanvasDocument doc, int dx, int dy) {
    final selection = doc.selection;
    if (selection == null || (dx == 0 && dy == 0)) {
      return doc;
    }

    final active = doc.activeLayer;
    final current = List<int>.from(active.cells);
    final next = List<int>.from(active.cells);

    for (var y = selection.top; y <= selection.bottom; y++) {
      for (var x = selection.left; x <= selection.right; x++) {
        if (_inBounds(doc, x, y)) {
          next[_index(doc.width, x, y)] = -1;
        }
      }
    }

    for (var y = selection.top; y <= selection.bottom; y++) {
      for (var x = selection.left; x <= selection.right; x++) {
        if (!_inBounds(doc, x, y)) {
          continue;
        }
        final targetX = x + dx;
        final targetY = y + dy;
        if (_inBounds(doc, targetX, targetY)) {
          next[_index(doc.width, targetX, targetY)] = current[_index(doc.width, x, y)];
        }
      }
    }

    final movedSelection = SelectionRect(
      left: (selection.left + dx).clamp(0, doc.width - 1),
      top: (selection.top + dy).clamp(0, doc.height - 1),
      right: (selection.right + dx).clamp(0, doc.width - 1),
      bottom: (selection.bottom + dy).clamp(0, doc.height - 1),
    );

    final layers = doc.layers
        .map((layer) => layer.id == active.id ? layer.copyWith(cells: next) : layer)
        .toList();

    return doc.copyWith(layers: layers, selection: movedSelection);
  }

  bool _inBounds(CanvasDocument doc, int x, int y) {
    return x >= 0 && x < doc.width && y >= 0 && y < doc.height;
  }

  int _index(int width, int x, int y) => y * width + x;
}

