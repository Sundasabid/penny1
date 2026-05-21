import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/insight_engine.dart';
import '../../../domain/entities/insight.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/repositories/chat_repository.dart';
import '../transaction_bloc.dart';
import 'insight_event.dart';
import 'insight_state.dart';

class InsightBloc extends Bloc<InsightEvent, InsightState> {
  final TransactionBloc transactionBloc;
  final ChatRepository chatRepository;
  
  StreamSubscription? _transactionSubscription;
  DateTime? _lastAiUpdateDate;
  int _lastTransactionCount = 0;
  Set<String> _dismissedIds = {};
  Set<String> _notifiedIds = {}; // Track which high-priority insights we've already alerted on

  InsightBloc({
    required this.transactionBloc,
    required this.chatRepository,
  }) : super(InsightInitial()) {
    on<GenerateInsightsRequested>(_onGenerateInsights);
    on<DismissInsightRequested>(_onDismissInsight);
    on<ClearPendingAlertRequested>(_onClearPendingAlert);
    on<ClearAllAlertsRequested>(_onClearAllAlerts);

    // Make it Reactive: Listen to TransactionBloc
    _transactionSubscription = transactionBloc.stream.listen((transactionState) {
      if (!transactionState.isLoading) {
         add(GenerateInsightsRequested(month: DateTime.now()));
      }
    });

    // Initial trigger in case it's already loaded
    if (!transactionBloc.state.isLoading) {
      add(GenerateInsightsRequested(month: DateTime.now()));
    }
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
  }

  void _onDismissInsight(DismissInsightRequested event, Emitter<InsightState> emit) {
    if (state is InsightLoaded) {
      _dismissedIds.add(event.insightId);
      final s = state as InsightLoaded;
      emit(s.copyWith(dismissedIds: Set.from(_dismissedIds)));
    }
  }

  void _onClearPendingAlert(ClearPendingAlertRequested event, Emitter<InsightState> emit) {
    if (state is InsightLoaded) {
      emit((state as InsightLoaded).copyWith(clearPendingAlert: true));
    }
  }

  void _onClearAllAlerts(ClearAllAlertsRequested event, Emitter<InsightState> emit) {
    if (state is InsightLoaded) {
      final s = state as InsightLoaded;
      final highPriorityIds = s.insights
          .where((i) => i.priority == InsightPriority.high)
          .map((i) => i.id)
          .toList();
      
      _dismissedIds.addAll(highPriorityIds);
      emit(s.copyWith(dismissedIds: Set.from(_dismissedIds)));
    }
  }

  Future<void> _onGenerateInsights(
    GenerateInsightsRequested event,
    Emitter<InsightState> emit,
  ) async {
    final transactions = transactionBloc.state.transactions;
    final engine = InsightEngine(transactions: transactions, currentMonth: event.month);
    final localInsights = engine.generateInsights();
    
    // SMART ALERT: Only show popup if transaction count increased (user just logged something)
    final justLogged = transactions.length > _lastTransactionCount;
    _lastTransactionCount = transactions.length;

    // Check for NEW high priority alerts to show as popups
    InsightEntity? pendingAlert;
    if (justLogged) {
      for (var insight in localInsights) {
        if (insight.priority == InsightPriority.high && 
            !_notifiedIds.contains(insight.id) &&
            !_dismissedIds.contains(insight.id)) {
          pendingAlert = insight;
          _notifiedIds.add(insight.id);
          break;
        }
      }
    }

    final now = DateTime.now();
    final isNewDay = _lastAiUpdateDate == null || 
        _lastAiUpdateDate!.day != now.day || 
        _lastAiUpdateDate!.month != now.month || 
        _lastAiUpdateDate!.year != now.year;

    // Preserve existing AI items if not a new day
    String? currentCoachNote = state is InsightLoaded ? (state as InsightLoaded).aiCoachNote : null;
    String? currentDailyTip = state is InsightLoaded ? (state as InsightLoaded).dailyTip : null;
    
    final dynNarrative = _generateDynamicNarrative(transactions);

    emit(InsightLoaded(
      insights: localInsights,
      aiCoachNote: currentCoachNote,
      dailyTip: currentDailyTip,
      dynamicNarrative: dynNarrative,
      isAiLoading: isNewDay && localInsights.isNotEmpty,
      pendingAlert: pendingAlert,
      dismissedIds: Set.from(_dismissedIds),
    ));

    // Hybrid Part: Fetch Daily Wisdom & Coach Note
    if (isNewDay && localInsights.isNotEmpty) {
      try {
        _lastAiUpdateDate = now;
        
        // Fetch both AI components
        final results = await Future.wait([
          chatRepository.getDailyFinancialTip(),
          chatRepository.getInsightCoachNote(
            insightSummary: localInsights.take(5).map((i) => i.title).join(", ")
          ),
        ]);

        emit((state as InsightLoaded).copyWith(
          dailyTip: results[0],
          aiCoachNote: results[1],
          isAiLoading: false,
        ));
      } catch (e) {
        if (state is InsightLoaded) {
          emit((state as InsightLoaded).copyWith(
            aiCoachNote: "Penny is analyzing your habits—keep up the great work!",
            dailyTip: "Every small step towards saving is a win for your future.",
            isAiLoading: false,
          ));
        }
      }
    }
  }

  String _generateDynamicNarrative(List<TransactionEntity> transactions) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    if (hour < 12) greeting = "Good morning";
    else if (hour < 17) greeting = "Good afternoon";
    else greeting = "Good evening";

    if (transactions.isEmpty) return "$greeting! Shall we start logging your first expense?";

    final todayTxs = transactions.where((t) => 
        t.dateTime.day == now.day && 
        t.dateTime.month == now.month && 
        t.dateTime.year == now.year && 
        !t.isIncome).toList();

    if (todayTxs.isEmpty) {
        return "$greeting! You haven't spent anything yet today. Keep the streak going!";
    }

    final totalToday = todayTxs.fold(0.0, (sum, t) => sum + t.amount);
    if (totalToday > 5000) {
        return "$greeting! A busy spending day. Penny is here to help you stay on track.";
    }
    
    return "$greeting! You've logged ${todayTxs.length} expenses today. Let's see how your week is looking.";
  }
}
