import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/custom_button.dart';
import 'package:frontend/presentation/screens/auth/otp_verification_screen.dart';

class FogotScreen extends StatefulWidget {
  const FogotScreen({super.key});

  @override
  State<FogotScreen> createState() => _FogotScreenState();
}

class _FogotScreenState extends State<FogotScreen> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Quên mật khẩu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Nhập email liên kết với tài khoản để được gửi mã đặt lại mật khẩu của bạn',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: _inputDecoration('Nhập email'),
              ),
              const SizedBox(height: 16),
              CustomButton(
                label: 'Gửi mã xác nhận',
                onPressed: () {
                  final text = _emailController.text.trim();
                  if (text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập email')),
                    );
                    return;
                  }
                  // TODO: trigger send code
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OtpVerificationScreen(
                        email: text,
                        purpose: OtpPurpose.reset,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
