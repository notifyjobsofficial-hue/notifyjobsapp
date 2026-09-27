import 'package:flutter/foundation.dart';

/// Lightweight performance tracer for recording startup, query, and render timings.
class PerformanceTracker {
  PerformanceTracker._();

  static final Stopwatch _stopwatch = Stopwatch()..start();
  static final Map<String, int> _milestones = {};

  /// Record milestone timestamp in milliseconds since app launch.
  static void mark(String label) {
    if (!_milestones.containsKey(label)) {
      final ms = _stopwatch.elapsedMilliseconds;
      _milestones[label] = ms;
      if (kDebugMode) {
        debugPrint('[PERF] $label: ${ms}ms');
      }
    }
  }

  /// Retrieve all logged milestones.
  static Map<String, int> get milestones => Map.unmodifiable(_milestones);

  /// Get elapsed time for a specific milestone.
  static int? get(String label) => _milestones[label];

  /// Reset stopwatch and milestone map.
  static void reset() {
    _stopwatch.reset();
    _stopwatch.start();
    _milestones.clear();
  }
}
