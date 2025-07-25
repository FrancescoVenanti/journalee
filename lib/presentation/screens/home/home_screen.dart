import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journalee/data/models/user_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/journal_provider.dart';
import '../../providers/entry_providers.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/journal/journal_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh all data
            ref.invalidate(currentUserProvider);
            ref.invalidate(userJournalsProvider);
            ref.invalidate(recentEntriesProvider);
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: false,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                  title: _buildAppBarTitle(context),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkBackgroundGradient
                          : AppColors.backgroundGradient,
                    ),
                  ),
                ),
                actions: [
                  _buildAddButton(context),
                  const SizedBox(width: 16),
                ],
              ),

              // Welcome Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildWelcomeSection(context, currentUser),
                ),
              ),

              // Recent Activity Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        context,
                        'Recent Entries',
                        onSeeAll: () {
                          // Navigate to full entries screen
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildRecentEntries(context, ref),
                    ],
                  ),
                ),
              ),

              // Journals Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(
                        context,
                        'Your Journals',
                        onSeeAll: () => context.go('/shared'),
                      ),
                      const SizedBox(height: 16),
                      _buildJournalsPreview(context, ref),
                    ],
                  ),
                ),
              ),

              // Bottom padding
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return Text(
      'Journalee',
      style: AppTextStyles.h3.copyWith(
        color: Theme.of(context).colorScheme.onBackground,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.add,
          color: Colors.white,
          size: 24,
        ),
        onPressed: () => _showCreateOptions(context),
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create New',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/personal/create');
              },
              leftIcon: Icons.person,
              child: const Text('Personal Journal'),
            ),
            const SizedBox(height: 12),
            CustomButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/shared/create');
              },
              variant: ButtonVariant.outline,
              leftIcon: Icons.people,
              child: const Text('Shared Journal'),
            ),
            const SizedBox(height: 12),
            CustomButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to quick entry - for now, just show message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Quick entry coming soon!'),
                  ),
                );
              },
              variant: ButtonVariant.text,
              leftIcon: Icons.edit,
              child: const Text('Quick Entry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(
      BuildContext context, AsyncValue<UserModel?> currentUser) {
    return currentUser.when(
      data: (user) => _buildWelcomeCard(context, user),
      loading: () => _buildWelcomeCardSkeleton(context),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, UserModel? user) {
    final timeOfDay = _getTimeOfDay();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$timeOfDay, ${user?.displayName ?? 'there'}!',
            style: AppTextStyles.h4.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to capture today\'s thoughts and experiences?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: () {
              // Show quick entry coming soon message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Quick entry coming soon!'),
                ),
              );
            },
            backgroundColor: Colors.white,
            foregroundColor: AppColors.accent,
            size: ButtonSize.medium,
            isFullWidth: false,
            leftIcon: Icons.edit,
            child: const Text('Start Writing'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCardSkeleton(BuildContext context) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 24,
            width: 180,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.h5.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: Text(
              'See All',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.accent,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRecentEntries(BuildContext context, WidgetRef ref) {
    final recentEntriesAsync = ref.watch(recentEntriesProvider);

    return recentEntriesAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return _buildEmptyRecentEntries(context);
        }

        return Column(
          children: entries.take(3).map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.cardDark
                    : AppColors.cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.dividerDark
                      : AppColors.dividerLight,
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title ?? 'Untitled Entry',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatRelativeTime(entry.createdAt),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.preview,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
      loading: () => _buildRecentEntriesSkeleton(),
      error: (error, stack) => _buildRecentEntriesError(context),
    );
  }

  Widget _buildEmptyRecentEntries(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.article_outlined,
            size: 48,
            color: isDark
                ? AppColors.textSecondaryDark.withOpacity(0.5)
                : AppColors.textSecondaryLight.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No entries yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start writing to see your recent entries here',
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

  Widget _buildRecentEntriesSkeleton() {
    return Column(
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  Widget _buildRecentEntriesError(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error.withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'Failed to load recent entries',
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

  Widget _buildJournalsPreview(BuildContext context, WidgetRef ref) {
    final journalsAsync = ref.watch(userJournalsProvider);

    return journalsAsync.when(
      data: (journals) {
        if (journals.isEmpty) {
          return _buildEmptyJournals(context);
        }

        return SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: journals.length.clamp(0, 5), // Show max 5 journals
            itemBuilder: (context, index) {
              final journal = journals[index];
              return Container(
                width: 200,
                margin: EdgeInsets.only(
                    right: index < journals.length - 1 ? 16 : 0),
                child: JournalCard(
                  title: journal.title,
                  subtitle: journal.description ?? journal.typeText,
                  isShared: journal.isShared,
                  memberCount: journal.memberCount,
                  lastEntryDate: journal.lastEntryAt,
                  entryCount: journal.entryCount,
                  onTap: () => AppRouter.goToJournalDetail(context, journal.id),
                ),
              );
            },
          ),
        );
      },
      loading: () => _buildJournalsSkeleton(),
      error: (error, stack) => _buildJournalsError(context),
    );
  }

  Widget _buildEmptyJournals(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 160,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 48,
            color: isDark
                ? AppColors.textSecondaryDark.withOpacity(0.5)
                : AppColors.textSecondaryLight.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No journals yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first journal to get started',
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

  Widget _buildJournalsSkeleton() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: EdgeInsets.only(right: index < 2 ? 16 : 0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildJournalsError(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 160,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error.withOpacity(0.6),
          ),
          const SizedBox(height: 12),
          Text(
            'Failed to load journals',
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

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }
}
