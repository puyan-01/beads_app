import 'package:flutter/material.dart';

import '../../app/ui/theme_tokens.dart';
import '../../domain/services/renderer_service.dart';
import '../shared/app_card.dart';
import '../shared/app_scaffold.dart';
import '../shared/primary_button.dart';
import '../shared/section_header.dart';
import '../shared/secondary_button.dart';
import 'editor_models.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({
    super.key,
    required this.projectName,
    required this.width,
    required this.height,
    required this.colorCount,
    required this.onExport,
  });

  final String projectName;
  final int width;
  final int height;
  final int colorCount;
  final Future<String?> Function(PngExportMode mode) onExport;

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  ExportPreset _preset = ExportPreset.preview;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppScaffold(
      appBar: AppBar(title: const Text('导出')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const SectionHeader(title: '导出预览'),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: tokens.editorBg,
                  ),
                  child: const Center(
                    child: Icon(Icons.image_outlined, size: 54),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '当前项目：${widget.projectName}',
                  style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: '导出类型设置'),
          const SizedBox(height: 10),
          AppCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _presetChip(ExportPreset.preview, '成品预览图'),
                _presetChip(ExportPreset.grid, '制作网格图'),
                _presetChip(ExportPreset.indexedGuide, '编号指引图'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: '统计与确认'),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('画布尺寸', '${widget.width} x ${widget.height}'),
                _row('预计颗粒数', '${widget.width * widget.height}'),
                _row('使用颜色', '${widget.colorCount}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: '导出记录',
                  icon: Icons.history,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('暂无导出记录')),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  label: '确认导出',
                  icon: Icons.file_download_done,
                  onPressed: _export,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _presetChip(ExportPreset preset, String label) {
    final tokens = context.tokens;
    return ChoiceChip(
      label: Text(label),
      selected: _preset == preset,
      selectedColor: tokens.primary.withValues(alpha: 0.2),
      onSelected: (_) => setState(() => _preset = preset),
    );
  }

  Widget _row(String label, String value) {
    final tokens = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: tokens.textSecondary))),
          Text(value, style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _export() async {
    final mode = switch (_preset) {
      ExportPreset.preview => PngExportMode.plain,
      ExportPreset.grid => PngExportMode.grid,
      ExportPreset.indexedGuide => PngExportMode.grid,
    };

    final path = await widget.onExport(mode);
    if (!mounted || path == null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('导出完成：$path'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

