import 'package:flutter/material.dart';

import '../../app/ui/theme_tokens.dart';
import 'primary_button.dart';

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.title,
    required this.description,
    this.buttonText,
    this.onPressed,
    this.icon = Icons.auto_awesome,
  });

  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [tokens.primary.withValues(alpha: 0.25), tokens.accent.withValues(alpha: 0.3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, size: 42, color: tokens.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: tokens.textSecondary,
              ),
            ),
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 16),
              PrimaryButton(label: buttonText!, onPressed: onPressed),
            ],
          ],
        ),
      ),
    );
  }
}

