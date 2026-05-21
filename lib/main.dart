 // lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/receipt_repository_impl.dart';
import 'domain/entities/transaction.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/receipt_repository.dart';
import 'domain/usecases/transaction/add_transaction.dart';
import 'domain/usecases/transaction/get_transactions.dart';
import 'domain/usecases/transaction/delete_transaction.dart';
import 'domain/usecases/receipt/get_receipts.dart';
import 'domain/usecases/receipt/save_receipt.dart';
import 'domain/usecases/receipt/delete_receipt.dart';
import 'presentation/bloc/receipt/receipt_bloc.dart';
import 'presentation/bloc/receipt/receipt_event.dart';
import 'data/repositories/firestore_transaction_repository.dart';
import 'presentation/bloc/transaction_bloc.dart';
import 'presentation/bloc/transaction_event.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/onboarding/onboarding_page.dart';
import 'data/repositories/firestore_copilot_repository.dart';
import 'domain/repositories/copilot_repository.dart';
import 'app_shell.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for debug check
import 'firebase_options.dart'; // Uncomment if ensuring generated options

// repositories
import 'data/repositories/firestore_budget_repository.dart';
import 'presentation/bloc/budget/budget_bloc.dart';
import 'presentation/bloc/budget/budget_event.dart';

// Theme
import 'config/themes/app_theme.dart';
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/bloc/theme/theme_event.dart';
import 'presentation/bloc/theme/theme_state.dart';

// Category
import 'data/repositories/firestore_category_repository.dart';
import 'presentation/bloc/category/category_bloc.dart';
import 'presentation/bloc/category/category_event.dart';

// Chat
import 'data/repositories/chat_repository_impl.dart';
import 'domain/repositories/chat_repository.dart';
import 'presentation/bloc/chat/chat_bloc.dart';

// Insights
import 'presentation/bloc/insight/insight_bloc.dart';

// Co-Pilot
import 'presentation/bloc/copilot/copilot_bloc.dart';

// Debts
import 'data/repositories/debt_repository_impl.dart';
import 'domain/repositories/debt_repository.dart';
import 'presentation/bloc/debt/debt_bloc.dart';
import 'presentation/bloc/debt/debt_event.dart';
import 'data/services/gemini_receipt_processor.dart';

// Vaults
import 'data/repositories/firestore_vault_repository.dart';
import 'domain/repositories/vault_repository.dart';
import 'presentation/bloc/vault/vault_bloc.dart';
import 'presentation/bloc/vault/vault_event.dart';

// Subscriptions
import 'data/repositories/firestore_subscription_repository.dart';
import 'domain/repositories/subscription_repository.dart';
import 'presentation/bloc/subscription/subscription_bloc.dart';
import 'presentation/bloc/subscription/subscription_event.dart';
import 'core/services/notification_service.dart';
import 'core/services/settings_service.dart';
import 'data/services/sms_parsing_service.dart';
import 'data/services/sms_sync_service.dart';
import 'core/utils/sms_background_handler.dart';
import 'package:telephony/telephony.dart';

