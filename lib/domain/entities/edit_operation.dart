enum EditTool { paint, erase, picker, select, move }

class EditOperation {
  const EditOperation._({
    required this.type,
    this.x,
    this.y,
    this.colorIndex,
    this.startX,
    this.startY,
    this.endX,
    this.endY,
    this.dx,
    this.dy,
  });

  final EditTool type;
  final int? x;
  final int? y;
  final int? colorIndex;
  final int? startX;
  final int? startY;
  final int? endX;
  final int? endY;
  final int? dx;
  final int? dy;

  factory EditOperation.paint({
    required int x,
    required int y,
    required int colorIndex,
  }) {
    return EditOperation._(
      type: EditTool.paint,
      x: x,
      y: y,
      colorIndex: colorIndex,
    );
  }

  factory EditOperation.erase({required int x, required int y}) {
    return EditOperation._(type: EditTool.erase, x: x, y: y);
  }

  factory EditOperation.pick({required int x, required int y}) {
    return EditOperation._(type: EditTool.picker, x: x, y: y);
  }

  factory EditOperation.select({
    required int startX,
    required int startY,
    required int endX,
    required int endY,
  }) {
    return EditOperation._(
      type: EditTool.select,
      startX: startX,
      startY: startY,
      endX: endX,
      endY: endY,
    );
  }

  factory EditOperation.moveSelection({required int dx, required int dy}) {
    return EditOperation._(type: EditTool.move, dx: dx, dy: dy);
  }
}

