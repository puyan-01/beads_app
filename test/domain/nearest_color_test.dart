import 'package:beads_app/domain/entities/palette.dart';
import 'package:beads_app/infrastructure/services/isolate_image_converter_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('nearest color chooses closest rgb candidate', () {
    final palette = Palette.defaultPalette;

    final white = findNearestColorIndex(r: 250, g: 250, b: 250, palette: palette);
    final black = findNearestColorIndex(r: 15, g: 15, b: 20, palette: palette);

    expect(white, 0);
    expect(black, 1);
  });
}

