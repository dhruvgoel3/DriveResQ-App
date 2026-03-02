// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../controllers/auth_controller.dart';
//
// class SplashView extends StatefulWidget {
//   const SplashView({super.key});
//
//   @override
//   State<SplashView> createState() => _SplashViewState();
// }
//
// class _SplashViewState extends State<SplashView>
//     with SingleTickerProviderStateMixin {
//   final AuthController controller = Get.find<AuthController>();
//
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // 🔹 Fade animation
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1200),
//     );
//
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeIn,
//     );
//
//     _animationController.forward();
//
//     _go();
//   }
//
//   Future<void> _go() async {
//     await Future.delayed(const Duration(seconds: 3));
//     await controller.checkAuthStatus();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF6A5AE0), // Deep Purple
//               Color(0xFFB8B2FF), // Light Lavender
//             ],
//           ),
//         ),
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // 🚗 LOGO
//               Container(
//                 height: 90,
//                 width: 90,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: Colors.white.withOpacity(0.15),
//                 ),
//                 child: const Icon(
//                   Icons.directions_car,
//                   size: 40,
//                   color: Colors.white,
//                 ),
//               ),
//
//               const SizedBox(height: 24),
//
//               // 🏷️ APP NAME
//               Text(
//                 "DriverResQ",
//                 style: GoogleFonts.poppins(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//
//               const SizedBox(height: 8),
//
//               // ✨ TAGLINE
//               Text(
//                 "Help is just a tap away",
//                 style: GoogleFonts.poppins(
//                   fontSize: 14,
//                   color: Colors.white.withOpacity(0.85),
//                 ),
//               ),
//
//               const SizedBox(height: 80),
//
//               // ⏳ LOADING INDICATOR
//               SizedBox(
//                 width: 120,
//                 child: LinearProgressIndicator(
//                   minHeight: 3,
//                   backgroundColor: Colors.white.withOpacity(0.3),
//                   valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _hasNavigated = false; // Prevent multiple navigations

  @override
  void initState() {
    super.initState();

    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Check auth only once
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Prevent multiple calls
    if (_hasNavigated) return;

    try {
      // Wait for animation
      await Future.delayed(const Duration(seconds: 2));

      // Check if already navigated (in case of rapid rebuilds)
      if (_hasNavigated || !mounted) return;

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // No user - go to role selection
        _navigateTo('/role');
      } else {
        // User exists - check role
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!mounted) return;

        if (userDoc.exists) {
          final data = userDoc.data();
          final role = data?['role'];

          if (role == 'driver') {
            _navigateTo('/driver');
          } else if (role == 'mechanic') {
            final onboardingCompleted = data?['onboardingCompleted'] == true;
            final verificationStatus = data?['verificationStatus'] ?? '';

            if (!onboardingCompleted) {
              _navigateTo('/mechanic-onboarding');
            } else if (verificationStatus == 'pending' ||
                verificationStatus == 'rejected') {
              _navigateTo('/mechanic-verification');
            } else if (verificationStatus == 'approved') {
              _navigateTo('/mechanic');
            } else {
              _navigateTo('/mechanic-onboarding');
            }
          } else {
            _navigateTo('/role');
          }
        } else {
          _navigateTo('/role');
        }
      }
    } catch (e) {
      print('❌ Splash navigation error: $e');
      if (mounted && !_hasNavigated) {
        _navigateTo('/role');
      }
    }
  }

  void _navigateTo(String route) {
    if (_hasNavigated || !mounted) return;

    _hasNavigated = true;
    Get.offAllNamed(route);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.car_repair,
                    size: 80,
                    color: Color(0xFF6C63FF),
                  ),
                ),

                const SizedBox(height: 30),

                // App Name
                Text(
                  "DriveResQ",
                  style: GoogleFonts.poppins(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 10),

                // Tagline
                Text(
                  "Your Roadside Guardian",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 50),

                // Loading indicator
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
