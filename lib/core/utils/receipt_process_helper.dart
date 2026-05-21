import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/bloc/receipt/receipt_bloc.dart';
import '../../presentation/bloc/receipt/receipt_event.dart';
import '../../presentation/bloc/transaction_bloc.dart';
import '../../presentation/bloc/transaction_event.dart';
import '../../domain/entities/transaction.dart';

class ReceiptProcessHelper {
  static void processScanResult(BuildContext context, Map<String, dynamic> result) {
    if (result.isEmpty) return;

    // Show immediate feedback to user
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔄 Processing your receipt...'),
        duration: Duration(seconds: 2),
      ),
    );

    debugPrint("📥 ReceiptProcessHelper: Starting log flow for ${result['merchantName']}");

    final receiptId = DateTime.now().millisecondsSinceEpoch.toString();
    final imagePath = result['imagePath'] as String;
    
    // Support both AI generator keys and fallback scanner keys
    final merchantName = (result['merchantName'] as String?)?.trim().isNotEmpty == true
        ? (result['merchantName'] as String)
        : 'Unknown Merchant';
    
    final rawAmount = result['amount'] ?? result['totalAmount'];
    final amount = (rawAmount as num?)?.toDouble() ?? 0.0;
    
    final category = (result['category'] as String?)?.trim().isNotEmpty == true
        ? (result['category'] as String)
        : 'other';
    
    final dateTime = (result['dateTime'] as DateTime?) ?? DateTime.now();

    // 1. Add to Receipt Bloc (Gallery)
    context.read<ReceiptBloc>().add(
      SaveReceiptRequested(
        receiptId: receiptId,
        imagePath: imagePath,
        merchantName: merchantName,
        amount: amount,
        category: category,
        dateTime: dateTime,
      ),
    );

    // 2. Add to Transaction Bloc (History / Dashboard)
    // We use context.read but ensure we're adding to the stream
    final txBloc = context.read<TransactionBloc>();
    
    txBloc.add(
      AddTransactionRequested(
        TransactionEntity(
          id: 'tx_$receiptId',
          merchant: merchantName,
          category: category,
          amount: amount,
          dateTime: dateTime,
          paymentMethod: 'Cash',
          isIncome: false,
          source: TransactionSource.receipt,
          receiptId: receiptId,
        ),
      ),
    );

    // 3. Force a reload of the transaction history to ensure history/dashboard sync
    txBloc.add(const LoadTransactionsRequested());

    // 4. Refresh the receipt list
    context.read<ReceiptBloc>().add(GetReceiptsRequested());
    
    debugPrint("✅ ReceiptProcessHelper: Successfully processed scan for $merchantName ($amount)");
  }
}
