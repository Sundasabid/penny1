
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
  final current = monthTotalSpend(month: currentMonth, transactions: transactions);
  final previous = monthTotalSpend(month: prevMonth, transactions: transactions);

  if (previous <= 0) return 0;
  return ((current - previous) / previous) * 100.0;
}
