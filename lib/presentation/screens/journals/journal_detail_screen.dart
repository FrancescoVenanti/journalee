import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../data/models/journal_model.dart';
import '../../providers/journal_provider.dart';
import '../../providers/entry_providers.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/entry/entry_card.dart';

class JournalDetailScreen extends ConsumerWidget {
  final String journalId;

  const JournalDetailScreen({
    super.key,
    required this.journalId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalAsync = ref.watch(journalProvider(journalId));

    return Scaffold(
      body: journalAsync.when(
        data: (journal) => _buildJournalContent(context, ref, journal),
        loading: () => const LoadingWidget(),
        error: (error, stack) => _buildErrorView(context, error.toString()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AppRouter.goToCreateEntry(context, journalId),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildJournalContent(
      BuildContext context, WidgetRef ref, JournalModel journal) {
    // Watch the journal entries
    final entriesAsync = ref.watch(journalEntriesProvider(journalId));

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () => _showJournalOptions(context, journal),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              journal.title,
              style: AppTextStyles.h6.copyWith(
                color: Colors.white,
                shadows: [
                  const Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    journal.isShared
                        ? AppColors.sharedJournal
                        : AppColors.personalJournal,
                    (journal.isShared
                            ? AppColors.sharedJournal
                            : AppColors.personalJournal)
                        .withOpacity(0.8),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 60,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (journal.description != null) ...[
                          Text(
                            journal.description!,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                        ],
                        _buildJournalStats(journal),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Entries List
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: entriesAsync.when(
            data: (entries) => _buildEntriesList(context, entries),
            loading: () => const SliverToBoxAdapter(
              child: LoadingWidget(message: 'Loading entries...'),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: _buildEntriesErrorView(context, error.toString(), ref),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEntriesList(BuildContext context, List<dynamic> entries) {
    if (entries.isEmpty) {
      return SliverToBoxAdapter(
        child: _buildEmptyEntriesState(context),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final entry = entries[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EntryCard(
              title: entry.title,
              content: entry.plainText,
              author: entry.author?.displayName ?? 'Unknown Author',
              authorAvatarUrl: entry.author?.avatarUrl,
              createdAt: entry.createdAt,
              updatedAt: entry.updatedAt,
              commentCount: entry.commentCount,
              reactionCount: entry.reactionCount,
              reactions: entry.uniqueReactions,
              isEdited: entry.wasEditedRecently,
              onTap: () => AppRouter.goToEntryDetail(context, entry.id),
              onComment: () => AppRouter.goToEntryDetail(context, entry.id),
              onReact: () {
                // Handle reaction - for now just navigate to entry detail
                AppRouter.goToEntryDetail(context, entry.id);
              },
            ),
          );
        },
        childCount: entries.length,
      ),
    );
  }

  Widget _buildEmptyEntriesState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.article_outlined,
            size: 64,
            color: isDark
                ? AppColors.textSecondaryDark.withOpacity(0.5)
                : AppColors.textSecondaryLight.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Entries Yet',
            style: AppTextStyles.h5.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start writing your first entry to begin your journaling journey.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => AppRouter.goToCreateEntry(context, journalId),
            icon: const Icon(Icons.add),
            label: const Text('Write First Entry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesErrorView(
      BuildContext context, String error, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to Load Entries',
            style: AppTextStyles.h5.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
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
          ElevatedButton.icon(
            onPressed: () {
              // Refresh entries
              ref.invalidate(journalEntriesProvider(journalId));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildJournalStats(JournalModel journal) {
    return Row(
      children: [
        _buildStatChip(
          Icons.people_outline,
          journal.isShared ? '${journal.memberCount} members' : 'Personal',
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          Icons.article_outlined,
          '${journal.entryCount ?? 0} entries',
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load journal',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  void _showJournalOptions(BuildContext context, JournalModel journal) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Journal Options',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Journal'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit journal
              },
            ),
            if (journal.isShared) ...[
              ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Manage Members'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to manage members
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Invite Link'),
                onTap: () {
                  Navigator.pop(context);
                  // Show invite link
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Export Journal'),
              onTap: () {
                Navigator.pop(context);
                // Export journal
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete Journal'),
              textColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, journal);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, JournalModel journal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Journal'),
        content: Text(
          'Are you sure you want to delete "${journal.title}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete journal logic
              context.pop(); // Go back to journal list
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
