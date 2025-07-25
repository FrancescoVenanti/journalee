class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }

  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != originalPassword) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? fullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }

    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters long';
    }

    return null;
  }

  static String? journalTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Journal title is required';
    }

    if (value.trim().length < 3) {
      return 'Journal title must be at least 3 characters long';
    }

    if (value.trim().length > 100) {
      return 'Journal title must be less than 100 characters';
    }

    return null;
  }

  static String? journalDescription(String? value) {
    if (value != null && value.trim().length > 500) {
      return 'Description must be less than 500 characters';
    }

    return null;
  }

  static String? entryTitle(String? value) {
    if (value != null && value.trim().length > 200) {
      return 'Entry title must be less than 200 characters';
    }

    return null;
  }

  static String? entryContent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Entry content cannot be empty';
    }

    if (value.trim().length < 10) {
      return 'Entry content must be at least 10 characters long';
    }

    return null;
  }

  static String? comment(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Comment cannot be empty';
    }

    if (value.trim().length > 500) {
      return 'Comment must be less than 500 characters';
    }

    return null;
  }

  static String? required(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  static String? minLength(String? value, int minLength, String fieldName) {
    if (value == null || value.trim().length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }

    return null;
  }

  static String? maxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.trim().length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }

    return null;
  }
}
