class Validators {
  // Email validation with comprehensive error messages
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      if (!value.contains('@')) {
        return 'Email must contain an @ symbol';
      } else if (!value.contains('.')) {
        return 'Email must contain a domain (e.g., .com, .org)';
      } else {
        return 'Please enter a valid email address';
      }
    }

    return null;
  }

  // Password validation with specific requirements
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
    // bool hasDigits = value.contains(RegExp(r'[0-9]'));
    // bool hasSpecialChars = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    // if (!hasUppercase) {
    //   return 'Password must contain at least one uppercase letter';
    // }

    // if (!hasDigits) {
    //   return 'Password must contain at least one number';
    // }

    // if (!hasSpecialChars) {
    //   return 'Password must contain at least one special character';
    // }

    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    // Check if name contains only letters, spaces, apostrophes, and hyphens
    final validNameRegex = RegExp(r"^[a-zA-Z\s'-]+$");
    if (!validNameRegex.hasMatch(value)) {
      return 'Name can only contain letters, spaces, apostrophes, and hyphens';
    }

    return null;
  }

  // Title validation for defect reports
  static String? validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }

    if (value.length < 5) {
      return 'Title must be at least 5 characters';
    }

    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }

    return null;
  }

  // Description validation for defect reports
  static String? validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }

    if (value.length < 10) {
      return 'Description must be at least 10 characters';
    }

    if (value.length > 500) {
      return 'Description must be less than 500 characters';
    }

    return null;
  }

  // Location validation
  static String? validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Location is required';
    }

    if (value.length < 5) {
      return 'Location must be at least 5 characters';
    }

    if (value.length > 200) {
      return 'Location must be less than 200 characters';
    }

    return null;
  }

  // Required field validator
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Image count validator
  static String? validateImageCount(List<dynamic>? images) {
    if (images == null || images.isEmpty) {
      return 'At least one image is required';
    }

    if (images.length > 5) {
      return 'Maximum of 5 images allowed';
    }

    return null;
  }

  // Phone number validator
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    // Basic phone validation - can be enhanced for different country formats
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  // URL validator
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  // Date validator - checks if date is in the future
  static String? validateFutureDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }

    if (value.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }

    return null;
  }

  // Date validator - checks if date is in the past
  static String? validatePastDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }

    if (value.isAfter(DateTime.now())) {
      return 'Date must be in the past';
    }

    return null;
  }
}