// 🔍 Global Navigator Key for 'Clean Escape' Logout
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Preferences & Session Storage
  final settingsService = SettingsService();
  await settingsService.init();

  await NotificationService().init();

  // 🔍 Debug: Print current platform status
  debugPrint("🚀 Penny App Starting...");
  debugPrint("🌍 kIsWeb: $kIsWeb");

  try {
    // 🔍 Check if Firebase is already initialized (Hot Restart handling)
    if (Firebase.apps.isNotEmpty) {
      debugPrint("♻️ Firebase already initialized. Using existing app.");
    } else {
      debugPrint("📱 Initializing Firebase for ${kIsWeb ? 'Web' : 'Mobile'}...");
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("✅ Firebase Initialized!");
    }

    // 🧪 VERIFY: Try to access auth instance immediately
    final auth = FirebaseAuth.instance;
    debugPrint("🔐 Auth Verified: App Name = ${auth.app.name}");
  } catch (e) {
    debugPrint("❌ Firebase Initialization Error: $e");
    runApp(InitializationErrorApp(error: e.toString()));
    return;
  }

  final authRepository = AuthRepositoryImpl();
  
  // Registration of SMS Sync Service
  final smsParser = SmsParsingService(apiKey: 'AIzaSyA56KXaqpK07kfglYsEPJzgsdElvCLDmEM');
  final txRepo = FirestoreTransactionRepository();
  final budgetRepo = FirestoreBudgetRepository();
  final addTx = AddTransactionUseCase(txRepo, budgetRepo);
  
  final smsSyncService = SmsSyncService(
    parser: smsParser,
    addTransaction: addTx,
  );

  // Initialize Background SMS Listener if enabled
  if (settingsService.isSmsSyncEnabled()) {
    debugPrint("📱 Penny SMS: Starting background listener...");
    Telephony.instance.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        // We can reuse the background handler logic for foreground too
        backgrounMessageHandler(message);
      },
      onBackgroundMessage: backgrounMessageHandler,
    );
  }

  runApp(PennyTestApp(
    authRepository: authRepository,
    settingsService: settingsService,
    smsSyncService: smsSyncService,
  ));
}

class InitializationErrorApp extends StatelessWidget {
  final Object error;
  const InitializationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              "Initialization Error:\n$error",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// TEST-ONLY In-Memory Transaction Repository
/// (manual + receipt transactions will both be stored here)
/// ------------------------------------------------------------
class InMemoryTransactionRepository implements TransactionRepository {
  final List<TransactionEntity> _store = [];

  @override
  Future<void> addTransaction(TransactionEntity tx) async {
    _store.add(tx);
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    final list = List<TransactionEntity>.from(_store);
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _store.removeWhere((tx) => tx.id == id);
  }
}

class PennyTestApp extends StatelessWidget {
  final AuthRepository authRepository;
  final SettingsService settingsService;
  final SmsSyncService smsSyncService;

  const PennyTestApp({
    super.key, 
    required this.authRepository,
    required this.settingsService,
    required this.smsSyncService,
  });

