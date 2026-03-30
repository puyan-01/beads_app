import 'dart:typed_data';

import '../../domain/entities/canvas_document.dart';
import '../../domain/entities/palette.dart';
import '../../domain/services/image_converter_service.dart';

class ImportImageInput {
  const ImportImageInput({
    required this.sourceBytes,
    required this.targetWidth,
    required this.targetHeight,
    required this.palette,
    required this.layerId,
  });

  final Uint8List sourceBytes;
  final int targetWidth;
  final int targetHeight;
  final Palette palette;
  final String layerId;
}

class ImportImageUseCase {
  ImportImageUseCase(this._converter);

  final ImageConverterService _converter;

  Future<CanvasDocument> call(ImportImageInput input) {
    return _converter.convertToBeadPattern(
      ConvertImageCommand(
        sourceBytes: input.sourceBytes,
        targetWidth: input.targetWidth,
        targetHeight: input.targetHeight,
        palette: input.palette,
        layerId: input.layerId,
      ),
    );
  }
}

