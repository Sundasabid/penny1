import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/planned_purchase.dart';
import '../../../domain/entities/penny_challenge.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../../../domain/repositories/copilot_repository.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../transaction_bloc.dart';
import 'copilot_event.dart';
import 'copilot_state.dart';

class CopilotBloc extends Bloc<CopilotEvent, CopilotState> {
  final TransactionBloc transactionBloc;
  final ChatRepository chatRepository;
  final CopilotRepository copilotRepository;
  final AuthRepository authRepository;
  StreamSubscription? _txSub;

  CopilotBloc({
    required this.transactionBloc,
    required this.chatRepository,
    required this.copilotRepository,
    required this.authRepository,
  }) : super(CopilotInitial()) {
    on<LoadCopilotRequested>(_onLoad);
    on<AddPlannedPurchase>(_onAddPurchase);
    on<RemovePlannedPurchase>(_onRemovePurchase);
    on<AcceptChallenge>(_onAcceptChallenge);
    on<CompleteChallenge>(_onCompleteChallenge);
    on<GenerateNewChallenge>(_onGenerateChallenge);

    // Reactive: re-calculate when transactions change
    _txSub = transactionBloc.stream.listen((txState) {
      if (!txState.isLoading) {
        add(const LoadCopilotRequested());
      }
    });

    add(const LoadCopilotRequested());
  }

  @override
  Future<void> close() {
    _txSub?.cancel();
    return super.close();
  }

  Future<void> _onLoad(LoadCopilotRequested event, Emitter<CopilotState> emit) async {
    final transactions = transactionBloc.state.transactions;

    // Load persisted data
    final purchases = await copilotRepository.getPlannedPurchases();
    final allChallenges = await copilotRepository.getChallenges();
    final activeChallenge = _detectActiveChallenge(allChallenges);

    final score = _calculateHealthScore(transactions);
    final subs = _detectSubscriptions(transactions);
    final totalFixed = subs.fold(0.0, (sum, s) => sum + s.avgAmount);
    final dailySpend = _getDailySpendThisMonth(transactions);
    final projected = _getProjectedMonthEnd(transactions);

    emit(CopilotLoaded(
      healthScore: score,
      purchases: purchases,
      challenges: allChallenges,
      activeChallenge: activeChallenge,
      isChallengeLoading: false,
      subscriptions: subs,
      totalFixedCosts: totalFixed,
      actualDailySpend: dailySpend,
      projectedMonthEnd: projected,
    ));
  }

  PennyChallenge? _detectActiveChallenge(List<PennyChallenge> challenges) {
    if (challenges.isEmpty) return null;
    // Active is the latest one that is NOT completed and was started within the last 7 days
    final now = DateTime.now();
    final latest = challenges.first; // sorted by weekStart desc
    if (!latest.isCompleted && now.difference(latest.weekStart).inDays < 7) {
      return latest;
    }
    return null;
  }

  Future<void> _onAddPurchase(AddPlannedPurchase event, Emitter<CopilotState> emit) async {
    if (state is! CopilotLoaded) return;
    final s = state as CopilotLoaded;

    final newPurchase = PlannedPurchase(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: event.name,
      amount: event.amount,
      targetDate: event.targetDate,
      createdAt: DateTime.now(),
      isAiLoading: true,
    );

    emit(s.copyWith(purchases: [...s.purchases, newPurchase]));

    // Build financial context for AI
    final transactions = transactionBloc.state.transactions;
    final expenses = transactions.where((t) => !t.isIncome).toList();
    final income = transactions.where((t) => t.isIncome).toList();
    final totalIn = income.fold(0.0, (sum, t) => sum + t.amount);
    final totalOut = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIn - totalOut;

    // Category breakdown
    final catSpend = <String, double>{};
    for (final tx in expenses) {
      catSpend[tx.category] = (catSpend[tx.category] ?? 0) + tx.amount;
    }
    final catSummary = catSpend.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCats = catSummary.take(6).map((e) => '${e.key}: ${e.value.round()} PKR').join(', ');

    final daysUntil = event.targetDate.difference(DateTime.now()).inDays;

    // Save initial purchase to Firestore
    await copilotRepository.savePlannedPurchase(newPurchase);

    try {
      final advice = await chatRepository.getPurchasePlan(
        purchaseName: event.name,
        amount: event.amount,
        targetDate: event.targetDate,
        financialSummary: 'Balance: ${balance.round()} PKR. '
            'Monthly categories: $topCats. '
            'Days until target: $daysUntil.',
      );

      if (state is CopilotLoaded) {
        final current = state as CopilotLoaded;
        final updatedPurchase = newPurchase.copyWith(aiAdvice: advice, isAiLoading: false);
        
        // Update purchase in Firestore with AI advice
        await copilotRepository.savePlannedPurchase(updatedPurchase);

        final updatedList = current.purchases.map((p) => p.id == newPurchase.id ? updatedPurchase : p).toList();
        emit(current.copyWith(purchases: updatedList));
      }
    } catch (e) {
      debugPrint('❌ Co-Pilot: Failed to get purchase plan: $e');
      if (state is CopilotLoaded) {
        final current = state as CopilotLoaded;
        final failedPurchase = newPurchase.copyWith(
          aiAdvice: 'Penny couldn\'t generate a plan right now.',
          isAiLoading: false,
        );
        
        await copilotRepository.savePlannedPurchase(failedPurchase);

        final updatedList = current.purchases.map((p) => p.id == newPurchase.id ? failedPurchase : p).toList();
        emit(current.copyWith(purchases: updatedList));
      }
    }
  }

