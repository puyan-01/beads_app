import 'package:beads_app/domain/entities/canvas_document.dart';
import 'package:beads_app/domain/entities/palette.dart';
import 'package:beads_app/domain/services/renderer_service.dart';
import 'package:beads_app/infrastructure/services/png_renderer_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  test('png export plain and grid generate decodable png', () async {
    final renderer = PngRendererService();
    final doc = CanvasDocument.empty(width: 2, height: 2, layerId: 'layer-1');
    final cells = List<int>.from(doc.activeLayer.cells)
      ..[0] = 0
      ..[1] = 1
      ..[2] = 2
      ..[3] = 3;

    final nextDoc = doc.copyWith(layers: [doc.activeLayer.copyWith(cells: cells)]);

    final plain = await renderer.renderPng(
      RenderPngCommand(document: nextDoc, palette: Palette.defaultPalette, mode: PngExportMode.plain),
    );
    final grid = await renderer.renderPng(
      RenderPngCommand(document: nextDoc, palette: Palette.defaultPalette, mode: PngExportMode.grid),
    );

    expect(img.decodePng(plain), isNotNull);
    expect(img.decodePng(grid), isNotNull);
    expect(grid.length, greaterThan(plain.length));
  });
}

