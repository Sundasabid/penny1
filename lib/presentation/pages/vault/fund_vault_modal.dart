import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/vault.dart';
import '../../bloc/vault/vault_bloc.dart';
import '../../bloc/vault/vault_event.dart';

class FundVaultModal extends StatefulWidget {
  final VaultEntity vault;
  final String symbol;

  const FundVaultModal({super.key, required this.vault, required this.symbol});

  @override
  State<FundVaultModal> createState() => _FundVaultModalState();
}

class _FundVaultModalState extends State<FundVaultModal> {
  late double _allocateValue;

  @override
  void initState() {
    super.initState();
    _allocateValue = 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _colorFromHex(widget.vault.colorHex);
    // Calculate remaining amount needed
    final remaining = (widget.vault.targetAmount - widget.vault.savedAmount).clamp(0.0, double.infinity);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark 
              ? Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8)
              : Colors.white.withOpacity(0.95),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(
            color: isDark ? color.withOpacity(0.2) : Colors.black.withOpacity(0.05), 
            width: 1.5
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
              blurRadius: 30,
              offset: const Offset(0, -5),
            )
          ],
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, 
              height: 5, 
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.withOpacity(0.3) : Colors.grey.withOpacity(0.2), 
                borderRadius: BorderRadius.circular(2.5)
              )
            ),
            const SizedBox(height: 32),
            
            Text(
              'DEPOSIT TO VAULT', 
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w900, 
                letterSpacing: 2, 
                color: isDark ? color : color.withOpacity(0.8)
              )
            ),
            const SizedBox(height: 8),
            Text(
              widget.vault.name, 
              style: TextStyle(
                fontSize: 28, 
                fontWeight: FontWeight.w900, 
                letterSpacing: -0.5,
                color: isDark ? Colors.white : const Color(0xFF101828),
              )
            ),
            
            const SizedBox(height: 40),
            
            // Slider value
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  widget.symbol, 
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    color: isDark ? color.withOpacity(0.7) : color.withOpacity(0.6)
                  )
                ),
                const SizedBox(width: 4),
                Text(
                  _allocateValue.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 72, 
                    fontWeight: FontWeight.w900, 
                    color: color, 
                    letterSpacing: -2,
                    shadows: [
                      if (!isDark) Shadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                    ]
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Slider with Arrows
            Row(
              children: [
                _buildArrowButton(
                  icon: Icons.remove_circle_outline_rounded,
                  color: color,
                  isEnabled: _allocateValue > 0,
                  onPressed: () => setState(() {
                    double nextValue = (_allocateValue / 10).floorToDouble() * 10;
                    if (nextValue == _allocateValue) nextValue -= 10;
                    _allocateValue = nextValue.clamp(0.0, remaining);
                  }),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: color,
                      inactiveTrackColor: color.withOpacity(isDark ? 0.1 : 0.15),
                      thumbColor: Colors.white,
                      overlayColor: color.withOpacity(0.1),
                      trackHeight: 12,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 16, 
                        elevation: isDark ? 6 : 4,
                        pressedElevation: 10,
                      ),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 30),
                    ),
                    child: Slider(
                      value: _allocateValue,
                      min: 0,
                      max: remaining > 0 ? remaining : 100,
                      divisions: remaining > 10 ? (remaining / 10).round().clamp(1, 100) : 10,
                      onChanged: remaining > 0 ? (val) => setState(() => _allocateValue = val) : null,
                    ),
                  ),
                ),
                _buildArrowButton(
                  icon: Icons.add_circle_outline_rounded,
                  color: color,
                  isEnabled: _allocateValue < remaining,
                  onPressed: () => setState(() {
                    double nextValue = (_allocateValue / 10).ceilToDouble() * 10;
                    if (nextValue == _allocateValue) nextValue += 10;
                    _allocateValue = nextValue.clamp(0.0, remaining);
                  }),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            Text(
              remaining > 0 
                ? 'Remaining needed: ${widget.symbol}${remaining.toStringAsFixed(0)}'
                : 'VAULT FULLY FUNDED 🎉',
              style: TextStyle(
                color: remaining > 0 
                    ? (isDark ? Colors.grey : const Color(0xFF667085))
                    : color, 
                fontSize: 14, 
                fontWeight: FontWeight.w700
              ),
            ),

            const SizedBox(height: 48),

            GestureDetector(
              onTap: () {
                if (_allocateValue <= 0) return;
                
                final updated = widget.vault.copyWith(
                  savedAmount: widget.vault.savedAmount + _allocateValue,
                );
                context.read<VaultBloc>().add(UpdateVaultRequested(updated));
                Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  color: _allocateValue > 0 
                      ? color 
                      : (isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF2F4F7)),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: _allocateValue > 0 ? [
                    BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
                  ] : [],
                ),
                child: Center(
                  child: Text(
                    'TRANSFER FUNDS', 
                    style: TextStyle(
                      color: _allocateValue > 0 
                          ? Colors.white 
                          : (isDark ? Colors.white24 : const Color(0xFF98A2B3)), 
                      fontSize: 16, 
                      fontWeight: FontWeight.w900, 
                      letterSpacing: 1.5
                    )
                  ),
                ),
              ),
            ),
            
             const SizedBox(height: 24),
             
             // Quick Withdraw Button
             if (widget.vault.savedAmount > 0)
               TextButton(
                 onPressed: () {
                   _showWithdrawConfirm(context, color);
                 },
                 style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                 child: const Text(
                   'Empty Vault (Withdraw All)', 
                   style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)
                 ),
               )
          ],
        ),
      ),
    );
  }

  Widget _buildArrowButton({
    required IconData icon,
    required Color color,
    required bool isEnabled,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: isEnabled ? onPressed : null,
      icon: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEnabled ? color.withOpacity(0.1) : Colors.transparent,
        ),
        child: Icon(
          icon, 
          color: isEnabled ? color : Colors.grey.withOpacity(0.3), 
          size: 32
        ),
      ),
    );
  }
  void _showWithdrawConfirm(BuildContext context, Color color) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectanglePlatform.borderRadius32,
        title: const Text('Empty Vault?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('This will transfer all ${widget.symbol}${widget.vault.savedAmount.toStringAsFixed(0)} back to your safe-to-spend balance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () {
              final updated = widget.vault.copyWith(savedAmount: 0.0);
              context.read<VaultBloc>().add(UpdateVaultRequested(updated));
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close modal
            },
            child: const Text('CONFIRM', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }


  Color _colorFromHex(String hex) {
    if (hex.isEmpty) return Colors.blue;
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.blue;
    }
  }
}

class RoundedRectanglePlatform {
    static final borderRadius32 = RoundedRectangleBorder(borderRadius: BorderRadius.circular(32));
}

