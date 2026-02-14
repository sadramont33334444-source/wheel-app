import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/prize_item.dart';
import '../services/audio_service.dart';
import '../services/spin_limit_service.dart';
import '../widgets/fortune_wheel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // سرویس‌ها
  final SpinLimitService _limitService = SpinLimitService();
  final AudioService _audioService = AudioService();

  // کنترل انیمیشن
  late AnimationController _animationController;
  late Animation<double> _animation;

  // وضعیت‌ها
  bool _isSpinning = false;
  int _remainingSpins = 3;
  Duration? _timeUntilReset;

  // Confetti
  late ConfettiController _confettiController;

  // زاویه فعلی گردونه
  double _currentRotation = 0.0;

  @override
  void initState() {
    super.initState();

    // ایجاد AnimationController
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );

    _confettiController = ConfettiController(
      duration: Duration(seconds: 3),
    );

    _loadSpinStatus();
  }

  /// بارگذاری وضعیت شانس‌های باقی‌مانده
  Future<void> _loadSpinStatus() async {
    final remaining = await _limitService.getRemainingSpins();
    final timeUntil = await _limitService.getTimeUntilReset();

    setState(() {
      _remainingSpins = remaining;
      _timeUntilReset = timeUntil;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  /// شروع چرخش گردونه
  Future<void> _spinWheel() async {
    // بررسی محدودیت
    final canSpin = await _limitService.canSpin();
    if (!canSpin) {
      _showLimitReachedDialog();
      return;
    }

    // جلوگیری از کلیک‌های متعدد
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    // انتخاب نتیجه به صورت تصادفی
    final random = math.Random();
    final selectedIndex = random.nextInt(wheelPrizes.length);
    final selectedPrize = wheelPrizes[selectedIndex];

    // محاسبه زاویه دقیق برای توقف
    // هر بخش = 360 / 8 = 45 درجه
    final degreesPerSection = 360.0 / wheelPrizes.length;

    // زاویه مرکز بخش انتخابی (نسبت به نشانگر در بالا)
    // توجه: نشانگر در بالا (270 درجه یا -90 درجه) قرار دارد
    // باید گردونه طوری بچرخد که بخش انتخابی زیر نشانگر بیاید

    // محاسبه زاویه هدف:
    // - چند دور کامل (5 دور = 1800 درجه)
    // - زاویه دقیق بخش: باید بخش در موقعیت 90 درجه باشد (بالا)
    final fullRotations = 5; // 5 دور کامل
    final baseAngle = fullRotations * 360.0;

    // زاویه هر بخش نسبت به شروع (index 0)
    final sectionAngle = selectedIndex * degreesPerSection;

    // زاویه نهایی: باید طوری باشد که بخش انتخابی در موقعیت 270 درجه (بالا) قرار گیرد
    // چون نشانگر در بالا است و گردونه در خلاف جهت عقربه ساعت می‌چرخد
    final targetAngle = baseAngle + (270 - sectionAngle);

    // تنظیم انیمیشن
    _animation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation + targetAngle,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animation.addListener(() {
      setState(() {
        _currentRotation = _animation.value;
      });
    });

    // شروع انیمیشن و صدا
    _audioService.playSpinSound();
    _animationController.reset();
    await _animationController.forward();

    // ثبت چرخش
    await _limitService.recordSpin();
    await _loadSpinStatus();

    // نمایش نتیجه
    if (!selectedPrize.isEmpty) {
      _audioService.playWinSound();
      _confettiController.play();
      _showWinDialog(selectedPrize.title);
    } else {
      _showEmptyDialog();
    }

    setState(() {
      _isSpinning = false;
    });
  }

  /// دیالوگ برد
  void _showWinDialog(String prizeName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '🎉 تبریک!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'شما این جایزه را برنده شدید:\n\n$prizeName',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('باشه', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  /// دیالوگ پوچ
  void _showEmptyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '😔 پوچ!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24),
        ),
        content: Text(
          'این بار چیزی برنده نشدید.\nدوباره امتحان کنید!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('باشه', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  /// دیالوگ محدودیت
  void _showLimitReachedDialog() {
    final timeRemaining = _formatDuration(_timeUntilReset);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '⏳ محدودیت روزانه',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22),
        ),
        content: Text(
          'شما امروز 3 بار شانس خود را امتحان کرده‌اید.\n\n'
          'لطفاً $timeRemaining دیگر تلاش کنید.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('متوجه شدم', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  /// فرمت زمان باقی‌مانده
  String _formatDuration(Duration? duration) {
    if (duration == null) return '0 ساعت';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours ساعت و $minutes دقیقه';
    } else {
      return '$minutes دقیقه';
    }
  }

  /// باز کردن لینک تلگرام
  Future<void> _openTelegram() async {
    final url = Uri.parse('https://t.me/tolmno');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // محتوای اصلی
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // عنوان
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                    child: Text(
                      'گردونه شانس',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // گردونه و نشانگر
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // نشانگر ثابت
                          WheelPointer(),
                          SizedBox(height: 0),

                          // گردونه
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: FortuneWheel(
                              rotationAngle: _currentRotation,
                              prizes: wheelPrizes,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // دکمه چرخش و اطلاعات
                  Padding(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      children: [
                        // نمایش شانس باقی‌مانده
                        Text(
                          'تعداد شانس باقی‌مانده امروز: $_remainingSpins از 3',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),

                        // دکمه چرخش
                        ElevatedButton(
                          onPressed: _isSpinning ? null : _spinWheel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF667eea),
                            padding: EdgeInsets.symmetric(
                              horizontal: 60,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            _isSpinning ? 'در حال چرخش...' : 'بچرخان!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // فوتر تلگرام
                        GestureDetector(
                          onTap: _openTelegram,
                          child: Text(
                            'ارتباط با ما در تلگرام: @tolmno',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              decoration: TextDecoration.underline,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Confetti
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: math.pi / 2, // به سمت پایین
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
