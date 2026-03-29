import 'dart:io';

import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/profile_entity.dart';
import 'package:frontend/presentation/providers/profile_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  final ProfileEntity initialProfile;

  const EditProfileScreen({super.key, required this.initialProfile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _linkController;
  late final TextEditingController _bioController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _genderController;

  bool _isPrivateAccount = false;
  String? _localAvatarPath;

  @override
  void initState() {
    super.initState();
    // Keep sample values in the edit form for frontend-only profile design.
    _nameController = TextEditingController(text: 'Hoàng Tú');
    _usernameController = TextEditingController(text: 'hoangtu_1');
    _linkController = TextEditingController(text: 'Thêm liên kết');
    _bioController = TextEditingController(
      text: 'Sẽ có những con cá sẽ phải trả giá gì ???',
    );
    _emailController = TextEditingController(text: 'hoangtu@gmail.com');
    _phoneController = TextEditingController(text: '0123456789');
    _genderController = TextEditingController(text: 'Nam');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _linkController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _genderController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (file == null || !mounted) return;

    setState(() {
      _localAvatarPath = file.path;
    });

    final provider = context.read<ProfileProvider>();
    final success = await provider.updateAvatar(file.path);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật ảnh đại diện.')),
      );
      return;
    }

    setState(() {
      _localAvatarPath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.error ?? 'Không thể cập nhật ảnh đại diện.'),
      ),
    );
  }

  void _saveProfileLocally() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ProfileProvider>().applyLocalProfileEdits(
      displayName: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      bio: _bioController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu thông tin trang cá nhân (lưu cục bộ).'),
      ),
    );

    Navigator.pop(context, true);
  }

  Widget _buildFlatFieldRow({
    required String label,
    required TextEditingController controller,
    bool isPlaceholder = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 42),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 86,
            child: Padding(
              padding: EdgeInsets.only(top: maxLines > 1 ? 10 : 0),
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              readOnly: readOnly,
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              maxLines: maxLines,
              style: TextStyle(
                fontSize: 12,
                color: isPlaceholder ? Colors.grey.shade500 : Colors.black87,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDivider() {
    return Divider(height: 1, color: Colors.grey.shade300);
  }

  Widget _buildAvatar(ProfileEntity profile, bool isSaving) {
    if (_localAvatarPath != null) {
      return CircleAvatar(
        radius: 36,
        backgroundImage: FileImage(File(_localAvatarPath!)),
      );
    }

    final avatarUrl = profile.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 36,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    return CircleAvatar(
      radius: 26,
      backgroundColor: Colors.grey.shade300,
      child: Icon(Icons.person, size: 34, color: Colors.grey.shade50),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile ?? widget.initialProfile;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.chevron_left, color: Colors.black),
            ),
            title: const Text(
              'Chỉnh sửa trang cá nhân',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: provider.isSaving ? null : _saveProfileLocally,
                child: const Text(
                  'Xong',
                  style: TextStyle(fontSize: 12, color: Color(0xFF0095F6)),
                ),
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (provider.isSaving)
                    const LinearProgressIndicator(
                      minHeight: 2,
                      color: Color(0xFF0095F6),
                    ),
                  const SizedBox(height: 4),
                  Center(
                    child: Column(
                      children: [
                        _buildAvatar(profile, provider.isSaving),
                        TextButton(
                          onPressed: provider.isSaving
                              ? null
                              : _pickAndUploadAvatar,
                          child: const Text(
                            'Chỉnh sửa ảnh hoặc avatar',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFF0095F6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildFlatFieldRow(
                    label: 'Tên',
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên hiển thị';
                      }
                      return null;
                    },
                  ),
                  _buildRowDivider(),
                  _buildFlatFieldRow(
                    label: 'Tên người dùng',
                    controller: _usernameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên người dùng';
                      }
                      return null;
                    },
                  ),
                  _buildRowDivider(),
                  _buildFlatFieldRow(
                    label: 'Liên kết',
                    controller: _linkController,
                    isPlaceholder: true,
                  ),
                  _buildRowDivider(),
                  _buildFlatFieldRow(
                    label: 'Tiểu sử',
                    controller: _bioController,
                    maxLines: 2,
                  ),
                  _buildRowDivider(),
                  Container(
                    height: 44,
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Tài khoản riêng tư',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: _isPrivateAccount,
                          activeColor: const Color(0xFF34C759),
                          onChanged: provider.isSaving
                              ? null
                              : (value) {
                                  setState(() => _isPrivateAccount = value);
                                },
                        ),
                      ],
                    ),
                  ),
                  _buildRowDivider(),
                  const SizedBox(height: 10),
                  const Text(
                    'Thông tin cá nhân',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  _buildFlatFieldRow(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!value.contains('@')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  _buildRowDivider(),
                  _buildFlatFieldRow(
                    label: 'Điện thoại',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildRowDivider(),
                  _buildFlatFieldRow(
                    label: 'Giới tính',
                    controller: _genderController,
                  ),
                  _buildRowDivider(),
                  const SizedBox(height: 10),
                  Text(
                    'Dữ liệu form đang dùng mẫu UI cho phần frontend.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
