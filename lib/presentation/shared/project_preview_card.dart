import 'package:flutter/material.dart';

import '../../app/ui/theme_tokens.dart';
import '../../domain/entities/bead_project.dart';
import 'app_card.dart';

class ProjectPreviewCard extends StatelessWidget {
  const ProjectPreviewCard({
    super.key,
    required this.project,
    required this.onTap,
    this.statusLabel,
  });

  final BeadProject project;
  final VoidCallback onTap;
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [tokens.primary.withValues(alpha: 0.35), tokens.accent.withValues(alpha: 0.3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.grid_view_rounded),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          color: tokens.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (statusLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: tokens.primary.withValues(alpha: 0.12),
                        ),
                        child: Text(
                          statusLabel!,
                          style: TextStyle(
                            color: tokens.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${project.canvasWidth}x${project.canvasHeight}',
                  style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '更新于 ${project.updatedAt.toLocal()}',
                  style: TextStyle(color: tokens.textTertiary, fontSize: 11),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: tokens.textSecondary),
        ],
      ),
    );
  }
}

