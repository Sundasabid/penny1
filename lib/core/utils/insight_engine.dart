import '../../domain/entities/transaction.dart';
import '../../domain/entities/insight.dart';
import 'dashboard_aggregations.dart';

class InsightEngine {
  final List<TransactionEntity> transactions;
  final DateTime currentMonth;

  InsightEngine({
    required this.transactions,
    required this.currentMonth,
  });

  List<InsightEntity> generateInsights() {
    if (transactions.isEmpty) return [];

    final List<InsightEntity> insights = [];
    
    // 0. WELCOME / SYSTEM CHECK
    insights.add(InsightEntity(
      id: 'system_ready',
      title: 'Penny is Analysis Ready',
      description: 'I\'ve analyzed your ${transactions.length} historical transactions to find patterns for you.',
      type: InsightType.tip,
      impact: InsightImpact.neutral,
      priority: InsightPriority.low,
      createdAt: DateTime.now(),
    ));

    // 1. SUMMARY
    insights.addAll(_calculateSummaryInsight());

    // 1.5 PROJECTIONS (New)
    final projection = _calculateProjections();
    if (projection != null) insights.add(projection);

    // Determine the month to analyze
    final analysisMonth = _getEffectiveAnalysisMonth();

    // 2. Velocity Insight
    final velocityInsight = _calculateVelocity();
    if (velocityInsight != null) insights.add(velocityInsight);

    // 3. Anomaly Insights
    insights.addAll(_detectAnomalies(analysisMonth));

    // 4. Trend Insights
    insights.addAll(_calculateTrends(analysisMonth));

    // 5. GLOBAL / ALL-TIME Insights
    insights.addAll(_calculateGlobalInsights());

    // 6. RUNWAY & MILESTONES (New)
    final runway = _calculateRunway();
    if (runway != null) insights.add(runway);
    
    insights.addAll(_checkMilestones());
    insights.addAll(_detectLargeExpenses(analysisMonth));

    return insights;
  }

  InsightEntity? _calculateProjections() {
    final now = DateTime.now();
    final spendThisMonth = monthTotalSpend(month: currentMonth, transactions: transactions);
    if (spendThisMonth <= 0 || now.month != currentMonth.month) return null;

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final elapsedDays = now.day;
    
    if (elapsedDays < 5) return null; // Wait for at least 5 days for data sanity

    final dailyAvg = spendThisMonth / elapsedDays;
    final projectedTotal = dailyAvg * daysInMonth;
    final avgMonthlySpend = _getAverageMonthlySpend(lastMonths: 3);

    if (avgMonthlySpend > 0) {
      final diff = projectedTotal - avgMonthlySpend;
      if (diff > 1000) {
        return InsightEntity(
          id: 'projection_high',
          title: 'Month-End Projection',
          description: 'At your current pace, you\'ll spend ${projectedTotal.round()} PKR by month-end, which is ${diff.round()} PKR above your average.',
          type: InsightType.projection,
          impact: InsightImpact.warning,
          priority: InsightPriority.medium,
          createdAt: DateTime.now(),
          metadata: {'projected': projectedTotal, 'diff': diff},
        );
      }
    }
    return null;
  }

  List<InsightEntity> _calculateSummaryInsight() {
    final analysisMonth = _getEffectiveAnalysisMonth();
    final monthTxs = transactions.where((t) => 
      t.dateTime.month == analysisMonth.month && 
      t.dateTime.year == analysisMonth.year
    ).toList();

    if (monthTxs.isEmpty) return [];

    final totalOut = monthTxs.where((t) => !t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
    final totalIn = monthTxs.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);

    return [
      InsightEntity(
        id: 'summary_overview',
        title: 'Activity Overview',
        description: 'In ${AnalysisMonthName(analysisMonth)}, you tracked ${totalOut.round()} PKR in expenses and ${totalIn.round()} PKR in income.',
        type: InsightType.tip,
        impact: InsightImpact.positive,
        priority: InsightPriority.low,
        createdAt: DateTime.now(),
        metadata: {'total_out': totalOut, 'total_in': totalIn},
      )
    ];
  }

  DateTime _getEffectiveAnalysisMonth() {
    final now = DateTime.now();
    final hasCurrentData = transactions.any((t) => 
      t.dateTime.month == now.month && t.dateTime.year == now.year);
    
    if (hasCurrentData) return DateTime(now.year, now.month, 1);
    if (transactions.isEmpty) return currentMonth;
    
    final latestTx = transactions.reduce((a, b) => a.dateTime.isAfter(b.dateTime) ? a : b);
    return DateTime(latestTx.dateTime.year, latestTx.dateTime.month, 1);
  }

