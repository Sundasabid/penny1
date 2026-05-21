import 'package:equatable/equatable.dart';
import '../../../../domain/entities/vault.dart';

class VaultState extends Equatable {
  final bool isLoading;
  final List<VaultEntity> vaults;
  final String? errorMessage;
  final double totalSavedInVaults;

  const VaultState({
    required this.isLoading,
    required this.vaults,
    this.errorMessage,
    required this.totalSavedInVaults,
  });

  factory VaultState.initial() => const VaultState(
        isLoading: false,
        vaults: [],
        totalSavedInVaults: 0.0,
      );

  VaultState copyWith({
    bool? isLoading,
    List<VaultEntity>? vaults,
    String? errorMessage,
    double? totalSavedInVaults,
  }) {
    return VaultState(
      isLoading: isLoading ?? this.isLoading,
      vaults: vaults ?? this.vaults,
      errorMessage: errorMessage,
      totalSavedInVaults: totalSavedInVaults ?? this.totalSavedInVaults,
    );
  }

  @override
  List<Object?> get props => [isLoading, vaults, errorMessage, totalSavedInVaults];
}
