import 'bead_layer.dart';
import 'selection_rect.dart';

class CanvasDocument {
  const CanvasDocument({
    required this.width,
    required this.height,
    required this.layers,
    required this.activeLayerId,
    this.selection,
  });

  final int width;
  final int height;
  final List<BeadLayer> layers;
  final String activeLayerId;
  final SelectionRect? selection;

  int get cellCount => width * height;

  BeadLayer get activeLayer {
    return layers.firstWhere((layer) => layer.id == activeLayerId);
  }

  CanvasDocument copyWith({
    int? width,
    int? height,
    List<BeadLayer>? layers,
    String? activeLayerId,
    SelectionRect? selection,
    bool clearSelection = false,
  }) {
    return CanvasDocument(
      width: width ?? this.width,
      height: height ?? this.height,
      layers: layers ?? this.layers,
      activeLayerId: activeLayerId ?? this.activeLayerId,
      selection: clearSelection ? null : (selection ?? this.selection),
    );
  }

  static CanvasDocument empty({
    required int width,
    required int height,
    required String layerId,
  }) {
    return CanvasDocument(
      width: width,
      height: height,
      layers: [
        BeadLayer(
          id: layerId,
          name: 'Layer 1',
          visible: true,
          cells: List<int>.filled(width * height, -1),
        ),
      ],
      activeLayerId: layerId,
    );
  }
}

