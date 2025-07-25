import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journalee/data/models/journal_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../providers/journal_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/journal/journal_card.dart';

enum JournalType { shared, personal }

class JournalListScreen extends ConsumerWidget {
  final JournalType journalType;

  const JournalListScreen({
    super.key,
    required this.journalType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalsAsync = journalType == JournalType.shared
        ? ref.watch(sharedJournalsProvider)
        : ref.watch(personalJournalsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(journalType == JournalType.shared
                ? sharedJournalsProvider
                : personalJournalsProvider);
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

              // Content
              journalsAsync.when(
                data: (journals) => _buildJournalsList(context, journals),
                loading: () => const SliverToBoxAdapter(
                  child: LoadingWidget(),
                ),
                error: (error, stack) => SliverToBoxAdapter(
                  child: _buildErrorView(context, error.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    final title = journalType == JournalType.shared ? 'Shared' : 'Personal';
    return Text(
      title,
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
        onPressed: () => AppRouter.goToCreateJournal(
          context,
          isShared: journalType == JournalType.shared,
        ),
      ),
    );
  }

  Widget _buildJournalsList(BuildContext context, List<JournalModel> journals) {
    if (journals.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyState(context),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final journal = journals[index];
            return JournalCard(
              title: journal.title,
              subtitle: journal.description ?? journal.typeText,
              isShared: journal.isShared,
              memberCount: journal.memberCount,
              lastEntryDate: journal.lastEntryAt,
              entryCount: journal.entryCount,
              onTap: () => AppRouter.goToJournalDetail(context, journal.id),
            );
          },
          childCount: journals.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isShared = journalType == JournalType.shared;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          // Illustration
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: (isShared
                      ? AppColors.sharedJournal
                      : AppColors.personalJournal)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              isShared ? Icons.people_outline : Icons.person_outline,
              size: 60,
              color: isShared
                  ? AppColors.sharedJournal
                  : AppColors.personalJournal,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            isShared ? 'No Shared Journals' : 'No Personal Journals',
            style: AppTextStyles.h4.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Description
          Text(
            isShared
                ? 'Create a shared journal to collaborate with friends and family, or ask someone to invite you to theirs.'
                : 'Create your first personal journal to start capturing your thoughts and experiences.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Create Button
          CustomButton(
            onPressed: () => AppRouter.goToCreateJournal(
              context,
              isShared: isShared,
            ),
            leftIcon: Icons.add,
            isFullWidth: false,
            child: Text(
                isShared ? 'Create Shared Journal' : 'Create Personal Journal'),
          ),

          if (isShared) ...[
            const SizedBox(height: 16),
            CustomButton(
              onPressed: () => _showJoinJournalDialog(context),
              variant: ButtonVariant.outline,
              leftIcon: Icons.link,
              isFullWidth: false,
              child: const Text('Join with Code'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withOpacity(0.6),
          ),
          const SizedBox(height: 24),
          Text(
            'Something went wrong',
            style: AppTextStyles.h5.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: () {
              final ref = ProviderScope.containerOf(context);
              ref.invalidate(journalType == JournalType.shared
                  ? sharedJournalsProvider
                  : personalJournalsProvider);
            },
            variant: ButtonVariant.outline,
            leftIcon: Icons.refresh,
            isFullWidth: false,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showJoinJournalDialog(BuildContext context) {
    final codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Journal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the invitation code to join a shared journal:'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Invitation Code',
                hintText: 'Enter code',
              ),
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle join journal logic
              Navigator.pop(context);
              // Show success/error message
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}
