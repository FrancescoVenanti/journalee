import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_helpers.dart';

class EntryCard extends StatelessWidget {
  final String? title;
  final String content;
  final String author;
  final String? authorAvatarUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int commentCount;
  final int reactionCount;
  final List<String>? reactions;
  final bool isEdited;
  final VoidCallback onTap;
  final VoidCallback? onComment;
  final VoidCallback? onReact;

  const EntryCard({
    super.key,
    this.title,
    required this.content,
    required this.author,
    this.authorAvatarUrl,
    required this.createdAt,
    this.updatedAt,
    this.commentCount = 0,
    this.reactionCount = 0,
    this.reactions,
    this.isEdited = false,
    required this.onTap,
    this.onComment,
    this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with author info
              _buildHeader(context, isDark),

              const SizedBox(height: 12),

              // Title (if exists)
              if (title != null && title!.isNotEmpty) ...[
                Text(
                  title!,
                  style: AppTextStyles.entryTitle.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],

              // Content preview
              Text(
                _getContentPreview(),
                style: AppTextStyles.entryContent.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 16),

              // Footer with interactions
              _buildFooter(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Author Avatar
        _buildAvatar(),

        const SizedBox(width: 12),

        // Author info and timestamp
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    author,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  if (isEdited) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.textSecondaryDark.withOpacity(0.2)
                            : AppColors.textSecondaryLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'edited',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                DateHelpers.getSmartDate(createdAt),
                style: AppTextStyles.entryDate.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),

        // More options
        IconButton(
          icon: Icon(
            Icons.more_horiz,
            size: 20,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          onPressed: () => _showEntryOptions(context),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: authorAvatarUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                authorAvatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAvatarFallback(),
              ),
            )
          : _buildAvatarFallback(),
    );
  }

  Widget _buildAvatarFallback() {
    final initials =
        author.isNotEmpty ? author.substring(0, 1).toUpperCase() : '?';

    return Center(
      child: Text(
        initials,
        style: AppTextStyles.labelMedium.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark) {
    return Row(
      children: [
        // Reactions
        if (reactions != null && reactions!.isNotEmpty) ...[
          _buildReactionChip(isDark),
          const SizedBox(width: 8),
        ] else if (reactionCount > 0) ...[
          _buildReactionCount(isDark),
          const SizedBox(width: 8),
        ],

        // Comments
        if (commentCount > 0) ...[
          _buildCommentCount(isDark),
          const SizedBox(width: 8),
        ],

        const Spacer(),

        // Action buttons
        _buildActionButtons(context, isDark),
      ],
    );
  }

  Widget _buildReactionChip(bool isDark) {
    final displayReactions = reactions!.take(3).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withOpacity(0.5)
            : AppColors.backgroundLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...displayReactions.map((emoji) => Text(
                emoji,
                style: const TextStyle(fontSize: 14),
              )),
          if (reactionCount > displayReactions.length) ...[
            const SizedBox(width: 4),
            Text(
              '+${reactionCount - displayReactions.length}',
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReactionCount(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.favorite_border,
          size: 16,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 4),
        Text(
          reactionCount.toString(),
          style: AppTextStyles.labelSmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentCount(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.chat_bubble_outline,
          size: 16,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        const SizedBox(width: 4),
        Text(
          commentCount.toString(),
          style: AppTextStyles.labelSmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onReact != null)
          IconButton(
            icon: Icon(
              Icons.favorite_border,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            onPressed: onReact,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        if (onComment != null)
          IconButton(
            icon: Icon(
              Icons.chat_bubble_outline,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            onPressed: onComment,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  String _getContentPreview() {
    // Remove any HTML tags or rich text formatting for preview
    final plainContent = content.replaceAll(RegExp(r'<[^>]*>'), '');

    if (plainContent.length <= 200) {
      return plainContent;
    }

    return '${plainContent.substring(0, 200)}...';
  }

  void _showEntryOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Entry'),
              onTap: () {
                Navigator.pop(context);
                // Handle edit
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Entry'),
              onTap: () {
                Navigator.pop(context);
                // Handle share
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Entry'),
              textColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                // Handle delete
              },
            ),
          ],
        ),
      ),
    );
  }
}
