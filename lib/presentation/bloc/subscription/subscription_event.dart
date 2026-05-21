import 'package:equatable/equatable.dart';
import '../../../domain/entities/subscription.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubscriptionsRequested extends SubscriptionEvent {}

class AddSubscriptionRequested extends SubscriptionEvent {
  final SubscriptionEntity subscription;
  const AddSubscriptionRequested(this.subscription);

  @override
  List<Object?> get props => [subscription];
}

class DeleteSubscriptionRequested extends SubscriptionEvent {
  final String id;
  const DeleteSubscriptionRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkSubscriptionPaidRequested extends SubscriptionEvent {
  final SubscriptionEntity subscription;
  const MarkSubscriptionPaidRequested(this.subscription);

  @override
  List<Object?> get props => [subscription];
}
