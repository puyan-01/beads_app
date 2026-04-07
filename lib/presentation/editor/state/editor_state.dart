import '../../../domain/entities/bead_project.dart';
import '../../../domain/entities/canvas_document.dart';
import '../../../domain/entities/edit_operation.dart';
import '../../../domain/entities/palette.dart';

enum SaveState { saved, saving, dirty }

class EditorState {
  const EditorState({
    required this.project,
    required this.document,
    required this.palette,
    required this.currentTool,
    required this.selectedColorIndex,
    this.isBusy = false,
    this.message,
    this.sourceImagePath,
    this.saveState = SaveState.saved,
    this.zoomLevel = 100,
    this.currentX,
    this.currentY,
    this.canUndo = false,
    this.canRedo = false,
  });

  final BeadProject project;
  final CanvasDocument document;
  final Palette palette;
  final EditTool currentTool;
  final int selectedColorIndex;
  final bool isBusy;
  final String? message;
  final String? sourceImagePath;
  final SaveState saveState;
  final double zoomLevel;
  final int? currentX;
  final int? currentY;
  final bool canUndo;
  final bool canRedo;

  EditorState copyWith({
    BeadProject? project,
    CanvasDocument? document,
    Palette? palette,
    EditTool? currentTool,
    int? selectedColorIndex,
    bool? isBusy,
    String? message,
    bool clearMessage = false,
    String? sourceImagePath,
    SaveState? saveState,
    double? zoomLevel,
    int? currentX,
    int? currentY,
    bool? canUndo,
    bool? canRedo,
    bool clearCoordinate = false,
  }) {
    return EditorState(
      project: project ?? this.project,
      document: document ?? this.document,
      palette: palette ?? this.palette,
      currentTool: currentTool ?? this.currentTool,
      selectedColorIndex: selectedColorIndex ?? this.selectedColorIndex,
      isBusy: isBusy ?? this.isBusy,
      message: clearMessage ? null : (message ?? this.message),
      sourceImagePath: sourceImagePath ?? this.sourceImagePath,
      saveState: saveState ?? this.saveState,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      currentX: clearCoordinate ? null : (currentX ?? this.currentX),
      currentY: clearCoordinate ? null : (currentY ?? this.currentY),
      canUndo: canUndo ?? this.canUndo,
      canRedo: canRedo ?? this.canRedo,
    );
  }
}
