import 'package:sqflite/sqflite.dart';

import '../../domain/entities/bead_color.dart';
import '../../domain/entities/bead_layer.dart';
import '../../domain/entities/bead_project.dart';
import '../../domain/entities/canvas_document.dart';
import '../../domain/entities/palette.dart';
import '../../domain/errors/app_failure.dart';
import '../../domain/repositories/project_repository.dart';
import '../database/app_database.dart';

class SqliteProjectRepository implements ProjectRepository {
  SqliteProjectRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  @override
  Future<void> init() async {
    await _appDatabase.database;
  }

  @override
  Future<List<BeadProject>> listRecent({int limit = 20}) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'projects',
      orderBy: 'updated_at DESC',
      limit: limit,
    );
    return rows.map(_mapProject).toList();
  }

  @override
  Future<ProjectSnapshot?> loadById(String projectId) async {
    final db = await _appDatabase.database;
    final projectRows = await db.query('projects', where: 'id = ?', whereArgs: [projectId]);
    if (projectRows.isEmpty) {
      return null;
    }

    final project = _mapProject(projectRows.first);

    final paletteRows = await db.query(
      'palette_colors',
      where: 'palette_id = ?',
      whereArgs: [project.paletteId],
      orderBy: 'sort_order ASC',
    );
    final palette = paletteRows.isEmpty
        ? Palette.defaultPalette
        : Palette(
            id: project.paletteId,
            name: project.paletteId,
            colors: paletteRows
                .map(
                  (row) => BeadColor(
                    code: row['code'] as String,
                    name: row['name'] as String,
                    r: row['r'] as int,
                    g: row['g'] as int,
                    b: row['b'] as int,
                  ),
                )
                .toList(),
          );

    final layerRows = await db.query(
      'project_layers',
      where: 'project_id = ?',
      whereArgs: [projectId],
      orderBy: 'sort_order ASC',
    );

    final cellsRows = await db.query(
      'project_cells',
      where: 'project_id = ?',
      whereArgs: [projectId],
    );

    final cellMap = <String, List<int>>{};
    for (final layer in layerRows) {
      final layerId = layer['id'] as String;
      cellMap[layerId] = List<int>.filled(project.canvasWidth * project.canvasHeight, -1);
    }

    for (final row in cellsRows) {
      final layerId = row['layer_id'] as String;
      final x = row['x'] as int;
      final y = row['y'] as int;
      final index = y * project.canvasWidth + x;
      final cells = cellMap[layerId];
      if (cells != null && index >= 0 && index < cells.length) {
        cells[index] = row['color_index'] as int;
      }
    }

    final layers = layerRows
        .map(
          (row) => BeadLayer(
            id: row['id'] as String,
            name: row['name'] as String,
            visible: (row['visible'] as int) == 1,
            cells: cellMap[row['id'] as String] ??
                List<int>.filled(project.canvasWidth * project.canvasHeight, -1),
          ),
        )
        .toList();

    final assetRows = await db.query(
      'assets',
      where: 'project_id = ? AND asset_type = ?',
      whereArgs: [projectId, 'source'],
      orderBy: 'created_at DESC',
      limit: 1,
    );

    return ProjectSnapshot(
      project: project,
      document: CanvasDocument(
        width: project.canvasWidth,
        height: project.canvasHeight,
        layers: layers,
        activeLayerId: project.activeLayerId,
      ),
      palette: palette,
      sourceImagePath: assetRows.isEmpty ? null : assetRows.first['path'] as String,
    );
  }

  @override
  Future<void> save(ProjectSnapshot snapshot) async {
    final db = await _appDatabase.database;
    final project = snapshot.project;

    await db.transaction((txn) async {
      await txn.insert(
        'projects',
        {
          'id': project.id,
          'name': project.name,
          'created_at': project.createdAt.millisecondsSinceEpoch,
          'updated_at': project.updatedAt.millisecondsSinceEpoch,
          'canvas_width': project.canvasWidth,
          'canvas_height': project.canvasHeight,
          'palette_id': project.paletteId,
          'active_layer_id': project.activeLayerId,
          'thumbnail_path': project.thumbnailPath,
          'sync_state': project.syncState,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.delete('project_layers', where: 'project_id = ?', whereArgs: [project.id]);
      await txn.delete('project_cells', where: 'project_id = ?', whereArgs: [project.id]);

      final layerBatch = txn.batch();
      for (var i = 0; i < snapshot.document.layers.length; i++) {
        final layer = snapshot.document.layers[i];
        layerBatch.insert('project_layers', {
          'id': layer.id,
          'project_id': project.id,
          'name': layer.name,
          'visible': layer.visible ? 1 : 0,
          'sort_order': i,
        });
      }
      await layerBatch.commit(noResult: true);

      final cellBatch = txn.batch();
      for (final layer in snapshot.document.layers) {
        for (var y = 0; y < snapshot.document.height; y++) {
          for (var x = 0; x < snapshot.document.width; x++) {
            final value = layer.cells[y * snapshot.document.width + x];
            if (value < 0) {
              continue;
            }
            cellBatch.insert('project_cells', {
              'project_id': project.id,
              'layer_id': layer.id,
              'x': x,
              'y': y,
              'color_index': value,
            });
          }
        }
      }
      await cellBatch.commit(noResult: true);

      await txn.delete('palettes', where: 'id = ?', whereArgs: [snapshot.palette.id]);
      await txn.delete('palette_colors', where: 'palette_id = ?', whereArgs: [snapshot.palette.id]);

      await txn.insert('palettes', {
        'id': snapshot.palette.id,
        'name': snapshot.palette.name,
      });

      final paletteBatch = txn.batch();
      for (var i = 0; i < snapshot.palette.colors.length; i++) {
        final color = snapshot.palette.colors[i];
        paletteBatch.insert('palette_colors', {
          'palette_id': snapshot.palette.id,
          'code': color.code,
          'name': color.name,
          'r': color.r,
          'g': color.g,
          'b': color.b,
          'sort_order': i,
        });
      }
      await paletteBatch.commit(noResult: true);

      if (snapshot.sourceImagePath != null) {
        await txn.insert('assets', {
          'project_id': project.id,
          'asset_type': 'source',
          'path': snapshot.sourceImagePath,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
    }).catchError((Object error) {
      throw PersistenceFailure('Save project failed: $error');
    });
  }

  BeadProject _mapProject(Map<String, Object?> row) {
    return BeadProject(
      id: row['id'] as String,
      name: row['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at'] as int),
      canvasWidth: row['canvas_width'] as int,
      canvasHeight: row['canvas_height'] as int,
      paletteId: row['palette_id'] as String,
      activeLayerId: row['active_layer_id'] as String,
      thumbnailPath: row['thumbnail_path'] as String?,
      syncState: row['sync_state'] as String,
    );
  }
}

