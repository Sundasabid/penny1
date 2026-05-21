import '../../domain/entities/transaction.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _isInMonth(DateTime dt, DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  final next = DateTime(month.year, month.month + 1, 1);
  return !dt.isBefore(first) && dt.isBefore(next);
}

double monthTotalSpend({
  required DateTime month,
  required List<TransactionEntity> transactions,
}) {
  double total = 0;
  for (final tx in transactions) {
    if (tx.isIncome) continue;
    if (!_isInMonth(tx.dateTime, month)) continue;
    total += tx.amount;
  }
  return total;
}

double allTimeTotalSpend({
  required List<TransactionEntity> transactions,
}) {
  double total = 0;
  for (final tx in transactions) {
    if (tx.isIncome) continue;
    total += tx.amount;
  }
  return total;
}

double monthTotalIncome({
  required DateTime month,
  required List<TransactionEntity> transactions,
}) {
  double total = 0;
  for (final tx in transactions) {
    if (!tx.isIncome) continue;
    if (!_isInMonth(tx.dateTime, month)) continue;
    total += tx.amount;
  }
  return total;
}

double allTimeTotalIncome({
  required List<TransactionEntity> transactions,
}) {
  double total = 0;
  for (final tx in transactions) {
    if (!tx.isIncome) continue;
    total += tx.amount;
  }
  return total;
}

Map<DateTime, double> dailySpendForMonth({
  required DateTime month,
  required List<TransactionEntity> transactions,
}) {
  final Map<DateTime, double> out = {};
  for (final tx in transactions) {
    if (tx.isIncome) continue;
    if (!_isInMonth(tx.dateTime, month)) continue;

    final key = _dateOnly(tx.dateTime);
    out[key] = (out[key] ?? 0) + tx.amount;
  }
  return out;
}

double percentChangeMonthToMonthSpend({
  required DateTime currentMonth,
  required List<TransactionEntity> transactions,
}) {
  final prevMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
  final current = monthTotalSpend(
    month: currentMonth,
    transactions: transactions,
  );
  final previous = monthTotalSpend(
    month: prevMonth,
    transactions: transactions,
  );

  if (previous <= 0) return 0;
  return ((current - previous) / previous) * 100.0;
}

double percentChangeMonthToMonthIncome({
  required DateTime currentMonth,
  required List<TransactionEntity> transactions,
}) {
  final prevMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
  final current = monthTotalIncome(
    month: currentMonth,
    transactions: transactions,
  );
  final previous = monthTotalIncome(
    month: prevMonth,
    transactions: transactions,
  );

  if (previous <= 0) return 0;
  return ((current - previous) / previous) * 100.0;
}

double getSavingsRate({
  required double income,
  required double expense,
}) {
  if (income <= 0) return 0;
  final rate = ((income - expense) / income) * 100;
  return rate.clamp(-100.0, 100.0);
}

Map<String, double> getTopSpendingCategories({
  required List<TransactionEntity> transactions,
  int limit = 5,
}) {
  final Map<String, double> categories = {};
  for (final tx in transactions) {
    if (tx.isIncome) continue;
    categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
  }

  final sortedEntries = categories.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  final Map<String, double> result = {};
  for (var i = 0; i < sortedEntries.length && i < limit; i++) {
    result[sortedEntries[i].key] = sortedEntries[i].value;
  }
  return result;
}

/// Returns daily net cash flow for the last [days] days
Map<DateTime, double> getDailyNetCashFlow({
  required List<TransactionEntity> transactions,
  int days = 7,
}) {
  final Map<DateTime, double> flow = {};
  final now = _dateOnly(DateTime.now());
  
  // Initialize map with dates for the last X days
  for (int i = 0; i < days; i++) {
    flow[now.subtract(Duration(days: i))] = 0;
  }

  for (final tx in transactions) {
    final txDate = _dateOnly(tx.dateTime);
    if (flow.containsKey(txDate)) {
      if (tx.isIncome) {
        flow[txDate] = (flow[txDate] ?? 0) + tx.amount;
      } else {
        flow[txDate] = (flow[txDate] ?? 0) - tx.amount;
      }
    }
  }
  return flow;
}
