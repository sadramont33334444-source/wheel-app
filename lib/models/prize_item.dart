import 'dart:ui';

/// مدل هر بخش گردونه (جایزه یا پوچ)
class PrizeItem {
  final String title;
  final bool isEmpty; // آیا این بخش "پوچ" است؟
  final Color color;

  const PrizeItem({
    required this.title,
    required this.isEmpty,
    required this.color,
  });
}

/// لیست ثابت 8 بخش گردونه به ترتیب دقیق
final List<PrizeItem> wheelPrizes = [
  PrizeItem(
    title: '10,000 تومان نقد',
    isEmpty: false,
    color: Color(0xFFFF6B6B),
  ),
  PrizeItem(
    title: 'پوچ',
    isEmpty: true,
    color: Color(0xFF4ECDC4),
  ),
  PrizeItem(
    title: 'لباس',
    isEmpty: false,
    color: Color(0xFFFFE66D),
  ),
  PrizeItem(
    title: 'پوچ',
    isEmpty: true,
    color: Color(0xFF95E1D3),
  ),
  PrizeItem(
    title: 'ساعت هوشمند',
    isEmpty: false,
    color: Color(0xFFA8E6CF),
  ),
  PrizeItem(
    title: 'پوچ',
    isEmpty: true,
    color: Color(0xFFFFD93D),
  ),
  PrizeItem(
    title: 'دستبند جایزه',
    isEmpty: false,
    color: Color(0xFFFF8C94),
  ),
  PrizeItem(
    title: 'پوچ',
    isEmpty: true,
    color: Color(0xFF6BCF7F),
  ),
];
