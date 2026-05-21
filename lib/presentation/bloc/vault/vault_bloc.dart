import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/vault_repository.dart';
import 'vault_event.dart';
import 'vault_state.dart';

class VaultBloc extends Bloc<VaultEvent, VaultState> {
  final VaultRepository repository;

  VaultBloc({required this.repository}) : super(VaultState.initial()) {
    on<LoadVaultsRequested>(_onLoadVaultsRequested);
    on<AddVaultRequested>(_onAddVaultRequested);
    on<UpdateVaultRequested>(_onUpdateVaultRequested);
    on<DeleteVaultRequested>(_onDeleteVaultRequested);
  }

  Future<void> _onLoadVaultsRequested(
    LoadVaultsRequested event,
    Emitter<VaultState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final vaults = await repository.getVaults();
      
      double total = 0;
      for (var v in vaults) {
        total += v.savedAmount;
      }
      
      emit(state.copyWith(
        isLoading: false,
        vaults: vaults,
        totalSavedInVaults: total,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddVaultRequested(
    AddVaultRequested event,
    Emitter<VaultState> emit,
  ) async {
    try {
      await repository.addVault(event.vault);
      add(LoadVaultsRequested()); // Reload to sync
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onUpdateVaultRequested(
    UpdateVaultRequested event,
    Emitter<VaultState> emit,
  ) async {
    try {
      await repository.updateVault(event.vault);
      add(LoadVaultsRequested()); // Reload to sync
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteVaultRequested(
    DeleteVaultRequested event,
    Emitter<VaultState> emit,
  ) async {
    try {
      await repository.deleteVault(event.id);
      add(LoadVaultsRequested()); // Reload to sync
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
