import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/core/routes/app_router.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/routes/app_routes.dart';

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
            getConversationsUseCase: GetConversationsUseCase(
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
        locale: const Locale('vi'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: AppRoutes.welcome,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