  Future<void> _onRemovePurchase(RemovePlannedPurchase event, Emitter<CopilotState> emit) async {
    if (state is! CopilotLoaded) return;
    final s = state as CopilotLoaded;
    
    await copilotRepository.deletePlannedPurchase(event.purchaseId);
    
    emit(s.copyWith(
      purchases: s.purchases.where((p) => p.id != event.purchaseId).toList(),
    ));
  }

  Future<void> _onAcceptChallenge(AcceptChallenge event, Emitter<CopilotState> emit) async {
    if (state is! CopilotLoaded) return;
    final s = state as CopilotLoaded;
    if (s.activeChallenge == null) return;
    
    final updatedChallenge = s.activeChallenge!.copyWith(isAccepted: true);
    await copilotRepository.saveChallenge(updatedChallenge);
    
    // Reward: +10 Onyx for accepting
    try {
      await authRepository.updateOnyxPoints(10);
      debugPrint('💰 Onyx: +10 awarded for acceptance');
    } catch (e) {
      debugPrint('⚠️ Onyx reward failed: $e');
    }

    final updatedList = s.challenges.map((c) => c.id == updatedChallenge.id ? updatedChallenge : c).toList();
    emit(s.copyWith(activeChallenge: updatedChallenge, challenges: updatedList));
  }

  Future<void> _onCompleteChallenge(CompleteChallenge event, Emitter<CopilotState> emit) async {

    if (state is! CopilotLoaded) return;
    final s = state as CopilotLoaded;
    if (s.activeChallenge == null) return;
    
    final updatedChallenge = s.activeChallenge!.copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
    await copilotRepository.saveChallenge(updatedChallenge);
    
    // Reward: +100 Onyx for completion
    try {
      await authRepository.updateOnyxPoints(100);
      debugPrint('💰 Onyx: +100 awarded for completion');
    } catch (e) {
      debugPrint('⚠️ Onyx reward failed: $e');
    }

    final updatedList = s.challenges.map((c) => c.id == updatedChallenge.id ? updatedChallenge : c).toList();
    emit(s.copyWith(activeChallenge: updatedChallenge, challenges: updatedList));
  }


  Future<void> _onGenerateChallenge(GenerateNewChallenge event, Emitter<CopilotState> emit) async {
    if (state is! CopilotLoaded) return;
    final s = state as CopilotLoaded;

    // IF refreshing and current isn't accepted, delete it to keep history clean
    if (s.activeChallenge != null && !s.activeChallenge!.isAccepted) {
      await copilotRepository.deleteChallenge(s.activeChallenge!.id);
    }

    emit(s.copyWith(isChallengeLoading: true, clearChallenge: true));

    try {
      final transactions = transactionBloc.state.transactions;
      final expenses = transactions.where((t) => !t.isIncome).toList();
      final catSpend = <String, double>{};
      for (final tx in expenses) {
        catSpend[tx.category] = (catSpend[tx.category] ?? 0) + tx.amount;
      }
      final summary = catSpend.entries.take(5).map((e) => '${e.key}: ${e.value.round()} PKR').join(', ');

      final challengeText = await chatRepository.generateWeeklyChallenge(
        spendingSummary: summary,
      );

      // Parse the AI response — expect "Title | Description" format
      final parts = challengeText.split('|');
      final title = parts[0].trim();
      final desc = parts.length > 1 ? parts[1].trim() : 'Complete this challenge to boost your Health Score!';

      final challenge = PennyChallenge(
        id: DateTime.now().microsecondsSinceEpoch.toString(), // Use micro for uniqueness
        title: title,
        description: desc,
        weekStart: DateTime.now(),
      );

      await copilotRepository.saveChallenge(challenge);

      if (state is CopilotLoaded) {
        final current = state as CopilotLoaded;
        // Also remove the deleted challenge from the local list if it was there
        final filteredChallenges = current.challenges.where((c) => c.id != (s.activeChallenge?.id ?? '')).toList();
        
        emit(current.copyWith(
          activeChallenge: challenge,
          challenges: [challenge, ...filteredChallenges],
          isChallengeLoading: false,
        ));
      }
    } catch (e) {
      debugPrint('❌ Co-Pilot: Failed to generate challenge: $e');
      
      final fallbacks = [
        PennyChallenge(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'The 500 PKR Rule',
          description: 'Wait 24 hours before any non-essential purchase over 500 PKR this week.',
          weekStart: DateTime.now(),
        ),
        PennyChallenge(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Subscription Review',
          description: 'Find and cancel one recurring service you no longer truly need.',
          weekStart: DateTime.now(),
        ),
        PennyChallenge(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Meatless Monday',
          description: 'Try cooking a vegetarian meal this Monday to save on grocery costs.',
          weekStart: DateTime.now(),
        ),
      ];
      
      final fallback = fallbacks[DateTime.now().second % fallbacks.length];
      
      await copilotRepository.saveChallenge(fallback);

      if (state is CopilotLoaded) {
        final current = state as CopilotLoaded;
        emit(current.copyWith(
          activeChallenge: fallback,
          challenges: [fallback, ...current.challenges],
          isChallengeLoading: false,
        ));
      }
    }

  }



