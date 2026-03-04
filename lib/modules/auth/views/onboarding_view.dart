import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/auth_controller.dart';

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
    for (final c in _fadeControllers) c.dispose();
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
      Get.put(AuthController()).selectRole(role);
    }
    Get.offAllNamed('/role');
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
              right: 16,
              child: TextButton(
                onPressed: _skip,
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
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
    if (_currentPage == _totalPages - 1) return const SizedBox(height: 20);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).padding.bottom + 20,
        top: 16,
      ),
      child: Row(
        children: [
          // Back
          if (_currentPage > 0)
            IconButton(
              onPressed: _previousPage,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, size: 20),
              ),
            )
          else
            const SizedBox(width: 48),

          const Spacer(),

          // Dots
          Row(
            children: List.generate(_totalPages, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF6C63FF)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),

          const Spacer(),

          // Next
          GestureDetector(
            onTap: _nextPage,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFF6C63FF),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x406C63FF),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 22,
              ),
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFF8B7CFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Animated illustration
              _animatedIcon(
                Icons.car_repair,
                120,
                Colors.white,
                bgColor: Colors.white.withOpacity(0.15),
              ),
              const SizedBox(height: 40),
              Text(
                'Welcome to',
                style: GoogleFonts.poppins(fontSize: 22, color: Colors.white70),
              ),
              const SizedBox(height: 4),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [Colors.white, Color(0xFFFFD180)],
                ).createShader(b),
                child: Text(
                  'DriveResQ',
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Your trusted roadside assistance partner',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
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
        icon: Icons.location_on,
        iconColor: const Color(0xFF2196F3),
        title: 'Stuck on the Road?',
        subtitle: 'Create a request and find nearby mechanics instantly',
        features: const [
          _Feature(Icons.flash_on, 'Quick request creation'),
          _Feature(Icons.my_location, 'Real-time mechanic tracking'),
          _Feature(Icons.chat_bubble, 'In-app chat with mechanic'),
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
        icon: Icons.build,
        iconColor: const Color(0xFFFF9800),
        title: 'Grow Your Business',
        subtitle: 'Get instant job requests in your area',
        features: const [
          _Feature(Icons.verified_user, 'Get verified customers'),
          _Feature(Icons.account_balance_wallet, 'Track your earnings'),
          _Feature(Icons.star, 'Build your reputation'),
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
        icon: Icons.shield,
        iconColor: const Color(0xFF4CAF50),
        title: 'Safe & Secure',
        subtitle: 'Verified mechanics, secure payments, 24/7 support',
        features: const [
          _Feature(Icons.verified, 'Verified professionals'),
          _Feature(Icons.star_rate, 'Ratings & reviews'),
          _Feature(Icons.support_agent, 'Emergency support'),
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
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Text(
                  "Let's Get Started!",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you want to use DriveResQ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 40),

                // Driver card
                _roleCard(
                  icon: Icons.directions_car,
                  title: 'I need help',
                  subtitle: 'Find a mechanic near you',
                  color: const Color(0xFF2196F3),
                  onTap: () => _completeOnboarding(role: 'driver'),
                ),
                const SizedBox(height: 16),

                // Mechanic card
                _roleCard(
                  icon: Icons.build,
                  title: "I'm a mechanic",
                  subtitle: 'Help drivers & earn money',
                  color: const Color(0xFFFF9800),
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
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF6C63FF)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 36, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
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
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              _animatedIcon(
                icon,
                90,
                iconColor,
                bgColor: iconColor.withOpacity(0.1),
              ),
              const SizedBox(height: 36),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 36),
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 15,
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
