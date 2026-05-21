import '../../domain/entities/planned_purchase.dart';
import '../../domain/entities/penny_challenge.dart';

abstract class CopilotRepository {
  Future<List<PlannedPurchase>> getPlannedPurchases();
  Future<void> savePlannedPurchase(PlannedPurchase purchase);
  Future<void> deletePlannedPurchase(String id);
  
  Future<List<PennyChallenge>> getChallenges();
  Future<void> saveChallenge(PennyChallenge challenge);
  Future<void> deleteChallenge(String id);
}