  InsightEntity? _calculateVelocity() {
    final now = DateTime.now();
    if (currentMonth.month != now.month || currentMonth.year != now.year) return null;

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final elapsedDays = now.day;
    final timeRatio = elapsedDays / daysInMonth;

    final totalSpend = monthTotalSpend(month: currentMonth, transactions: transactions);
    final avgSpend = _getAverageMonthlySpend(lastMonths: 3);
    
    if (avgSpend <= 0 || totalSpend <= 0) return null;
    final spendRatio = totalSpend / avgSpend;

    if (spendRatio > timeRatio + 0.1) {
      return InsightEntity(
        id: 'velocity_${currentMonth.month}',
        title: 'Spending Velocity Alert',
        description: 'You\'ve used ${(spendRatio * 100).toStringAsFixed(0)}% of your typical budget in only ${(timeRatio * 100).toStringAsFixed(0)}% of the month.',
        type: InsightType.velocity,
        impact: InsightImpact.warning,
        priority: InsightPriority.high, // Alerts!
        actionType: InsightActionType.setBudget,
        createdAt: DateTime.now(),
        metadata: {'spend_ratio': spendRatio, 'time_ratio': timeRatio},
      );
    }
    return null;
  }

  List<InsightEntity> _detectAnomalies(DateTime targetMonth) {
    final List<InsightEntity> anomalies = [];
    final monthTxs = transactions.where((t) => 
      !t.isIncome && t.dateTime.month == targetMonth.month && t.dateTime.year == targetMonth.year
    ).toList();

    final Map<String, List<double>> catHistory = {};
    for (final tx in transactions) {
      if (tx.isIncome) continue;
      catHistory.putIfAbsent(tx.category, () => []).add(tx.amount);
    }

    for (final tx in monthTxs) {
      final history = catHistory[tx.category] ?? [];
      if (history.length < 2) continue; 
      final avg = history.reduce((a, b) => a + b) / history.length;
      
      if (tx.amount > (avg * 1.3)) {
        anomalies.add(InsightEntity(
          id: 'anomaly_${tx.id}',
          title: 'Spending Anomaly Detected',
          description: 'Your payment at ${tx.merchant} is significantly higher than your typical ${tx.category} spending.',
          type: InsightType.anomaly,
          impact: InsightImpact.warning,
          priority: InsightPriority.high, // Alerts!
          actionType: InsightActionType.viewHistory,
          category: tx.category,
          createdAt: DateTime.now(),
          metadata: {'amount': tx.amount, 'average': avg, 'merchant': tx.merchant},
        ));
      }
    }
    anomalies.sort((a, b) => (b.metadata['amount'] as double).compareTo(a.metadata['amount'] as double));
    return anomalies.take(3).toList();
  }

  List<InsightEntity> _calculateTrends(DateTime targetMonth) {
    final List<InsightEntity> trends = [];
    final prevMonth = DateTime(targetMonth.year, targetMonth.month - 1, 1);
    
    final currentCatTotals = getTopSpendingCategories(
      transactions: transactions.where((t) => t.dateTime.month == targetMonth.month && !t.isIncome).toList(),
      limit: 10
    );
    final prevCatTotals = getTopSpendingCategories(
      transactions: transactions.where((t) => t.dateTime.month == prevMonth.month && !t.isIncome).toList(),
      limit: 10
    );

    for (final entry in currentCatTotals.entries) {
      final cat = entry.key;
      final currentAmount = entry.value;
      final prevAmount = prevCatTotals[cat] ?? 0;

      if (prevAmount > 0) {
        final growth = ((currentAmount - prevAmount) / prevAmount) * 100;
        if (growth > 15) {
          trends.add(InsightEntity(
            id: 'trend_$cat',
            title: '$cat spend is rising',
            description: 'Your $cat expenses have grown by ${growth.round()}% compared to last month.',
            type: InsightType.trend,
            impact: InsightImpact.neutral,
            priority: InsightPriority.medium,
            actionType: InsightActionType.setBudget,
            category: cat,
            createdAt: DateTime.now(),
            metadata: {'growth': growth, 'amount': currentAmount},
          ));
        }
      }
    }
    return trends;
  }

  List<InsightEntity> _calculateGlobalInsights() {
    final List<InsightEntity> globals = [];
    final expenses = transactions.where((t) => !t.isIncome).toList();
    final income = transactions.where((t) => t.isIncome).toList();

    if (expenses.isNotEmpty && income.isNotEmpty) {
      final totalOut = expenses.fold(0.0, (sum, t) => sum + t.amount);
      final totalIn = income.fold(0.0, (sum, t) => sum + t.amount);
      final savingsRate = totalIn > 0 ? ((totalIn - totalOut) / totalIn * 100).clamp(0.0, 100.0) : 0.0;
      
      globals.add(InsightEntity(
        id: 'global_savings_rate',
        title: 'Lifetime Savings Rate',
        description: 'You\'ve saved ${savingsRate.toStringAsFixed(1)}% of all income tracked in Penny.',
        type: InsightType.tip,
        impact: InsightImpact.positive,
        priority: InsightPriority.low,
        createdAt: DateTime.now(),
        metadata: {'rate': savingsRate},
      ));
    }
    return globals;
  }

