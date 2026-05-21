import '../entities/subscription.dart';

abstract class SubscriptionRepository {
  Future<void> addSubscription(SubscriptionEntity subscription);
  Future<void> updateSubscription(SubscriptionEntity subscription);
  Future<void> deleteSubscription(String id);
  Future<List<SubscriptionEntity>> getSubscriptions();
}
