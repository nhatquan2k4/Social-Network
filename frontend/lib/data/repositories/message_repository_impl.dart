import '../../core/constants/api_constants.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/message_repository.dart';
import '../models/message/message_model.dart';
import '../mappers/message_mapper.dart';
import '../services/api_service.dart';

class MessageRepositoryImpl implements MessageRepository {
  final ApiService apiService;

  MessageRepositoryImpl(this.apiService);

  @override
  Future<List<MessageEntity>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await apiService.get(
        '/conversations/$conversationId/messages',
        queryParameters: {'limit': limit},
      );

      if (response.data['messages'] != null) {
        final List<dynamic> messagesJson = response.data['messages'];
        final List<MessageModel> models = messagesJson
            .map((json) => MessageModel.fromJson(json))
            .toList();
        return MessageMapper.toEntityList(models);
      }
      return [];
    } catch (e) {
      throw Exception('Không thể tải tin nhắn: $e');
    }
  }

  @override
  Future<MessageEntity> sendMessage(
    String recipientId,
    String content, {
    String? conversationId,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'recipientId': recipientId,
        'content': content,
      };

      if (conversationId != null) {
        requestData['conversationId'] = conversationId;
      }

      print('📤 Sending message to API:');
      print('   recipientId: $recipientId');
      print('   content: $content');
      print('   conversationId: $conversationId');
      print('   requestData: $requestData');

      final response = await apiService.post(
        ApiConstants.messages,
        requestData,
      );

      print('✅ API Response: ${response.data}');

      final MessageModel model = MessageModel.fromJson(response.data['data']);
      return MessageMapper.toEntity(model);
    } catch (e) {
      print('❌ Error in sendMessage: $e');
      throw Exception('Không thể gửi tin nhắn: $e');
    }
  }
}
