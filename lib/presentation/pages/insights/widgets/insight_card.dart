import 'package:flutter/material.dart';
import '../../../../domain/entities/insight.dart';

class InsightCard extends StatelessWidget {
  final InsightEntity insight;
  final VoidCallback? onAction;
  final VoidCallback? onDismiss;

  const InsightCard({
    super.key,
    required this.insight,
    this.onAction,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E272E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: insight.priority == InsightPriority.high 
            ? _getImpactColor(insight.impact).withOpacity(0.5)
            : _getImpactColor(insight.impact).withOpacity(0.3),
          width: insight.priority == InsightPriority.high ? 2 : 1,
        ),
        boxShadow: [
          if (insight.priority == InsightPriority.high)
            BoxShadow(
              color: _getImpactColor(insight.impact).withOpacity(0.15),
              blurRadius: 15,
              spreadRadius: 2,
            )
          else
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getImpactColor(insight.impact).withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconForType(insight.type),
                        color: _getImpactColor(insight.impact),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF101828),
                            ),
                          ),
                          if (insight.category != null)
                            Text(
                              insight.category!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF667085),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  insight.description,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF475467),
                  ),
                ),
                
                // --- SUBTLE BUT PROMINENT BUTTON ---
                if (insight.actionType != InsightActionType.none) ...[
                  const SizedBox(height: 16),
                  _buildActionButton(context, isDark),
                ],
              ],
            ),
          ),

          // --- DISMISS BUTTON (X) ---
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: onDismiss,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Color(0xFF667085),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, bool isDark) {
    final color = _getImpactColor(insight.impact);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        // --- SOFT GLOW EFFECT ---
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: onAction,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: color.withOpacity(0.05),
        ),
        child: Text(
          _getActionText(insight.actionType),
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getActionText(InsightActionType type) {
    switch (type) {
      case InsightActionType.setBudget: return 'Adjust Budget';
      case InsightActionType.viewHistory: return 'Review Details';
      default: return 'Learn More';
    }
  }

  IconData _getIconForType(InsightType type) {
    switch (type) {
      case InsightType.velocity: return Icons.speed;
      case InsightType.anomaly: return Icons.warning_amber_rounded;
      case InsightType.trend: return Icons.trending_up_rounded;
      case InsightType.projection: return Icons.insights;
      default: return Icons.lightbulb_outline;
    }
  }

  Color _getImpactColor(InsightImpact impact) {
    switch (impact) {
      case InsightImpact.positive: return const Color(0xFF18B27A);
      case InsightImpact.warning: return const Color(0xFFF04438);
      case InsightImpact.neutral: return const Color(0xFF1570EF);
    }
  }
}
