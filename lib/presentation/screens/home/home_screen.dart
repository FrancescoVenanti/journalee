import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journalee/data/models/user_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/activity/activity_list.dart';
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
            // Refresh data
            ref.invalidate(currentUserProvider);
            // Add other data refreshes here
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
                        'Recent Activity',
                        onSeeAll: () {
                          // Navigate to full activity screen
                        },
                      ),
                      const SizedBox(height: 16),
                      const ActivityList(limit: 5),
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
                        'Journals',
                        onSeeAll: () => context.go('/shared'),
                      ),
                      const SizedBox(height: 16),
                      _buildJournalsPreview(context),
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
      'CoJournal',
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
                // Navigate to quick entry
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
              // Navigate to quick entry
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

  Widget _buildJournalsPreview(BuildContext context) {
    // This would normally fetch from a provider
    // For now, showing placeholder
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: EdgeInsets.only(right: index < 2 ? 16 : 0),
            child: JournalCard(
              title: index == 0 ? 'Personal Journal' : 'Shared Journal',
              subtitle: index == 0 ? 'Personal Journal' : 'Shared Journal',
              isShared: index != 0,
              memberCount: index == 0 ? null : 3,
              lastEntryDate: DateTime.now().subtract(Duration(days: index)),
              onTap: () {
                // Navigate to journal detail
              },
            ),
          );
        },
      ),
    );
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
