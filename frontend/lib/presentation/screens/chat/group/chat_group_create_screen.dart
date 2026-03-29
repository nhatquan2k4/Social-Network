import 'package:flutter/material.dart';
import 'package:frontend/presentation/providers/mock_chat_store.dart';
import 'package:frontend/presentation/screens/chat/group/chat_group_setup_screen.dart';

class ChatGroupCreateScreen extends StatefulWidget {
  final String? conversationId;
  final String? currentFriendId;
  final MockChatStore chatStore;

  const ChatGroupCreateScreen({
    super.key,
    this.conversationId,
    this.currentFriendId,
    required this.chatStore,
  });

  @override
  State<ChatGroupCreateScreen> createState() => _ChatGroupCreateScreenState();
}

class _ChatGroupCreateScreenState extends State<ChatGroupCreateScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.currentFriendId != null) {
      _selectedIds.add(widget.currentFriendId!);
    }
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allSuggestions = widget.chatStore.groupSuggestions(
      excludeConversationId: widget.conversationId ?? '',
    );
    final query = _searchController.text.trim().toLowerCase();
    final filtered = allSuggestions.where((c) {
      if (query.isEmpty) return true;
      return c.username.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F4),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 17),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nhóm mới',
          style: TextStyle(
            color: Color(0xFF1F1F23),
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _selectedIds.isEmpty
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatGroupSetupScreen(
                          selectedConversationIds: _selectedIds.toList(),
                          chatStore: widget.chatStore,
                        ),
                      ),
                    );
                  },
            child: Text(
              'Tiếp',
              style: TextStyle(
                color: _selectedIds.isEmpty
                    ? const Color(0xFF98A0AA)
                    : const Color(0xFF1689F6),
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 2),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Thành viên được mời',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF1F1F23),
                ),
              ),
            ),
          ),
          if (_selectedIds.isNotEmpty)
            SizedBox(
              height: 84,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: _selectedIds
                    .map((id) => widget.chatStore.conversationById(id))
                    .whereType<MockConversation>()
                    .map(
                      (conversation) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _selectedAvatarChip(
                          conversation: conversation,
                          isRequired: conversation.id == widget.currentFriendId,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF9A9AA1)),
                filled: true,
                fillColor: const Color(0xFFECECEF),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Gợi ý',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 31 / 2,
                  color: Color(0xFF1F1F23),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final user = filtered[index];
                final selected = _selectedIds.contains(user.id);

                return ListTile(
                  leading: CircleAvatar(
                    radius: 20,
                    foregroundImage: AssetImage(user.avatarAssetPath),
                    backgroundColor: user.avatarColor,
                  ),
                  title: Text(
                    _toDisplayName(user.username),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF27272B),
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    user.username,
                    style: const TextStyle(
                      color: Color(0xFF88888F),
                      fontSize: 13,
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedIds.remove(user.id);
                        } else {
                          _selectedIds.add(user.id);
                        }
                      });
                    },
                    child: Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selected
                          ? const Color(0xFF1689F6)
                          : const Color(0xFF8E8E93),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      if (selected) {
                        _selectedIds.remove(user.id);
                      } else {
                        _selectedIds.add(user.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedAvatarChip({
    required MockConversation conversation,
    required bool isRequired,
  }) {
    return SizedBox(
      width: 84,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 22,
                foregroundImage: AssetImage(conversation.avatarAssetPath),
                backgroundColor: conversation.avatarColor,
              ),
              if (!isRequired)
                Positioned(
                  right: -4,
                  top: -4,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIds.remove(conversation.id);
                      });
                    },
                    child: Container(
                      width: 19,
                      height: 19,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _toDisplayName(conversation.username),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2A2A2E),
            ),
          ),
        ],
      ),
    );
  }

  String _toDisplayName(String username) {
    final normalized = username.replaceAll(RegExp(r'[._]'), ' ').trim();
    final parts = normalized.split(RegExp(r'\s+'));
    return parts
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }
}
