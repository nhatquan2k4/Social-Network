import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/data/services/local_storage_service.dart';
import 'package:frontend/domain/entities/post_entity.dart';
import 'package:frontend/presentation/controllers/common/bottom_nav_route_controller.dart';
import 'package:frontend/presentation/providers/feed_provider.dart';
import 'package:frontend/presentation/widgets/common/bottom_nav.dart';
import 'package:frontend/presentation/widgets/common/empty_state.dart';
import 'package:frontend/presentation/widgets/common/error_display.dart';
import 'package:frontend/presentation/widgets/feed/feed_widgets.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/logger.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final LocalStorageService _localStorage = LocalStorageService();

  String? _currentUserId;
  int _currentIndex = 0;
  bool _isHandlingAuthExpiry = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCurrentUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final feedProvider = context.read<FeedProvider>();
      if (feedProvider.posts.isEmpty) {
        feedProvider.loadInitial();
      }
    });
  }

  Future<void> _loadCurrentUser() async {
    final token = await _localStorage.getToken();
    if (token == null) return;

    try {
      final decoded = JwtDecoder.decode(token);
      final rawUserId =
          decoded['userId'] ??
          decoded['_id'] ??
          decoded['id'] ??
          decoded['sub'];
      setState(() {
        _currentUserId = rawUserId?.toString();
      });
    } catch (e, stackTrace) {
      logger.e(
        'Cannot decode auth token: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 280) {
      context.read<FeedProvider>().loadMore();
    }
  }

  Future<void> _handleLike({
    required FeedProvider feedProvider,
    required String postId,
    required bool isCurrentlyLiked,
  }) async {
    await feedProvider.toggleLike(
      postId: postId,
      isCurrentlyLiked: isCurrentlyLiked,
    );

    if (!mounted) return;
    if (feedProvider.requiresAuth) return;

    final message = feedProvider.error;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      feedProvider.clearError();
    }
  }

  Future<void> _openCommentsSheet(PostEntity initialPost) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(
        initialPost: initialPost,
        currentUserId: _currentUserId,
      ),
    );
  }

  Future<void> _openCreatePostScreen() async {
    await Navigator.of(context).pushNamed(AppRoutes.postsCreate);
  }

  Future<void> _showPostOptionsSheet(PostEntity post) async {
    final l10n = context.l10n;

    final selectedAction = await showModalBottomSheet<_PostOptionAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      isScrollControlled: false,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 34,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2D2D6),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPostOptionsGroup(
                    children: [
                      _buildPostOptionTile(
                        icon: Icons.star_border,
                        label: l10n.postOptionAddToFavorites,
                        onTap: () => Navigator.pop(
                          sheetContext,
                          _PostOptionAction.addToFavorites,
                        ),
                      ),
                      _buildPostOptionTile(
                        icon: Icons.person_search_outlined,
                        label: l10n.postOptionAboutThisAccount,
                        onTap: () => Navigator.pop(
                          sheetContext,
                          _PostOptionAction.aboutAccount,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildPostOptionsGroup(
                    children: [
                      _buildPostOptionTile(
                        icon: Icons.visibility_off_outlined,
                        label: l10n.postOptionHidePost,
                        onTap: () => Navigator.pop(
                          sheetContext,
                          _PostOptionAction.hidePost,
                        ),
                      ),
                      _buildPostOptionTile(
                        icon: Icons.report_gmailerrorred_outlined,
                        label: l10n.postOptionReport,
                        labelColor: const Color(0xFFE53935),
                        iconColor: const Color(0xFFE53935),
                        onTap: () => Navigator.pop(
                          sheetContext,
                          _PostOptionAction.report,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || selectedAction == null) return;

    final feedProvider = context.read<FeedProvider>();
    final messenger = ScaffoldMessenger.of(context);

    switch (selectedAction) {
      case _PostOptionAction.addToFavorites:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.postOptionAddToFavoritesDone)),
        );
        break;
      case _PostOptionAction.aboutAccount:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.featureInDevelopment)),
        );
        break;
      case _PostOptionAction.hidePost:
        await feedProvider.hidePost(post.id);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.postOptionHidePostDone)),
        );
        break;
      case _PostOptionAction.report:
        final reportReason = await _showReportReasonSheet();
        if (!mounted || reportReason == null) return;

        final reasonKey = reportReason.name;
        await feedProvider.reportPost(
          postId: post.id,
          reason: reasonKey,
        );

        if (!mounted) return;
        final providerError = feedProvider.error;
        if (providerError != null && providerError.isNotEmpty) {
          messenger.showSnackBar(SnackBar(content: Text(providerError)));
          feedProvider.clearError();
          return;
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l10n.postOptionReportDoneWithReason(
                _reportReasonLabel(reportReason, l10n),
              ),
            ),
          ),
        );
        break;
    }
  }

  String _reportReasonLabel(_PostReportReason reason, dynamic l10n) {
    switch (reason) {
      case _PostReportReason.spam:
        return l10n.postReportReasonSpam;
      case _PostReportReason.harassment:
        return l10n.postReportReasonHarassment;
      case _PostReportReason.falseInfo:
        return l10n.postReportReasonFalseInfo;
      case _PostReportReason.hateSpeech:
        return l10n.postReportReasonHateSpeech;
      case _PostReportReason.violence:
        return l10n.postReportReasonViolence;
      case _PostReportReason.other:
        return l10n.postReportReasonOther;
    }
  }

  Future<_PostReportReason?> _showReportReasonSheet() async {
    final l10n = context.l10n;
    _PostReportReason? selectedReason;

    return showModalBottomSheet<_PostReportReason>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      isScrollControlled: false,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          width: 34,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD2D2D6),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.postReportTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.postReportSelectReason,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF66666B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._PostReportReason.values.map((reason) {
                        final isSelected = selectedReason == reason;

                        return InkWell(
                          onTap: () => setSheetState(() {
                            selectedReason = reason;
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  size: 20,
                                  color: isSelected
                                      ? const Color(0xFF1689F6)
                                      : const Color(0xFF96969B),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _reportReasonLabel(reason, l10n),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1A1A1F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(sheetContext),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(l10n.cancel),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: selectedReason == null
                                    ? null
                                    : () => Navigator.pop(
                                        sheetContext,
                                        selectedReason,
                                      ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE53935),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(l10n.postReportSubmit),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostOptionsGroup({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildPostOptionTile({
    required IconData icon,
    required String label,
    Color labelColor = const Color(0xFF111111),
    Color iconColor = const Color(0xFF111111),
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 17, color: iconColor),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 22 / 1.8,
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.add_box_outlined,
            color: Colors.black,
            size: 22,
          ),
          onPressed: _openCreatePostScreen,
        ),
        title: Image.asset(
          'assets/images/logo.jpg',
          height: 36,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) {
            return const Text(
              'Mochi',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            );
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.black,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.feedNotificationSoon)),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(height: 0.8, color: Colors.grey.shade200),
        ),
      ),
      body: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: Consumer<FeedProvider>(
          builder: (consumerContext, feedProvider, _) {
            final visiblePosts = feedProvider.visiblePosts;

            if (feedProvider.requiresAuth && !_isHandlingAuthExpiry) {
              _isHandlingAuthExpiry = true;

              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) return;

                await _localStorage.clearToken();

                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text(l10n.sessionExpiredRelogin)),
                );

                Navigator.of(
                  this.context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              });
            }

            if (feedProvider.isLoadingInitial && visiblePosts.isEmpty) {
              return const FeedSkeletonList(itemCount: 2);
            }

            if (feedProvider.error != null && visiblePosts.isEmpty) {
              return ErrorDisplay(
                message: feedProvider.error!,
                onRetry: () => feedProvider.loadInitial(),
              );
            }

            if (visiblePosts.isEmpty) {
              return EmptyState(
                message: l10n.postOptionAllHiddenTitle,
                description: l10n.postOptionAllHiddenDescription,
                icon: Icons.photo_library_outlined,
              );
            }

            return RefreshIndicator(
              onRefresh: () => feedProvider.refresh(),
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                itemCount:
                    visiblePosts.length +
                    (feedProvider.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= visiblePosts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final post = visiblePosts[index];
                  final isLikedByMe =
                      _currentUserId != null &&
                      post.likes.contains(_currentUserId);

                  return PostCard(
                    post: post,
                    isLikedByMe: isLikedByMe,
                    onLike: () => _handleLike(
                      feedProvider: feedProvider,
                      postId: post.id,
                      isCurrentlyLiked: isLikedByMe,
                    ),
                    onComment: () => _openCommentsSheet(post),
                    onViewComments: () => _openCommentsSheet(post),
                    onShare: () {
                      ScaffoldMessenger.of(consumerContext).showSnackBar(
                        SnackBar(content: Text(l10n.shareSoon)),
                      );
                    },
                    onSave: () {
                      ScaffoldMessenger.of(consumerContext).showSnackBar(
                        SnackBar(content: Text(l10n.saveSoon)),
                      );
                    },
                    onMore: () => _showPostOptionsSheet(post),
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: BottomNav(
          currentIndex: _currentIndex,
          onTap: (index) => BottomNavRouteController.handleTabSelection(
            context: context,
            currentIndex: _currentIndex,
            nextIndex: index,
            onIndexChanged: (next) => setState(() => _currentIndex = next),
            onUnsupportedDestination: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.pageNotImplemented)),
              );
            },
          ),
        ),
      ),
    );
  }
}

enum _PostOptionAction {
  addToFavorites,
  aboutAccount,
  hidePost,
  report,
}

enum _PostReportReason {
  spam,
  harassment,
  falseInfo,
  hateSpeech,
  violence,
  other,
}
