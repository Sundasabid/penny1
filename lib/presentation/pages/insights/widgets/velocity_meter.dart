import 'package:flutter/material.dart';
import '../../../../config/themes/app_colors.dart';

class VelocityMeter extends StatelessWidget {
  final double timeRatio; // 0.0 to 1.0 (elapsed days / total days)
  final double spendRatio; // 0.0 to 1.0 (current spend / average month spend)

  const VelocityMeter({
    super.key,
    required this.timeRatio,
    required this.spendRatio,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverspending = spendRatio > (timeRatio + 0.1);
    
    final color = isOverspending ? Colors.orangeAccent : AppColors.neon;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A21) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? const Color(0xFF1E272E) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Spending Velocity',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.5,
                ),
              ),
              _buildStatusBadge(isOverspending),
            ],
          ),
          const SizedBox(height: 24),
          
          // The Progress Bar
          Stack(
            children: [
              // Background track
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              
              // Time Marker (Dotted line or subtle indicator)
              Positioned(
                left: 0,
                right: 0,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: timeRatio.clamp(0.0, 1.0),
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: isDark ? Colors.white38 : Colors.black38,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Spend Fill
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: spendRatio.clamp(0.0, 1.0),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCaption('Month Elapsed', '${(timeRatio * 100).toStringAsFixed(0)}%', isDark),
              _buildCaption('Budget Used', '${(spendRatio * 100).toStringAsFixed(0)}%', isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isOverspending) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isOverspending ? Colors.orangeAccent : AppColors.neon).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isOverspending ? 'FAST' : 'NORMAL',
        style: TextStyle(
          color: isOverspending ? Colors.orangeAccent : AppColors.neon,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildCaption(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
