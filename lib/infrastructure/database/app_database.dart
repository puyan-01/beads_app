import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

typedef DbPathResolver = Future<String> Function();

class AppDatabase {
  AppDatabase({
    DatabaseFactory? factory,
    DbPathResolver? pathResolver,
  })  : _factory = factory ?? databaseFactory,
        _pathResolver = pathResolver;

  final DatabaseFactory _factory;
  final DbPathResolver? _pathResolver;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    final dbPath = await (_pathResolver != null ? _pathResolver() : _defaultPath());
    _database = await _factory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await _createSchema(db);
        },
      ),
    );
    return _database!;
  }

  Future<String> _defaultPath() async {
    final baseDir = await getApplicationDocumentsDirectory();
    return p.join(baseDir.path, 'beads_app.db');
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        canvas_width INTEGER NOT NULL,
        canvas_height INTEGER NOT NULL,
        palette_id TEXT NOT NULL,
        active_layer_id TEXT NOT NULL,
        thumbnail_path TEXT,
        sync_state TEXT NOT NULL DEFAULT 'local_only'
      )
    ''');

    await db.execute('''
      CREATE TABLE project_layers (
        id TEXT NOT NULL,
        project_id TEXT NOT NULL,
        name TEXT NOT NULL,
        visible INTEGER NOT NULL,
        sort_order INTEGER NOT NULL,
        PRIMARY KEY (project_id, id)
      )
    ''');

    await db.execute('''
      CREATE TABLE project_cells (
        project_id TEXT NOT NULL,
        layer_id TEXT NOT NULL,
        x INTEGER NOT NULL,
        y INTEGER NOT NULL,
        color_index INTEGER NOT NULL,
        PRIMARY KEY (project_id, layer_id, x, y)
      )
    ''');

    await db.execute('''
      CREATE TABLE palettes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE palette_colors (
        palette_id TEXT NOT NULL,
        code TEXT NOT NULL,
        name TEXT NOT NULL,
        r INTEGER NOT NULL,
        g INTEGER NOT NULL,
        b INTEGER NOT NULL,
        sort_order INTEGER NOT NULL,
        PRIMARY KEY (palette_id, code)
      )
    ''');

    await db.execute('''
      CREATE TABLE assets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id TEXT NOT NULL,
        asset_type TEXT NOT NULL,
        path TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE board_specs (
        id TEXT PRIMARY KEY,
        cell_layout TEXT NOT NULL,
        cell_size REAL NOT NULL,
        fit_rule TEXT NOT NULL,
        snap_rule TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE board_binding_rules (
        id TEXT PRIMARY KEY,
        board_spec_id TEXT NOT NULL,
        palette_id TEXT NOT NULL,
        rule_json TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE operation_log (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        op_type TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }
}

