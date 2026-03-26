import '../../core/constants/api_constants.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/repositories/conversation_repository.dart';
import '../models/conversation/conversation_model.dart';
import '../mappers/conversation_mapper.dart';
import '../services/api_service.dart';
import '../../core/utils/logger.dart';

class ConversationRepositoryImpl implements ConversationRepository {
  final ApiService apiService;

  ConversationRepositoryImpl(this.apiService);

  @override
  Future<ConversationEntity> createConversation({
    required String recipientId,
    String type = 'direct',
  }) async {
    try {
      final response = await apiService.post(ApiConstants.conversations, {
        'type': type,
        'recipientId': recipientId,
      });

      logger.i("Raw API Response: ${response.data}");
      logger.d(
        'Conversation data: ${response.data[ApiConstants.conversations]}',
      );

      final ConversationModel model = ConversationModel.fromJson(
        response.data[ApiConstants.conversations],
      );
      return ConversationMapper.toEntity(model);
    } catch (e, stackTrace) {
      logger.e('Create conversation failed', error: e, stackTrace: stackTrace);
      throw Exception('Không thể tạo conversation: $e');
    }
  }

  @override
  Future<List<ConversationEntity>> getConversations() async {
    try {
      final response = await apiService.get(ApiConstants.conversations);

      if (response.data['data'] != null) {
        final List<dynamic> conversationsJson = response.data['data'];
        final List<ConversationModel> models = conversationsJson
            .map((json) => ConversationModel.fromJson(json))
            .toList();
        return ConversationMapper.toEntityList(models);
      }
      return [];
    } catch (e) {
      throw Exception('Không thể tải conversations: $e');
    }
  }
}
