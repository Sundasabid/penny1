import '../../domain/entities/chat_message.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/chat_session.dart';

abstract class ChatRepository {
  Future<List<ChatSession>> getSessions();
  Future<List<ChatMessage>> getMessages(String sessionId);
  Future<void> saveMessage(String sessionId, ChatMessage message);
  Future<ChatSession> createSession(String title);
  Future<void> updateSessionTitle(String sessionId, String title);
  Future<void> updateSessionPinStatus(String sessionId, bool isPinned);
  Future<void> deleteSession(String sessionId);
  Future<ChatMessage> getChatResponse({
    required List<ChatMessage> history,
    required String message,
    required List<TransactionEntity> transactions,
  });

  /// Generates a concise, supportive coaching note based on rule-based insights
  Future<String> getInsightCoachNote({required String insightSummary});

  /// Generates a randomized, daily financial tip of the day
  Future<String> getDailyFinancialTip();

  /// Generates an AI "Path to Purchase" plan with category-wise reductions
  Future<String> getPurchasePlan({
    required String purchaseName,
    required double amount,
    required DateTime targetDate,
    required String financialSummary,
  });

  /// Generates a personalized weekly savings challenge
  Future<String> generateWeeklyChallenge({required String spendingSummary});
}
