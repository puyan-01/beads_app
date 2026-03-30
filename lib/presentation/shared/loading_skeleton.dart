import 'package:flutter/material.dart';

import '../../app/ui/theme_tokens.dart';

class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({
    super.key,
    this.itemCount = 3,
  });

  final int itemCount;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.25 + (_controller.value * 0.35);
        return ListView.separated(
          itemCount: widget.itemCount,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Container(
              height: 82,
              decoration: BoxDecoration(
                color: tokens.borderLight.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(tokens.radiusCard),
              ),
            );
          },
        );
      },
    );
  }
}

