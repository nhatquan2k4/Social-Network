import 'package:flutter/material.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/message_usecase.dart';
import '../../domain/usecases/conversation_usecase.dart';

class ChatProvider extends ChangeNotifier {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final CreateConversationUseCase createConversationUseCase;

  ChatProvider({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.createConversationUseCase,
  });

  List<MessageEntity> messages = [];
  bool isLoading = false;
  bool isSending = false;
  String? error;
  String? currentConversationId;
  String? currentRecipientId;

  // Optimistic UI: tin nhắn tạm thời đang chờ gửi
  final List<MessageEntity> _pendingMessages = [];

  List<MessageEntity> get allMessages {
    // Kết hợp tin nhắn thực + tin nhắn đang gửi
    return [...messages, ..._pendingMessages];
  }

  void setConversation(String? conversationId, String recipientId) {
    currentConversationId = conversationId;
    currentRecipientId = recipientId;
    messages = [];
    _pendingMessages.clear();
    error = null;
  }

  // Tạo conversation mới và load messages
  Future<void> createAndLoadConversation(String recipientId) async {
    try {
      isLoading = true;
      notifyListeners();

      print('📞 Creating conversation for recipientId: $recipientId');

      // Tạo conversation
      final conversation = await createConversationUseCase(
        recipientId: recipientId,
      );

      print('✅ Conversation created: ${conversation.id}');

      // Set conversation ID
      currentConversationId = conversation.id;
      currentRecipientId = recipientId;

      print('💾 Saved conversationId: $currentConversationId');

      // Load messages (sẽ rỗng cho conversation mới)
      await loadMessages();

      error = null;
    } catch (e) {
      print('❌ Error creating conversation: $e');
      error = "Không thể tạo cuộc trò chuyện: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
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
      print('❌ ERROR: conversationId is NULL!');
      notifyListeners();
      return;
    }

    print('✅ Sending message with conversationId: $currentConversationId');
    print('📤 Content: $content');
    print('👤 RecipientId: $currentRecipientId');

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

      print('✅ Message sent successfully: ${sentMessage.id}');

      // Xóa tin nhắn tạm, thêm tin nhắn thật
      _pendingMessages.remove(tempMessage);
      messages.add(sentMessage);
      error = null;
    } catch (e) {
      print('❌ Error sending message: $e');
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
