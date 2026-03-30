class SelectionRect {
  const SelectionRect({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final int left;
  final int top;
  final int right;
  final int bottom;

  int get width => right - left + 1;
  int get height => bottom - top + 1;

  bool contains(int x, int y) {
    return x >= left && x <= right && y >= top && y <= bottom;
  }

  SelectionRect normalize() {
    final nLeft = left < right ? left : right;
    final nRight = left < right ? right : left;
    final nTop = top < bottom ? top : bottom;
    final nBottom = top < bottom ? bottom : top;
    return SelectionRect(left: nLeft, top: nTop, right: nRight, bottom: nBottom);
  }
}

