import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/reaction_model.dart';

class ReactionBar extends StatelessWidget {
  final Map<String, int> reactions;
  final List<String> userReactions;
  final Function(String emoji)? onReactionTap;
  final VoidCallback? onAddReaction;

  const ReactionBar({
    super.key,
    required this.reactions,
    this.userReactions = const [],
    this.onReactionTap,
    this.onAddReaction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (reactions.isEmpty && onAddReaction == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Existing Reactions
        if (reactions.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: reactions.entries.map((entry) {
              final emoji = entry.key;
              final count = entry.value;
              final isUserReaction = userReactions.contains(emoji);

              return _buildReactionChip(
                context,
                emoji: emoji,
                count: count,
                isSelected: isUserReaction,
                onTap: () => onReactionTap?.call(emoji),
                isDark: isDark,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Add Reaction Button
        if (onAddReaction != null) _buildAddReactionButton(context, isDark),
      ],
    );
  }

  Widget _buildReactionChip(
    BuildContext context, {
    required String emoji,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withOpacity(0.15)
              : (isDark ? AppColors.cardDark : AppColors.cardLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : (isDark ? AppColors.dividerDark : AppColors.dividerLight),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Text(
                count.toString(),
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected
                      ? AppColors.accent
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddReactionButton(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => _showReactionPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_reaction_outlined,
              size: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 6),
            Text(
              'React',
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReactionPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'React to this entry',
              style: AppTextStyles.h6,
            ),
            const SizedBox(height: 16),

            // Common Reactions
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: EmojiReactions.common.map((emoji) {
                final isSelected = userReactions.contains(emoji);
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onReactionTap?.call(emoji);
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.accent.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.accent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
