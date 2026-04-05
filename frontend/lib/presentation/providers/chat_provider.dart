import 'package:flutter/material.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/message_usecase.dart';
import '../../domain/usecases/conversation_usecase.dart';
import '../../core/utils/logger.dart';

class ChatProvider extends ChangeNotifier {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final CreateConversationUseCase createConversationUseCase;
  final GetConversationsUseCase getConversationsUseCase;

  ChatProvider({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.createConversationUseCase,
    required this.getConversationsUseCase,
  });

  List<MessageEntity> messages = [];
  bool isLoading = false;
  bool isSending = false;
  String? error;
  String? currentConversationId;
  String? currentRecipientId;
  final Map<String, String> _conversationIdByRecipientId =
      <String, String>{};

  // Optimistic UI: tin nhắn tạm thời đang chờ gửi
  final List<MessageEntity> _pendingMessages = [];

  List<MessageEntity> get allMessages {
    // Kết hợp tin nhắn thực + tin nhắn đang gửi
    return [...messages, ..._pendingMessages];
  }

  void setConversation(String? conversationId, String recipientId) {
    currentConversationId = conversationId;
    currentRecipientId = recipientId;
    if (conversationId != null && conversationId.trim().isNotEmpty) {
      _conversationIdByRecipientId[recipientId] = conversationId;
    }
    messages = [];
    _pendingMessages.clear();
    error = null;
  }

  // Tạo conversation mới và load messages
  Future<void> createAndLoadConversation(String recipientId) async {
    try {
      isLoading = true;
      notifyListeners();

      logger.i('Resolving conversation for recipientId: $recipientId');

      final cachedConversationId =
          _conversationIdByRecipientId[recipientId]?.trim();
      if (cachedConversationId != null && cachedConversationId.isNotEmpty) {
        logger.i('Using cached conversationId: $cachedConversationId');
        currentConversationId = cachedConversationId;
        currentRecipientId = recipientId;

        await loadMessages();
        if (error == null) {
          return;
        }

        // Cache can become stale; clear and continue with API resolution.
        _conversationIdByRecipientId.remove(recipientId);
      }

      final conversations = await getConversationsUseCase();
      _hydrateConversationCache(conversations);

      final existingConversation = _findExistingDirectConversation(
        conversations: conversations,
        recipientId: recipientId,
      );

      if (existingConversation != null) {
        logger.i('Found existing conversation: ${existingConversation.id}');
        currentConversationId = existingConversation.id;
        currentRecipientId = recipientId;
        _conversationIdByRecipientId[recipientId] = existingConversation.id;

        await loadMessages();
        error = null;
        return;
      }

      logger.i('No existing conversation found. Creating a new one.');

      // Tạo conversation
      final conversation = await createConversationUseCase(
        recipientId: recipientId,
      );

      logger.i('Conversation created: ${conversation.id}');

      // Set conversation ID
      currentConversationId = conversation.id;
      currentRecipientId = recipientId;
      _conversationIdByRecipientId[recipientId] = conversation.id;

      logger.i('Saved conversationId: $currentConversationId');

      // Load messages (sẽ rỗng cho conversation mới)
      await loadMessages();

      error = null;
    } catch (e, stackTrace) {
      logger.e(
        'Error creating conversation: $e',
        error: e,
        stackTrace: stackTrace,
      );
      error = "Không thể tạo cuộc trò chuyện: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _hydrateConversationCache(List<ConversationEntity> conversations) {
    for (final conversation in conversations) {
      if (conversation.type != 'direct') continue;

      for (final participantId in conversation.participantIds) {
        final normalizedParticipantId = participantId.trim();
        if (normalizedParticipantId.isEmpty) continue;

        _conversationIdByRecipientId[normalizedParticipantId] = conversation.id;
      }
    }
  }

  ConversationEntity? _findExistingDirectConversation({
    required List<ConversationEntity> conversations,
    required String recipientId,
  }) {
    for (final conversation in conversations) {
      if (conversation.type != 'direct') continue;
      if (conversation.participantIds.contains(recipientId)) {
        return conversation;
      }
    }
    return null;
  }

  Future<void> loadMessages({bool loadMore = false}) async {
    if (currentConversationId == null) return;

    try {
      if (!loadMore) {
        isLoading = true;
        notifyListeners();
      }

      final newMessages = await getMessagesUseCase(currentConversationId!);
      messages = newMessages;
      error = null;
    } catch (e) {
      error = "Không thể tải tin nhắn: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content) async {
    if (currentRecipientId == null || content.trim().isEmpty) return;

    // QUAN TRỌNG: Phải có conversationId trước khi gửi tin nhắn
    if (currentConversationId == null) {
      error = "Không có conversation ID. Vui lòng thử lại.";
      logger.e('ERROR: conversationId is NULL!');
      notifyListeners();
      return;
    }

    logger.i('Sending message with conversationId: $currentConversationId');
    logger.i('Content: $content');
    logger.i('RecipientId: $currentRecipientId');

    // Optimistic UI: Thêm tin nhắn tạm thời ngay lập tức
    final tempMessage = MessageEntity(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: currentConversationId!,
      senderId: 'currentUser', // Sẽ được thay bằng user ID thật
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _pendingMessages.add(tempMessage);
    notifyListeners();

    try {
      isSending = true;

      final sentMessage = await sendMessageUseCase(
        currentRecipientId!,
        content,
        conversationId: currentConversationId!, // Bắt buộc phải có
      );

      logger.i('Message sent successfully: ${sentMessage.id}');

      // Xóa tin nhắn tạm, thêm tin nhắn thật
      _pendingMessages.remove(tempMessage);
      messages.add(sentMessage);
      error = null;
    } catch (e, stackTrace) {
      logger.e('Error sending message: $e', error: e, stackTrace: stackTrace);
      error = "Không thể gửi tin nhắn: $e";
      // Xóa tin nhắn tạm nếu gửi thất bại
      _pendingMessages.remove(tempMessage);
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  void clearChat() {
    messages = [];
    _pendingMessages.clear();
    currentConversationId = null;
    currentRecipientId = null;
    error = null;
    notifyListeners();
  }
}
