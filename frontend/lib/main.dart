import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/routes/app_routes.dart';

import 'package:frontend/presentation/screens/auth/login_screen.dart';
import 'package:frontend/presentation/screens/auth/welcome_screen.dart';
import 'package:frontend/presentation/screens/feed/create_post_screen.dart';
import 'package:frontend/presentation/screens/feed/feed_screen.dart';
import 'package:frontend/presentation/screens/chat/messages_screen.dart';
import 'package:frontend/presentation/screens/auth/register_screen.dart';
import 'package:frontend/presentation/screens/auth/fogot_screen.dart';
import 'package:frontend/presentation/screens/profile/profile_screen.dart';

import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/data/repositories/auth_repository_impl.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/data/services/local_storage_service.dart';
import 'package:frontend/domain/usecases/login_usecase.dart';
import 'package:frontend/domain/usecases/register_usecase.dart';

import 'package:frontend/presentation/providers/friend_provider.dart';
import 'package:frontend/domain/usecases/friend_usecase.dart';
import 'package:frontend/data/repositories/friend_repository_impl.dart';

import 'package:frontend/presentation/providers/chat_provider.dart';
import 'package:frontend/domain/usecases/message_usecase.dart';
import 'package:frontend/domain/usecases/conversation_usecase.dart';
import 'package:frontend/data/repositories/message_repository_impl.dart';
import 'package:frontend/data/repositories/conversation_repository_impl.dart';

import 'package:frontend/domain/usecases/profile_usecase.dart';
import 'package:frontend/presentation/providers/profile_provider.dart';
import 'package:frontend/data/repositories/profile_repository_impl.dart';
import 'package:frontend/domain/usecases/post_usecase.dart';
import 'package:frontend/data/repositories/post_repository_impl.dart';
import 'package:frontend/presentation/providers/feed_provider.dart';

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
          create: (_) => AuthProvider(
            LoginUseCase(AuthRepositoryImpl(apiService, localStorageService)),
            RegisterUseCase(
              AuthRepositoryImpl(apiService, localStorageService),
            ),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => MessagesProvider(
            GetFriendsUseCase(FriendRepositoryImpl(apiService)),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            GetProfileUseCase(ProfileRepositoryImpl(apiService)),
            UpdateMyAvatarUseCase(ProfileRepositoryImpl(apiService)),
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

        ChangeNotifierProvider(
          create: (_) =>
              FeedProvider(PostUsecase(PostRepositoryImpl(apiService))),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.welcome,
        routes: {
          AppRoutes.welcome: (context) => const WelcomeScreen(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.fogot: (context) => const FogotScreen(),
          AppRoutes.postsFeed: (context) => const FeedScreen(),
          AppRoutes.postsCreate: (context) => const CreatePostScreen(),
          AppRoutes.messages: (context) => const MessagesScreen(),
          AppRoutes.profile: (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
