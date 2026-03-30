import 'package:flutter/material.dart';

import '../../app/ui/theme_tokens.dart';
import 'pressable_scale.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: tokens.cardBg,
          borderRadius: BorderRadius.circular(tokens.radiusButton),
          border: Border.all(color: tokens.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: tokens.textPrimary),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: tokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
