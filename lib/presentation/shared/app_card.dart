import 'package:flutter/material.dart';

import '../../app/ui/theme_tokens.dart';

class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.enableTapBounce = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final bool enableTapBounce;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _highlighted = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isInteractive = widget.onTap != null;
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: isInteractive
          ? (_) => setState(() {
              _highlighted = true;
              _pressed = true;
            })
          : null,
      onTapCancel: isInteractive
          ? () => setState(() {
              _highlighted = false;
              _pressed = false;
            })
          : null,
      onTapUp: isInteractive
          ? (_) => setState(() {
              _highlighted = false;
              _pressed = false;
            })
          : null,
      child: AnimatedScale(
        duration: tokens.pressDuration,
        scale: widget.enableTapBounce && _pressed ? 0.98 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: tokens.cardBg,
            borderRadius: BorderRadius.circular(tokens.radiusCard),
            boxShadow: _highlighted ? tokens.shadowFloat : tokens.shadowCard,
            border: Border.all(
              color: _highlighted
                  ? tokens.primary.withValues(alpha: 0.35)
                  : tokens.borderLight,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
