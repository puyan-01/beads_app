import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/ui/theme_tokens.dart';
import '../../domain/entities/edit_operation.dart';
import '../../domain/repositories/project_repository.dart';
import '../shared/app_card.dart';
import '../shared/app_scaffold.dart';
import '../shared/color_chip.dart';
import '../shared/secondary_button.dart';
import '../shared/tool_icon_button.dart';
import 'editor_models.dart';
import 'export_page.dart';
import 'import_config_page.dart';
import 'state/editor_controller.dart';
import 'state/editor_state.dart';
import 'widgets/bead_canvas.dart';

enum _EditorToolAction { export }

class EditorPage extends ConsumerStatefulWidget {
  const EditorPage({
    super.key,
    required this.initialSnapshot,
    this.initialImportBytes,
  });

  final ProjectSnapshot initialSnapshot;
  final Uint8List? initialImportBytes;

  @override
  ConsumerState<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends ConsumerState<EditorPage> {
  bool _handledInitialImport = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledInitialImport || widget.initialImportBytes == null) {
      return;
    }
    _handledInitialImport = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openImportConfig(widget.initialImportBytes!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editorControllerProvider(widget.initialSnapshot));
    final controller = ref.read(
      editorControllerProvider(widget.initialSnapshot).notifier,
    );
    final tokens = context.tokens;

