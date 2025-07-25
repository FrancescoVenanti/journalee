import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_helpers.dart';
import '../../../data/models/entry_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/entry/comment_widget.dart';
import '../../widgets/entry/reaction_bar.dart';

// Mock provider for now - replace with real provider later
final mockEntryDetailProvider =
    FutureProvider.family<EntryModel, String>((ref, entryId) async {
  // Mock data - replace with actual repository call
  return EntryModel(
    id: entryId,
    journalId: 'journal-1',
    authorId: 'author-1',
    title: 'A Beautiful Day',
    content: {'ops': []}, // Mock Delta content
    plainText:
        'Today was a beautiful day. I spent time reflecting on life and enjoying nature.',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  );
});

class EntryDetailScreen extends ConsumerWidget {
  final String entryId;

  const EntryDetailScreen({
    super.key,
    required this.entryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(mockEntryDetailProvider(entryId));

    return Scaffold(
      body: entryAsync.when(
        data: (entry) => _buildMainContent(context, ref, entry),
        loading: () => const LoadingWidget(),
        error: (error, stack) => _buildErrorView(context, error.toString()),
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, WidgetRef ref, EntryModel entry) {
    return CustomScrollView(
      slivers: [
        // App Bar
        _buildAppBar(context, entry),

        // Entry Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Entry Header
                _buildEntryHeader(context, entry),

                const SizedBox(height: 24),

                // Entry Title
                if (entry.title != null && entry.title!.isNotEmpty) ...[
                  _buildEntryTitle(context, entry),
                  const SizedBox(height: 16),
                ],

                // Entry Content
                _buildEntryTextContent(context, entry),

                const SizedBox(height: 24),

                // Reactions Bar
                _buildReactionsBar(),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),

        // Comments Section
        _buildCommentsHeader(context),

        // Comments List
        _buildCommentsList(),

        // Add Comment Input
        SliverToBoxAdapter(
          child: _buildAddCommentSection(context),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, EntryModel entry) {
    return SliverAppBar(
      floating: true,
      pinned: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // Navigate to edit entry
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showEntryOptions(context, entry),
        ),
      ],
    );
  }

  Widget _buildEntryHeader(BuildContext context, EntryModel entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Author Avatar
        _buildAuthorAvatar(entry),

        const SizedBox(width: 16),

        // Author Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.author?.displayName ?? 'Unknown Author',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 4),
              _buildTimestamp(context, entry),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorAvatar(EntryModel entry) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: entry.author?.avatarUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                entry.author!.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildAvatarFallback(entry),
              ),
            )
          : _buildAvatarFallback(entry),
    );
  }

  Widget _buildAvatarFallback(EntryModel entry) {
    final initials = entry.author?.initials ?? '?';

    return Center(
      child: Text(
        initials,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context, EntryModel entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Text(
          DateHelpers.getSmartDate(entry.createdAt),
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        if (entry.wasEditedRecently) ...[
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
    );
  }

  Widget _buildEntryTitle(BuildContext context, EntryModel entry) {
    return Text(
      entry.title!,
      style: AppTextStyles.h3.copyWith(
        color: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }

  Widget _buildEntryTextContent(BuildContext context, EntryModel entry) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.dividerDark : AppColors.dividerLight,
          width: 0.5,
        ),
      ),
      child: Text(
        entry.plainText,
        style: AppTextStyles.entryContent.copyWith(
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildReactionsBar() {
    return const ReactionBar(
      reactions: {'❤️': 3, '👍': 2, '😊': 1},
      userReactions: ['❤️'],
    );
  }

  Widget _buildCommentsHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comments',
              style: AppTextStyles.h5.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: CommentWidget(
                authorName: 'User ${index + 1}',
                content: 'This is a sample comment for testing purposes.',
                timestamp: DateTime.now().subtract(Duration(hours: index + 1)),
                onReply: () {
                  // Handle reply
                },
              ),
            );
          },
          childCount: 3, // Mock count
        ),
      ),
    );
  }

  Widget _buildAddCommentSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(24),
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
        children: [
          // User Avatar
          _buildCommentUserAvatar(),

          const SizedBox(width: 12),

          // Comment Input
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),

          // Send Button
          IconButton(
            icon: const Icon(
              Icons.send,
              color: AppColors.accent,
            ),
            onPressed: () {
              // Handle send comment
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Text(
          'U',
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
        ),
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
              'Failed to load entry',
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

  void _showEntryOptions(BuildContext context, EntryModel entry) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Entry Options',
              style: AppTextStyles.h5,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildOptionTile(
              icon: Icons.edit,
              title: 'Edit Entry',
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit entry
              },
            ),
            _buildOptionTile(
              icon: Icons.share,
              title: 'Share Entry',
              onTap: () {
                Navigator.pop(context);
                // Share entry
              },
            ),
            _buildOptionTile(
              icon: Icons.bookmark_border,
              title: 'Bookmark',
              onTap: () {
                Navigator.pop(context);
                // Bookmark entry
              },
            ),
            _buildOptionTile(
              icon: Icons.delete,
              title: 'Delete Entry',
              textColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      textColor: textColor,
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text(
          'Are you sure you want to delete this entry? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Delete entry logic
              context.pop(); // Go back
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
