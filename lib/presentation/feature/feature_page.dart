
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import '../../app/ui/text_styles.dart';
import '../../app/ui/theme_tokens.dart';
import '../../application/usecases/create_project_usecase.dart';
import '../editor/editor_page.dart';
import '../shared/app_card.dart';
import '../shared/empty_state_view.dart';
import '../shared/loading_skeleton.dart';
import '../shared/primary_button.dart';
import '../shared/project_preview_card.dart';
import '../shared/section_header.dart';
import '../shared/secondary_button.dart';
import '../template/template_page.dart';

class FeaturePage extends ConsumerWidget {
  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(recentProjectsProvider);
    final tokens = context.tokens;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('拼豆工坊', style: AppTextStyles.titlePage),
                const SizedBox(height: 4),
                Text(
                  '把图片快速转成拼豆图纸，继续你的创作',
                  style: AppTextStyles.body.copyWith(color: tokens.textSecondary),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('继续上次编辑', style: AppTextStyles.titleSection),
                      const SizedBox(height: 8),
                      Text(
                        '直接回到最近一次项目，减少重复操作。',
                        style: AppTextStyles.body.copyWith(color: tokens.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      projectsAsync.maybeWhen(
                        data: (projects) {
                          if (projects.isEmpty) {
                            return SecondaryButton(
                              label: '暂无最近项目',
                              onPressed: null,
                              icon: Icons.history,
                            );
                          }
                          return PrimaryButton(
                            label: '继续 ${projects.first.name}',
                            icon: Icons.play_arrow_rounded,
                            onPressed: () => _openProject(context, ref, projects.first.id),
                          );
                        },
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SectionHeader(title: '核心操作', subtitle: '第一优先导入图片，第二优先新建图纸'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.image_outlined,
                        title: '导入图片',
                        subtitle: '从相册快速开始',
                        onTap: () => _importImageFlow(context, ref),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.add_box_outlined,
                        title: '新建图纸',
                        subtitle: '创建空白项目',
                        onTap: () => _createProject(context, ref),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _QuickActionCard(
                  icon: Icons.auto_awesome,
                  title: '模板推荐',
                  subtitle: '浏览模板资源库（占位）',
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TemplatePage()));
                  },
                ),
                const SizedBox(height: 20),
                SectionHeader(title: '最近作品', subtitle: '继续创作你的项目'),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        projectsAsync.when(
          loading: () => SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: SizedBox(height: 280, child: LoadingSkeleton(itemCount: 3)),
            ),
          ),
          error: (error, stack) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: EmptyStateView(
                title: '读取失败',
                description: '$error',
                buttonText: '重试',
                onPressed: () => ref.invalidate(recentProjectsProvider),
                icon: Icons.error_outline,
              ),
            ),
          ),
          data: (projects) {
            if (projects.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: EmptyStateView(
                    title: '还没有作品',
                    description: '从一张喜欢的图片开始，做出你的第一张拼豆图纸',
                    buttonText: '导入图片',
                    onPressed: () => _importImageFlow(context, ref),
                    icon: Icons.interests_rounded,
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.separated(
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return AnimatedSlide(
                    duration: tokens.listEntrance,
                    curve: Curves.easeOut,
                    offset: const Offset(0, 0),
                    child: ProjectPreviewCard(
                      project: project,
                      statusLabel: _statusLabel(project.updatedAt),
                      onTap: () => _openProject(context, ref, project.id),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 12),
              ),
            );
          },
        ),
      ],
    );
  }

  String _statusLabel(DateTime updatedAt) {
    final diff = DateTime.now().difference(updatedAt);
    if (diff.inHours < 24) {
      return '最近编辑';
    }
    if (diff.inDays < 3) {
      return '草稿';
    }
    return '已完成';
  }

  Future<void> _openProject(BuildContext context, WidgetRef ref, String projectId) async {
    final loader = ref.read(loadProjectUseCaseProvider);
    final snapshot = await loader(projectId);
    if (snapshot == null || !context.mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditorPage(initialSnapshot: snapshot)),
    );
    ref.invalidate(recentProjectsProvider);
  }

  Future<void> _createProject(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_ProjectDraft>(
      context: context,
      builder: (_) => const _CreateProjectDialog(),
    );
    if (result == null || !context.mounted) {
      return;
    }

    final creator = ref.read(createProjectUseCaseProvider);
    final snapshot = await creator(
      CreateProjectInput(
        name: result.name,
        width: result.width,
        height: result.height,
      ),
    );

    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditorPage(initialSnapshot: snapshot)));
    ref.invalidate(recentProjectsProvider);
  }

  Future<void> _importImageFlow(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null || !context.mounted) {
      return;
    }

    final draft = await showDialog<_ProjectDraft>(
      context: context,
      builder: (_) => const _CreateProjectDialog(defaultName: '导入项目'),
    );

    if (draft == null || !context.mounted) {
      return;
    }

    final bytes = await picked.readAsBytes();
    final creator = ref.read(createProjectUseCaseProvider);
    final snapshot = await creator(
      CreateProjectInput(
        name: draft.name,
        width: draft.width,
        height: draft.height,
      ),
    );

    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditorPage(
          initialSnapshot: snapshot,
          initialImportBytes: bytes,
        ),
      ),
    );

    ref.invalidate(recentProjectsProvider);
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tokens.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: tokens.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: tokens.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectDraft {
  const _ProjectDraft({
    required this.name,
    required this.width,
    required this.height,
  });

  final String name;
  final int width;
  final int height;
}

class _CreateProjectDialog extends StatefulWidget {
  const _CreateProjectDialog({this.defaultName = '新建图纸'});

  final String defaultName;

  @override
  State<_CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<_CreateProjectDialog> {
  late final TextEditingController _nameController;
  final TextEditingController _widthController = TextEditingController(text: '58');
  final TextEditingController _heightController = TextEditingController(text: '58');

  bool get _isValid {
    if (_nameController.text.trim().isEmpty) {
      return false;
    }
    final width = int.tryParse(_widthController.text);
    final height = int.tryParse(_heightController.text);
    if (width == null || height == null) {
      return false;
    }
    return width >= 8 && width <= 256 && height >= 8 && height <= 256;
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.defaultName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(tokens.radiusCard)),
      title: const Text('新建项目'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '名称'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _widthController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '宽度'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '高度'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!_isValid)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '请填写名称，并保证宽高在 8~256 之间',
                style: TextStyle(fontSize: 12, color: Colors.redAccent),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('取消')),
        FilledButton(
          onPressed: _isValid
              ? () {
            final width = int.tryParse(_widthController.text) ?? 58;
            final height = int.tryParse(_heightController.text) ?? 58;
            final draft = _ProjectDraft(
              name: _nameController.text.trim().isEmpty ? widget.defaultName : _nameController.text.trim(),
              width: width.clamp(8, 256),
              height: height.clamp(8, 256),
            );
            Navigator.of(context).pop(draft);
          }
              : null,
          child: const Text('创建'),
        ),
      ],
    );
  }
}




