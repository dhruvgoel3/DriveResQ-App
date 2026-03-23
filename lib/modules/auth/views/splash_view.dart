import 'package:iconsax/iconsax.dart';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driveresq_app/utils/helpers/responsive_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _progressCtrl;
  late AnimationController _taglineCtrl;
  late AnimationController _carCtrl;
  late AnimationController _exitCtrl;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _pulse;
  late Animation<double> _progress;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _carPos;
  late Animation<double> _exitFade;
  late Animation<double> _exitScale;

  String _status = 'Initializing...';
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    // Logo
    _logoCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _logoScale = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));

    // Pulse
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // Progress
    _progressCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3500),
    );
    _progress = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut));
    _progressCtrl.addListener(_updateStatus);

    // Tagline
    _taglineCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _taglineSlide = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut));
    _taglineFade = CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut);

    // Car
    _carCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500),
    )..repeat();
    _carPos = Tween<double>(
      begin: -1.2,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _carCtrl, curve: Curves.easeInOut));

    // Exit
    _exitCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _exitFade = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
    _exitScale = Tween<double>(
      begin: 1,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));

    _startSequence();
  }

  void _updateStatus() {
    if (!mounted) return;
    final v = _progress.value;
    final newStatus = v < 0.3
        ? 'Initializing...'
        : v < 0.6
        ? 'Checking connection...'
        : v < 0.9
        ? 'Loading your data...'
        : 'Almost ready...';
    if (newStatus != _status) {
      setState(() => _status = newStatus);
    }
  }

  Future<void> _startSequence() async {
    await Future.delayed(Duration(milliseconds: 200));
    if (!mounted) return;
    _logoCtrl.forward();

    await Future.delayed(Duration(milliseconds: 800));
    if (!mounted) return;
    _taglineCtrl.forward();

    await Future.delayed(Duration(milliseconds: 400));
    if (!mounted) return;
    _progressCtrl.forward();

    _checkAuth();
  }

  Future<void> _checkAuth() async {
    if (_navigated) return;

    try {
      await Future.delayed(Duration(milliseconds: 3800));
      if (_navigated || !mounted) return;

      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('hasSeenOnboarding') ?? false;

      if (!seen) {
        await _goTo('/onboarding');
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await _goTo('/role');
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

      if (!doc.exists) {
        await _goTo('/role');
        return;
      }

      final data = doc.data();
      final role = data?['role'];

      if (role == 'driver') {
        final done = data?['driverOnboardingCompleted'] == true;
        await _goTo(done ? '/driver' : '/driver-onboarding');
      } else if (role == 'mechanic') {
        final onboarded = data?['onboardingCompleted'] == true;
        final vs = data?['verificationStatus'] ?? '';
        if (!onboarded) {
          await _goTo('/mechanic-onboarding');
        } else if (vs == 'approved') {
          await _goTo('/mechanic');
        } else {
          await _goTo('/mechanic-verification');
        }
      } else {
        await _goTo('/role');
      }
    } catch (e) {
      debugPrint('❌ Splash: $e');
      if (mounted && !_navigated) await _goTo('/role');
    }
  }

  Future<void> _goTo(String route) async {
    if (_navigated || !mounted) return;
    _navigated = true;
    await _exitCtrl.forward();
    if (!mounted) return;
    Get.offAllNamed(route);
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    _taglineCtrl.dispose();
    _carCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _exitCtrl,
        builder: (_, __) => Opacity(
          opacity: _exitFade.value,
          child: Transform.scale(
            scale: _exitScale.value,
            child: Container(
              width: sz.width,
              height: sz.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6C63FF),
                    Color(0xFF5B52E5),
                    Color(0xFF3D35C5),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  // Glow circles
                  Positioned(top: -80, right: -60, child: _circle(200, 0.06)),
                  Positioned(
                    bottom: -100,
                    left: -80,
                    child: _circle(250, 0.05),
                  ),
                  Positioned(
                    top: sz.height * 0.3,
                    left: -50,
                    child: _circle(120, 0.04),
                  ),

                  // Car
                  _movingCar(sz),

                  // Main content
                  SafeArea(
                    child: Column(
                      children: [
                        Spacer(flex: 3),
                        _logo(),
                        SizedBox(height: 28.h),
                        _appName(),
                        SizedBox(height: 10.h),
                        _tagline(),
                        Spacer(flex: 2),
                        _progressSection(sz),
                        Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _circle(double s, double o) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: o),
    ),
  );

  Widget _movingCar(Size sz) {
    return Positioned(
      bottom: sz.height * 0.22,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _carPos,
        builder: (_, __) => Transform.translate(
          offset: Offset(_carPos.value * sz.width * 0.5, 0),
          child: Icon(
            Iconsax.car,
            size: 22.w,
            color: Colors.white.withValues(alpha: 0.25),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoCtrl, _pulseCtrl]),
      builder: (_, __) => Opacity(
        opacity: _logoFade.value,
        child: Transform.scale(
          scale: _logoScale.value * _pulse.value,
          child: Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6C63FF).withValues(alpha: 0.4),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Iconsax.car,
                  size: 40.w,
                  color: Color(0xFF6C63FF),
                ),
                Positioned(
                  right: 22.w,
                  bottom: 24.h,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: Icon(
                      Iconsax.setting_2,
                      size: 22.w,
                      color: Color(0xFFFF9800).withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appName() {
    return FadeTransition(
      opacity: _logoFade,
      child: ShaderMask(
        shaderCallback: (b) => LinearGradient(
          colors: [Colors.white, Color(0xFFFFD180)],
        ).createShader(b),
        child: Text(
          'DriveResQ',
          style: GoogleFonts.poppins(
            fontSize: 42.sp,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _tagline() {
    return SlideTransition(
      position: _taglineSlide,
      child: FadeTransition(
        opacity: _taglineFade,
        child: Text(
          'Your Roadside Guardian',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 0.8,
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }

  Widget _progressSection(Size sz) {
    return AnimatedBuilder(
      animation: _progressCtrl,
      builder: (_, __) {
        final v = _progress.value;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: sz.width * 0.15),
          child: Column(
            children: [
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final sinVal = sin((v * 6 + i * 0.3) * pi);
                  final op = 0.3 + (sinVal + 1) * 0.35;
                  final sc = 0.7 + (sinVal + 1) * 0.15;
                  return Transform.scale(
                    scale: sc,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: 10.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 1
                            ? Color.fromRGBO(255, 152, 0, op)
                            : Color.fromRGBO(255, 255, 255, op),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20.h),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6.r),
                child: SizedBox(
                  height: 5.h,
                  child: Stack(
                    children: [
                      Container(color: Colors.white.withValues(alpha: 0.15)),
                      FractionallySizedBox(
                        widthFactor: v,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.r),
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFFF9800),
                                Color(0xFFFFD180),
                                Colors.white,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Status
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Text(
                  _status,
                  key: ValueKey(_status),
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.7),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              SizedBox(height: 4.h),

              // Percentage
              Text(
                '${(v * 100).toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
