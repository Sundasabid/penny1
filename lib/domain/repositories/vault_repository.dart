import '../entities/vault.dart';

abstract class VaultRepository {
  Future<List<VaultEntity>> getVaults();
  Future<void> addVault(VaultEntity vault);
  Future<void> updateVault(VaultEntity vault);
  Future<void> deleteVault(String id);
}
