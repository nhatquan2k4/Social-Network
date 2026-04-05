import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/presentation/providers/mock_chat_store.dart';

class ChatSearchScreen extends StatefulWidget {
  final String displayName;
  final String conversationId;
  final MockChatStore chatStore;

  const ChatSearchScreen({
    super.key,
    required this.displayName,
    required this.conversationId,
    required this.chatStore,
  });

  @override
  State<ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<ChatSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F4),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.chatStore,
          builder: (context, _) {
            final results = _searchResults();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 12, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 17),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _query = value),
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: l10n.searchInConversationHint,
                              border: InputBorder.none,
                              prefixIcon: const Icon(Icons.search),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _query.trim().isEmpty
                      ? Center(
                          child: Text(
                            l10n.enterKeywordToSearch,
                            style: TextStyle(
                              color: Color(0xFF7D7D84),
                              fontSize: 14,
                            ),
                          ),
                        )
                      : results.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noMatchingResults,
                            style: TextStyle(
                              color: Color(0xFF7D7D84),
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                          itemCount: results.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final message = results[index];
                            final sender = message.isMe
                              ? l10n.youLabel
                                : widget.displayName;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              leading: const Icon(
                                Icons.chat_bubble_outline,
                                size: 18,
                                color: Color(0xFF6B6B71),
                              ),
                              title: _buildHighlightedContent(
                                message.content,
                                _query.trim(),
                              ),
                              subtitle: Text(
                                sender,
                                style: const TextStyle(
                                  color: Color(0xFF8A8A91),
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<MockChatMessage> _searchResults() {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];

    final allMessages = widget.chatStore
        .conversationMessages(widget.conversationId)
        .reversed
        .toList();

    return allMessages.where((m) {
      return m.content.toLowerCase().contains(normalized);
    }).toList();
  }

  Widget _buildHighlightedContent(String text, String keyword) {
    final normalizedText = text.toLowerCase();
    final normalizedKeyword = keyword.toLowerCase();
    final matchStart = normalizedText.indexOf(normalizedKeyword);

    if (keyword.isEmpty || matchStart < 0) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F1F23),
        ),
      );
    }

    final matchEnd = matchStart + keyword.length;
    final before = text.substring(0, matchStart);
    final matched = text.substring(matchStart, matchEnd);
    final after = text.substring(matchEnd);

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F1F23),
        ),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: matched,
            style: const TextStyle(
              color: Color(0xFF1689F6),
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}