  @override
  Widget build(BuildContext context) {
    // Repositories
    final txRepo = FirestoreTransactionRepository();
    final budgetRepo = FirestoreBudgetRepository();
    final aiProcessor =
        GeminiReceiptProcessor(apiKey: 'AIzaSyA56KXaqpK07kfglYsEPJzgsdElvCLDmEM');
    final receiptRepo = ReceiptRepositoryImpl(aiProcessor: aiProcessor);
    final debtRepo = DebtRepositoryImpl();
    final subscriptionRepo = FirestoreSubscriptionRepository();
    final vaultRepo = FirestoreVaultRepository();

    // Transaction usecases
    final addTx = AddTransactionUseCase(txRepo, budgetRepo);
    final getTx = GetTransactionsUseCase(txRepo);
    final deleteTx = DeleteTransactionUseCase(txRepo, budgetRepo);

    // Receipt usecases
    final getReceipts = GetReceipts(receiptRepo);
    final saveReceipt = SaveReceipt(receiptRepo);
    final deleteReceipt = DeleteReceiptUseCase(
      receiptRepository: receiptRepo,
      transactionRepository: txRepo,
      budgetRepository: budgetRepo,
    );

    // Category Repository
    final categoryRepo = FirestoreCategoryRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingsService>.value(value: settingsService),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<ReceiptRepository>.value(value: receiptRepo),
        RepositoryProvider<ChatRepository>(
          create: (_) => ChatRepositoryImpl(
            apiKey: 'AIzaSyA56KXaqpK07kfglYsEPJzgsdElvCLDmEM',
            budgetRepository: budgetRepo,
            authRepository: authRepository,
            addTransactionUseCase: addTx,
            deleteTransactionUseCase: deleteTx,
          ),
        ),
        RepositoryProvider<CopilotRepository>(
          create: (_) => FirestoreCopilotRepository(),
        ),
        RepositoryProvider<DebtRepository>.value(value: debtRepo),
        RepositoryProvider<SubscriptionRepository>.value(value: subscriptionRepo),
        RepositoryProvider<VaultRepository>.value(value: vaultRepo),
        RepositoryProvider<SmsSyncService>.value(value: smsSyncService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(
              settingsService: context.read<SettingsService>(),
            )..add(LoadThemeRequested()),
          ),
          BlocProvider<CategoryBloc>(
            create: (_) =>
                CategoryBloc(categoryRepository: categoryRepo)
                  ..add(LoadCategoriesRequested()),
          ),
          BlocProvider<TransactionBloc>(
            create: (_) => TransactionBloc(
              addTransaction: addTx,
              getTransactions: getTx,
              deleteTransaction: deleteTx,
            )..add(const LoadTransactionsRequested()),
          ),
          BlocProvider<BudgetBloc>(
            create: (_) =>
                BudgetBloc(budgetRepository: budgetRepo)
                  ..add(LoadBudgetsRequested()),
          ),
          BlocProvider<ReceiptBloc>(
            create: (_) => ReceiptBloc(
              getReceipts: getReceipts,
              saveReceipt: saveReceipt,
              deleteReceipt: deleteReceipt,
            )..add(GetReceiptsRequested()),
          ),
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: authRepository,
              settingsService: context.read<SettingsService>(),
            ),
          ),
          BlocProvider<ChatBloc>(
            create: (context) =>
                ChatBloc(chatRepository: context.read<ChatRepository>()),
          ),
          BlocProvider<InsightBloc>(
            create: (context) => InsightBloc(
              transactionBloc: context.read<TransactionBloc>(),
              chatRepository: context.read<ChatRepository>(),
            ),
          ),
          BlocProvider<CopilotBloc>(
            create: (context) => CopilotBloc(
              transactionBloc: context.read<TransactionBloc>(),
              chatRepository: context.read<ChatRepository>(),
              copilotRepository: context.read<CopilotRepository>(),
              authRepository: context.read<AuthRepository>(),
            ),
          ),
          BlocProvider<DebtBloc>(
            create: (context) =>
                DebtBloc(repository: context.read<DebtRepository>())
                  ..add(LoadDebtsRequested()),
          ),
          BlocProvider<SubscriptionBloc>(
            create: (context) => SubscriptionBloc(
              repository: context.read<SubscriptionRepository>(),
              addTransaction: addTx,
              notificationService: NotificationService(),
            )..add(LoadSubscriptionsRequested()),
          ),
          BlocProvider<VaultBloc>(
            create: (context) => VaultBloc(
              repository: context.read<VaultRepository>(),
            )..add(LoadVaultsRequested()),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'PENNY',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeState.themeMode,
          home: BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) =>
                previous.status != current.status,
            builder: (context, state) {
              if (state.status == AuthStatus.authenticated) {
                return InitTransactionsWrapper(child: const AppShell());
              }
              if (state.status == AuthStatus.unknown) {
                return const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text("Loading Penny..."),
                      ],
                    ),
                  ),
                );
              }
              // unauthenticated / loading / error all keep LoginScreen
              // mounted so the user can see the error snackbar and retry.
              final settings = context.read<SettingsService>();
              if (!settings.hasSeenOnboarding()) {
                return const OnboardingPage();
              }
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}

class InitTransactionsWrapper extends StatefulWidget {
  final Widget child;
  const InitTransactionsWrapper({super.key, required this.child});

  @override
  State<InitTransactionsWrapper> createState() =>
      _InitTransactionsWrapperState();
}

class _InitTransactionsWrapperState extends State<InitTransactionsWrapper> {
  @override
  void initState() {
    super.initState();
    // Trigger load when this widget is mounted (which happens on Auth Success)
    context.read<TransactionBloc>().add(const LoadTransactionsRequested());
    context.read<CategoryBloc>().add(LoadCategoriesRequested());
    context.read<BudgetBloc>().add(LoadBudgetsRequested());
    context.read<ReceiptBloc>().add(GetReceiptsRequested());
    context.read<VaultBloc>().add(LoadVaultsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
