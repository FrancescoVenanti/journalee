import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../providers/journal_provider.dart';
import '../../widgets/common/custom_button.dart';

class CreateJournalScreen extends ConsumerStatefulWidget {
  final bool isShared;

  const CreateJournalScreen({
    super.key,
    required this.isShared,
  });

  @override
  ConsumerState<CreateJournalScreen> createState() =>
      _CreateJournalScreenState();
}

class _CreateJournalScreenState extends ConsumerState<CreateJournalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleCreateJournal() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(journalControllerProvider.notifier).createJournal(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          isShared: widget.isShared,
        );
  }

  @override
  Widget build(BuildContext context) {
    final journalState = ref.watch(journalControllerProvider);

    ref.listen<JournalState>(journalControllerProvider, (previous, next) {
      switch (next) {
        case JournalStateSuccess():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.isShared ? 'Shared' : 'Personal'} journal created successfully!',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.pop();
          break;
        case JournalStateError(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
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
          'Create ${widget.isShared ? 'Shared' : 'Personal'} Journal',
          style: AppTextStyles.h6,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                _buildHeader(),

                const SizedBox(height: 32),

                // Title Field
                _buildTitleField(),

                const SizedBox(height: 20),

                // Description Field
                _buildDescriptionField(),

                const SizedBox(height: 32),

                // Info Card
                _buildInfoCard(),

                const SizedBox(height: 32),

                // Create Button
                _buildCreateButton(journalState),

                const SizedBox(height: 16),

                // Cancel Button
                _buildCancelButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: (widget.isShared
                    ? AppColors.sharedJournal
                    : AppColors.personalJournal)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            widget.isShared ? Icons.people : Icons.person,
            size: 40,
            color: widget.isShared
                ? AppColors.sharedJournal
                : AppColors.personalJournal,
          ),
        ),

        const SizedBox(height: 20),

        // Title
        Text(
          'Create ${widget.isShared ? 'Shared' : 'Personal'} Journal',
          style: AppTextStyles.h3.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          widget.isShared
              ? 'Create a journal that you can share with friends and family'
              : 'Create a private journal for your personal thoughts',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.words,
      validator: Validators.journalTitle,
      decoration: InputDecoration(
        labelText: 'Journal Title',
        hintText: widget.isShared
            ? 'e.g., Family Adventures, Book Club Discussion'
            : 'e.g., Daily Reflections, Travel Journal',
        prefixIcon: const Icon(Icons.title),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      textInputAction: TextInputAction.newline,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 4,
      validator: Validators.journalDescription,
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        hintText: widget.isShared
            ? 'Describe what this journal is about and who can participate'
            : 'Add a personal description for this journal',
        prefixIcon: const Icon(Icons.description),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildInfoCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (widget.isShared
                ? AppColors.sharedJournal
                : AppColors.personalJournal)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (widget.isShared
                  ? AppColors.sharedJournal
                  : AppColors.personalJournal)
              .withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: widget.isShared
                    ? AppColors.sharedJournal
                    : AppColors.personalJournal,
              ),
              const SizedBox(width: 8),
              Text(
                widget.isShared
                    ? 'Shared Journal Features'
                    : 'Personal Journal Features',
                style: AppTextStyles.labelLarge.copyWith(
                  color: widget.isShared
                      ? AppColors.sharedJournal
                      : AppColors.personalJournal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...(_getFeaturesList().map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: widget.isShared
                          ? AppColors.sharedJournal
                          : AppColors.personalJournal,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ))),
        ],
      ),
    );
  }

  List<String> _getFeaturesList() {
    if (widget.isShared) {
      return [
        'Invite friends and family to collaborate',
        'Everyone can write entries and comments',
        'See activity from all members',
        'React to entries with emojis',
        'Manage member permissions',
      ];
    } else {
      return [
        'Private and secure personal space',
        'Write unlimited entries',
        'Add photos and rich formatting',
        'Search through your entries',
        'Export your journal anytime',
      ];
    }
  }

  Widget _buildCreateButton(JournalState journalState) {
    final isLoading = journalState is JournalStateLoading;

    return CustomButton(
      onPressed: isLoading ? null : _handleCreateJournal,
      leftIcon: widget.isShared ? Icons.people : Icons.person,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text('Create ${widget.isShared ? 'Shared' : 'Personal'} Journal'),
    );
  }

  Widget _buildCancelButton() {
    return CustomButton(
      onPressed: () => context.pop(),
      variant: ButtonVariant.text,
      child: const Text('Cancel'),
    );
  }
}
