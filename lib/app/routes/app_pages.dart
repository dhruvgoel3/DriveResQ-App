abstract class Routes {
  static const SPLASH = '/';
  static const ONBOARDING = '/onboarding';
  static const ROLE = '/role';
  static const LOGIN = '/login';
  static const OTP = "/otp";
  static const DRIVER = '/driver';
  static const DRIVER_ONBOARDING = '/driver-onboarding';
  static const MECHANIC = '/mechanic';
  static const MECHANIC_ONBOARDING = '/mechanic-onboarding';
  static const MECHANIC_VERIFICATION = '/mechanic-verification';

  // Admin routes
  static const ADMIN_LOGIN = '/admin';
  static const ADMIN_DASHBOARD = '/admin/dashboard';
  static const ADMIN_PENDING = '/admin/pending';
  static const ADMIN_APPROVED = '/admin/approved';
  static const ADMIN_REJECTED = '/admin/rejected';
  static const ADMIN_REVIEW = '/admin/review';
  static const ADMIN_SETTINGS = '/admin/settings';

  // Job completion
  static const JOB_COMPLETION = '/job-completion';

  // Chat
  static const CHAT = '/chat';

  // Notifications
  static const NOTIFICATIONS = '/notifications';

  // History
  static const DRIVER_HISTORY = '/driver/history';
  static const MECHANIC_HISTORY = '/mechanic/history';
}
