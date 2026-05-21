// lib/presentation/pages/chat/chat_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:ui';
import '../../../config/themes/app_colors.dart';
import '../../../domain/entities/chat_message.dart';
import '../../bloc/chat/chat_bloc.dart';
import '../../bloc/chat/chat_event.dart';
import '../../bloc/chat/chat_state.dart';
import '../../bloc/transaction_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadSessionsRequested());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return WillPopScope(
          onWillPop: () async {
            if (state.currentSessionId != null) {
              context.read<ChatBloc>().add(DeselectSessionRequested());
              return false;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Builder(
                builder: (context) {
                  if (state.currentSessionId == null) {
                    return const Text(
                      "Penny AI Advisor",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    );
                  }
                  final sessions = state.sessions.where(
                    (s) => s.id == state.currentSessionId,
                  );
                  final title = sessions.isNotEmpty
                      ? sessions.first.title
                      : "Chat";
                  return Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  );
                },
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  if (state.currentSessionId != null) {
                    context.read<ChatBloc>().add(DeselectSessionRequested());
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_comment_rounded),
                  onPressed: () => context.read<ChatBloc>().add(
                    const CreateNewSessionRequested(),
                  ),
                  tooltip: "New Chat",
                ),
              ],
            ),
            body: BlocListener<ChatBloc, ChatState>(
              listener: (context, state) {
                if (state.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage!),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              },
              child: Stack(
                children: [
                  state.currentSessionId == null
                      ? _buildSessionList(isDark)
                      : Column(
                          children: [
                            Expanded(
                              child: BlocBuilder<ChatBloc, ChatState>(
                                builder: (context, state) {
                                  if (state.messages.isEmpty &&
                                      !state.isLoading) {
                                    return _buildEmptyState(isDark);
                                  }
                                  WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => _scrollToBottom(),
                                  );
                                  return ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(16),
                                    itemCount:
                                        state.messages.length +
                                        (state.isLoading ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == state.messages.length) {
                                        return const _LoadingBubble();
                                      }
                                      final message = state.messages[index];
                                      final isLatestAI =
                                          message.role == MessageRole.model &&
                                          index == state.messages.length - 1;

                                      return _ChatBubble(
                                        message: message,
                                        isDark: isDark,
                                        isLatestAI: isLatestAI,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            if (state.messages.isEmpty && !state.isLoading)
                              _buildQuickActions(isDark),
                            _buildInputArea(isDark),
                          ],
                        ),
                  if (state.isLoading && state.currentSessionId == null)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.neon),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionList(bool isDark) {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (state.sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.chat_rounded, size: 64, color: AppColors.neon),
                const SizedBox(height: 16),
                const Text(
                  "No Recent Chats",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => context.read<ChatBloc>().add(
                    const CreateNewSessionRequested(),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text("Start first chat"),
                ),
              ],
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                "Recent Conversations",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.neon,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: state.sessions.length,
                itemBuilder: (context, index) {
                  final session = state.sessions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    color: isDark ? const Color(0xFF1C252E) : Colors.white,
                    elevation: session.isPinned ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: session.isPinned
                          ? const BorderSide(color: AppColors.neon, width: 1.5)
                          : BorderSide.none,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.neon.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          session.isPinned
                              ? Icons.push_pin_rounded
                              : Icons.chat_bubble_outline_rounded,
                          color: AppColors.neon,
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          if (session.isPinned)
                            const Padding(
                              padding: EdgeInsets.only(right: 6),
                              child: Icon(
                                Icons.push_pin_rounded,
                                size: 14,
                                color: AppColors.neon,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        "${session.updatedAt.day}/${session.updatedAt.month} • AI Penny",
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              size: 20,
                            ),
                            onSelected: (value) {
                              if (value == 'rename') {
                                _showRenameDialog(session.id, session.title);
                              } else if (value == 'pin') {
                                context.read<ChatBloc>().add(
                                      TogglePinSessionRequested(
                                        sessionId: session.id,
                                        isPinned: !session.isPinned,
                                      ),
                                    );
                              } else if (value == 'delete') {
                                _showDeleteDialog(session.id);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'rename',
                                child: Row(
                                  children: const [
                                    Icon(Icons.edit_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text("Rename"),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'pin',
                                child: Row(
                                  children: [
                                    Icon(
                                      session.isPinned
                                          ? Icons.push_pin_outlined
                                          : Icons.push_pin_rounded,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      session.isPinned ? "Unpin Chat" : "Pin Chat",
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: AppColors.danger,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Delete",
                                      style: TextStyle(color: AppColors.danger),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        ],
                      ),
                      onTap: () => context.read<ChatBloc>().add(
                            SelectSessionRequested(session.id),
                          ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(bool isDark) {
    final actions = [
      {"icon": Icons.analytics_rounded, "text": "Analyze my spending"},
      {
        "icon": Icons.account_balance_wallet_rounded,
        "text": "What's my balance?",
      },
      {"icon": Icons.trending_up_rounded, "text": "How can I save more?"},
      {"icon": Icons.receipt_long_rounded, "text": "Show recent expenses"},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              avatar: Icon(
                action["icon"] as IconData,
                size: 16,
                color: AppColors.neon,
              ),
              label: Text(
                action["text"] as String,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                _controller.text = action["text"] as String;
                _sendMessage();
              },
              backgroundColor: isDark ? const Color(0xFF1C252E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppColors.neon.withOpacity(0.2)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.neon.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.neon,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Hello! I'm Penny AI.",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                "Ask me anything about your spending, budgets, or how to save more effectively.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131A21) : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C252E)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    hintText: "Ask about your expenses...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: AppColors.neon,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showDeleteDialog(String sessionId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Chat?"),
        content: const Text(
          "This will permanently remove this conversation.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<ChatBloc>().add(
                    DeleteSessionRequested(sessionId),
                  );
              Navigator.pop(dialogContext);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(String sessionId, String currentTitle) {
    final TextEditingController renameController =
        TextEditingController(text: currentTitle);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Rename Chat"),
        content: TextField(
          controller: renameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Enter new name",
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.neon),
            ),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              context.read<ChatBloc>().add(
                    UpdateSessionTitleRequested(
                      sessionId: sessionId,
                      title: value.trim(),
                    ),
                  );
              Navigator.pop(dialogContext);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (renameController.text.trim().isNotEmpty) {
                context.read<ChatBloc>().add(
                      UpdateSessionTitleRequested(
                        sessionId: sessionId,
                        title: renameController.text.trim(),
                      ),
                    );
                Navigator.pop(dialogContext);
              }
            },
            child: const Text(
              "Rename",
              style: TextStyle(color: AppColors.neon),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;

    final transactions = context.read<TransactionBloc>().state.transactions;

    context.read<ChatBloc>().add(
      SendMessageRequested(message: text, transactions: transactions),
    );

    _controller.clear();
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;
  final bool isLatestAI;

  const _ChatBubble({
    required this.message,
    required this.isDark,
    required this.isLatestAI,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.neon
              : (isDark ? const Color(0xFF1C252E) : Colors.white),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 20),
          ),
          border: isUser
              ? null
              : Border.all(color: AppColors.neon.withOpacity(0.1)),
          boxShadow: [
            if (isUser)
              BoxShadow(
                color: AppColors.neon.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: isLatestAI
            ? _TypewriterText(
                text: message.text,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              )
            : MarkdownBody(
                data: message.text,
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    color: isUser
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black87),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  strong: const TextStyle(fontWeight: FontWeight.w900),
                  listBullet: TextStyle(
                    color: isUser ? Colors.white : AppColors.neon,
                  ),
                ),
              ),
      ),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _TypewriterText({required this.text, required this.style});

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _displayedText = "";
  int _currentIndex = 0;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() async {
    while (_currentIndex < widget.text.length && mounted) {
      setState(() {
        _displayedText += widget.text[_currentIndex];
        _currentIndex++;
      });
      await Future.delayed(const Duration(milliseconds: 15));
    }
    if (mounted) setState(() => _isDone = true);
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: _displayedText + (_isDone ? "" : " ▮"),
      styleSheet: MarkdownStyleSheet(
        p: widget.style,
        strong: const TextStyle(fontWeight: FontWeight.w900),
        listBullet: const TextStyle(color: AppColors.neon),
      ),
    );
  }
}

class _LoadingBubble extends StatefulWidget {
  const _LoadingBubble();

  @override
  State<_LoadingBubble> createState() => _LoadingBubbleState();
}

class _LoadingBubbleState extends State<_LoadingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C252E) : Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(color: AppColors.neon.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delay = index * 0.2;
                final value = Curves.easeInOut.transform(
                  ((_controller.value + delay) % 1.0).clamp(0.0, 1.0),
                );
                return Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: AppColors.neon.withOpacity(0.3 + (value * 0.7)),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
