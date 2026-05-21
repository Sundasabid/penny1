import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/vault.dart';
import '../../../../core/utils/currency_helper.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/vault/vault_bloc.dart';
import '../../bloc/vault/vault_event.dart';
import '../../bloc/vault/vault_state.dart';
import 'create_vault_page.dart';
import 'fund_vault_modal.dart';
import 'liquid_jar_painter.dart';

class VaultsOverviewPage extends StatefulWidget {
  const VaultsOverviewPage({super.key});

  @override
  State<VaultsOverviewPage> createState() => _VaultsOverviewPageState();
}

class _VaultsOverviewPageState extends State<VaultsOverviewPage> with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    final symbol = CurrencyHelper.getSymbol(user.currency);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('THE VAULT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
          ),
        ),
        child: BlocBuilder<VaultBloc, VaultState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null) {
              return Center(child: Text('Error: ${state.errorMessage}', style: const TextStyle(color: Colors.red)));
            }

            final vaults = state.vaults;

            if (vaults.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_person_rounded, size: 100, color: Colors.grey.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    const Text('YOUR VAULT IS EMPTY', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    Text('Secure your future, bucket by bucket.', style: TextStyle(color: Colors.grey.withOpacity(0.6), fontSize: 13)),
                  ],
                ),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: vaults.length,
              itemBuilder: (context, index) {
                return _buildVaultJar(vaults[index], symbol, context);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateVaultPage()));
        },
        backgroundColor: (isDark ? Colors.white : Colors.black),
        elevation: 10,
        icon: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
        label: Text('NEW VAULT', style: TextStyle(color: isDark ? Colors.black : Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }

  Widget _buildVaultJar(VaultEntity vault, String symbol, BuildContext context) {
    final progress = (vault.savedAmount / vault.targetAmount).clamp(0.0, 1.0);
    final isFull = vault.savedAmount >= vault.targetAmount;
    final color = _colorFromHex(vault.colorHex);

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withOpacity(0.7),
          builder: (_) => FundVaultModal(vault: vault, symbol: symbol),
        ).then((_) {
            if (context.mounted) {
              context.read<VaultBloc>().add(LoadVaultsRequested());
            }
        }); 
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isFull ? color : color.withOpacity(0.3), 
            width: isFull ? 2 : 1.5
          ),
          boxShadow: [
            BoxShadow(
              color: isFull ? color.withOpacity(0.4) : color.withOpacity(0.1),
              blurRadius: isFull ? 30 : 15,
              spreadRadius: isFull ? 2 : 0,
              offset: const Offset(0, 10),
            )
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Liquid fill background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: LiquidJarPainter(
                      progress: progress,
                      color: color,
                      waveAnimation: _waveController.value,
                    ),
                  );
                },
              ),
            ),
            
            // Glass reflection overlay
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Icon(Icons.shield_rounded, color: color, size: 24),
                  const Spacer(),
                  Text(
                    vault.name,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isFull ? 'FULLY FUNDED' : 'SAVED: $symbol${vault.savedAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.bold,
                      color: isFull ? color : Colors.grey,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Progress Pillage
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(color: color.withOpacity(0.4), blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                   Text(
                    'GOAL: $symbol${vault.targetAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
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


