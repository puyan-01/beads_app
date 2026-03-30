import 'package:uuid/uuid.dart';

import '../../domain/entities/bead_project.dart';
import '../../domain/entities/canvas_document.dart';
import '../../domain/entities/palette.dart';
import '../../domain/repositories/project_repository.dart';

class CreateProjectInput {
  const CreateProjectInput({
    required this.name,
    required this.width,
    required this.height,
    this.palette = Palette.defaultPalette,
  });

  final String name;
  final int width;
  final int height;
  final Palette palette;
}

class CreateProjectUseCase {
  CreateProjectUseCase(this._repository);

  final ProjectRepository _repository;
  final Uuid _uuid = const Uuid();

  Future<ProjectSnapshot> call(CreateProjectInput input) async {
    final now = DateTime.now();
    final projectId = _uuid.v4();
    final layerId = _uuid.v4();
    final project = BeadProject(
      id: projectId,
      name: input.name,
      createdAt: now,
      updatedAt: now,
      canvasWidth: input.width,
      canvasHeight: input.height,
      paletteId: input.palette.id,
      activeLayerId: layerId,
    );
    final document = CanvasDocument.empty(
      width: input.width,
      height: input.height,
      layerId: layerId,
    );
    final snapshot = ProjectSnapshot(
      project: project,
      document: document,
      palette: input.palette,
    );
    await _repository.save(snapshot);
    return snapshot;
  }
}

