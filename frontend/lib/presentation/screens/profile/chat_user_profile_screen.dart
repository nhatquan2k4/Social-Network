import 'package:flutter/material.dart';

class ChatUserProfileScreen extends StatelessWidget {
  final String displayName;
  final String avatarAssetPath;
  final Color avatarColor;

  const ChatUserProfileScreen({
    super.key,
    required this.displayName,
    this.avatarAssetPath = 'assets/images/logo1.jpg',
    this.avatarColor = const Color(0xFF7A6256),
  });

  static const _actions = <_ProfileActionItem>[
    _ProfileActionItem(icon: Icons.person_outline, label: 'Trang cá nhân'),
    _ProfileActionItem(icon: Icons.search, label: 'Tìm kiếm'),
    _ProfileActionItem(icon: Icons.notifications_none, label: 'Tắt'),
    _ProfileActionItem(icon: Icons.more_horiz, label: 'Lựa chọn'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 17),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 6),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  padding: const EdgeInsets.all(1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFCCCCD1)),
                  ),
                  child: CircleAvatar(
                    backgroundColor: avatarColor,
                    foregroundImage: AssetImage(avatarAssetPath),
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222225),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: _actions
                    .map(
                      (item) => Expanded(
                        child: Column(
                          children: [
                            Icon(
                              item.icon,
                              size: 21,
                              color: const Color(0xFF1D1D21),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF3A3A3F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFD8D8DD)),
              _optionTile(icon: Icons.edit_outlined, label: 'Biệt danh'),
              _optionTile(
                icon: Icons.group_add_outlined,
                label: 'Tạo nhóm chat',
              ),
              const SizedBox(height: 6),
              const Text(
                'Ảnh và Video',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF242428),
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 16,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final tile = ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Image.asset(
                      'assets/images/logo1.jpg',
                      fit: BoxFit.cover,
                    ),
                  );

                  if (index == 11) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        tile,
                        Container(color: Colors.black.withValues(alpha: 0.34)),
                        const Center(
                          child: Text(
                            '+23',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return tile;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionTile({required IconData icon, required String label}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, size: 18, color: const Color(0xFF222225)),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F1F23),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF86868C),
        size: 20,
      ),
      onTap: () {},
    );
  }
}

class _ProfileActionItem {
  final IconData icon;
  final String label;

  const _ProfileActionItem({required this.icon, required this.label});
}
