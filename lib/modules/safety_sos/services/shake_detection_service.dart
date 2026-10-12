import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Highly reliable foreground shake gesture detection.
///
/// Uses [userAccelerometerEventStream] (gravity-compensated acceleration).
/// Falls back gracefully to [accelerometerEventStream] if user-accelerometer is unavailable.
///
/// Hardware Operating Conditions & Requirements:
///   - Requires an accelerometer sensor (present on virtually all modern smartphones).
///   - Operates in the FOREGROUND while the application is active.
///   - Background / lock-screen detection requires native OS background services
///     with specialized OEM background battery exemptions, which is noted transparently in the UI.
class ShakeDetectionService {
  // ─── Default Thresholds ──────────────────────────────────────────────────
  /// Acceleration magnitude threshold (m/s²).
  /// A firm intentional shake produces 12–25 m/s².
  /// Walking/ambient noise is ~1–3 m/s².
  static const double defaultThreshold = 13.0;

  /// Number of distinct shake peaks required.
  static const int defaultRequiredShakes = 3;

  /// Rolling time window in which the shakes must occur.
  static const Duration defaultShakeWindow = Duration(milliseconds: 2000);

  /// Minimum delay between peak counts (prevents counting 1 long shake swing multiple times).
  static const Duration defaultDebounce = Duration(milliseconds: 250);

  /// Cooldown after a valid shake sequence triggers, preventing duplicate triggers.
  static const Duration defaultCooldown = Duration(seconds: 5);

  // ─── Instance Configuration ──────────────────────────────────────────────
  final double threshold;
  final int requiredShakes;
  final Duration shakeWindow;
  final Duration debounce;
  final Duration cooldown;

  final VoidCallback onShakeDetected;
  final void Function(double currentMagnitude)? onMagnitudeSample;

  // ─── Internal State ──────────────────────────────────────────────────────
  StreamSubscription<dynamic>? _sensorSub;
  final List<DateTime> _eventTimestamps = [];
  DateTime? _lastShakeEventTime;
  bool _inCooldown = false;
  Timer? _cooldownTimer;
  bool _usingFallbackAccelerometer = false;

  ShakeDetectionService({
    required this.onShakeDetected,
    this.threshold = defaultThreshold,
    this.requiredShakes = defaultRequiredShakes,
    this.shakeWindow = defaultShakeWindow,
    this.debounce = defaultDebounce,
    this.cooldown = defaultCooldown,
    this.onMagnitudeSample,
  });

  bool get isListening => _sensorSub != null;
  bool get isInCooldown => _inCooldown;
  bool get isUsingFallbackAccelerometer => _usingFallbackAccelerometer;

  /// Start listening for shake events with high-frequency UI sensor sampling.
  void start() {
    if (_sensorSub != null) return;

    try {
      // Primary: userAccelerometerEventStream gives linear acceleration (gravity removed)
      _sensorSub = userAccelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
        (UserAccelerometerEvent event) {
          _processVector(event.x, event.y, event.z);
        },
        onError: (Object err) {
          debugPrint('ShakeDetectionService: userAccelerometer error, falling back: $err');
          _fallbackToStandardAccelerometer();
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('ShakeDetectionService: userAccelerometer failed to start, falling back: $e');
      _fallbackToStandardAccelerometer();
    }
  }

  void _fallbackToStandardAccelerometer() {
    _sensorSub?.cancel();
    _sensorSub = null;
    _usingFallbackAccelerometer = true;

    try {
      _sensorSub = accelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
        (AccelerometerEvent event) {
          // Standard accelerometer includes gravity (~9.81 m/s²), subtract vector magnitude
          final rawMag = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
          final netMag = max(0.0, rawMag - 9.81);
          _processMagnitude(netMag);
        },
        onError: (Object err) {
          debugPrint('ShakeDetectionService: standard accelerometer error: $err');
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('ShakeDetectionService: standard accelerometer failed to start: $e');
    }
  }

  void _processVector(double x, double y, double z) {
    final magnitude = sqrt(x * x + y * y + z * z);
    _processMagnitude(magnitude);
  }

  void _processMagnitude(double magnitude) {
    onMagnitudeSample?.call(magnitude);

    if (_inCooldown) return;
    if (magnitude < threshold) return;

    final now = DateTime.now();

    // Debounce check
    if (_lastShakeEventTime != null &&
        now.difference(_lastShakeEventTime!) < debounce) {
      return;
    }
    _lastShakeEventTime = now;

    // Record shake
    _eventTimestamps.add(now);

    // Evict expired timestamps outside rolling window
    _eventTimestamps.removeWhere((t) => now.difference(t) > shakeWindow);

    debugPrint(
      'ShakeDetection: qualifying shake peak (mag=${magnitude.toStringAsFixed(1)} m/s²), '
      'count=${_eventTimestamps.length}/$requiredShakes',
    );

    // Check if required sequence reached
    if (_eventTimestamps.length >= requiredShakes) {
      _eventTimestamps.clear();
      _startCooldown();
      debugPrint('ShakeDetection: sequence MATCHED! Triggering SOS callback.');
      onShakeDetected();
    }
  }

  void _startCooldown() {
    _inCooldown = true;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(cooldown, () {
      _inCooldown = false;
    });
  }

  /// Stop listening and reset all timers.
  void stop() {
    _sensorSub?.cancel();
    _sensorSub = null;
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
    _eventTimestamps.clear();
    _lastShakeEventTime = null;
    _inCooldown = false;
  }

  void dispose() => stop();
}
