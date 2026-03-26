import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/bottom_nav.dart';
import 'package:frontend/presentation/widgets/common/error_display.dart';
import 'package:frontend/presentation/widgets/common/loading_indicator.dart';
// import 'package:provider/provider.dart'; // ← COMMENTED: Provider approach

import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/domain/entities/profile_entity.dart';
import 'package:frontend/domain/usecases/profile_usecase.dart';
import 'package:frontend/domain/repositories/profile_repository.dart';
import 'package:frontend/data/repositories/profile_repository_impl.dart';
import 'package:frontend/data/services/api_service.dart';

// import '../../providers/profile_provider.dart'; // ← COMMENTED: Provider

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4;
  late Future<ProfileEntity> _profileFuture;

  //PROVIDER
  // @override
  // void initState() {
  //   super.initState();
  //
  //   Future.microtask(() async {
  //     if (!mounted) return;
  //     await context.read<ProfileProvider>().fetchProfile('me');
  //   });
  // }
  //END PROVIDER
  //FUTUREBUILDER
  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchProfile();
  }

  Future<ProfileEntity> _fetchProfile() async {
    final apiService = ApiService();
    final ProfileRepository repository = ProfileRepositoryImpl(apiService);
    final getProfileUseCase = GetProfileUseCase(repository);
    return await getProfileUseCase('me');
  }

  Future<void> _refresh() async {
    setState(() {
      _profileFuture = _fetchProfile();
    });
  }
  //END FUTUREBUILDER

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Trang cá nhân',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      //PROVIDER
      // body: Consumer<ProfileProvider>(
      //   builder: (context, provider, _) {
      //     if (provider.isLoading) {
      //       return const LoadingIndicator(message: 'Đang tải thông tin...');
      //     }
      //
      //     if (provider.error != null) {
      //       return ErrorDisplay(
      //         message: provider.error!,
      //         onRetry: () => provider.fetchProfile('me'),
      //       );
      //     }
      //
      //     final profile = provider.profile;
      //     if (profile == null) {
      //       return const Center(
      //         child: Text(
      //           'Chưa có dữ liệu hồ sơ.',
      //           style: TextStyle(color: Colors.grey),
      //         ),
      //       );
      //     }
      //
      //     return SingleChildScrollView(
      //       padding: const EdgeInsets.all(16),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         children: [
      //           const SizedBox(width: double.infinity),
      //           CircleAvatar(
      //             radius: 44,
      //             backgroundColor: Colors.blue,
      //             child: Text(
      //               profile.displayName.isNotEmpty
      //                   ? profile.displayName[0].toUpperCase()
      //                   : '?',
      //               style: const TextStyle(
      //                 color: Colors.white,
      //                 fontSize: 28,
      //                 fontWeight: FontWeight.bold,
      //               ),
      //             ),
      //           ),
      //           const SizedBox(height: 12),
      //           Text(
      //             profile.displayName,
      //             style: const TextStyle(
      //               fontSize: 20,
      //               fontWeight: FontWeight.w700,
      //               color: Colors.black,
      //             ),
      //           ),
      //           const SizedBox(height: 4),
      //           Text(
      //             profile.email,
      //             style: const TextStyle(fontSize: 14, color: Colors.grey),
      //           ),
      //         ],
      //       ),
      //     );
      //   },
      // ),
      //END PROVIDER

      //FUTUREBUILDER
      body: FutureBuilder<ProfileEntity>(
        future: _profileFuture,
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Đang tải thông tin...');
          }

          // Error state
          if (snapshot.hasError) {
            return ErrorDisplay(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          // No data state
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Chưa có dữ liệu hồ sơ.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          // Success state
          final profile = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // ← Allow pull-to-refresh even when content is short
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: double.infinity),
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.blue,
                    child: Text(
                      profile.displayName.isNotEmpty
                          ? profile.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.displayName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.email,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      //END FUTUREBUILDER
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;

          setState(() => _currentIndex = index);

          if (index == 3) {
            Navigator.pushReplacementNamed(context, AppRoutes.messages);
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, AppRoutes.profile);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Trang này chưa được triển khai.')),
            );
          }
        },
      ),
    );
  }
}
