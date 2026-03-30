import '../../domain/repositories/project_repository.dart';

class LoadProjectUseCase {
  LoadProjectUseCase(this._repository);

  final ProjectRepository _repository;

  Future<ProjectSnapshot?> call(String projectId) {
    return _repository.loadById(projectId);
  }
}

