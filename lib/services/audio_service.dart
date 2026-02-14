import 'package:audioplayers/audioplayers.dart';

/// سرویس پخش صدا به صورت آفلاین
class AudioService {
  final AudioPlayer _spinPlayer = AudioPlayer();
  final AudioPlayer _winPlayer = AudioPlayer();

  /// پخش صدای چرخش
  Future<void> playSpinSound() async {
    try {
      await _spinPlayer.stop();
      await _spinPlayer.play(AssetSource('audio/spin.mp3'));
    } catch (e) {
      // در صورت عدم وجود فایل صدا، خطا را نادیده می‌گیریم
      // ignore: avoid_print
      print('خطا در پخش صدای چرخش: $e');
    }
  }

  /// پخش صدای برد
  Future<void> playWinSound() async {
    try {
      await _winPlayer.stop();
      await _winPlayer.play(AssetSource('audio/win.mp3'));
    } catch (e) {
      // ignore: avoid_print
      print('خطا در پخش صدای برد: $e');
    }
  }

  /// توقف همه صداها
  Future<void> stopAll() async {
    await _spinPlayer.stop();
    await _winPlayer.stop();
  }

  /// آزادسازی منابع
  void dispose() {
    _spinPlayer.dispose();
    _winPlayer.dispose();
  }
}
