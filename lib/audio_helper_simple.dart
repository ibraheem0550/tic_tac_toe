import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AudioHelper {
  static bool _initialized = false;
  static bool _soundEnabled = true;

  static Future<void> initializeAudio() async {
    if (!_initialized) {
      try {
        // تحضير الأصوات باستخدام SystemSound
        _initialized = true;
        if (kDebugMode) {
          debugPrint('Audio initialized successfully (using system sounds)');
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Audio initialization failed: $e');
        }
      }
    }
  }

  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  static bool get isSoundEnabled => _soundEnabled;

  static Future<void> _playSystemSound() async {
    if (!_soundEnabled) return;

    try {
      // استخدام أصوات النظام البديلة
      SystemSound.play(SystemSoundType.click);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('System sound playback failed: $e');
      }
    }
  }

  static Future<void> playClickSound() async {
    await _playSystemSound();
  }

  static Future<void> playWinSound({bool isAI = false}) async {
    if (!_soundEnabled) return;

    try {
      // صوت مختلف للفوز
      if (isAI) {
        SystemSound.play(SystemSoundType.alert);
      } else {
        SystemSound.play(SystemSoundType.click);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Win sound playback failed: $e');
      }
    }
  }

  static Future<void> playLoseSound() async {
    if (!_soundEnabled) return;

    try {
      SystemSound.play(SystemSoundType.alert);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Lose sound playback failed: $e');
      }
    }
  }

  static Future<void> playDrawSound() async {
    if (!_soundEnabled) return;

    try {
      SystemSound.play(SystemSoundType.click);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Draw sound playback failed: $e');
      }
    }
  }

  static void dispose() {
    // لا حاجة للتنظيف مع أصوات النظام
    _initialized = false;
  }
}