    return PopScope(
      canPop: state.saveState == SaveState.saved,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || state.saveState == SaveState.saved) {
          return;
        }
        final navigator = Navigator.of(context);
        final leave = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('退出未保存项目？'),
            content: const Text('当前有未保存的修改，确认退出吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('退出'),
              ),
            ],
          ),
        );

        if (leave == true && mounted) {
          navigator.pop();
        }
      },
      child: AppScaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.project.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _saveText(state.saveState),
                style: TextStyle(fontSize: 11, color: tokens.textSecondary),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: '回退',
              onPressed: state.canUndo ? controller.undo : null,
              icon: const Icon(Icons.undo_rounded),
            ),
            IconButton(
              tooltip: '前进',
              onPressed: state.canRedo ? controller.redo : null,
              icon: const Icon(Icons.redo_rounded),
            ),
            IconButton(
              tooltip: '保存工程',
              onPressed: () async {
                await controller.save();
                if (!mounted) return;
                _showTopToast('已保存');
              },
              icon: const Icon(Icons.save_outlined),
            ),
            PopupMenuButton<_EditorToolAction>(
              tooltip: '工具',
              icon: const Icon(Icons.build_outlined),
              onSelected: (action) => _onToolAction(action, state, controller),
              itemBuilder: (context) => const [
                PopupMenuItem<_EditorToolAction>(
                  value: _EditorToolAction.export,
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.file_upload_outlined),
                    title: Text('导出'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: AppCard(
                  padding: const EdgeInsets.all(8),
                  child: BeadCanvas(
                    document: state.document,
                    palette: state.palette,
                    onTapCell: controller.tapCell,
                    onUpdateSelection: (startX, startY, endX, endY) {
                      if (state.currentTool == EditTool.select ||
                          state.currentTool == EditTool.move) {
                        controller.updateSelection(startX, startY, endX, endY);
                      }
                    },
                    onCursor: controller.setCursor,
                    onScaleChanged: controller.setZoom,
                  ),
                ),
              ),
            ),
            _secondaryOperations(state, controller),
            _primaryToolBar(state, controller),
            if (state.isBusy) const LinearProgressIndicator(minHeight: 2),
            if (state.message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  state.message!,
                  style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _secondaryOperations(EditorState state, EditorController controller) {
    final tokens = context.tokens;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(tokens.radiusCard),
        border: Border.all(color: tokens.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final color = state.palette.colors[index];
                return ColorChip(
                  color: Color.fromARGB(255, color.r, color.g, color.b),
                  name: color.code,
                  selected: state.selectedColorIndex == index,
                  onTap: () => controller.setSelectedColor(index),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemCount: state.palette.colors.length,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '缩放 ${state.zoomLevel.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 12, color: tokens.textSecondary),
              ),
              const SizedBox(width: 12),
              Text(
                state.currentX == null
                    ? '坐标 -'
                    : '坐标 (${state.currentX}, ${state.currentY})',
                style: TextStyle(fontSize: 12, color: tokens.textSecondary),
              ),
              const Spacer(),
              TextButton(onPressed: _openStats, child: const Text('统计')),
              TextButton(onPressed: _openViewSettings, child: const Text('视图')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _primaryToolBar(EditorState state, EditorController controller) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: context.tokens.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.tokens.borderLight),
        boxShadow: context.tokens.shadowCard,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ToolIconButton(
              icon: Icons.brush_rounded,
              label: '画笔',
              selected: state.currentTool == EditTool.paint,
              onPressed: () => controller.setTool(EditTool.paint),
            ),
            const SizedBox(width: 8),
            ToolIconButton(
              icon: Icons.auto_fix_off_rounded,
              label: '橡皮',
              selected: state.currentTool == EditTool.erase,
              onPressed: () => controller.setTool(EditTool.erase),
            ),
            const SizedBox(width: 8),
            ToolIconButton(
              icon: Icons.colorize_rounded,
              label: '吸色',
              selected: state.currentTool == EditTool.picker,
              onPressed: () => controller.setTool(EditTool.picker),
            ),
            const SizedBox(width: 8),
            ToolIconButton(
              icon: Icons.select_all_rounded,
              label: '框选',
              selected: state.currentTool == EditTool.select,
              onPressed: () => controller.setTool(EditTool.select),
            ),
            const SizedBox(width: 8),
            ToolIconButton(
              icon: Icons.open_with_rounded,
              label: '移动',
              selected: state.currentTool == EditTool.move,
              onPressed: () => controller.setTool(EditTool.move),
            ),
            const SizedBox(width: 8),
            SecondaryButton(
              label: '撤销',
              icon: Icons.undo_rounded,
              onPressed: state.canUndo ? controller.undo : null,
            ),
            const SizedBox(width: 8),
            SecondaryButton(
              label: '重做',
              icon: Icons.redo_rounded,
              onPressed: state.canRedo ? controller.redo : null,
            ),
          ],
        ),
      ),
    );
  }

  String _saveText(SaveState saveState) {
    return switch (saveState) {
      SaveState.saved => '已保存',
      SaveState.saving => '保存中',
      SaveState.dirty => '未保存',
    };
  }

  void _onToolAction(
    _EditorToolAction action,
    EditorState state,
    EditorController controller,
  ) {
    switch (action) {
      case _EditorToolAction.export:
        _openExport(state, controller);
    }
  }

  void _openExport(EditorState state, EditorController controller) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExportPage(
          projectName: state.project.name,
          width: state.document.width,
          height: state.document.height,
          colorCount: state.palette.colors.length,
          onExport: controller.export,
        ),
      ),
    );
  }

  Future<void> _openImportConfig(Uint8List bytes) async {
    final controller = ref.read(
      editorControllerProvider(widget.initialSnapshot).notifier,
    );
    final state = ref.read(editorControllerProvider(widget.initialSnapshot));

    final config = await Navigator.of(context).push<ImportConfig>(
      MaterialPageRoute(
        builder: (_) => ImportConfigPage(
          imageBytes: bytes,
          defaultWidth: state.document.width,
          defaultHeight: state.document.height,
          defaultMaxColors: state.palette.colors.length,
        ),
      ),
    );

    if (config == null) {
      return;
    }

    await controller.importImage(bytes, config: config);
  }

  void _openStats() {
    final state = ref.read(editorControllerProvider(widget.initialSnapshot));
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '颜色统计',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text('画布总颗粒数：${state.document.width * state.document.height}'),
              const SizedBox(height: 4),
              Text('可用颜色数：${state.palette.colors.length}'),
              const SizedBox(height: 12),
              SecondaryButton(
                label: '关闭',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openViewSettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '视图设置',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text('双击画布可恢复合适缩放比例。'),
              const SizedBox(height: 12),
              SecondaryButton(
                label: '关闭',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTopToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }
}
