import 'package:driveresq_app/modules/driver/bindings/driver_binding.dart';
import 'package:driveresq_app/modules/driver/views/driver_dashboard_view.dart';
import 'package:driveresq_app/modules/driver/views/onboarding/driver_onboarding_view.dart';
import 'package:driveresq_app/modules/jobs/controllers/job_completion_controller.dart';
import 'package:driveresq_app/modules/jobs/views/job_completion_page.dart';
import 'package:driveresq_app/modules/mechanic/bindings/mechanic_binding.dart';
import 'package:driveresq_app/modules/mechanic/controllers/onboarding_controller.dart';
import 'package:driveresq_app/modules/mechanic/views/mechanic_dashboard_view.dart';
import 'package:driveresq_app/modules/mechanic/views/onboarding/step1_personal_details.dart';
import 'package:driveresq_app/modules/mechanic/views/verification_pending_view.dart';
import 'package:get/get.dart';

import '../../admin/controllers/admin_auth_controller.dart';
import '../../admin/controllers/admin_dashboard_controller.dart';
import '../../admin/controllers/verification_controller.dart';
import '../../admin/views/admin_dashboard_view.dart';
import '../../admin/views/admin_login_view.dart';
import '../../admin/views/approved_mechanics_view.dart';
import '../../admin/views/pending_verifications_view.dart';
import '../../admin/views/rejected_applications_view.dart';
import '../../admin/views/review_application_view.dart';
import '../../modules/auth/views/enter_phone_number_view.dart';
import '../../modules/auth/views/otp_verification_view.dart';
import '../../modules/auth/views/role_selection_view.dart';
import '../../modules/auth/views/splash_view.dart';
import '../../modules/auth/views/onboarding_view.dart';
import '../../modules/notifications/views/notifications_view.dart';
import 'app_pages.dart';

class AppPages {
  static const _dur = Duration(milliseconds: 300);

  static final pages = [
    GetPage(name: Routes.SPLASH, page: () => SplashView()),
    GetPage(
      name: Routes.ONBOARDING,
      page: () => const OnboardingView(),
      transition: Transition.fadeIn,
      transitionDuration: _dur,
    ),
    GetPage(
      name: Routes.ROLE,
      page: () => RoleSelectionView(),
      transition: Transition.fadeIn,
      transitionDuration: _dur,
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => PhoneNumberView(),
      transition: Transition.rightToLeft,
      transitionDuration: _dur,
    ),
    GetPage(
      name: Routes.OTP,
      page: () => OTPVerificationView(),
      transition: Transition.rightToLeft,
      transitionDuration: _dur,
    ),

    GetPage(
      name: Routes.DRIVER,
      page: () => DriverDashboardView(),
      binding: DriverBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _dur,
    ),

    GetPage(
      name: Routes.DRIVER_ONBOARDING,
      page: () => const DriverOnboardingView(),
      transition: Transition.rightToLeft,
      transitionDuration: _dur,
    ),

    GetPage(
      name: Routes.MECHANIC,
      page: () => MechanicDashboardView(),
      binding: MechanicBinding(),
      transition: Transition.fadeIn,
      transitionDuration: _dur,
    ),

    GetPage(
      name: Routes.MECHANIC_ONBOARDING,
      page: () => const Step1PersonalDetails(),
      transition: Transition.rightToLeft,
      transitionDuration: _dur,
      binding: BindingsBuilder(() {
        Get.lazyPut<MechanicOnboardingController>(
          () => MechanicOnboardingController(),
        );
      }),
    ),

    GetPage(
      name: Routes.MECHANIC_VERIFICATION,
      page: () => const VerificationPendingView(),
      transition: Transition.fadeIn,
      transitionDuration: _dur,
    ),

    // ── Admin Routes ──
    GetPage(
      name: Routes.ADMIN_LOGIN,
      page: () => const AdminLoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AdminAuthController>(() => AdminAuthController());
      }),
    ),

    GetPage(
      name: Routes.ADMIN_DASHBOARD,
      page: () => const AdminDashboardView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AdminAuthController>()) {
          Get.put(AdminAuthController());
        }
        Get.lazyPut<AdminDashboardController>(() => AdminDashboardController());
        Get.lazyPut<VerificationController>(() => VerificationController());
      }),
    ),

    GetPage(
      name: Routes.ADMIN_PENDING,
      page: () => const PendingVerificationsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AdminAuthController>()) {
          Get.put(AdminAuthController());
        }
        if (!Get.isRegistered<AdminDashboardController>()) {
          Get.lazyPut<AdminDashboardController>(
            () => AdminDashboardController(),
          );
        }
        Get.lazyPut<VerificationController>(() => VerificationController());
      }),
    ),

    GetPage(
      name: Routes.ADMIN_APPROVED,
      page: () => const ApprovedMechanicsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AdminAuthController>()) {
          Get.put(AdminAuthController());
        }
        if (!Get.isRegistered<AdminDashboardController>()) {
          Get.lazyPut<AdminDashboardController>(
            () => AdminDashboardController(),
          );
        }
        Get.lazyPut<VerificationController>(() => VerificationController());
      }),
    ),

    GetPage(
      name: Routes.ADMIN_REJECTED,
      page: () => const RejectedApplicationsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AdminAuthController>()) {
          Get.put(AdminAuthController());
        }
        if (!Get.isRegistered<AdminDashboardController>()) {
          Get.lazyPut<AdminDashboardController>(
            () => AdminDashboardController(),
          );
        }
        Get.lazyPut<VerificationController>(() => VerificationController());
      }),
    ),

    GetPage(
      name: Routes.ADMIN_REVIEW,
      page: () => const ReviewApplicationView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AdminAuthController>()) {
          Get.put(AdminAuthController());
        }
        if (!Get.isRegistered<VerificationController>()) {
          Get.lazyPut<VerificationController>(() => VerificationController());
        }
      }),
    ),

    // Job Completion
    GetPage(
      name: Routes.JOB_COMPLETION,
      page: () => const JobCompletionPage(),
      binding: BindingsBuilder(() {
        Get.lazyPut<JobCompletionController>(() => JobCompletionController());
      }),
    ),

    // Notifications
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: () => const NotificationsView(),
      transition: Transition.rightToLeft,
      transitionDuration: _dur,
    ),
  ];
}
