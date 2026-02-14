import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/prize_item.dart';

/// ویجت گردونه که به صورت دایره‌ای 8 بخش را نمایش می‌دهد
class FortuneWheel extends StatelessWidget {
  final double rotationAngle;
  final List<PrizeItem> prizes;

  const FortuneWheel({
    super.key,
    required this.rotationAngle,
    required this.prizes,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(300, 300),
      painter: _WheelPainter(
        rotationAngle: rotationAngle,
        prizes: prizes,
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final double rotationAngle;
  final List<PrizeItem> prizes;

  _WheelPainter({
    required this.rotationAngle,
    required this.prizes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // تعداد بخش‌ها
    final sectionCount = prizes.length;
    final sweepAngle = 360.0 / sectionCount;

    // رسم هر بخش
    for (int i = 0; i < sectionCount; i++) {
      final startAngle = (i * sweepAngle) + rotationAngle;
      final prize = prizes[i];

      // رسم بخش رنگی
      final paint = Paint()
        ..color = prize.color
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        _degreesToRadians(startAngle),
        _degreesToRadians(sweepAngle),
        false,
      );
      path.close();

      canvas.drawPath(path, paint);

      // رسم خط جدا کننده
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, borderPaint);

      // نوشتن متن در وسط هر بخش
      _drawText(
        canvas,
        center,
        radius,
        startAngle + (sweepAngle / 2),
        prize.title,
      );
    }

    // رسم دایره مرکزی
    final centerCirclePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 30, centerCirclePaint);

    final centerCircleBorderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, 30, centerCircleBorderPaint);
  }

  void _drawText(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    String text,
  ) {
    final textAngle = _degreesToRadians(angle);
    final textRadius = radius * 0.65;

    final textX = center.dx + textRadius * math.cos(textAngle);
    final textY = center.dy + textRadius * math.sin(textAngle);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black45,
              offset: Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.rtl,
    );

    textPainter.layout();

    // چرخش متن به سمت مرکز
    canvas.save();
    canvas.translate(textX, textY);
    canvas.rotate(textAngle + math.pi / 2);
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle;
  }
}

/// نشانگر ثابت در بالای گردونه
class WheelPointer extends StatelessWidget {
  const WheelPointer({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(40, 40),
      painter: _PointerPainter(),
    );
  }
}

class _PointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    final path = Path();
    // فلش مثلثی رو به پایین
    path.moveTo(size.width / 2, size.height); // نوک پایین
    path.lineTo(0, 0); // گوشه چپ
    path.lineTo(size.width, 0); // گوشه راست
    path.close();

    canvas.drawPath(path, paint);

    // سایه
    final shadowPaint = Paint()
      ..color = Colors.black26
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawPath(path, shadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
