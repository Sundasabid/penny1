import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/dashboard_aggregations.dart';
import '../../../domain/entities/transaction.dart';

class TotalSpendCard extends StatefulWidget {
  const TotalSpendCard({
    super.key,
    required this.transactions,
    required this.symbol,
  });

  final List<TransactionEntity> transactions;
  final String symbol;

  @override
  State<TotalSpendCard> createState() => _TotalSpendCardState();
}

class _TotalSpendCardState extends State<TotalSpendCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offsetAnimation;
  bool _isAllTime = false;
  DateTime _selectedMonth = DateTime.now();

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _offsetAnimation = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalSpend = 0;
    double pct = 0;

    if (_isAllTime) {
      totalSpend = allTimeTotalSpend(transactions: widget.transactions);
      pct = 0;
    } else {
      totalSpend = monthTotalSpend(month: _selectedMonth, transactions: widget.transactions);
      pct = percentChangeMonthToMonthSpend(currentMonth: _selectedMonth, transactions: widget.transactions);
    }

    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offsetAnimation.value),
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF18B27A).withOpacity(0.4),
                  blurRadius: 40,
                  offset: Offset(0, 15 + (_offsetAnimation.value * 0.5)),
                ),
                BoxShadow(
                  color: const Color(0xFF18B27A).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background Gradient
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF20D692), // Lighter, more neon top-left
                        Color(0xFF18B27A),
                        Color(0xFF0F7A54),
                      ],
                    ),
                  ),
                ),

                // Pattern Overlay
                ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _CardPatternPainter(),
                  ),
                ),

                // Glass effect overlay (subtle)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL SPEND',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              if (!_isAllTime)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        InkWell(
                                          onTap: _previousMonth,
                                          child: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 16),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          child: Text(
                                            DateFormat('MMM yyyy').format(_selectedMonth).toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: _nextMonth,
                                          child: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isAllTime = !_isAllTime;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(_isAllTime ? 0.3 : 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Text(
                                    _isAllTime ? 'ALL TIME' : 'MONTHLY',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (!_isAllTime)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        pct >= 0 ? Icons.trending_up : Icons.trending_down,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${pct.abs().toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            widget.symbol,
                            style: const TextStyle(
                              color: Color(0xCCFFFFFF),
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _formatWithCommas(totalSpend.round()),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1.5,
                                height: 1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _formatWithCommas(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write(',');
    }
    return buf.toString();
  }
}

class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw some stylized lines/curves

    // Bottom right circles
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 60, paint);
    canvas.drawCircle(
      Offset(size.width * 0.9, size.height * 0.8),
      100,
      paint..color = Colors.white.withOpacity(0.03),
    );

    // Top left waves
    final wavePath = Path();
    wavePath.moveTo(0, size.height * 0.3);
    wavePath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.1,
      size.width * 0.5,
      size.height * 0.3,
    );
    wavePath.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.5,
      size.width,
      size.height * 0.3,
    );

    canvas.drawPath(wavePath, paint..color = Colors.white.withOpacity(0.05));

    // Abstract grid dots
    final dotPaint = Paint()..color = Colors.white.withOpacity(0.1);
    for (double i = 40; i < size.width; i += 40) {
      for (double j = 40; j < size.height; j += 40) {
        canvas.drawCircle(Offset(i, j), 1, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
