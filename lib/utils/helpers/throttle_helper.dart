import 'dart:async';
import 'package:flutter/material.dart';

/// A utility to throttle user actions (prevent double-clicks or spam-clicks).
class ThrottleHelper {
  static final Map<String, bool> _isRunningList = {};

  /// Wraps an async function to prohibit concurrent executions.
  /// 
  /// The [action] will not be invoked if it is currently running.
  static Future<void> Function() asyncAction(
      String key, 
      Future<void> Function() action,
      ) {
    return () async {
      if (_isRunningList[key] ?? false) {
        debugPrint('Throttle: Action $key ignored because it is already running.');
        return;
      }
      _isRunningList[key] = true;
      try {
        await action();
      } finally {
        _isRunningList[key] = false;
      }
    };
  }

  static final Map<String, Timer> _throttleTimers = {};

  /// Throttles a synchronous action by a specific duration [ms].
  /// Meaning, the first click works, and any subsequent clicks within [ms] are ignored.
  static void throttle(String key, VoidCallback action, {int ms = 1000}) {
    if (_throttleTimers.containsKey(key)) {
      if (_throttleTimers[key]!.isActive) {
        debugPrint('Throttle: Callback $key ignored (Within timeframe).');
        return;
      }
    }
    
    // Execute immediately
    action();
    
    // Block subsequent triggers for the given duration
    _throttleTimers[key] = Timer(Duration(milliseconds: ms), () {
      _throttleTimers.remove(key);
    });
  }
}
