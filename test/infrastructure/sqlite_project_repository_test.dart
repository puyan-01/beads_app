import 'package:beads_app/domain/entities/bead_project.dart';
import 'package:beads_app/domain/entities/canvas_document.dart';
import 'package:beads_app/domain/entities/palette.dart';
import 'package:beads_app/domain/repositories/project_repository.dart';
import 'package:beads_app/infrastructure/database/app_database.dart';
import 'package:beads_app/infrastructure/repositories/sqlite_project_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  test('sqlite repository save and load roundtrip', () async {
    final db = AppDatabase(
      factory: databaseFactoryFfi,
      pathResolver: () async => inMemoryDatabasePath,
    );
    final repo = SqliteProjectRepository(db);
    await repo.init();

    final now = DateTime.now();
    const layerId = 'layer-1';
    final project = BeadProject(
      id: 'p1',
      name: 'demo',
      createdAt: now,
      updatedAt: now,
      canvasWidth: 3,
      canvasHeight: 3,
      paletteId: Palette.defaultPalette.id,
      activeLayerId: layerId,
    );
    final doc = CanvasDocument.empty(width: 3, height: 3, layerId: layerId);
    final cells = List<int>.from(doc.activeLayer.cells);
    cells[0] = 2;

    final snapshot = ProjectSnapshot(
      project: project,
      document: doc.copyWith(layers: [doc.activeLayer.copyWith(cells: cells)]),
      palette: Palette.defaultPalette,
    );

    await repo.save(snapshot);

    final loaded = await repo.loadById('p1');
    expect(loaded, isNotNull);
    expect(loaded!.project.name, 'demo');
    expect(loaded.document.activeLayer.cells[0], 2);
  });
}

