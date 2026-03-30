import '../../domain/repositories/project_repository.dart';

class SaveProjectUseCase {
  SaveProjectUseCase(this._repository);

  final ProjectRepository _repository;

  Future<void> call(ProjectSnapshot snapshot) {
    return _repository.save(snapshot);
  }
}

