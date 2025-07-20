import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();
  static bool _initialized = false;
  static bool _soundEnabled = true;
  static bool _isPreloading = false;

  static Future<void> initializeAudio() async {
    if (_initialized) return;

    try {
      _initialized = true;

      if (!kIsWeb) {
        // تحميل سريع للموبايل/ديسكتوب - بدون انتظار
        _preloadSoundsAsync();
      } else {
        // تحميل مبسط للويب
        _preloadWebSounds();
      }

      debugPrint('✅ Audio system initialized');
    } catch (e) {
      debugPrint('⚠️ Audio initialization warning: $e');
      // نستمر بدون الصوت
    }
  }

  // تحميل الأصوات في الخلفية للموبايل/ديسكتوب
  static void _preloadSoundsAsync() {
    if (_isPreloading) return;
    _isPreloading = true;

    // تحميل في الخلفية بدون await
    Future.microtask(() async {
      try {
        const sounds = ['click.mp3', 'win.mp3', 'lose.mp3', 'draw.mp3'];
        for (final sound in sounds) {
          await _player.setSource(AssetSource('sounds/$sound'));
          await Future.delayed(
            const Duration(milliseconds: 50),
          ); // استراحة صغيرة
        }
        debugPrint('✅ Audio preload completed');
      } catch (e) {
        debugPrint('⚠️ Audio preload warning: $e');
      } finally {
        _isPreloading = false;
      }
    });
  }

  // تحميل مبسط للويب
  static void _preloadWebSounds() {
    // تحميل واحد فقط للاختبار السريع
    Future.microtask(() async {
      try {
        await _player.setSource(AssetSource('sounds/click.mp3'));
        debugPrint('✅ Web audio ready');
      } catch (e) {
        debugPrint('⚠️ Web audio warning: $e');
      }
    });
  }

  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  static bool get isSoundEnabled => _soundEnabled;

  static Future<void> _playSound(String soundPath) async {
    if (!_soundEnabled) return;

    try {
      // تهيئة سريعة إذا لم تتم
      if (!_initialized) {
        await initializeAudio();
      }

      // إيقاف الصوت السابق بسرعة
      unawaited(_player.stop());

      // تشغيل الصوت الجديد
      final source = AssetSource('sounds/$soundPath');
      unawaited(_player.play(source));
    } catch (e) {
      debugPrint('⚠️ Sound play warning: $e');
      // نستمر بدون الصوت
    }
  }

  // دالة مساعدة للعمليات غير المنتظرة
  static void unawaited(Future<void> future) {
    future.catchError((e) {
      debugPrint('⚠️ Unawaited operation warning: $e');
    });
  }

  static Future<void> playClickSound() async {
    await _playSound('click.mp3');
  }

  static Future<void> playWinSound({bool isAI = false}) async {
    if (!isAI) {
      await _playSound('win.mp3');
    }
  }

  static Future<void> playLoseSound() async {
    await _playSound('lose.mp3');
  }

  static Future<void> playDrawSound() async {
    await _playSound('draw.mp3');
  }

  static void dispose() {
    try {
      _player.dispose();
    } catch (e) {
      debugPrint('⚠️ Audio dispose warning: $e');
    }
  }
}
