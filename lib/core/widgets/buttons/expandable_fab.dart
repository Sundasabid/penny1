import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../config/themes/app_colors.dart';

class AddTransactionFab extends StatefulWidget {
  const AddTransactionFab({
    super.key,
    required this.onManualEntry,
    required this.onScanReceipt,
  });

  final VoidCallback onManualEntry;
  final VoidCallback onScanReceipt;

  @override
  State<AddTransactionFab> createState() => _AddTransactionFabState();
}

class _AddTransactionFabState extends State<AddTransactionFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _isOpen ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // RESOLVE BUTTONS NOT WORKING: Increase hit-test area to encompass expansion
    return SizedBox(
      width: 250,
      height: 200,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // SCAN RECEIPT BUTTON (VERTICAL)
          _ExpandingButton(
            directionInDegrees: 270,
            maxDistance: 130,
            progress: _expandAnimation,
            child: _ActionCircle(
              icon: Icons.receipt_long_rounded,
              label: 'Scan receipt',
              onTap: () {
                _toggle();
                widget.onScanReceipt();
              },
            ),
          ),
          // MANUAL ENTRY BUTTON (VERTICAL)
          _ExpandingButton(
            directionInDegrees: 270,
            maxDistance: 72,
            progress: _expandAnimation,
            child: _ActionCircle(
              icon: Icons.edit_note_rounded,
              label: 'Manual entry',
              onTap: () {
                _toggle();
                widget.onManualEntry();
              },
            ),
          ),
          // MAIN FAB - Anchored at the bottom
          Positioned(
            bottom: 0,
            child: _MainFab(
              isOpen: _isOpen,
              onPressed: _toggle,
              progress: _expandAnimation,
            ),
          ),
        ],
      ),
    );
  }
}

class _MainFab extends StatefulWidget {
  const _MainFab({
    required this.isOpen,
    required this.onPressed,
    required this.progress,
  });

  final bool isOpen;
  final VoidCallback onPressed;
  final Animation<double> progress;

  @override
  State<_MainFab> createState() => _MainFabState();
}

class _MainFabState extends State<_MainFab> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // REPAINT BOUNDARY: Optimize glow performance
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neon.withOpacity(0.3 + (_glowController.value * 0.2)),
                  blurRadius: 15 + (_glowController.value * 15),
                  spreadRadius: 2 + (_glowController.value * 2),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: widget.progress,
              builder: (context, child) {
                return Transform.rotate(
                  angle: widget.progress.value * (math.pi / 4),
                  child: FloatingActionButton(
                    heroTag: 'main_add_transaction_fab',
                    backgroundColor: AppColors.neon,
                    elevation: 0,
                    highlightElevation: 0,
                    onPressed: widget.onPressed,
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ExpandingButton extends StatelessWidget {
  const _ExpandingButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // CORRECT POSITIONED PLACEMENT: Must be a direct child of Stack
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          bottom: -offset.dy, // FIXED: Now expands UPWARD instead of downward
          left: -120, // Wider for symmetrical centering
          right: -120, // Wider for symmetrical centering
          child: Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: progress.value.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.8 + (0.2 * progress.value), // Micro-scale in
                child: child!,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _ActionCircle extends StatelessWidget {
  const _ActionCircle({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (isDark ? Colors.black : Colors.white).withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C252E) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.neon.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.neon, size: 22),
          ),
        ],
      ),
    );
  }
}




