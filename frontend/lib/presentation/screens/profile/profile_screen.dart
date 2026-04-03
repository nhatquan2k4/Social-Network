import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/domain/entities/profile_entity.dart';
import 'package:frontend/presentation/controllers/common/bottom_nav_route_controller.dart';
import 'package:frontend/presentation/providers/feed_provider.dart';
import 'package:frontend/presentation/providers/profile_provider.dart';
import 'package:frontend/presentation/screens/profile/edit_profile_screen.dart';
import 'package:frontend/presentation/screens/profile/profile_media_picker_screen.dart';
import 'package:frontend/presentation/widgets/common/bottom_nav.dart';
import 'package:frontend/presentation/widgets/common/error_display.dart';
import 'package:frontend/presentation/widgets/common/loading_indicator.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 3;
  int _selectedTab = 0;
  bool _showLinkCopiedBanner = false;

  static const int _postCount = 9;
  static const int _followerCount = 18;
  static const int _followingCount = 36;

  static const List<String> _mockPosts = [
    'https://images.unsplash.com/photo-1464863979621-258859e62245?w=1000',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=1000',
    'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=1000',
    'https://images.unsplash.com/photo-1519699047748-de8e457a634e?w=1000',
    'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=1000',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=1000',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=900',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=900',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=900',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ProfileProvider>().fetchProfile('me');
      context.read<FeedProvider>().ensureLocalStateLoaded();
    });
  }

  Future<void> _refresh() {
    return context.read<ProfileProvider>().fetchProfile('me');
  }

  Future<void> _openEditProfile(ProfileEntity profile) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(initialProfile: profile),
      ),
    );
  }

  Future<void> _openMediaPicker() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileMediaPickerScreen()),
    );
  }

  void _showCopiedLinkBanner() {
    if (!mounted) return;

    setState(() {
      _showLinkCopiedBanner = true;
    });

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        _showLinkCopiedBanner = false;
      });
    });
  }

  Future<void> _showAccountSwitchSheet(ProfileEntity profile) async {
    final l10n = context.l10n;
    String selected = profile.username;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerContext, setInnerState) {
            Widget accountTile(String displayName, String username) {
              final isSelected = selected == username;
              return InkWell(
                onTap: () => setInnerState(() => selected = username),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey.shade300,
                        child: Text(
                          displayName.isEmpty
                              ? '?'
                              : displayName[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '@$username',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? const Color(0xFF0095F6)
                            : Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      l10n.profileChooseAccount,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    accountTile(profile.displayName, profile.username),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.pop(innerContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.profileAccountSwitched),
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0095F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(l10n.done),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.addAccountSoon),
                          ),
                        );
                      },
                      child: Text(l10n.addAccount),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showProfileActionsSheet(ProfileEntity profile) async {
    final l10n = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.settings_outlined),
                  title: Text(l10n.settingsAndActivity),
                  onTap: () => Navigator.pop(sheetContext),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.archive_outlined),
                  title: Text(l10n.archive),
                  onTap: () => Navigator.pop(sheetContext),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: Text(l10n.switchToProfessionalAccount),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.featureInDevelopment)),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.business_center_outlined),
                  title: Text(l10n.switchToBusinessAccount),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.featureInDevelopment)),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.swap_horiz),
                  title: Text(l10n.switchAccount),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showAccountSwitchSheet(profile);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(ProfileEntity profile) {
    final avatarUrl = profile.avatarUrl;

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Container(
        width: 78,
        height: 78,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: CircleAvatar(
          radius: 38,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: NetworkImage(avatarUrl),
        ),
      );
    }

    return Container(
      width: 78,
      height: 78,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: CircleAvatar(
        radius: 38,
        backgroundColor: Colors.grey.shade300,
        child: Text(
          profile.displayName.isEmpty
              ? '?'
              : profile.displayName[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildPostImage(String url) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.grey.shade200,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Icon(
            Icons.content_copy_rounded,
            size: 14,
            color: Colors.white.withValues(alpha: 0.95),
          ),
        ),
      ],
    );
  }

  Widget _buildTopCount({required String value, required String label}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileActionButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: SizedBox(
        height: 34,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEFEFEF),
            foregroundColor: Colors.black,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          child: FittedBox(child: Text(label)),
        ),
      ),
    );
  }

  Widget _buildHighlightItem({
    required Widget child,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: child,
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTabHeader() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () => setState(() => _selectedTab = 0),
                icon: Icon(
                  Icons.grid_on,
                  color: _selectedTab == 0
                      ? Colors.black
                      : Colors.grey.shade500,
                ),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () => setState(() => _selectedTab = 1),
                icon: Icon(
                  Icons.person_pin_outlined,
                  color: _selectedTab == 1
                      ? Colors.black
                      : Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 2,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  color: _selectedTab == 0 ? Colors.black : Colors.transparent,
                ),
              ),
              Expanded(
                child: Container(
                  color: _selectedTab == 1 ? Colors.black : Colors.transparent,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey.shade300),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final syncedFollowingCount = context.select<FeedProvider, int>(
      (provider) => provider.followingAuthorsCount,
    );

    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;

        if (provider.isLoading && profile == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: LoadingIndicator(message: l10n.loadingProfileInfo),
          );
        }

        if (provider.error != null && profile == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: ErrorDisplay(message: provider.error!, onRetry: _refresh),
          );
        }

        if (profile == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text(l10n.noProfileData, style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 13, color: Colors.black),
                const SizedBox(width: 4),
                Text(
                  profile.username,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: Colors.black,
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => _showProfileActionsSheet(profile),
                icon: const Icon(Icons.menu, color: Colors.black, size: 24),
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  if (provider.isSaving)
                    const LinearProgressIndicator(
                      minHeight: 2,
                      color: Color(0xFF0095F6),
                    ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                        children: [
                          Row(
                            children: [
                              _buildAvatar(profile),
                              const SizedBox(width: 18),
                              _buildTopCount(
                                value: '$_postCount',
                                label: l10n.postsLabel,
                              ),
                              _buildTopCount(
                                value: '$_followerCount',
                                label: l10n.followersLabel,
                              ),
                              _buildTopCount(
                                value: '${_followingCount + syncedFollowingCount}',
                                label: l10n.followingLabel,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            profile.displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            (profile.bio ?? '').isNotEmpty
                                ? profile.bio!
                                : 'Sẽ có những con cá sẽ phải trả gió???',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildProfileActionButton(
                                label: l10n.editAction,
                                onPressed: () => _openEditProfile(profile),
                              ),
                              const SizedBox(width: 8),
                              _buildProfileActionButton(
                                label: l10n.shareProfileAction,
                                onPressed: _showCopiedLinkBanner,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildHighlightItem(
                                label: l10n.newLabel,
                                onTap: _openMediaPicker,
                                child: const Center(
                                  child: Icon(
                                    Icons.add,
                                    size: 30,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              _buildHighlightItem(
                                label: l10n.myLoveLabel,
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: ClipOval(
                                    child: Image.network(
                                      _mockPosts.first,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              color: Colors.grey.shade300,
                                              child: const Icon(Icons.person),
                                            );
                                          },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildTabHeader(),
                          if (_selectedTab == 0)
                            GridView.builder(
                              itemCount: _mockPosts.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 1,
                                    mainAxisSpacing: 1,
                                  ),
                              itemBuilder: (context, index) {
                                return _buildPostImage(_mockPosts[index]);
                              },
                            )
                          else
                            SizedBox(
                              height: 170,
                              child: Center(
                                child: Text(
                                  l10n.taggedPostsEmpty,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                top: _showLinkCopiedBanner ? 10 : -56,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8AC8B8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l10n.linkCopied,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNav(
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
        );
      },
    );
  }
}
