import 'package:flutter/material.dart';
import '../../../../config/themes/app_colors.dart';
import '../../../../domain/entities/penny_challenge.dart';
import '../challenge_analytics_page.dart';


class ChallengeCard extends StatelessWidget {
  final PennyChallenge? challenge;
  final bool isLoading;
  final VoidCallback onAccept;
  final VoidCallback onComplete;
  final VoidCallback onGenerate;

  const ChallengeCard({
    super.key,
    this.challenge,
    this.isLoading = false,
    required this.onAccept,
    required this.onComplete,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return _buildShell(isDark, child: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: AppColors.neon, strokeWidth: 2),
        ),
      ));
    }

    if (challenge == null) {
      return _buildShell(isDark, child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.emoji_events_rounded, color: AppColors.neon.withOpacity(0.5), size: 40),
            const SizedBox(height: 16),
            Text(
              'Ready for a challenge?',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF101828),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Penny will create a personalized savings goal for your week.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onGenerate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Generate Challenge', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ));
    }

    final c = challenge!;
    return _buildShell(isDark, child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                c.isCompleted ? Icons.check_circle_rounded : Icons.emoji_events_rounded,
                color: c.isCompleted ? AppColors.neon : const Color(0xFFFDB022),
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  c.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF101828),
                  ),
                ),
              ),
              if (c.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neon.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('DONE', style: TextStyle(color: AppColors.neon, fontSize: 10, fontWeight: FontWeight.w900)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  c.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? const Color(0xFF98A2B3) : const Color(0xFF475467),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (c.isAccepted || c.isCompleted)
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ChallengeAnalyticsPage()),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Details', style: TextStyle(color: AppColors.neon, fontWeight: FontWeight.bold, fontSize: 13)),
                      Icon(Icons.chevron_right_rounded, color: AppColors.neon, size: 16),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (!c.isAccepted && !c.isCompleted)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neon,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Accept Challenge', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: onGenerate,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Icon(Icons.refresh_rounded, size: 20),
                ),
              ],
            )
          else if (c.isAccepted && !c.isCompleted)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onComplete,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.neon, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Mark as Complete ✓', style: TextStyle(color: AppColors.neon, fontWeight: FontWeight.w800)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onGenerate,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Get New Challenge', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    ));
  }

  Widget _buildShell(bool isDark, {required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: child,
    );
  }
}
