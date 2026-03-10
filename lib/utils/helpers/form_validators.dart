/// Centralized form validation helpers for DriveResQ
class FormValidators {
  FormValidators._();

  /// Validates Indian phone number (10 digits, starts with 6-9)
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    // Strip spaces, dashes, +91 prefix
    final clean = value.replaceAll(RegExp(r'[\s\-+]'), '');
    final digits = clean.startsWith('91') && clean.length > 10
        ? clean.substring(clean.length - 10)
        : clean;

    if (digits.length != 10) {
      return 'Enter a valid 10-digit phone number';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
      return 'Phone number must start with 6, 7, 8, or 9';
    }
    return null; // valid
  }

  /// Validates a person's name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (value.trim().length > 50) {
      return 'Name cannot exceed 50 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s'.]+$").hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Validates an email address (optional field)
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // email is optional
    }
    final pattern = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates Aadhaar number (12 digits)
  static String? validateAadhaar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Aadhaar number is required';
    }
    final clean = value.replaceAll(RegExp(r'\s'), '');
    if (clean.length != 12 || !RegExp(r'^\d{12}$').hasMatch(clean)) {
      return 'Aadhaar must be exactly 12 digits';
    }
    return null;
  }

  /// Validates PAN card (ABCDE1234F format)
  static String? validatePAN(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN number is required';
    }
    if (!RegExp(r'^[A-Z]{5}\d{4}[A-Z]$').hasMatch(value.trim().toUpperCase())) {
      return 'Enter a valid PAN (e.g., ABCDE1234F)';
    }
    return null;
  }

  /// Validates IFSC code (ABCD0123456 format)
  static String? validateIFSC(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'IFSC code is required';
    }
    if (!RegExp(r'^[A-Z]{4}0\d{6}$').hasMatch(value.trim().toUpperCase())) {
      return 'Enter a valid IFSC code (e.g., SBIN0001234)';
    }
    return null;
  }

  /// Validates bank account number (9-18 digits)
  static String? validateAccountNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Account number is required';
    }
    final clean = value.replaceAll(RegExp(r'\s'), '');
    if (!RegExp(r'^\d{9,18}$').hasMatch(clean)) {
      return 'Account number must be 9-18 digits';
    }
    return null;
  }

  /// Validates UPI ID (user@bank format)
  static String? validateUPI(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // optional
    }
    if (!RegExp(r'^[\w.\-]+@[\w]+$').hasMatch(value.trim())) {
      return 'Enter a valid UPI ID (e.g., user@paytm)';
    }
    return null;
  }

  /// Validates OTP (6 digits)
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }
    if (value.length != 6 || !RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must be 6 digits';
    }
    return null;
  }
}
