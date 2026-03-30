import 'package:flutter/material.dart';

import '../../app/ui/text_styles.dart';
import '../../app/ui/theme_tokens.dart';
import 'pressable_scale.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return PressableScale(
      onTap: onPressed,
      duration: tokens.pressDuration,
      child: AnimatedContainer(
        duration: tokens.pressDuration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.radiusButton),
          gradient: LinearGradient(
            colors: [tokens.primary, tokens.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: tokens.shadowFloat,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTextStyles.buttonText),
          ],
        ),
      ),
    );
  }
}
