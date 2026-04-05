import 'package:iconsax/iconsax.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:driveresq_app/theme/app_colors.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  // Fade controllers for each page
  late List<AnimationController> _fadeControllers;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _fadeControllers = List.generate(
      _totalPages,
      (i) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );
    _fadeAnimations = _fadeControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _fadeControllers[0].forward();
  }

  @override
  void dispose() {
    for (final c in _fadeControllers) {
      c.dispose();
    }
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    // Trigger fade-in for the new page
    _fadeControllers[index].reset();
    _fadeControllers[index].forward();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding({String? role}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);

    if (role != null) {
      Get.offAllNamed('/login', arguments: {'role': role});
    } else {
      Get.offAllNamed('/role');
    }
  }

  Future<void> _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    Get.offAllNamed('/role');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Page view
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              _slide0Welcome(),
              _slide1Drivers(),
              _slide2Mechanics(),
              _slide3Safety(),
              _slide4RoleSelect(),
            ],
          ),

          // Skip button (top right)
          if (_currentPage < _totalPages - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 16.w,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Controls ───
  Widget _buildBottomControls() {
    if (_currentPage == _totalPages - 1) return SizedBox(height: 20.h);

    return Container(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        bottom: MediaQuery.of(context).padding.bottom + 20,
        top: 16.h,
      ),
      child: Row(
        children: [
          // Back
          if (_currentPage > 0)
            IconButton(
              onPressed: _previousPage,
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.arrow_left, size: 20.w),
              ),
            )
          else
            SizedBox(width: 48.w),

          const Spacer(),

          // Dots
          Row(
            children: List.generate(_totalPages, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: isActive ? 28 : 8,
                height: 8.h,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              );
            }),
          ),

          const Spacer(),

          // Next
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryLight.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Iconsax.arrow_right, color: Colors.white, size: 22.w),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  SLIDE 0: WELCOME
  // ═══════════════════════════════════════════
  Widget _slide0Welcome() {
    return FadeTransition(
      opacity: _fadeAnimations[0],
      child: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Animated logo illustration
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
                builder: (_, val, child) =>
                    Transform.scale(scale: val, child: child),
                child: Container(
                  width: 140.w,
                  height: 140.h,
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/logo.png',
                    color: Colors.white,
                    colorBlendMode: BlendMode.srcIn,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              Text(
                'Welcome to',
                style: GoogleFonts.poppins(
                  fontSize: 22.sp,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 4.h),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFFFD180)],
                ).createShader(b),
                child: Text(
                  'DriveResQ',
                  style: GoogleFonts.poppins(
                    fontSize: 42.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Your trusted roadside assistance partner',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  SLIDE 1: FOR DRIVERS
  // ═══════════════════════════════════════════
  Widget _slide1Drivers() {
    return FadeTransition(
      opacity: _fadeAnimations[1],
      child: _whiteSlide(
        icon: Iconsax.location,
        iconColor: AppColors.info,
        title: 'Stuck on the Road?',
        subtitle: 'Create a request and find nearby mechanics instantly',
        features: [
          const _Feature(Iconsax.flash, 'Quick request creation'),
          const _Feature(Iconsax.gps, 'Real-time mechanic tracking'),
          const _Feature(Iconsax.message, 'In-app chat with mechanic'),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  SLIDE 2: FOR MECHANICS
  // ═══════════════════════════════════════════
  Widget _slide2Mechanics() {
    return FadeTransition(
      opacity: _fadeAnimations[2],
      child: _whiteSlide(
        icon: Iconsax.setting_2,
        iconColor: AppColors.mechanicPrimary,
        title: 'Grow Your Business',
        subtitle: 'Get instant job requests in your area',
        features: [
          const _Feature(Iconsax.verify, 'Get verified customers'),
          const _Feature(Iconsax.wallet, 'Track your earnings'),
          const _Feature(Iconsax.star, 'Build your reputation'),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  SLIDE 3: SAFETY
  // ═══════════════════════════════════════════
  Widget _slide3Safety() {
    return FadeTransition(
      opacity: _fadeAnimations[3],
      child: _whiteSlide(
        icon: Iconsax.shield,
        iconColor: AppColors.success,
        title: 'Safe & Secure',
        subtitle: 'Verified mechanics, secure payments, 24/7 support',
        features: [
          const _Feature(Iconsax.verify, 'Verified professionals'),
          const _Feature(Iconsax.star, 'Ratings & reviews'),
          const _Feature(Iconsax.support, 'Emergency support'),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  //  SLIDE 4: ROLE SELECTION
  // ═══════════════════════════════════════════
  Widget _slide4RoleSelect() {
    return FadeTransition(
      opacity: _fadeAnimations[4],
      child: Container(
        color: const Color(0xFFF5F6FA),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Text(
                  "Let's Get Started!",
                  style: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Choose how you want to use DriveResQ',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                SizedBox(height: 40.h),

                // Driver card
                _roleCard(
                  icon: Iconsax.car,
                  title: 'I need help',
                  subtitle: 'Find a mechanic near you',
                  color: AppColors.info,
                  onTap: () => _completeOnboarding(role: 'driver'),
                ),
                SizedBox(height: 16.h),

                // Mechanic card
                _roleCard(
                  icon: Iconsax.setting_2,
                  title: "I'm a mechanic",
                  subtitle: 'Help drivers & earn money',
                  color: AppColors.mechanicPrimary,
                  onTap: () => _completeOnboarding(role: 'mechanic'),
                ),

                const Spacer(flex: 3),

                // Bottom dots (no controls on last page)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_totalPages, (i) {
                    final isActive = i == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: isActive ? 28 : 8,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    );
                  }),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Role card for slide 5 ───
  Widget _roleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: color.withOpacity(0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, size: 36.w, color: color),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, color: color, size: 18.w),
          ],
        ),
      ),
    );
  }

  // ─── White slide template ───
  Widget _whiteSlide({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<_Feature> features,
  }) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _animatedIcon(
                icon,
                90,
                iconColor,
                bgColor: iconColor.withOpacity(0.1),
              ),
              SizedBox(height: 36.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 36.h),
              ...features.map((f) => _featureRow(f.icon, f.label)),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20.w),
          ),
          SizedBox(width: 14.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _animatedIcon(
    IconData icon,
    double size,
    Color color, {
    Color? bgColor,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (_, val, child) => Transform.scale(scale: val, child: child),
      child: Container(
        padding: EdgeInsets.all(size * 0.3),
        decoration: BoxDecoration(
          color: bgColor ?? color.withOpacity(0.1),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(icon, size: size * 0.5, color: color),
      ),
    );
  }
}

// Feature data class
class _Feature {
  final IconData icon;
  final String label;
  const _Feature(this.icon, this.label);
}
