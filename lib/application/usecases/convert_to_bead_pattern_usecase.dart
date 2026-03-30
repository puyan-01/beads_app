import '../../domain/entities/canvas_document.dart';
import '../../domain/services/image_converter_service.dart';

class ConvertToBeadPatternUseCase {
  ConvertToBeadPatternUseCase(this._converter);

  final ImageConverterService _converter;

  Future<CanvasDocument> call(ConvertImageCommand command) {
    return _converter.convertToBeadPattern(command);
  }
}

