import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'subscription_event.dart';
import 'subscription_state.dart';
import '../../../domain/repositories/subscription_repository.dart';
import '../../../domain/usecases/transaction/add_transaction.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/entities/subscription.dart';
import '../../../core/services/notification_service.dart';

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository repository;
  final AddTransactionUseCase addTransaction;
  final NotificationService notificationService;

  SubscriptionBloc({
    required this.repository,
    required this.addTransaction,
    required this.notificationService,
  }) : super(SubscriptionState.initial()) {
    on<LoadSubscriptionsRequested>(_onLoadSubscriptions);
    on<AddSubscriptionRequested>(_onAddSubscription);
    on<DeleteSubscriptionRequested>(_onDeleteSubscription);
    on<MarkSubscriptionPaidRequested>(_onMarkSubscriptionPaid);
  }

  Future<void> _onLoadSubscriptions(
      LoadSubscriptionsRequested event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final items = await repository.getSubscriptions();
      
      // Sort by soonest due date
      items.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      
      emit(state.copyWith(isLoading: false, subscriptions: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onAddSubscription(
      AddSubscriptionRequested event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null, actionSuccess: false));
    try {
      await repository.addSubscription(event.subscription);
      
      // Schedule local notification 2 days before
      await notificationService.scheduleBillReminder(
        id: event.subscription.id.hashCode,
        title: 'Upcoming Bill: ${event.subscription.name}',
        body: 'Your \$${event.subscription.amount.toStringAsFixed(2)} bill is due soon.',
        scheduledDate: event.subscription.nextDueDate,
      );

      final items = await repository.getSubscriptions();
      items.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      
      emit(state.copyWith(
          isLoading: false, subscriptions: items, actionSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteSubscription(
      DeleteSubscriptionRequested event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      await repository.deleteSubscription(event.id);
      
      // Cancel reminder
      await notificationService.cancelReminder(event.id.hashCode);

      final items = await repository.getSubscriptions();
      items.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      
      emit(state.copyWith(isLoading: false, subscriptions: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onMarkSubscriptionPaid(
      MarkSubscriptionPaidRequested event, Emitter<SubscriptionState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final sub = event.subscription;

      // 1. Add Transaction automatically
      final tx = TransactionEntity.manualExpense(
        id: const Uuid().v4(),
        merchant: '${sub.name} (Subscription)',
        amount: sub.amount,
        category: sub.category,
        dateTime: DateTime.now(),
        paymentMethod: 'Auto-Pay',
      );
      await addTransaction(tx);

      // 2. Calculate next due date
      DateTime nextDue;
      if (sub.cycle == BillingCycle.monthly) {
        nextDue = DateTime(sub.nextDueDate.year, sub.nextDueDate.month + 1, sub.nextDueDate.day);
      } else if (sub.cycle == BillingCycle.yearly) {
        nextDue = DateTime(sub.nextDueDate.year + 1, sub.nextDueDate.month, sub.nextDueDate.day);
      } else {
        // weekly
        nextDue = sub.nextDueDate.add(const Duration(days: 7));
      }

      // 3. Update subscription
      final updatedSub = sub.copyWith(nextDueDate: nextDue);
      await repository.updateSubscription(updatedSub);

      // 4. Reschedule Notification
      await notificationService.cancelReminder(sub.id.hashCode);
      await notificationService.scheduleBillReminder(
        id: updatedSub.id.hashCode,
        title: 'Upcoming Bill: ${updatedSub.name}',
        body: 'Your \$${updatedSub.amount.toStringAsFixed(2)} bill is due soon.',
        scheduledDate: updatedSub.nextDueDate,
      );

      final items = await repository.getSubscriptions();
      items.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
      
      emit(state.copyWith(isLoading: false, subscriptions: items));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
