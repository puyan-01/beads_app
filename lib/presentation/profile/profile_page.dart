import 'package:flutter/material.dart';

import '../../app/ui/theme_tokens.dart';
import '../../app/ui/ui_spec.dart';
import '../feature/my_works_page.dart';
import '../shared/app_card.dart';
import '../shared/app_scaffold.dart';
import '../shared/section_header.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.primary.withValues(alpha: 0.16),
                ),
                child: Icon(Icons.person_rounded, color: tokens.primary, size: 30),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '我的',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                  ),
                  Text('设置与版本信息', style: TextStyle(color: tokens.textSecondary, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SectionHeader(title: '作品管理'),
          const SizedBox(height: 12),
          AppCard(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyWorksPage()));
            },
            child: Row(
              children: [
                Icon(Icons.grid_view_rounded, color: tokens.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('我的作品', style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: '设置'),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                _settingTile(context, icon: Icons.palette_outlined, title: '配色与显示', subtitle: '浅色模式（P0固定）'),
                const Divider(height: 20),
                _settingTile(context, icon: Icons.save_outlined, title: '自动保存', subtitle: '已开启'),
                const Divider(height: 20),
                _settingTile(context, icon: Icons.info_outline, title: '关于应用', subtitle: '拼豆 App'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionHeader(title: '版本信息'),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('UI Spec 版本: $uiSpecVersion', style: TextStyle(color: tokens.textPrimary, fontSize: 14)),
                const SizedBox(height: 8),
                Text('Template 模式: ${TemplateEntryMode.placeholder.name}', style: TextStyle(color: tokens.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final tokens = context.tokens;
    return Row(
      children: [
        Icon(icon, color: tokens.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: tokens.textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: tokens.textSecondary, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