  double _getAverageMonthlySpend({int lastMonths = 3}) {
    double total = 0;
    int count = 0;
    final now = DateTime.now();
    for (int i = 1; i <= lastMonths; i++) {
        final targetMonth = DateTime(now.year, now.month - i, 1);
        final spend = monthTotalSpend(month: targetMonth, transactions: transactions);
        if (spend > 0) { total += spend; count++; }
    }
    return count > 0 ? total / count : 0;
  }

  InsightEntity? _calculateRunway() {
    final expenses = transactions.where((t) => !t.isIncome).toList();
    final income = transactions.where((t) => t.isIncome).toList();
    if (expenses.isEmpty || income.isEmpty) return null;

    final totalOut = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final totalIn = income.fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIn - totalOut;

    if (balance <= 0) return null;

    // Calculate daily average spend from last 30 days
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final recentExpenses = expenses.where((t) => t.dateTime.isAfter(thirtyDaysAgo)).toList();
    
    if (recentExpenses.isEmpty) return null;
    
    final recentTotal = recentExpenses.fold(0.0, (sum, t) => sum + t.amount);
    final dailyAvg = recentTotal / 30;

    if (dailyAvg <= 0) return null;

    final daysRemaining = (balance / dailyAvg).floor();
    final runoutDate = now.add(Duration(days: daysRemaining));

    if (daysRemaining < 60) { // Only show if runway is less than 2 months
      return InsightEntity(
        id: 'runway_prediction',
        title: 'Financial Runway Alert',
        description: 'At your current spending rate of ${dailyAvg.round()} PKR/day, your funds will last until ${runoutDate.day} ${AnalysisMonthName(runoutDate)}${now.year != runoutDate.year ? " " + runoutDate.year.toString() : ""}.',
        type: InsightType.projection,
        impact: daysRemaining < 15 ? InsightImpact.warning : InsightImpact.neutral,
        priority: daysRemaining < 15 ? InsightPriority.high : InsightPriority.medium,
        createdAt: DateTime.now(),
        metadata: {'days': daysRemaining, 'date': runoutDate.toIso8601String()},
      );
    }
    return null;
  }

  List<InsightEntity> _checkMilestones() {
    final List<InsightEntity> milestones = [];
    final expenses = transactions.where((t) => !t.isIncome).toList();
    final income = transactions.where((t) => t.isIncome).toList();
    
    final totalOut = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final totalIn = income.fold(0.0, (sum, t) => sum + t.amount);
    final balance = totalIn - totalOut;

    // Savings Milestones (e.g., 5k, 10k, 25k, 50k, 100k)
    final targets = [5000.0, 10000.0, 25000.0, 50000.0, 100000.0];
    for (final target in targets) {
      if (balance >= target && balance < target + 5000) { // Show when just reached
        milestones.add(InsightEntity(
          id: 'milestone_${target.toInt()}',
          title: 'Savings Milestone Reached! 🏆',
          description: 'Congratulations! You\'ve officially saved over ${target.toInt()} PKR. You\'re building a solid financial future.',
          type: InsightType.tip,
          impact: InsightImpact.positive,
          priority: InsightPriority.high,
          createdAt: DateTime.now(),
          metadata: {'target': target},
        ));
      }
    }
    return milestones;
  }

  List<InsightEntity> _detectLargeExpenses(DateTime targetMonth) {
    final List<InsightEntity> large = [];
    final monthTxs = transactions.where((t) => 
      !t.isIncome && t.dateTime.month == targetMonth.month && t.dateTime.year == targetMonth.year
    ).toList();

    final avgMonthlySpend = _getAverageMonthlySpend(lastMonths: 3);
    if (avgMonthlySpend <= 0) return [];

    for (final tx in monthTxs) {
      if (tx.amount > (avgMonthlySpend * 0.25)) { // Single expense > 25% of avg monthly
        large.add(InsightEntity(
          id: 'large_expense_${tx.id}',
          title: 'Significant Single Expense',
          description: 'Your payment of ${tx.amount.round()} PKR at ${tx.merchant} represents a large portion of your typical monthly spending.',
          type: InsightType.anomaly,
          impact: InsightImpact.neutral,
          priority: InsightPriority.medium,
          createdAt: DateTime.now(),
          category: tx.category,
          metadata: {'amount': tx.amount, 'merchant': tx.merchant},
        ));
      }
    }
    return large;
  }

  String AnalysisMonthName(DateTime date) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return m[date.month - 1];
  }
}
