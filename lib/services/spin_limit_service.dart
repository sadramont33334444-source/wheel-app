import 'package:shared_preferences/shared_preferences.dart';

/// سرویس مدیریت محدودیت 3 بار چرخش در هر 24 ساعت
class SpinLimitService {
  static const String _keySpinCount = 'spin_count';
  static const String _keyFirstSpinTimestamp = 'first_spin_timestamp';
  static const int _maxSpinsPerDay = 3;
  static const Duration _resetDuration = Duration(hours: 24);

  /// بررسی آیا کاربر می‌تواند چرخش جدید داشته باشد
  Future<bool> canSpin() async {
    final prefs = await SharedPreferences.getInstance();
    final spinCount = prefs.getInt(_keySpinCount) ?? 0;
    final firstSpinTimestamp = prefs.getInt(_keyFirstSpinTimestamp);

    // اگر هنوز چرخشی نداشته یا تایم ریست شده
    if (firstSpinTimestamp == null) {
      return true;
    }

    final firstSpinDate = DateTime.fromMillisecondsSinceEpoch(firstSpinTimestamp);
    final now = DateTime.now();
    final diff = now.difference(firstSpinDate);

    // اگر 24 ساعت گذشته، ریست کن
    if (diff >= _resetDuration) {
      await _resetSpins();
      return true;
    }

    // اگر کمتر از حد مجاز چرخیده
    return spinCount < _maxSpinsPerDay;
  }

  /// دریافت تعداد شانس باقی‌مانده
  Future<int> getRemainingSpins() async {
    final prefs = await SharedPreferences.getInstance();
    final spinCount = prefs.getInt(_keySpinCount) ?? 0;
    final firstSpinTimestamp = prefs.getInt(_keyFirstSpinTimestamp);

    if (firstSpinTimestamp == null) {
      return _maxSpinsPerDay;
    }

    final firstSpinDate = DateTime.fromMillisecondsSinceEpoch(firstSpinTimestamp);
    final now = DateTime.now();
    final diff = now.difference(firstSpinDate);

    // اگر 24 ساعت گذشته
    if (diff >= _resetDuration) {
      return _maxSpinsPerDay;
    }

    return _maxSpinsPerDay - spinCount;
  }

  /// ثبت یک چرخش جدید
  Future<void> recordSpin() async {
    final prefs = await SharedPreferences.getInstance();
    final spinCount = prefs.getInt(_keySpinCount) ?? 0;
    final firstSpinTimestamp = prefs.getInt(_keyFirstSpinTimestamp);

    // اگر اولین چرخش است یا بازه جدید شروع شده
    if (firstSpinTimestamp == null) {
      await prefs.setInt(_keyFirstSpinTimestamp, DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt(_keySpinCount, 1);
    } else {
      final firstSpinDate = DateTime.fromMillisecondsSinceEpoch(firstSpinTimestamp);
      final now = DateTime.now();
      final diff = now.difference(firstSpinDate);

      // اگر 24 ساعت گذشته، ریست و شروع دوره جدید
      if (diff >= _resetDuration) {
        await prefs.setInt(_keyFirstSpinTimestamp, now.millisecondsSinceEpoch);
        await prefs.setInt(_keySpinCount, 1);
      } else {
        // اضافه کردن یک چرخش به تعداد فعلی
        await prefs.setInt(_keySpinCount, spinCount + 1);
      }
    }
  }

  /// دریافت زمان باقی‌مانده تا ریست (به میلی‌ثانیه)
  Future<Duration?> getTimeUntilReset() async {
    final prefs = await SharedPreferences.getInstance();
    final firstSpinTimestamp = prefs.getInt(_keyFirstSpinTimestamp);

    if (firstSpinTimestamp == null) {
      return null;
    }

    final firstSpinDate = DateTime.fromMillisecondsSinceEpoch(firstSpinTimestamp);
    final now = DateTime.now();
    final resetTime = firstSpinDate.add(_resetDuration);

    if (now.isAfter(resetTime)) {
      return null;
    }

    return resetTime.difference(now);
  }

  /// ریست کردن تعداد چرخش‌ها (فقط داخلی)
  Future<void> _resetSpins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySpinCount);
    await prefs.remove(_keyFirstSpinTimestamp);
  }

  /// برای تست و دیباگ - پاک کردن کل داده‌ها
  Future<void> resetAll() async {
    await _resetSpins();
  }
}