  // ---------------------------------------------------------------------------
  // CALCULATIONS
  // ---------------------------------------------------------------------------

  int _calculateHealthScore(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return 50;

    final expenses = transactions.where((t) => !t.isIncome).toList();
    final income = transactions.where((t) => t.isIncome).toList();
    final totalIn = income.fold(0.0, (sum, t) => sum + t.amount);
    final totalOut = expenses.fold(0.0, (sum, t) => sum + t.amount);

    // 1. Savings Rate (40% weight)
    double savingsScore = 0;
    if (totalIn > 0) {
      final rate = ((totalIn - totalOut) / totalIn).clamp(0.0, 1.0);
      savingsScore = rate * 100;
    }

    // 2. Spending Consistency (30% weight) — low variance = good
    double consistencyScore = 50;
    if (expenses.length > 5) {
      final amounts = expenses.map((e) => e.amount).toList();
      final avg = amounts.reduce((a, b) => a + b) / amounts.length;
      final variance = amounts.map((a) => (a - avg) * (a - avg)).reduce((a, b) => a + b) / amounts.length;
      final stdDev = variance > 0 ? (variance * 0.5) : 0.0; // approximate
      consistencyScore = (100 - (stdDev / avg * 100)).clamp(0.0, 100.0);
    }

    // 3. Activity Score (30% weight) — are they logging regularly?
    double activityScore = 0;
    final now = DateTime.now();
    final last30 = transactions.where((t) =>
    t.dateTime.isAfter(now.subtract(const Duration(days: 30)))).length;
    activityScore = (last30 / 30 * 100).clamp(0.0, 100.0);

    final score = (savingsScore * 0.4 + consistencyScore * 0.3 + activityScore * 0.3).round();
    return score.clamp(0, 100);
  }

  List<DetectedSubscription> _detectSubscriptions(List<TransactionEntity> transactions) {
    final expenses = transactions.where((t) => !t.isIncome).toList();
    final merchantCount = <String, List<double>>{};

    for (final tx in expenses) {
      final key = tx.merchant.toLowerCase().trim();
      if (key.isEmpty || key == 'unknown') continue;
      merchantCount.putIfAbsent(key, () => []).add(tx.amount);
    }

    final subs = <DetectedSubscription>[];
    for (final entry in merchantCount.entries) {
      if (entry.value.length >= 3) { // At least 3 transactions = recurring
        final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
        subs.add(DetectedSubscription(
          merchant: entry.key[0].toUpperCase() + entry.key.substring(1),
          avgAmount: avg,
          occurrences: entry.value.length,
        ));
      }
    }
    subs.sort((a, b) => b.avgAmount.compareTo(a.avgAmount));
    return subs.take(10).toList();
  }

  List<double> _getDailySpendThisMonth(List<TransactionEntity> transactions) {
    final now = DateTime.now();
    final daysElapsed = now.day;
    final dailySpend = List<double>.filled(daysElapsed, 0);

    for (final tx in transactions) {
      if (tx.isIncome) continue;
      if (tx.dateTime.month == now.month && tx.dateTime.year == now.year) {
        final dayIndex = tx.dateTime.day - 1;
        if (dayIndex >= 0 && dayIndex < daysElapsed) {
          dailySpend[dayIndex] += tx.amount;
        }
      }
    }
    return dailySpend;
  }

  double _getProjectedMonthEnd(List<TransactionEntity> transactions) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final expenses = transactions.where((t) =>
    !t.isIncome &&
        t.dateTime.month == now.month &&
        t.dateTime.year == now.year
    ).toList();

    if (expenses.isEmpty || now.day < 3) return 0;

    final totalSoFar = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final dailyAvg = totalSoFar / now.day;
    return dailyAvg * daysInMonth;
  }
}
