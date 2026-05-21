import 'package:equatable/equatable.dart';
import '../../../domain/entities/subscription.dart';

class SubscriptionState extends Equatable {
  final bool isLoading;
  final List<SubscriptionEntity> subscriptions;
  final String? errorMessage;
  final bool actionSuccess;

  const SubscriptionState({
    required this.isLoading,
    required this.subscriptions,
    this.errorMessage,
    required this.actionSuccess,
  });

  factory SubscriptionState.initial() {
    return const SubscriptionState(
      isLoading: false,
      subscriptions: [],
      errorMessage: null,
      actionSuccess: false,
    );
  }

  SubscriptionState copyWith({
    bool? isLoading,
    List<SubscriptionEntity>? subscriptions,
    String? errorMessage,
    bool? actionSuccess,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      subscriptions: subscriptions ?? this.subscriptions,
      errorMessage: errorMessage,
      actionSuccess: actionSuccess ?? this.actionSuccess,
    );
  }

  @override
  List<Object?> get props => [isLoading, subscriptions, errorMessage, actionSuccess];
}
