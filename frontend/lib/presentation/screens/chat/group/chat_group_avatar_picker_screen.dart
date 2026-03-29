import 'package:flutter/material.dart';

class ChatGroupAvatarPickerScreen extends StatefulWidget {
  final List<String> avatarAssets;
  final String? selectedAsset;

  const ChatGroupAvatarPickerScreen({
    super.key,
    required this.avatarAssets,
    this.selectedAsset,
  });

  @override
  State<ChatGroupAvatarPickerScreen> createState() =>
      _ChatGroupAvatarPickerScreenState();
}

class _ChatGroupAvatarPickerScreenState
    extends State<ChatGroupAvatarPickerScreen> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedAsset ?? widget.avatarAssets.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F4),
        elevation: 0,
        title: const Text(
          'Thư viện',
          style: TextStyle(
            color: Color(0xFF1F1F23),
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Hủy',
            style: TextStyle(
              color: Color(0xFF1689F6),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        leadingWidth: 70,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selected),
            child: const Text(
              'Xong',
              style: TextStyle(
                color: Color(0xFF1689F6),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Image.asset(_selected, fit: BoxFit.cover),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(top: 2),
              itemCount: widget.avatarAssets.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemBuilder: (context, index) {
                final asset = widget.avatarAssets[index];
                final isSelected = asset == _selected;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selected = asset;
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(asset, fit: BoxFit.cover),
                      if (isSelected)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF1689F6),
                              width: 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
