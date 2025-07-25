import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'activity_item.dart';

// Mock activity data for now - this will be replaced with real provider
final recentActivitiesProvider = Provider<List<ActivityData>>((ref) {
  return [
    ActivityData(
      userDisplayName: 'Liam',
      userAvatarUrl: null,
      action: 'added a new entry',
      journalName: 'Shared Journal',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      entryPreview:
          'Today, I had a profound realization about the nature of time...',
    ),
    ActivityData(
      userDisplayName: 'You',
      userAvatarUrl: null,
      action: 'added a new entry',
      journalName: 'Personal Journal',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      entryPreview: 'Reflecting on yesterday\'s meditation session...',
    ),
    ActivityData(
      userDisplayName: 'Sarah',
      userAvatarUrl: null,
      action: 'commented on an entry',
      journalName: 'Shared Journal',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      commentPreview: 'This resonates deeply with my own experiences.',
    ),
    ActivityData(
      userDisplayName: 'You',
      userAvatarUrl: null,
      action: 'created a new journal',
      journalName: 'Morning Thoughts',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
});

class ActivityList extends ConsumerWidget {
  final int? limit;
  final bool showHeader;

  const ActivityList({
    super.key,
    this.limit,
    this.showHeader = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activities = ref.watch(recentActivitiesProvider);
    final displayActivities =
        limit != null ? activities.take(limit!).toList() : activities;

    if (displayActivities.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showHeader) ...[
          Text(
            'Recent Activity',
            style: AppTextStyles.h5.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
        ],
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayActivities.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final activity = displayActivities[index];
            return ActivityItem(
              activity: activity,
              onTap: () => _handleActivityTap(context, activity),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.timeline_outlined,
            size: 64,
            color: isDark
                ? AppColors.textSecondaryDark.withOpacity(0.5)
                : AppColors.textSecondaryLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Recent Activity',
            style: AppTextStyles.h6.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start writing or join a journal to see activity here',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _handleActivityTap(BuildContext context, ActivityData activity) {
    // Handle navigation based on activity type
    // This would navigate to the appropriate screen (journal, entry, etc.)
  }
}

class ActivityData {
  final String userDisplayName;
  final String? userAvatarUrl;
  final String action;
  final String journalName;
  final DateTime timestamp;
  final String? entryPreview;
  final String? commentPreview;

  ActivityData({
    required this.userDisplayName,
    this.userAvatarUrl,
    required this.action,
    required this.journalName,
    required this.timestamp,
    this.entryPreview,
    this.commentPreview,
  });
}
