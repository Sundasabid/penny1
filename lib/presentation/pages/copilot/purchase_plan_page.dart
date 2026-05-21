import 'package:flutter/material.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../domain/entities/planned_purchase.dart';

class PurchasePlanPage extends StatelessWidget {
  final PlannedPurchase purchase;

  const PurchasePlanPage({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalDays = purchase.targetDate.difference(DateTime.now()).inDays.abs() + 1;
    final advice = purchase.aiAdvice ?? '';

    // Parsing structured AI response
    String dailyTarget = '0';
    String weeklyTarget = '0';
    List<Map<String, String>> categoricalCuts = [];
    List<String> strategyPoints = [];
    String summary = '';

    if (advice.contains('DAILY_TARGET:')) {
      final lines = advice.split('\n');
      for (var line in lines) {
        if (line.startsWith('DAILY_TARGET:')) dailyTarget = _cleanValue(line.split(':')[1]);
        if (line.startsWith('WEEKLY_TARGET:')) weeklyTarget = _cleanValue(line.split(':')[1]);
        
        if (line.startsWith('CATEGORICAL_CUTS:')) {
          final cutsData = line.replaceFirst('CATEGORICAL_CUTS:', '').trim();
          final cuts = cutsData.replaceAll('[', '').replaceAll(']', '').split(';');
          for (var cut in cuts) {
            final parts = cut.split('|');
            if (parts.length >= 3) {
              categoricalCuts.add({
                'category': parts[0].trim(),
                'spend': parts[1].trim(),
                'save': parts[2].trim(),
                'tip': parts.length > 3 ? parts[3].trim() : 'Optimize',
              });
            }
          }
        }
        
        if (line.startsWith('STRATEGY_POINTS:')) {
          final pointsData = line.replaceFirst('STRATEGY_POINTS:', '').trim();
          strategyPoints = pointsData.replaceAll('[', '').replaceAll(']', '').split(';').map((p) => p.trim()).toList();
        }
      }
      
      final summaryIndex = lines.indexWhere((l) => !l.contains('_TARGET') && !l.contains('_POINTS') && !l.contains('_CUTS') && l.trim().isNotEmpty);
      if (summaryIndex != -1) {
        summary = lines.skip(summaryIndex).join('\n').trim();
      }
    } else {
       summary = advice;
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      appBar: AppBar(
        title: const Text('PURCHASE PLAN', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // 1. HEADER HERO (GLOWING)
          _buildHeroSection(isDark),
          const SizedBox(height: 32),

          // 2. TIMELINE (GLOWING PROGRESS)
          _buildSectionHeader('TIMELINE PROGRESS'),
          const SizedBox(height: 16),
          _buildTimelineTracker(totalDays, isDark),
          const SizedBox(height: 32),

          // 3. TARGET TILES (NEON GLOW)
          Row(
            children: [
              Expanded(child: _buildMilestoneCard('DAILY TARGET', '$dailyTarget PKR', Icons.calendar_today_rounded, AppColors.neon, isDark)),
              const SizedBox(width: 16),
              Expanded(child: _buildMilestoneCard('WEEKLY GOAL', '$weeklyTarget PKR', Icons.checklist_rounded, Colors.orangeAccent, isDark)),
            ],
          ),
          const SizedBox(height: 32),

          // 4. SMART REDUCTIONS (DETAIL CARDS)
          _buildSectionHeader('CATEGORY TRIMMING PLAN'),
          const SizedBox(height: 16),
          if (categoricalCuts.isEmpty)
             _buildEmptyCuts(isDark)
          else
             ...categoricalCuts.map((cut) => _buildDetailedCutCard(cut, isDark)),
          
          const SizedBox(height: 32),

          // 5. QUICK ACTION STEPS
          _buildSectionHeader("ACTION STEPS"),
          const SizedBox(height: 16),
          _buildActionList(strategyPoints, isDark),
          
          const SizedBox(height: 32),
          
          // AI SUMMARY
          _buildSummaryBox(summary, isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _cleanValue(String val) => val.replaceAll('[', '').replaceAll(']', '').trim();

  Widget _buildDetailedCutCard(Map<String, String> cut, bool isDark) {
    final category = cut['category'] ?? 'General';
    final icon = _getCategoryIcon(category);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: isDark ? [] : [
           BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neon.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.neon, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${cut["spend"]} spend', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 10, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text('Target ${cut["save"]} Save', style: const TextStyle(fontSize: 12, color: AppColors.neon, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF04438).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Trim',
                style: const TextStyle(color: Color(0xFFF04438), fontWeight: FontWeight.w900, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionList(List<String> points, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: points.map((p) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.neon, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  p,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildHeroSection(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.neon.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.neon.withOpacity(0.2),
                blurRadius: 40,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.shopping_bag_rounded, color: AppColors.neon, size: 48),
        ),
        const SizedBox(height: 24),
        Text(
          purchase.name.toUpperCase(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        Text(
          '${purchase.amount.round()} PKR Target',
          style: const TextStyle(fontSize: 16, color: AppColors.neon, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildTimelineTracker(int days, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Timeline Check', style: TextStyle(fontWeight: FontWeight.w900)),
              Text('$days Days Remaining', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.25,
              minHeight: 10,
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation(AppColors.neon),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: isDark ? [
           BoxShadow(color: color.withOpacity(0.05), blurRadius: 20, spreadRadius: -5),
        ] : [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black)),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String summary, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.neon.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neon.withOpacity(0.1)),
      ),
      child: Text(
        summary,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, fontStyle: FontStyle.italic, height: 1.5),
      ),
    );
  }

  Widget _buildEmptyCuts(bool isDark) {
     return Center(child: Text('AI analyzing details...', style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)));
  }

  IconData _getCategoryIcon(String cat) {
    final lower = cat.toLowerCase();
    if (lower.contains('food') || lower.contains('dining') || lower.contains('eat')) return Icons.restaurant_rounded;
    if (lower.contains('travel') || lower.contains('transport') || lower.contains('fuel')) return Icons.commute_rounded;
    if (lower.contains('shop') || lower.contains('purchas')) return Icons.shopping_bag_rounded;
    if (lower.contains('home') || lower.contains('rent')) return Icons.home_rounded;
    if (lower.contains('health')) return Icons.health_and_safety_rounded;
    if (lower.contains('educ')) return Icons.school_rounded;
    return Icons.auto_graph_rounded;
  }
}
