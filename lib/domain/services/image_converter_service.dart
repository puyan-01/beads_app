import 'dart:typed_data';

import '../entities/canvas_document.dart';
import '../entities/palette.dart';

class ConvertImageCommand {
  const ConvertImageCommand({
    required this.sourceBytes,
    required this.targetWidth,
    required this.targetHeight,
    required this.palette,
    this.layerId = 'layer-1',
  });

  final Uint8List sourceBytes;
  final int targetWidth;
  final int targetHeight;
  final Palette palette;
  final String layerId;
}

abstract class ImageConverterService {
  Future<CanvasDocument> convertToBeadPattern(ConvertImageCommand command);
}

