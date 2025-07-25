import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journalee/data/models/user_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _initializeControllers(UserModel? user) {
    if (user != null) {
      _fullNameController.text = user.fullName ?? '';
      _emailController.text = user.email;
    }
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authControllerProvider.notifier).updateProfile(
          fullName: _fullNameController.text.trim().isEmpty
              ? null
              : _fullNameController.text.trim(),
        );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      _hasChanges = false;
    });

    if (!_isEditing) {
      // Reset controllers to original values when canceling
      final user = ref.read(currentUserProvider).value;
      _initializeControllers(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final authState = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      switch (next) {
        case AuthStateSuccess():
          setState(() {
            _isEditing = false;
            _hasChanges = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
          // Refresh the current user data
          ref.invalidate(currentUserProvider);
        case AuthStateError(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
            ),
          );
        default:
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTextStyles.h6,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_hasChanges) {
              _showUnsavedChangesDialog();
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          if (!_isEditing)
            TextButton(
              onPressed: _toggleEditing,
              child: const Text('Edit'),
            ),
        ],
      ),
      body: currentUser.when(
        data: (user) {
          // Initialize controllers when user data is available
          if (user != null &&
              _fullNameController.text.isEmpty &&
              _emailController.text.isEmpty) {
            _initializeControllers(user);
          }
          return _buildProfileContent(context, user, authState);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorView(context, error.toString()),
      ),
    );
  }

  Widget _buildProfileContent(
      BuildContext context, UserModel? user, AuthState authState) {
    if (user == null) {
      return const Center(
        child: Text('No user data available'),
      );
    }

    final isLoading = authState is AuthStateLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        onChanged: () {
          if (_isEditing && !_hasChanges) {
            setState(() {
              _hasChanges = true;
            });
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Avatar
            _buildProfileAvatar(user),

            const SizedBox(height: 32),

            // Profile Information
            _buildProfileInfo(user, isLoading),

            const SizedBox(height: 32),

            // Account Statistics
            _buildAccountStats(user),

            const SizedBox(height: 32),

            // Action Buttons
            if (_isEditing) _buildEditActions(isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(UserModel user) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: user.avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      user.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildAvatarFallback(user),
                    ),
                  )
                : _buildAvatarFallback(user),
          ),
          if (_isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {
                    // Implement photo picker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Photo upload feature coming soon!'),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarFallback(UserModel user) {
    return Center(
      child: Text(
        user.initials,
        style: AppTextStyles.h2.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProfileInfo(UserModel user, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: AppTextStyles.h6.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),

        const SizedBox(height: 16),

        // Full Name Field
        TextFormField(
          controller: _fullNameController,
          enabled: _isEditing,
          textCapitalization: TextCapitalization.words,
          validator: Validators.fullName,
          decoration: InputDecoration(
            labelText: 'Full Name',
            prefixIcon: const Icon(Icons.person_outline),
            enabled: _isEditing,
          ),
        ),

        const SizedBox(height: 16),

        // Email Field (read-only)
        TextFormField(
          controller: _emailController,
          enabled: false,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
            helperText: 'Email cannot be changed',
          ),
        ),

        const SizedBox(height: 16),

        // Account Created
        _buildInfoRow(
          'Member Since',
          user.createdAt != null ? _formatDate(user.createdAt!) : "Unkown",
          Icons.calendar_today_outlined,
        ),
      ],
    );
  }

  Widget _buildAccountStats(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.cardDark
            : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Your Activity',
            style: AppTextStyles.h6.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Journals', '3', Icons.book_outlined),
              ),
              Expanded(
                child: _buildStatItem('Entries', '12', Icons.article_outlined),
              ),
              Expanded(
                child: _buildStatItem('Comments', '8', Icons.comment_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.h5.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditActions(bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          onPressed: isLoading ? null : _handleSaveProfile,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save Changes'),
        ),
        const SizedBox(height: 12),
        CustomButton(
          onPressed: _toggleEditing,
          variant: ButtonVariant.outline,
          child: const Text('Cancel'),
        ),
      ],
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
              'Failed to load profile',
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
            CustomButton(
              onPressed: () {
                ref.invalidate(currentUserProvider);
              },
              variant: ButtonVariant.outline,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
