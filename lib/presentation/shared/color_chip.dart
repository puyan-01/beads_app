import 'package:flutter/material.dart';

import '../../app/ui/theme_tokens.dart';
import 'pressable_scale.dart';

class ColorChip extends StatelessWidget {
  const ColorChip({
    super.key,
    required this.color,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return PressableScale(
      onTap: onTap,
      duration: const Duration(milliseconds: 120),
      scale: selected ? 1.0 : 0.98,
      child: AnimatedScale(
        scale: selected ? 1.05 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(tokens.radiusTag),
            border: Border.all(
              color: selected ? tokens.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: AnimatedOpacity(
            opacity: selected ? 1 : 0.7,
            duration: const Duration(milliseconds: 120),
            child: Text(
              name,
              style: TextStyle(
                color: _foregroundFor(color),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _foregroundFor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.55 ? Colors.black87 : Colors.white;
  }
}
