
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../../domain/entities/bead_layer.dart';
import '../../domain/entities/canvas_document.dart';
import '../../domain/entities/palette.dart';
import '../../domain/services/image_converter_service.dart';

typedef _Payload = Map<String, Object?>;

class IsolateImageConverterService implements ImageConverterService {
  @override
  Future<CanvasDocument> convertToBeadPattern(ConvertImageCommand command) async {
    final payload = <String, Object?>{
      'bytes': command.sourceBytes,
      'width': command.targetWidth,
      'height': command.targetHeight,
      'layerId': command.layerId,
      'palette': command.palette.colors
          .map((c) => <String, int>{'r': c.r, 'g': c.g, 'b': c.b})
          .toList(),
    };
    final result = await compute<_Payload, _Payload>(_convertInIsolate, payload);
    final cells = (result['cells'] as List).cast<int>();
    return CanvasDocument(
      width: command.targetWidth,
      height: command.targetHeight,
      layers: [
        BeadLayer(
          id: command.layerId,
          name: 'Layer 1',
          visible: true,
          cells: cells,
        ),
      ],
      activeLayerId: command.layerId,
    );
  }
}

_Payload _convertInIsolate(_Payload payload) {
  final bytes = payload['bytes'] as Uint8List;
  final width = payload['width'] as int;
  final height = payload['height'] as int;
  final palette = (payload['palette'] as List)
      .map((item) => (item as Map).cast<String, int>())
      .toList();

  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    return {'cells': List<int>.filled(width * height, -1)};
  }

  final resized = img.copyResize(decoded, width: width, height: height, interpolation: img.Interpolation.linear);
  final cells = List<int>.filled(width * height, -1);

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final pixel = resized.getPixel(x, y);
      final pr = pixel.r.toInt();
      final pg = pixel.g.toInt();
      final pb = pixel.b.toInt();
      var bestIndex = 0;
      var bestDistance = 1 << 62;
      for (var i = 0; i < palette.length; i++) {
        final c = palette[i];
        final dr = pr - c['r']!;
        final dg = pg - c['g']!;
        final db = pb - c['b']!;
        final distance = dr * dr + dg * dg + db * db;
        if (distance < bestDistance) {
          bestDistance = distance;
          bestIndex = i;
        }
      }
      cells[y * width + x] = bestIndex;
    }
  }

  return {'cells': cells};
}

int findNearestColorIndex({
  required int r,
  required int g,
  required int b,
  required Palette palette,
}) {
  var bestIndex = 0;
  var bestDistance = 1 << 62;
  for (var i = 0; i < palette.colors.length; i++) {
    final c = palette.colors[i];
    final dr = r - c.r;
    final dg = g - c.g;
    final db = b - c.b;
    final distance = dr * dr + dg * dg + db * db;
    if (distance < bestDistance) {
      bestDistance = distance;
      bestIndex = i;
    }
  }
  return bestIndex;
}

