import 'package:beads_app/application/usecases/apply_edit_operation_usecase.dart';
import 'package:beads_app/domain/entities/canvas_document.dart';
import 'package:beads_app/domain/entities/edit_operation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('paint and erase update expected cells', () {
    const layerId = 'layer-1';
    final doc = CanvasDocument.empty(width: 4, height: 4, layerId: layerId);
    final useCase = ApplyEditOperationUseCase();

    final painted = useCase(doc, EditOperation.paint(x: 1, y: 2, colorIndex: 5));
    expect(painted.activeLayer.cells[2 * 4 + 1], 5);

    final erased = useCase(painted, EditOperation.erase(x: 1, y: 2));
    expect(erased.activeLayer.cells[2 * 4 + 1], -1);
  });

  test('selection move shifts selected block', () {
    const layerId = 'layer-1';
    final doc = CanvasDocument.empty(width: 4, height: 4, layerId: layerId);
    final useCase = ApplyEditOperationUseCase();

    final p1 = useCase(doc, EditOperation.paint(x: 1, y: 1, colorIndex: 3));
    final selected = useCase(p1, EditOperation.select(startX: 1, startY: 1, endX: 1, endY: 1));
    final moved = useCase(selected, EditOperation.moveSelection(dx: 1, dy: 0));

    expect(moved.activeLayer.cells[1 * 4 + 1], -1);
    expect(moved.activeLayer.cells[1 * 4 + 2], 3);
  });
}

