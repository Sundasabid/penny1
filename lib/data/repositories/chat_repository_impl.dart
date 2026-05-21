import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart'
    hide ChatSession;
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/chat_session.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/budget_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/transaction/add_transaction.dart';
import '../../domain/usecases/transaction/delete_transaction.dart';
import '../../domain/entities/budget.dart';

class ChatRepositoryImpl implements ChatRepository {
  final String _apiKey;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BudgetRepository? _budgetRepository;
  final AuthRepository? _authRepository;
  final AddTransactionUseCase? _addTransactionUseCase;
  final DeleteTransactionUseCase? _deleteTransactionUseCase;

  ChatRepositoryImpl({
    required String apiKey,
    BudgetRepository? budgetRepository,
    AuthRepository? authRepository,
    AddTransactionUseCase? addTransactionUseCase,
    DeleteTransactionUseCase? deleteTransactionUseCase,
  })  : _apiKey = apiKey,
        _budgetRepository = budgetRepository,
        _authRepository = authRepository,
        _addTransactionUseCase = addTransactionUseCase,
        _deleteTransactionUseCase = deleteTransactionUseCase;

  String get _userId => _auth.currentUser?.uid ?? "anonymous";

  @override
  Future<List<ChatSession>> getSessions() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chat_sessions')
        .orderBy('updatedAt', descending: true)
        .get();

    final sessions = snapshot.docs.map((doc) {
      final data = doc.data();
      return ChatSession(
        id: doc.id,
        title: data['title'] ?? 'New Chat',
        messages: [],
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isPinned: data['isPinned'] ?? false,
      );
    }).toList();

