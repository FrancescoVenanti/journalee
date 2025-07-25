import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_helpers.dart';
import 'activity_list.dart';

class ActivityItem extends StatelessWidget {
  final ActivityData activity;
  final VoidCallback? onTap;

  const ActivityItem({
    super.key,
    required this.activity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            _buildAvatar(context),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action description
                  _buildActionText(context, isDark),

                  const SizedBox(height: 4),

                  // Timestamp
                  Text(
                    DateHelpers.getRelativeTime(activity.timestamp),
                    style: AppTextStyles.activitySubtitle.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),

                  // Preview text if available
                  if (activity.entryPreview != null ||
                      activity.commentPreview != null) ...[
                    const SizedBox(height: 8),
                    _buildPreview(context, isDark),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final isCurrentUser = activity.userDisplayName == 'You';

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _getAvatarColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: activity.userAvatarUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                activity.userAvatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAvatarFallback(),
              ),
            )
          : _buildAvatarFallback(),
    );
  }

  Widget _buildAvatarFallback() {
    final initials = activity.userDisplayName.isNotEmpty
        ? activity.userDisplayName.substring(0, 1).toUpperCase()
        : '?';

    return Center(
      child: Text(
        initials,
        style: AppTextStyles.labelMedium.copyWith(
          color: _getAvatarColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionText(BuildContext context, bool isDark) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.activityTitle.copyWith(
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        children: [
          TextSpan(
            text: activity.userDisplayName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          TextSpan(text: ' ${activity.action} '),
          if (activity.journalName.isNotEmpty) ...[
            const TextSpan(text: 'in '),
            TextSpan(
              text: activity.journalName,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _getJournalTypeColor(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context, bool isDark) {
    final previewText = activity.entryPreview ?? activity.commentPreview ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.backgroundDark.withOpacity(0.5)
            : AppColors.backgroundLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Text(
        previewText.length > 100
            ? '${previewText.substring(0, 100)}...'
            : previewText,
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          fontStyle: activity.commentPreview != null ? FontStyle.italic : null,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Color _getAvatarColor() {
    // Color based on activity type
    switch (activity.activityType) {
      case ActivityType.entryCreated:
        return AppColors.accent;
      case ActivityType.commentAdded:
        return AppColors.info;
      case ActivityType.reactionAdded:
        return AppColors.warning;
      case ActivityType.journalCreated:
        return AppColors.success;
      case ActivityType.memberAdded:
        return AppColors.sharedJournal;
    }
  }

  Color _getJournalTypeColor() {
    // This would be determined by actual journal data
    // For now, using a simple heuristic based on activity type
    switch (activity.activityType) {
      case ActivityType.journalCreated:
      case ActivityType.memberAdded:
        return AppColors.sharedJournal;
      default:
        return activity.journalName.toLowerCase().contains('shared')
            ? AppColors.sharedJournal
            : AppColors.personalJournal;
    }
  }
}
