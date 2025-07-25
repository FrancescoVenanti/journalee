class AppConstants {
  // App Information
  static const String appName = 'Journalee';
  static const String appDescription = 'A collaborative journaling app';

  // Database Tables
  static const String profilesTable = 'profiles';
  static const String journalsTable = 'journals';
  static const String journalMembersTable = 'journal_members';
  static const String entriesTable = 'entries';
  static const String commentsTable = 'comments';
  static const String reactionsTable = 'reactions';
  static const String activitiesTable = 'activities';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Text Limits
  static const int maxJournalTitleLength = 100;
  static const int maxJournalDescriptionLength = 500;
  static const int maxEntryTitleLength = 200;
  static const int maxCommentLength = 500;
  static const int maxFullNameLength = 100;

  // Activity Types
  static const String activityEntryCreated = 'entry_created';
  static const String activityCommentAdded = 'comment_added';
  static const String activityReactionAdded = 'reaction_added';
  static const String activityJournalCreated = 'journal_created';
  static const String activityMemberAdded = 'member_added';

  // Journal Member Roles
  static const String roleOwner = 'owner';
  static const String roleAdmin = 'admin';
  static const String roleMember = 'member';

  // Date Formats
  static const String dateFormat = 'MMM d, yyyy';
  static const String timeFormat = 'h:mm a';
  static const String dateTimeFormat = 'MMM d, yyyy h:mm a';

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Border Radius
  static const double smallBorderRadius = 8.0;
  static const double defaultBorderRadius = 12.0;
  static const double largeBorderRadius = 16.0;

  // Icon Sizes
  static const double smallIconSize = 16.0;
  static const double defaultIconSize = 24.0;
  static const double largeIconSize = 32.0;

  // Avatar Sizes
  static const double smallAvatarSize = 32.0;
  static const double defaultAvatarSize = 40.0;
  static const double largeAvatarSize = 80.0;

  // Common Emojis for Reactions
  static const List<String> commonReactionEmojis = [
    '❤️',
    '👍',
    '😊',
    '🙏',
    '💪',
    '🌟',
    '🎉',
    '😢',
    '🤗',
    '💡',
    '🔥',
    '✨'
  ];

  // Error Messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String authErrorMessage =
      'Authentication error. Please sign in again.';

  // Success Messages
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  static const String journalCreatedMessage = 'Journal created successfully!';
  static const String entryCreatedMessage = 'Entry created successfully!';
  static const String commentAddedMessage = 'Comment added successfully!';

  // Validation Messages
  static const String requiredFieldMessage = 'This field is required';
  static const String invalidEmailMessage =
      'Please enter a valid email address';
  static const String passwordTooShortMessage =
      'Password must be at least 6 characters';
  static const String passwordsDoNotMatchMessage = 'Passwords do not match';
}
