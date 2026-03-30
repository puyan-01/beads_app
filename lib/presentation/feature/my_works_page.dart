import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/ui/theme_tokens.dart';
import '../editor/editor_page.dart';
import '../shared/app_scaffold.dart';
import '../shared/empty_state_view.dart';
import '../shared/loading_skeleton.dart';
import '../shared/project_preview_card.dart';
import '../shared/section_header.dart';

class MyWorksPage extends ConsumerStatefulWidget {
  const MyWorksPage({super.key});

  @override
  ConsumerState<MyWorksPage> createState() => _MyWorksPageState();
}

class _MyWorksPageState extends ConsumerState<MyWorksPage> {
  String _filter = '最近编辑';

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(recentProjectsProvider);
    final tokens = context.tokens;

    return AppScaffold(
      appBar: AppBar(title: const Text('我的作品')),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.space16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            SectionHeader(title: '状态筛选'),
            const SizedBox(height: 10),
            Row(
              children: [
                _chip('最近编辑'),
                const SizedBox(width: 8),
                _chip('已完成'),
                const SizedBox(width: 8),
                _chip('草稿'),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: projectsAsync.when(
                loading: () => const LoadingSkeleton(itemCount: 4),
                error: (error, stack) => EmptyStateView(
                  title: '读取失败',
                  description: '$error',
                  icon: Icons.error_outline,
                ),
                data: (projects) {
                  final filtered = projects.where((project) {
                    final diff = DateTime.now().difference(project.updatedAt);
                    if (_filter == '最近编辑') return diff.inHours < 24;
                    if (_filter == '草稿') return diff.inDays < 3;
                    return diff.inDays >= 3;
                  }).toList();

                  if (filtered.isEmpty) {
                    return EmptyStateView(
                      title: '作品库还是空的',
                      description: '新建一个图纸，开始你的第一次创作',
                      icon: Icons.layers_clear,
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final project = filtered[index];
                      return ProjectPreviewCard(
                        project: project,
                        statusLabel: _filter,
                        onTap: () async {
                          final snapshot = await ref.read(loadProjectUseCaseProvider)(project.id);
                          if (snapshot == null || !context.mounted) {
                            return;
                          }
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => EditorPage(initialSnapshot: snapshot)),
                          );
                          ref.invalidate(recentProjectsProvider);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    final tokens = context.tokens;
    return ChoiceChip(
      label: Text(text),
      selected: _filter == text,
      selectedColor: tokens.primary.withValues(alpha: 0.2),
      onSelected: (_) => setState(() => _filter = text),
    );
  }
}




