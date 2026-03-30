abstract class BoardSpec {
  const BoardSpec();

  String get id;
  String get cellLayout;
  double get cellSize;
  String get fitRule;
  String get snapRule;
}

class VirtualBoardSpec extends BoardSpec {
  const VirtualBoardSpec();

  @override
  String get id => 'virtual';

  @override
  String get cellLayout => 'square';

  @override
  double get cellSize => 1;

  @override
  String get fitRule => 'stretch_to_canvas';

  @override
  String get snapRule => 'pixel_snap';
}

