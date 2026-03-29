import 'package:flutter/material.dart';

class ProfileMediaPickerScreen extends StatefulWidget {
  const ProfileMediaPickerScreen({super.key});

  @override
  State<ProfileMediaPickerScreen> createState() =>
      _ProfileMediaPickerScreenState();
}

class _ProfileMediaPickerScreenState extends State<ProfileMediaPickerScreen> {
  int _selectedIndex = 0;

  static const List<String> _mediaUrls = [
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=1200',
    'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=1200',
    'https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?w=1200',
    'https://images.unsplash.com/photo-1545912452-8aea7e25a3d3?w=1200',
    'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?w=1200',
    'https://images.unsplash.com/photo-1521119989659-a83eee488004?w=1200',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=1200',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=1200',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=1200',
    'https://images.unsplash.com/photo-1511988617509-a57c8a288659?w=1200',
    'https://images.unsplash.com/photo-1481214110143-ed630356e1bb?w=1200',
    'https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?w=1200',
  ];

  @override
  Widget build(BuildContext context) {
    final selectedUrl = _mediaUrls[_selectedIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leadingWidth: 70,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Thư viện', style: TextStyle(fontWeight: FontWeight.w700)),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã chọn ảnh, sẵn sàng bước tiếp.'),
                ),
              );
            },
            child: const Text('Tiếp'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            height: 230,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              selectedUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white70,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(left: 2, right: 2, bottom: 8),
              itemCount: _mediaUrls.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedIndex;

                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        _mediaUrls[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                      if (isSelected)
                        Container(color: Colors.black.withValues(alpha: 0.25)),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF0095F6)
                                : Colors.black.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.2),
                          ),
                          child: Icon(
                            isSelected ? Icons.check : Icons.circle,
                            size: 12,
                            color: Colors.white,
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