    // Sort in memory: pinned first, then by updatedAt (desc)
    sessions.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return sessions;
  }

  @override
  Future<List<ChatMessage>> getMessages(String sessionId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chat_sessions')
        .doc(sessionId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ChatMessage(
        text: data['text'] ?? '',
        role: data['role'] == 'user' ? MessageRole.user : MessageRole.model,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
      );
    }).toList();
  }

  @override
  Future<void> saveMessage(String sessionId, ChatMessage message) async {
    final sessionRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('chat_sessions')
        .doc(sessionId);

    await sessionRef.collection('messages').add({
      'text': message.text,
      'role': message.role == MessageRole.user ? 'user' : 'model',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await sessionRef.update({
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': message.text,
    });
  }

  @override
  Future<ChatSession> createSession(String title) async {
    final docRef = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chat_sessions')
        .add({
          'title': title,
          'updatedAt': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
          'isPinned': false,
        });

    return ChatSession(
      id: docRef.id,
      title: title,
      messages: [],
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> updateSessionTitle(String sessionId, String title) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chat_sessions')
        .doc(sessionId)
        .update({'title': title});
  }

  @override
  Future<void> updateSessionPinStatus(String sessionId, bool isPinned) async {
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chat_sessions')
        .doc(sessionId)
        .update({'isPinned': isPinned});
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    final sessionRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('chat_sessions')
        .doc(sessionId);

    // Delete all messages in the subcollection
    final messages = await sessionRef.collection('messages').get();
    for (var doc in messages.docs) {
      await doc.reference.delete();
    }

    // Delete the session document itself
    await sessionRef.delete();
  }

  @override
  Future<ChatMessage> getChatResponse({
    required List<ChatMessage> history,
    required String message,
    required List<TransactionEntity> transactions,
  }) async {
    final modelsToTry = [
      'gemini-1.5-flash',
      'gemini-2.0-flash',
      'gemini-flash-latest',
    ];

    Object? lastError;
    debugPrint("🤖 Penny AI: Starting resilient request flow...");

    for (var modelName in modelsToTry) {
      try {
        debugPrint("🤖 Penny AI: Trying model $modelName...");
        final botTools = Tool(
          functionDeclarations: [
            FunctionDeclaration(
              'add_budget',
              'Creates or updates a budget for a specific category with a given limit.',
              Schema(
                SchemaType.object,
                properties: {
                  'category': Schema(SchemaType.string, description: 'The category to add the budget for, e.g., Groceries'),
                  'limit': Schema(SchemaType.number, description: 'The amount/limit for the budget'),
                },
                requiredProperties: ['category', 'limit'],
              ),
            ),
            FunctionDeclaration(
              'add_transaction',
              'Adds a new income or expense transaction.',
              Schema(
                SchemaType.object,
                properties: {
                  'amount': Schema(SchemaType.number, description: 'The amount of the transaction'),
                  'category': Schema(SchemaType.string, description: 'The category, e.g., Salary, Food'),
                  'isIncome': Schema(SchemaType.boolean, description: 'True if income, false if expense'),
                  'merchant': Schema(SchemaType.string, description: 'Optional merchant name or description'),
                },
                requiredProperties: ['amount', 'category', 'isIncome'],
              ),
            ),
            FunctionDeclaration(
              'delete_transaction',
              'Deletes a transaction by its exact ID. Use transaction ID provided in the recent activity context.',
              Schema(
                SchemaType.object,
                properties: {
                  'id': Schema(SchemaType.string, description: 'The exact transaction ID'),
                },
                requiredProperties: ['id'],
              ),
            ),
            FunctionDeclaration(
              'update_income',
              'Updates the user\'s default monthly income.',
              Schema(
                SchemaType.object,
                properties: {
                  'monthlyIncome': Schema(SchemaType.number, description: 'The new monthly income amount'),
                },
                requiredProperties: ['monthlyIncome'],
              ),
            ),
          ],
        );

        final model = GenerativeModel(
          model: modelName, 
          apiKey: _apiKey,
          tools: [botTools],
        );

        final context = _buildTransactionContext(transactions);
        final systemPrompt =
            "You are Penny, a friendly and professional personal finance assistant. "
            "Your goal is to help users manage their money, track expenses, and save better. "
            "Keep your answers extremely concise and completely to the point. Do not add any extra, irrelevant, or clustered information. "
            "Avoid using excessive markdown. "
            "If the user asks to perform an action (like adding/deleting a transaction, updating income, or adding a budget), ALWAYS use the provided tool functions to do so automatically. "
            "Always refer to the user's actual transactions and financial summary provided in the context.";

        final prompt =
            "$systemPrompt\n\nUser Transactions Context:\n$context\n\nUser Question: $message";

        final chat = model.startChat(
          history: history.map((m) {
            return Content(m.role == MessageRole.user ? 'user' : 'model', [
              TextPart(m.text),
            ]);
          }).toList(),
        );

        // Attempt to send message with exponential backoff for 503/429 errors
        GenerateContentResponse? response;
        int maxAttempts = 3;
        for (int attempt = 0; attempt < maxAttempts; attempt++) {
          try {
            response = await chat.sendMessage(Content.text(prompt));
            break; // Success!
          } catch (e) {
            final errorStr = e.toString();
            bool isTemporary =
                errorStr.contains("503") ||
                errorStr.contains("429") ||
                errorStr.contains("overloaded");

            if (isTemporary && attempt < maxAttempts - 1) {
              final waitMs = (attempt + 1) * 500; // 500ms, 1s
              debugPrint(
                "⚠️ Penny AI: Server busy (Attempt ${attempt + 1}), retrying in ${waitMs}ms...",
              );
              await Future.delayed(Duration(milliseconds: waitMs));
              continue;
            }
            rethrow; // Permanent error or out of retries
          }
        }
        
        if (response != null && response.functionCalls.isNotEmpty) {
          final call = response.functionCalls.first;
          
          if (call.name == 'add_budget' && _budgetRepository != null) {
            final args = call.args;
            final category = args['category'] as String;
            final limit = (args['limit'] as num).toDouble();
            
            await _budgetRepository.saveBudget(BudgetEntity(
              id: '',
              category: category,
              limit: limit,
              spent: 0,
            ));
            
            response = await chat.sendMessage(Content.functionResponse(
              'add_budget',
              {'status': 'success', 'message': 'Successfully added a budget of $limit for $category. Let the user know it was done.'}
            ));
          } else if (call.name == 'add_transaction' && _addTransactionUseCase != null) {
            final args = call.args;
            final amount = (args['amount'] as num).toDouble();
            final category = args['category'] as String;
            final isIncome = args['isIncome'] as bool;
            final merchant = args['merchant'] as String? ?? 'Added by Penny AI';
            
            final newTx = isIncome 
                ? TransactionEntity.manualIncome(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    amount: amount,
                    category: category,
                    merchant: merchant,
                    dateTime: DateTime.now(),
                    paymentMethod: 'Cash',
                  )
                : TransactionEntity.manualExpense(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    amount: amount,
                    category: category,
                    merchant: merchant,
                    dateTime: DateTime.now(),
                    paymentMethod: 'Cash',
                  );
            
            await _addTransactionUseCase.call(newTx);
            
            response = await chat.sendMessage(Content.functionResponse(
              'add_transaction',
              {'status': 'success', 'message': 'Successfully added transaction.'}
            ));
          } else if (call.name == 'delete_transaction' && _deleteTransactionUseCase != null) {
            final args = call.args;
            final id = args['id'] as String;
            
            final targetTx = transactions.where((t) => t.id == id).firstOrNull;
            if (targetTx != null) {
              await _deleteTransactionUseCase.call(targetTx);
            }
            
            response = await chat.sendMessage(Content.functionResponse(
              'delete_transaction',
              {'status': targetTx != null ? 'success' : 'error', 'message': targetTx != null ? 'Successfully deleted transaction.' : 'Transaction not found for ID $id'}
            ));
          } else if (call.name == 'update_income' && _authRepository != null) {
            final args = call.args;
            final monthlyIncome = (args['monthlyIncome'] as num).toDouble();
            
            await _authRepository.updateFinancialProfile(monthlyIncome: monthlyIncome);
            
            response = await chat.sendMessage(Content.functionResponse(
              'update_income',
              {'status': 'success', 'message': 'Successfully updated monthly income.'}
            ));
          }
        }

        final text =
            response?.text ?? "I'm sorry, I couldn't generate a response.";

        return ChatMessage(
          text: text,
          role: MessageRole.model,
          timestamp: DateTime.now(),
        );
      } catch (e) {
        lastError = e;
        debugPrint("❌ Penny AI: Model $modelName final failure: $e");

        // If it's a temporary error, wait briefly before trying a DIFFERENT model
        if (e.toString().contains("503") || e.toString().contains("429")) {
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    }

    // If all models across all retries fail
    String userFriendlyMessage = "Penny AI Assistant is currently unavailable.";
    final errorStr = lastError.toString();

    if (errorStr.contains("503") || errorStr.contains("overloaded")) {
      userFriendlyMessage =
          "Google's AI servers are currently overloaded due to extremely high demand. This is temporary—please wait a few moments and try again.";
    } else if (errorStr.contains("429") || errorStr.contains("quota")) {
      userFriendlyMessage =
          "You have reached your Gemini API quota limit. Please check your usage on the Google AI Studio dashboard or try again later.";
    }

    throw Exception(
      "$userFriendlyMessage\n\n(Details: ${lastError?.toString()})",
    );
  }

  @override
  Future<String> getInsightCoachNote({
    required String insightSummary,
  }) async {
    final modelName = 'gemini-1.5-flash';
    try {
      final model = GenerativeModel(
        model: modelName,
        apiKey: _apiKey,
      );

      final prompt = 
          "You are Penny, a friendly financial coach. I will provide you with a summary of a user's spending habits for this month. "
          "Your job is to provide ONE SINGLE, SHORT, and supportive piece of advice or a 'coach's note' (max 25 words). "
          "Make it sound encouraging and personal. "
          "Summary data: $insightSummary";

      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? "Keep tracking your expenses to stay on top of your goals!";
    } catch (e) {
      debugPrint("❌ Penny AI: Failed to get coach note: $e");
      return "You're making progress! Keep up the good work.";
    }
  }

  @override
  Future<String> getDailyFinancialTip() async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final prompt = [
        Content.text(
          "You are Penny, a financial coach. Provide one unique, inspiring daily tip OR a financial quote (under 20 words) focused strictly on MANAGING or LOWERING expenses. It should feel like a 'Daily Wisdom'. Make it punchy and actionable."
        )
      ];

      final response = await model.generateContent(prompt);
      return response.text?.trim() ?? "Small savings today lead to big freedom tomorrow.";
    } catch (e) {
      debugPrint("❌ Penny AI: Failed to get daily tip: $e");
      return "Every small saving counts towards your big goals.";
    }
  }

  String _buildTransactionContext(List<TransactionEntity> transactions) {
    if (transactions.isEmpty) return "No transactions found.";

    // Sort transactions by date (newest first)
    final sortedTx = List<TransactionEntity>.from(transactions)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    final now = DateTime.now();
    final last30Days = sortedTx.where(
      (t) => t.dateTime.isAfter(now.subtract(const Duration(days: 30))),
    );

    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalExpenses = transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    final last30Income = last30Days
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    final last30Expenses = last30Days
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    final categories = <String, double>{};
    for (var t in transactions.where((t) => !t.isIncome)) {
      categories[t.category] = (categories[t.category] ?? 0.0) + t.amount;
    }

    final topCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final recentTx = sortedTx
        .take(15)
        .map(
          (t) =>
              "- [ID: ${t.id}] ${t.dateTime.day}/${t.dateTime.month}/${t.dateTime.year}: ${t.isIncome ? '+' : '-'}${t.amount} | ${t.category} (${t.merchant})",
        )
        .join("\n");

    return """
Financial Summary (Lifetime):
- Total Income: $totalIncome
- Total Expenses: $totalExpenses
- Current Balance: ${totalIncome - totalExpenses}

Last 30 Days:
- Income: $last30Income
- Expenses: $last30Expenses
- Net: ${last30Income - last30Expenses}

Top Spending Categories:
${topCategories.take(5).map((e) => "  * ${e.key}: ${e.value}").join("\n")}

Recent activity:
$recentTx
""";
  }

  @override
  Future<String> getPurchasePlan({
    required String purchaseName,
    required double amount,
    required DateTime targetDate,
    required String financialSummary,
  }) async {
    final modelsToTry = [
      'gemini-1.5-flash',
      'gemini-2.0-flash',
      'gemini-flash-latest',
    ];

    final daysUntil = targetDate.difference(DateTime.now()).inDays;
    final prompt = 
        "You are Penny, a financial coach. The user wants to buy '$purchaseName' costing $amount PKR "
        "within $daysUntil days (by ${targetDate.day}/${targetDate.month}/${targetDate.year}). "
        "Their financial situation: $financialSummary. "
        "Generate a VERY DETAILED, VISUAL 'Path to Purchase' plan. "
        "Your response MUST start with these EXACT three lines for the UI to parse: "
        "DAILY_TARGET: [PKR] "
        "WEEKLY_TARGET: [PKR] "
        "CATEGORICAL_CUTS: [Category | Spend PKR | Save PKR | ProTip; Category | Spend PKR | Save PKR | ProTip] "
        "STRATEGY_POINTS: [Point 1; Point 2; Point 3] "
        "THEN, provide a friendly, encouraging 2-sentence summary and feasibility check.";

    for (var modelName in modelsToTry) {
      try {
        final model = GenerativeModel(model: modelName, apiKey: _apiKey);
        
        GenerateContentResponse? response;
        for (int attempt = 0; attempt < 3; attempt++) {
          try {
            response = await model.generateContent([Content.text(prompt)]);
            break;
          } catch (e) {
            if (e.toString().contains("503") || e.toString().contains("429")) {
              await Future.delayed(Duration(milliseconds: (attempt + 1) * 500));
              continue;
            }
            rethrow;
          }
        }
        
        if (response?.text != null) return response!.text!.trim();
      } catch (e) {
        debugPrint("❌ Penny AI: Purchase Plan Model $modelName failed: $e");
      }
    }

    return "Penny is currently thinking hard! Try again in a moment. In the meantime, look at cutting your top spending category to save for this goal.";
  }

  @override
  Future<String> generateWeeklyChallenge({required String spendingSummary}) async {
    final modelsToTry = [
      'gemini-1.5-flash',
      'gemini-2.0-flash',
    ];

    // Added a random seed to prompt to ensure AI variety even with same summary
    final prompt = 
        "You are Penny, a financial coach. Based on the user's spending: ${spendingSummary.isEmpty ? 'No data yet' : spendingSummary}. "
        "Generate ONE unique, specific, and highly creative weekly savings challenge. "
        "CRITICAL: Do not repeat common challenges. Be original. Target specific categories (Food, Entertainment, Transport, etc.). "
        "Random Seed: ${DateTime.now().microsecondsSinceEpoch}. "
        "Format your response EXACTLY as: Title | Description. "
        "The title should be catchy (max 5 words). The description should be actionable (max 20 words). "
        "Example: Green Commute | Walk or cycle for any trip under 1km this week to save fuel.";

    for (var modelName in modelsToTry) {
      try {
        final model = GenerativeModel(model: modelName, apiKey: _apiKey);
        
        GenerateContentResponse? response;
        for (int attempt = 0; attempt < 3; attempt++) {
          try {
            response = await model.generateContent([Content.text(prompt)]);
            break;
          } catch (e) {
            if (e.toString().contains("503") || e.toString().contains("429")) {
              await Future.delayed(Duration(milliseconds: (attempt + 1) * 500));
              continue;
            }
            rethrow;
          }
        }
        
        if (response?.text != null) return response!.text!.trim();
      } catch (e) {
        debugPrint("❌ Penny AI: Challenge Model $modelName failed: $e");
      }
    }

    // Rotating fallbacks to prevent "The Savings Streak" repetition
    final fallbacks = [
      "The 500 PKR Rule | Wait 24 hours before any non-essential purchase over 500 PKR.",
      "Hidden Subscriptions | Review your bank statement and cancel one unused subscription today.",
      "Home Chef Week | Avoid ordering food for the next 2 days and cook at home.",
      "Generic Swap | Buy only store-brand items for your next grocery run to save 20%.",
      "The Change Jar | Transfer 100 PKR to your savings every time you log a transaction.",
      "Digital Detox | Avoid paid digital entertainment for one evening and read a book instead.",
      "The Beverage Challenge | Drink only water for the next 48 hours to save on sodas/coffees."
    ];
    return fallbacks[DateTime.now().second % fallbacks.length];
  }
}

