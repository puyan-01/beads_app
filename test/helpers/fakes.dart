import 'dart:typed_data';

import 'package:beads_app/domain/entities/bead_project.dart';
import 'package:beads_app/domain/entities/canvas_document.dart';
import 'package:beads_app/domain/entities/palette.dart';
import 'package:beads_app/domain/repositories/project_repository.dart';
import 'package:beads_app/domain/services/asset_storage_service.dart';

class FakeProjectRepository implements ProjectRepository {
  FakeProjectRepository({List<ProjectSnapshot>? initial}) {
    if (initial != null) {
      for (final item in initial) {
        _store[item.project.id] = item;
      }
    }
  }

  final Map<String, ProjectSnapshot> _store = {};

  @override
  Future<void> init() async {}

  @override
  Future<List<BeadProject>> listRecent({int limit = 20}) async {
    final items = _store.values.map((e) => e.project).toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return items.take(limit).toList();
  }

  @override
  Future<ProjectSnapshot?> loadById(String projectId) async {
    return _store[projectId];
  }

  @override
  Future<void> save(ProjectSnapshot snapshot) async {
    _store[snapshot.project.id] = snapshot;
  }
}

class FakeAssetStorageService implements AssetStorageService {
  @override
  Future<void> init() async {}

  @override
  Future<String> saveExportPng(String projectId, Uint8List bytes, {required String suffix}) async {
    return '/tmp/$projectId/export_$suffix.png';
  }

  @override
  Future<String> saveSourceImage(String projectId, Uint8List bytes) async {
    return '/tmp/$projectId/source.png';
  }

  @override
  Future<String> saveThumbnail(String projectId, Uint8List bytes) async {
    return '/tmp/$projectId/thumb.png';
  }
}

ProjectSnapshot sampleSnapshot({
  String id = 'project-1',
  String name = '测试项目',
  int width = 16,
  int height = 16,
}) {
  final now = DateTime.now();
  const layerId = 'layer-1';
  return ProjectSnapshot(
    project: BeadProject(
      id: id,
      name: name,
      createdAt: now,
      updatedAt: now,
      canvasWidth: width,
      canvasHeight: height,
      paletteId: Palette.defaultPalette.id,
      activeLayerId: layerId,
    ),
    document: CanvasDocument.empty(width: width, height: height, layerId: layerId),
    palette: Palette.defaultPalette,
  );
}
