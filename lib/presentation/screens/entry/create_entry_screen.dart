import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../providers/entry_providers.dart';
import '../../widgets/common/custom_button.dart';

class CreateEntryScreen extends ConsumerStatefulWidget {
  final String journalId;

  const CreateEntryScreen({
    super.key,
    required this.journalId,
  });

  @override
  ConsumerState<CreateEntryScreen> createState() => _CreateEntryScreenState();
}

class _CreateEntryScreenState extends ConsumerState<CreateEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _scrollController = ScrollController();

  bool _hasChanges = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    // Create entry using the provider
    await ref.read(entryControllerProvider.notifier).createEntry(
          journalId: widget.journalId,
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          content: {'ops': []}, // Simple Delta format for now
          plainText: _contentController.text.trim(),
        );
  }

  Future<void> _handleSaveDraft() async {
    // For now, just show a message - implement draft saving later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saving coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entryState = ref.watch(entryControllerProvider);
    final isLoading = entryState is EntryStateLoading;

    // Listen to entry state changes
    ref.listen<EntryState>(entryControllerProvider, (previous, next) {
      switch (next) {
        case EntryStateSuccess():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entry created successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          // Invalidate the journal entries provider to refresh the list
          ref.invalidate(journalEntriesProvider(widget.journalId));
          context.pop();
          break;
        case EntryStateError(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create entry: $message'),
              backgroundColor: AppColors.error,
            ),
          );
          break;
        default:
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'New Entry',
          style: AppTextStyles.h6,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleBackPressed(),
        ),
        actions: [
          TextButton(
            onPressed: isLoading ? null : _handleSaveDraft,
            child: const Text('Draft'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        onChanged: () {
          if (!_hasChanges) {
            setState(() {
              _hasChanges = true;
            });
          }
        },
        child: Column(
          children: [
            // Content Area
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title Field
                    _buildTitleField(),

                    const SizedBox(height: 20),

                    // Content Field
                    _buildContentField(),

                    const SizedBox(height: 20),

                    // Writing Tips
                    _buildWritingTips(),
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            _buildBottomActionBar(isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.sentences,
      style: AppTextStyles.entryTitle.copyWith(
        color: Theme.of(context).colorScheme.onBackground,
      ),
      validator: Validators.entryTitle,
      decoration: InputDecoration(
        hintText: 'Entry title (optional)',
        hintStyle: AppTextStyles.entryTitle.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildContentField() {
    return TextFormField(
      controller: _contentController,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      maxLines: null,
      minLines: 10,
      style: AppTextStyles.entryContent.copyWith(
        color: Theme.of(context).colorScheme.onBackground,
      ),
      validator: Validators.entryContent,
      decoration: InputDecoration(
        hintText: 'What\'s on your mind?',
        hintStyle: AppTextStyles.entryContent.copyWith(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildWritingTips() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 20,
                color: AppColors.info,
              ),
              const SizedBox(width: 8),
              Text(
                'Writing Tips',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._getWritingTips().map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  List<String> _getWritingTips() {
    return [
      'Write in the present tense to make your entries more vivid',
      'Include specific details about how you felt and what you experienced',
      'Don\'t worry about perfect grammar - focus on expressing yourself',
      'Consider writing about three things you\'re grateful for today',
    ];
  }

  Widget _buildBottomActionBar(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.dividerDark
                : AppColors.dividerLight,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Word Count
            Expanded(
              child: Text(
                '${_getWordCount()} words',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),

            // Publish Button
            CustomButton(
              onPressed: isLoading ? null : _handleSaveEntry,
              isFullWidth: false,
              leftIcon: Icons.publish,
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Publish'),
            ),
          ],
        ),
      ),
    );
  }

  int _getWordCount() {
    final text = _contentController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  void _handleBackPressed() {
    if (_hasChanges) {
      _showUnsavedChangesDialog();
    } else {
      context.pop();
    }
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. What would you like to do?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Writing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleSaveDraft();
              context.pop();
            },
            child: const Text('Save Draft'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}
