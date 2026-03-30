import 'package:flutter/material.dart';

import '../../app/ui/theme_tokens.dart';
import 'pressable_scale.dart';

class ToolIconButton extends StatelessWidget {
  const ToolIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return PressableScale(
      onTap: onPressed,
      duration: const Duration(milliseconds: 120),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        width: 56,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(tokens.radiusButton),
          gradient: selected
              ? LinearGradient(colors: [tokens.primary, tokens.accent])
              : null,
          color: selected ? null : tokens.cardBg,
          border: Border.all(color: selected ? Colors.transparent : tokens.borderLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: selected ? 1.06 : 1,
              duration: const Duration(milliseconds: 140),
              child: Icon(icon, size: 20, color: selected ? Colors.white : tokens.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white : tokens.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
