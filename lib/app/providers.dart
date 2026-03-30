import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/usecases/apply_edit_operation_usecase.dart';
import '../application/usecases/create_project_usecase.dart';
import '../application/usecases/export_png_usecase.dart';
import '../application/usecases/import_image_usecase.dart';
import '../application/usecases/load_project_usecase.dart';
import '../application/usecases/save_project_usecase.dart';
import '../domain/repositories/project_repository.dart';
import '../domain/services/asset_storage_service.dart';
import '../domain/services/image_converter_service.dart';
import '../domain/services/renderer_service.dart';
import '../infrastructure/database/app_database.dart';
import '../infrastructure/repositories/sqlite_project_repository.dart';
import '../infrastructure/services/isolate_image_converter_service.dart';
import '../infrastructure/services/local_asset_storage_service.dart';
import '../infrastructure/services/png_renderer_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return SqliteProjectRepository(ref.watch(appDatabaseProvider));
});

final assetStorageProvider = Provider<AssetStorageService>((ref) {
  return LocalAssetStorageService();
});

final imageConverterProvider = Provider<ImageConverterService>((ref) {
  return IsolateImageConverterService();
});

final rendererProvider = Provider<RendererService>((ref) {
  return PngRendererService();
});

final createProjectUseCaseProvider = Provider<CreateProjectUseCase>((ref) {
  return CreateProjectUseCase(ref.watch(projectRepositoryProvider));
});

final importImageUseCaseProvider = Provider<ImportImageUseCase>((ref) {
  return ImportImageUseCase(ref.watch(imageConverterProvider));
});

final applyEditOperationUseCaseProvider = Provider<ApplyEditOperationUseCase>((ref) {
  return ApplyEditOperationUseCase();
});

final saveProjectUseCaseProvider = Provider<SaveProjectUseCase>((ref) {
  return SaveProjectUseCase(ref.watch(projectRepositoryProvider));
});

final loadProjectUseCaseProvider = Provider<LoadProjectUseCase>((ref) {
  return LoadProjectUseCase(ref.watch(projectRepositoryProvider));
});

final exportPngUseCaseProvider = Provider<ExportPngUseCase>((ref) {
  return ExportPngUseCase(ref.watch(rendererProvider), ref.watch(assetStorageProvider));
});

final appBootstrapProvider = FutureProvider<void>((ref) async {
  await ref.read(projectRepositoryProvider).init();
  await ref.read(assetStorageProvider).init();
});

final recentProjectsProvider = FutureProvider((ref) async {
  await ref.watch(appBootstrapProvider.future);
  return ref.watch(projectRepositoryProvider).listRecent();
});

