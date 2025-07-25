import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../providers/entry_providers.dart';
import 'activity_item.dart';

// Real activity provider that fetches recent entries as activities
final recentActivitiesProvider =
    FutureProvider<List<ActivityData>>((ref) async {
  try {
    // Get recent entries to show as activities
    final entries = await ref.watch(recentEntriesProvider.future);

    // Convert entries to activity data
    return entries.map((entry) {
      return ActivityData(
        id: entry.id,
        userDisplayName: entry.author?.displayName ?? 'Unknown User',
        userAvatarUrl: entry.author?.avatarUrl,
        action: 'added a new entry',
        journalName: 'Journal', // We'd need to fetch journal name separately
        timestamp: entry.createdAt,
        entryPreview: entry.preview,
        activityType: ActivityType.entryCreated,
        relatedId: entry.id,
        journalId: entry.journalId,
      );
    }).toList();
  } catch (e) {
    // Return empty list if there's an error
    return [];
  }
});

enum ActivityType {
  entryCreated,
  commentAdded,
  reactionAdded,
  journalCreated,
  memberAdded,
}

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
    final activitiesAsync = ref.watch(recentActivitiesProvider);

    return activitiesAsync.when(
      data: (activities) => _buildActivitiesList(context, activities),
      loading: () => _buildLoadingState(context),
      error: (error, stack) => _buildErrorState(context),
    );
  }

  Widget _buildActivitiesList(
      BuildContext context, List<ActivityData> activities) {
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

  Widget _buildLoadingState(BuildContext context) {
    return Column(
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
        // Show skeleton loading
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: limit ?? 5,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Activity',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
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
    switch (activity.activityType) {
      case ActivityType.entryCreated:
        if (activity.relatedId != null) {
          AppRouter.goToEntryDetail(context, activity.relatedId!);
        }
        break;
      case ActivityType.commentAdded:
        if (activity.relatedId != null) {
          AppRouter.goToEntryDetail(context, activity.relatedId!);
        }
        break;
      case ActivityType.journalCreated:
        if (activity.journalId != null) {
          AppRouter.goToJournalDetail(context, activity.journalId!);
        }
        break;
      default:
        // For other types, just show a message for now
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feature coming soon!'),
          ),
        );
    }
  }
}

class ActivityData {
  final String id;
  final String userDisplayName;
  final String? userAvatarUrl;
  final String action;
  final String journalName;
  final DateTime timestamp;
  final String? entryPreview;
  final String? commentPreview;
  final ActivityType activityType;
  final String? relatedId; // Entry ID, Comment ID, etc.
  final String? journalId;

  ActivityData({
    required this.id,
    required this.userDisplayName,
    this.userAvatarUrl,
    required this.action,
    required this.journalName,
    required this.timestamp,
    this.entryPreview,
    this.commentPreview,
    required this.activityType,
    this.relatedId,
    this.journalId,
  });
}
