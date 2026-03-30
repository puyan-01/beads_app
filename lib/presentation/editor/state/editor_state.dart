import '../../../domain/entities/bead_project.dart';
import '../../../domain/entities/canvas_document.dart';
import '../../../domain/entities/edit_operation.dart';
import '../../../domain/entities/palette.dart';

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
  });

  final BeadProject project;
  final CanvasDocument document;
  final Palette palette;
  final EditTool currentTool;
  final int selectedColorIndex;
  final bool isBusy;
  final String? message;
  final String? sourceImagePath;

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
    );
  }
}

