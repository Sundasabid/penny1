import 'package:telephony/telephony.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:app/firebase_options.dart';
import 'package:app/data/services/sms_parsing_service.dart';
import 'package:app/domain/usecases/transaction/add_transaction.dart';
import 'package:app/data/repositories/firestore_transaction_repository.dart';
import 'package:app/data/repositories/firestore_budget_repository.dart';
import 'package:app/core/services/notification_service.dart';
import 'package:app/domain/entities/transaction.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// This is a top-level function required by the telephony package
/// for background SMS handling.
@pragma('vm:entry-point')
void backgrounMessageHandler(SmsMessage message) async {
  debugPrint("📩 Penny Background SMS: Received from ${message.address}");

  // Only process if it looks like a financial SMS (initial filter)
  final body = message.body ?? "";
  final lowerBody = body.toLowerCase();
  
  bool isFinancial = lowerBody.contains("rs.") || 
                     lowerBody.contains("pkr") || 
                     lowerBody.contains("spent") || 
                     lowerBody.contains("debited") || 
                     lowerBody.contains("credited") || 
                     lowerBody.contains("paid");

  if (!isFinancial) {
    debugPrint("⏭️ Penny Background: Not a financial SMS. Ignoring.");
    return;
  }

  try {
    // Initialize Firebase in the background isolate
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // 2. Parse with AI
    // Note: We need a hardcoded/stored API key here since we can't easily access context
    final smsParser = SmsParsingService(apiKey: 'AIzaSyA56KXaqpK07kfglYsEPJzgsdElvCLDmEM');
    
    // We'll use a standard set of categories for now
    final categories = ['Groceries', 'Dining', 'Transport', 'Shopping', 'Utilities', 'Others', 'Salary', 'Freelance', 'Investment', 'Gift'];
    
    final parsedData = await smsParser.parseFinancialSms(body, categories);

    if (parsedData != null) {
      debugPrint("✅ Penny Background: Parsed successfully: ${parsedData['merchantName']}");

      // 3. Save to Firestore
      final txRepo = FirestoreTransactionRepository();
      final budgetRepo = FirestoreBudgetRepository();
      final addTxUseCase = AddTransactionUseCase(txRepo, budgetRepo);

      final transaction = TransactionEntity(
        id: const Uuid().v4(),
        merchant: parsedData['merchantName'] ?? "Unknown Merchant",
        category: parsedData['category'] ?? "Others",
        amount: (parsedData['amount'] as num).toDouble(),
        dateTime: DateTime.now(),
        paymentMethod: "Bank/SMS",
        isIncome: parsedData['isIncome'] ?? false,
        source: TransactionSource.sms,
      );

      await addTxUseCase(transaction);

      // 4. Show Notification
      final notifications = NotificationService();
      // We don't need full init again if it's already done statically?
      // Actually, init might be needed in background isolate
      await notifications.init(); 

      final title = transaction.isIncome ? "Money Received! 💰" : "Expense Logged! 💸";
      final action = transaction.isIncome ? "credited to" : "spent at";
      
      await notifications.flutterLocalNotificationsPlugin.show(
        id: transaction.id.hashCode,
        title: title,
        body: "Rs. ${transaction.amount} $action ${transaction.merchant}",
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'sms_auto_log',
            'Automatic SMS Logging',
            channelDescription: 'Notifications for transactions logged from SMS',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  } catch (e) {
    debugPrint("❌ Penny Background: Error processing SMS: $e");
  }
}
