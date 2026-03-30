import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../application/usecases/create_project_usecase.dart';
import '../editor/editor_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(recentProjectsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('拼豆软件 P0')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createProject(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('新建项目'),
      ),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return const Center(child: Text('暂无项目，点击右下角创建'));
          }
          return ListView.separated(
            itemCount: projects.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final project = projects[index];
              return ListTile(
                title: Text(project.name),
                subtitle: Text(
                  '${project.canvasWidth}x${project.canvasHeight}  ·  ${project.updatedAt}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final loader = ref.read(loadProjectUseCaseProvider);
                  final snapshot = await loader(project.id);
                  if (snapshot == null || !context.mounted) {
                    return;
                  }
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditorPage(initialSnapshot: snapshot),
                    ),
                  );
                  ref.invalidate(recentProjectsProvider);
                },
              );
            },
          );
        },
        error: (error, _) => Center(child: Text('读取项目失败: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Future<void> _createProject(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController(text: '新项目');
    final widthController = TextEditingController(text: '58');
    final heightController = TextEditingController(text: '58');

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建项目'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: '名称')),
            TextField(
              controller: widthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '宽度'),
            ),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '高度'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('创建')),
        ],
      ),
    );

    if (ok != true || !context.mounted) {
      return;
    }

    final width = int.tryParse(widthController.text) ?? 58;
    final height = int.tryParse(heightController.text) ?? 58;

    final creator = ref.read(createProjectUseCaseProvider);
    final snapshot = await creator(
      CreateProjectInput(
        name: nameController.text.trim().isEmpty ? '新项目' : nameController.text.trim(),
        width: width.clamp(8, 256),
        height: height.clamp(8, 256),
      ),
    );

    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditorPage(initialSnapshot: snapshot)),
    );
    ref.invalidate(recentProjectsProvider);
  }
}


