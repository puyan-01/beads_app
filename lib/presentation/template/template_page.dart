import 'package:flutter/material.dart';

import '../../app/ui/theme_tokens.dart';
import '../shared/app_scaffold.dart';
import '../shared/empty_state_view.dart';
import '../shared/section_header.dart';

class TemplatePage extends StatefulWidget {
  const TemplatePage({super.key});

  @override
  State<TemplatePage> createState() => _TemplatePageState();
}

class _TemplatePageState extends State<TemplatePage> {
  String _price = '免费';
  String _sort = '热门';

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppScaffold(
      appBar: AppBar(title: const Text('模板库')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: '筛选与排序', subtitle: '占位模式：模板即将上线'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip('免费', _price == '免费', () => setState(() => _price = '免费')),
                _chip('付费', _price == '付费', () => setState(() => _price = '付费')),
                _chip('热门', _sort == '热门', () => setState(() => _sort = '热门')),
                _chip('最新', _sort == '最新', () => setState(() => _sort = '最新')),
                _chip('简单入门', _sort == '简单入门', () => setState(() => _sort = '简单入门')),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: EmptyStateView(
                title: '没有找到相关模板',
                description: '试试更换关键词或分类',
                buttonText: '查看全部',
                onPressed: () {},
                icon: Icons.auto_awesome,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '提示：当前为 TemplateEntryMode.placeholder',
              style: TextStyle(fontSize: 12, color: tokens.textTertiary),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, bool selected, VoidCallback onTap) {
    final tokens = context.tokens;
    return ChoiceChip(
      label: Text(text),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: tokens.primary.withValues(alpha: 0.2),
    );
  }
}

