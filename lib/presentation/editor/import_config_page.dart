import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app/ui/theme_tokens.dart';
import '../shared/app_scaffold.dart';
import '../shared/app_card.dart';
import '../shared/primary_button.dart';
import '../shared/section_header.dart';
import 'editor_models.dart';

class ImportConfigPage extends StatefulWidget {
  const ImportConfigPage({
    super.key,
    required this.imageBytes,
    required this.defaultWidth,
    required this.defaultHeight,
    required this.defaultMaxColors,
  });

  final Uint8List imageBytes;
  final int defaultWidth;
  final int defaultHeight;
  final int defaultMaxColors;

  @override
  State<ImportConfigPage> createState() => _ImportConfigPageState();
}

class _ImportConfigPageState extends State<ImportConfigPage> {
  late int _width;
  late int _height;
  late double _maxColors;
  bool _showAdvanced = false;
  bool _dithering = false;
  bool _keepBackground = true;

  @override
  void initState() {
    super.initState();
    _width = widget.defaultWidth;
    _height = widget.defaultHeight;
    _maxColors = widget.defaultMaxColors.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppScaffold(
      appBar: AppBar(title: const Text('图片导入配置')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          AppCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('导入预览', style: TextStyle(fontWeight: FontWeight.w600, color: tokens.textPrimary)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    widget.imageBytes,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionHeader(title: '优先参数', subtitle: '新手默认只需调整这里'),
          const SizedBox(height: 10),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _numberField('输出宽度', _width, (value) => _width = value)),
                    const SizedBox(width: 12),
                    Expanded(child: _numberField('输出高度', _height, (value) => _height = value)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('最大颜色数', style: TextStyle(color: tokens.textPrimary)),
                    const Spacer(),
                    Text(_maxColors.toInt().toString(), style: TextStyle(color: tokens.primary)),
                  ],
                ),
                Slider(
                  value: _maxColors,
                  min: 2,
                  max: 16,
                  divisions: 14,
                  label: _maxColors.toInt().toString(),
                  onChanged: (value) => setState(() => _maxColors = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            onTap: () => setState(() => _showAdvanced = !_showAdvanced),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('高级参数', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Icon(_showAdvanced ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 220),
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: _dithering,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('抖动开关'),
                          onChanged: (value) => setState(() => _dithering = value),
                        ),
                        SwitchListTile(
                          value: _keepBackground,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('保留背景'),
                          onChanged: (value) => setState(() => _keepBackground = value),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: _showAdvanced ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('即时预估', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                _statRow('预计颗粒数', '${_width * _height}'),
                _statRow('预计颜色数', _maxColors.toInt().toString()),
                _statRow('预览复杂度', _complexity(_width * _height, _maxColors.toInt())),
              ],
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: '应用并继续',
            icon: Icons.check,
            onPressed: () {
              final config = ImportConfig(
                outputWidth: _width,
                outputHeight: _height,
                maxColors: _maxColors.toInt(),
                enableDithering: _dithering,
                keepBackground: _keepBackground,
              );
              Navigator.of(context).pop(config);
            },
          ),
        ],
      ),
    );
  }

  Widget _numberField(String label, int value, ValueChanged<int> onChanged) {
    return TextFormField(
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (raw) {
        final parsed = int.tryParse(raw);
        if (parsed != null) {
          setState(() => onChanged(parsed.clamp(8, 256)));
        }
      },
    );
  }

  Widget _statRow(String label, String value) {
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

  String _complexity(int beads, int colors) {
    if (beads > 5000 || colors > 12) return '高';
    if (beads > 2500 || colors > 8) return '中';
    return '低';
  }
}
