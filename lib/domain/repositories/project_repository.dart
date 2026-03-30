import '../entities/bead_project.dart';
import '../entities/canvas_document.dart';
import '../entities/palette.dart';

class ProjectSnapshot {
  const ProjectSnapshot({
    required this.project,
    required this.document,
    required this.palette,
    this.sourceImagePath,
  });

  final BeadProject project;
  final CanvasDocument document;
  final Palette palette;
  final String? sourceImagePath;
}

abstract class ProjectRepository {
  Future<void> init();
  Future<void> save(ProjectSnapshot snapshot);
  Future<ProjectSnapshot?> loadById(String projectId);
  Future<List<BeadProject>> listRecent({int limit = 20});
}

