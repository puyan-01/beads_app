class AppFailure implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class ImportFailure extends AppFailure {
  const ImportFailure(super.message);
}

class ExportFailure extends AppFailure {
  const ExportFailure(super.message);
}

class PersistenceFailure extends AppFailure {
  const PersistenceFailure(super.message);
}

