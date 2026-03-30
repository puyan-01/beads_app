import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entities/edit_operation.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/services/renderer_service.dart';
import 'state/editor_controller.dart';
import 'widgets/bead_canvas.dart';

class EditorPage extends ConsumerWidget {
  const EditorPage({super.key, required this.initialSnapshot});

  final ProjectSnapshot initialSnapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorControllerProvider(initialSnapshot));
    final controller = ref.read(editorControllerProvider(initialSnapshot).notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(state.project.name),
        actions: [
          IconButton(
            tooltip: '保存工程',
            onPressed: () async {
              await controller.save();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('工程已保存')));
              }
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: Column(
        children: [
          _TopActions(
            onImportGallery: () => _importFromGallery(context, controller),
            onImportFile: () => _importFromFile(context, controller),
            onExportPlain: () async {
              final path = await controller.export(PngExportMode.plain);
              if (context.mounted && path != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出完成: $path')));
              }
            },
            onExportGrid: () async {
              final path = await controller.export(PngExportMode.grid);
              if (context.mounted && path != null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('导出完成: $path')));
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: EditTool.values
                    .map(
                      (tool) => ChoiceChip(
                        label: Text(_toolName(tool)),
                        selected: state.currentTool == tool,
                        onSelected: (_) => controller.setTool(tool),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final color = state.palette.colors[index];
                final selected = state.selectedColorIndex == index;
                return GestureDetector(
                  onTap: () => controller.setSelectedColor(index),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, color.r, color.g, color.b),
                      border: Border.all(
                        color: selected ? Colors.black : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemCount: state.palette.colors.length,
            ),
          ),
          if (state.currentTool == EditTool.move) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(onPressed: () => controller.moveSelection(0, -1), child: const Text('上移')),
                OutlinedButton(onPressed: () => controller.moveSelection(0, 1), child: const Text('下移')),
                OutlinedButton(onPressed: () => controller.moveSelection(-1, 0), child: const Text('左移')),
                OutlinedButton(onPressed: () => controller.moveSelection(1, 0), child: const Text('右移')),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: BeadCanvas(
                  document: state.document,
                  palette: state.palette,
                  onTapCell: controller.tapCell,
                  onUpdateSelection: (startX, startY, endX, endY) {
                    if (state.currentTool == EditTool.select || state.currentTool == EditTool.move) {
                      controller.updateSelection(startX, startY, endX, endY);
                    }
                  },
                ),
              ),
            ),
          ),
          if (state.isBusy) const LinearProgressIndicator(),
          if (state.message != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(state.message!, style: const TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Future<void> _importFromGallery(BuildContext context, EditorController controller) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return;
    }
    final bytes = await file.readAsBytes();
    await controller.importImage(bytes);
  }

  Future<void> _importFromFile(BuildContext context, EditorController controller) async {
    final picked = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (picked == null || picked.files.isEmpty) {
      return;
    }

    final data = picked.files.first;
    if (data.bytes != null) {
      await controller.importImage(data.bytes!);
      return;
    }

    if (data.path != null) {
      final bytes = await File(data.path!).readAsBytes();
      await controller.importImage(bytes);
    }
  }

  String _toolName(EditTool tool) {
    return switch (tool) {
      EditTool.paint => '点涂',
      EditTool.erase => '擦除',
      EditTool.picker => '吸管',
      EditTool.select => '框选',
      EditTool.move => '移动',
    };
  }
}

class _TopActions extends StatelessWidget {
  const _TopActions({
    required this.onImportGallery,
    required this.onImportFile,
    required this.onExportPlain,
    required this.onExportGrid,
  });

  final VoidCallback onImportGallery;
  final VoidCallback onImportFile;
  final VoidCallback onExportPlain;
  final VoidCallback onExportGrid;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          FilledButton.icon(
            onPressed: onImportGallery,
            icon: const Icon(Icons.photo),
            label: const Text('相册导入'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onImportFile,
            icon: const Icon(Icons.folder_open),
            label: const Text('文件导入'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onExportPlain,
            icon: const Icon(Icons.image),
            label: const Text('导出 PNG'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onExportGrid,
            icon: const Icon(Icons.grid_on),
            label: const Text('导出网格 PNG'),
          ),
        ],
      ),
    );
  }
}


