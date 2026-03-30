import 'package:flutter/material.dart';

import '../../app/ui/theme_tokens.dart';
import '../../app/ui/ui_spec.dart';
import '../feature/feature_page.dart';
import '../profile/profile_page.dart';
import '../shared/app_scaffold.dart';

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  AppTab _current = AppTab.feature;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const FeaturePage(),
      const ProfilePage(),
    ];

    return AppScaffold(
      body: IndexedStack(
        index: _current.index,
        children: pages,
      ),
      bottomNavigationBar: _AnimatedBottomBar(
        current: _current,
        onChange: (tab) {
          if (tab == _current) {
            return;
          }
          setState(() => _current = tab);
        },
      ),
    );
  }
}

class _AnimatedBottomBar extends StatelessWidget {
  const _AnimatedBottomBar({
    required this.current,
    required this.onChange,
  });

  final AppTab current;
  final ValueChanged<AppTab> onChange;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: tokens.cardBg,
          borderRadius: BorderRadius.circular(tokens.radiusLarge),
          boxShadow: tokens.shadowFloat,
          border: Border.all(color: tokens.borderLight),
        ),
        child: Row(
          children: [
            _tabItem(
              context,
              tab: AppTab.feature,
              icon: Icons.widgets_rounded,
              label: '功能',
            ),
            _tabItem(
              context,
              tab: AppTab.profile,
              icon: Icons.person_rounded,
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(
    BuildContext context, {
    required AppTab tab,
    required IconData icon,
    required String label,
  }) {
    final tokens = context.tokens;
    final selected = current == tab;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusButton),
        onTap: () => onChange(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 9),
          transform: Matrix4.translationValues(0, selected ? -1.5 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radiusButton),
            gradient: selected
                ? LinearGradient(
                    colors: [tokens.primary, tokens.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: selected ? Colors.white : tokens.textSecondary),
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : tokens.textSecondary,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
