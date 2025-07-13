import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();
  static bool _initialized = false;
  static bool _soundEnabled = true;

  static Future<void> initializeAudio() async {
    if (!_initialized) {
      if (kIsWeb) {
        // Pre-load sounds for web by creating source objects
        await Future.wait([
          _player.setSource(AssetSource('sounds/click.mp3')),
          _player.setSource(AssetSource('sounds/win.mp3')),
          _player.setSource(AssetSource('sounds/lose.mp3')),
          _player.setSource(AssetSource('sounds/draw.mp3')),
        ]);
      }
      _initialized = true;
    }
  }

  static void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  static bool get isSoundEnabled => _soundEnabled;

  static Future<void> _playSound(String soundPath) async {
    if (!_soundEnabled) return;

    try {
      if (!_initialized) {
        await initializeAudio();
      }

      // Stop any currently playing sound
      await _player.stop();

      // Use source with full path for web
      final source =
          kIsWeb ? AssetSource('sounds/$soundPath') : AssetSource(soundPath);

      await _player.play(source);
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
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
    _player.dispose();
  }
}
