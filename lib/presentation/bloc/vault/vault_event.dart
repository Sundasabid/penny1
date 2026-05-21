import 'package:equatable/equatable.dart';
import '../../../../domain/entities/vault.dart';

abstract class VaultEvent extends Equatable {
  const VaultEvent();

  @override
  List<Object> get props => [];
}

class LoadVaultsRequested extends VaultEvent {}

class AddVaultRequested extends VaultEvent {
  final VaultEntity vault;
  const AddVaultRequested(this.vault);

  @override
  List<Object> get props => [vault];
}

class UpdateVaultRequested extends VaultEvent {
  final VaultEntity vault;
  const UpdateVaultRequested(this.vault);

  @override
  List<Object> get props => [vault];
}

class DeleteVaultRequested extends VaultEvent {
  final String id;
  const DeleteVaultRequested(this.id);

  @override
  List<Object> get props => [id];
}
