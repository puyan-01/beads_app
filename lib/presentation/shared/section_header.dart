import 'package:flutter/material.dart';

import '../../app/ui/text_styles.dart';
import '../../app/ui/theme_tokens.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleSection),
              if (subtitle case final subtitleText?) ...[
                SizedBox(height: tokens.space4),
                Text(
                  subtitleText,
                  style: AppTextStyles.caption.copyWith(color: tokens.textSecondary),
                ),
              ],
            ],
          ),
        ),
        ...?(trailing == null ? null : <Widget>[trailing!]),
      ],
    );
  }
}

