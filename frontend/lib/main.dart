import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/routes/app_routes.dart';

import 'package:frontend/presentation/screens/auth/login_screen.dart';
import 'package:frontend/presentation/screens/friends/friends_screen.dart';

import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/data/repositories/auth_repository_impl.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/data/services/local_storage_service.dart';
import 'package:frontend/domain/usecases/login_usecase.dart';

import 'package:frontend/presentation/providers/messages_provider.dart';
import 'package:frontend/domain/usecases/friend_usecase.dart';
import 'package:frontend/data/repositories/friend_repository_impl.dart';

import 'package:frontend/presentation/providers/chat_provider.dart';
import 'package:frontend/domain/usecases/message_usecase.dart';
import 'package:frontend/domain/usecases/conversation_usecase.dart';
import 'package:frontend/data/repositories/message_repository_impl.dart';
import 'package:frontend/data/repositories/conversation_repository_impl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    final localStorageService = LocalStorageService();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MessagesProvider(
            GetFriendsUseCase(FriendRepositoryImpl(apiService)),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            LoginUseCase(AuthRepositoryImpl(apiService, localStorageService)),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            getMessagesUseCase: GetMessagesUseCase(
              MessageRepositoryImpl(apiService),
            ),
            sendMessageUseCase: SendMessageUseCase(
              MessageRepositoryImpl(apiService),
            ),
            createConversationUseCase: CreateConversationUseCase(
              ConversationRepositoryImpl(apiService),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.messages: (context) => const MessagesScreen(),
        },
      ),
    );
  }
}
