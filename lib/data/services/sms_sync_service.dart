import 'package:telephony/telephony.dart';
import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'sms_parsing_service.dart';
import '../../domain/usecases/transaction/add_transaction.dart';
import '../../domain/entities/transaction.dart';
import 'package:uuid/uuid.dart';

class SmsSyncService {
  final Telephony telephony = Telephony.instance;
  final SmsParsingService parser;
  final AddTransactionUseCase addTransaction;

  static const String _processedSmsBoxName = 'processed_sms';
  static const int _maxParseAttempts = 3;

  static const String _statusSuccess = 'success';
  static const String _statusNotTransaction = 'not_transaction';
  static const String _statusFailed = 'failed';

  SmsSyncService({
    required this.parser,
    required this.addTransaction,
  });

  /// Reads the dedupe entry for [id] and decides whether to skip processing.
  /// Returns true to skip, false to attempt parsing.
  ///
  /// Backward-compat: legacy entries stored as `true` (pre-retry-tracking) are
  /// treated as final-success and skipped.
  bool _shouldSkip(Box box, String id) {
    if (!box.containsKey(id)) return false;
    final entry = box.get(id);
    if (entry is bool) return entry; // legacy: true → skip
    if (entry is Map) {
      final status = entry['status'];
      final attempts = (entry['attempts'] as num?)?.toInt() ?? 0;
      if (status == _statusSuccess || status == _statusNotTransaction) return true;
      if (status == _statusFailed && attempts >= _maxParseAttempts) return true;
      return false;
    }
    // Unknown shape — fail safe and skip to avoid infinite reprocessing.
    return true;
  }

  /// Returns the prior attempt count for [id], handling legacy `true` entries.
  int _priorAttempts(Box box, String id) {
    final entry = box.get(id);
    if (entry is Map) return (entry['attempts'] as num?)?.toInt() ?? 0;
    return 0;
  }

  /// Syncs all financial SMS from the inbox starting from the 1st of the current month.
  Future<void> syncCurrentMonthSms() async {
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    
    debugPrint("📥 Penny SMS Sync: Starting catch-up from ${firstOfMonth.toIso8601String()}");

    // 1. Fetch SMS from inbox
    debugPrint("📥 Penny SMS Sync: Querying inbox...");
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ID, SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      filter: SmsFilter.where(SmsColumn.DATE).greaterThanOrEqualTo(firstOfMonth.millisecondsSinceEpoch.toString()),
    );

    debugPrint("📥 Penny SMS Sync: Found ${messages.length} total messages since start of month.");

    if (messages.isEmpty) {
      debugPrint("ℹ️ Penny SMS Sync: No messages found in this time range.");
      return;
    }

    // 2. Open de-duplication box
    final box = await Hive.openBox(_processedSmsBoxName);

    int loggedCount = 0;
    int financialCount = 0;

    for (var msg in messages) {
      final id = msg.id.toString();

      if (_shouldSkip(box, id)) {
        debugPrint("⏭️ Penny SMS Sync: Skipping already processed message ID: $id");
        continue;
      }

      final body = msg.body ?? "";
      final lowerBody = body.toLowerCase();

      // Initial heuristic filter
      bool isFinancial = lowerBody.contains("rs.") ||
                         lowerBody.contains("pkr") ||
                         lowerBody.contains("spent") ||
                         lowerBody.contains("debited") ||
                         lowerBody.contains("credited") ||
                         lowerBody.contains("paid") ||
                         lowerBody.contains("transaction");

      if (!isFinancial) {
        debugPrint("🔍 Penny SMS Sync: Ignoring non-financial message from ${msg.address}");
        continue;
      }

      financialCount++;
      debugPrint("💸 Penny SMS Sync: Processing potential transaction from ${msg.address}...");

      // 3. Parse with AI
      final categories = ['Groceries', 'Dining', 'Transport', 'Shopping', 'Utilities', 'Others', 'Salary', 'Freelance', 'Investment', 'Gift'];

      final attempt = _priorAttempts(box, id) + 1;

      try {
        final parsedData = await parser.parseFinancialSms(body, categories);

        if (parsedData != null) {
          debugPrint("✨ Penny SMS Sync: Successfully parsed: ${parsedData['amount']} @ ${parsedData['merchantName']}");
          final transaction = TransactionEntity(
            id: const Uuid().v4(),
            merchant: parsedData['merchantName'] ?? "Unknown Merchant",
            category: parsedData['category'] ?? "Others",
            amount: (parsedData['amount'] as num).toDouble(),
            dateTime: DateTime.fromMillisecondsSinceEpoch(msg.date ?? DateTime.now().millisecondsSinceEpoch),
            paymentMethod: "Bank/SMS",
            isIncome: parsedData['isIncome'] ?? false,
            source: TransactionSource.sms,
          );

          await addTransaction(transaction);
          loggedCount++;
          await box.put(id, {'status': _statusSuccess, 'attempts': attempt});
        } else {
          debugPrint("⚠️ Penny SMS Sync: AI returned no transaction data for this message.");
          await box.put(id, {'status': _statusNotTransaction, 'attempts': attempt});
        }
      } on SmsParsingException catch (e) {
        debugPrint("❌ Penny SMS Sync: AI parsing error (attempt $attempt/$_maxParseAttempts): $e");
        await box.put(id, {'status': _statusFailed, 'attempts': attempt});
        if (attempt >= _maxParseAttempts) {
          debugPrint("🛑 Penny SMS Sync: Giving up on message ID $id after $attempt attempts.");
        }
      } catch (e) {
        // Defensive: shouldn't happen now that the parser only throws SmsParsingException,
        // but if a downstream call (e.g. addTransaction) fails, treat it as transient too.
        debugPrint("❌ Penny SMS Sync: Unexpected error (attempt $attempt/$_maxParseAttempts): $e");
        await box.put(id, {'status': _statusFailed, 'attempts': attempt});
        if (attempt >= _maxParseAttempts) {
          debugPrint("🛑 Penny SMS Sync: Giving up on message ID $id after $attempt attempts.");
        }
      }
    }

    debugPrint("✅ Penny SMS Sync: Process complete. Potential: $financialCount, Logged: $loggedCount");
  }

  /// syncCurrentMonthSms() ...
  
  void registerListener(void Function(SmsMessage) handler) {
    telephony.listenIncomingSms(
      onNewMessage: handler,
      onBackgroundMessage: handler,
    );
  }

  /// Check if the feature is enabled (can be stored in SettingsService)
  Future<void> toggleSmsSync(bool enabled, void Function(SmsMessage) handler) async {
    debugPrint("📱 Penny SMS Sync: toggleSmsSync called with enabled=$enabled");
    if (enabled) {
      debugPrint("📱 Penny SMS Sync: Requesting permissions...");
      bool? permissionsGranted = await telephony.requestSmsPermissions;
      debugPrint("📱 Penny SMS Sync: Permissions status: $permissionsGranted");
      
      if (permissionsGranted == true) {
        debugPrint("📱 Penny SMS Sync: Initializing listener and syncing...");
        registerListener(handler);
        await syncCurrentMonthSms();
      } else {
        debugPrint("⚠️ Penny SMS Sync: Permissions were not granted.");
        throw Exception("SMS Permissions are required for this feature.");
      }
    }
  }
}
