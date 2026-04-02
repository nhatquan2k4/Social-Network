import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/common/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
// import 'package:frontend/presentation/screens/auth/otp_verification_screen.dart';
import 'package:frontend/core/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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

              // Logo
              Image.asset('assets/images/logo.jpg', height: 120, width: 220),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _firstNameController,
                      decoration: _inputDecoration('Tên'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      decoration: _inputDecoration('Họ'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                decoration: _inputDecoration('Tên người dùng'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('Nhập email'),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration('Nhập mật khẩu').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: _confirmController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration('Nhập lại mật khẩu').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    color: Colors.black,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              CustomButton(
                label: 'Đăng ký',
                onPressed: () async {
                  final firstName = _firstNameController.text.trim();
                  final lastName = _lastNameController.text.trim();
                  final username = _usernameController.text.trim();
                  final email = _emailController.text.trim();
                  final password = _passwordController.text;
                  final confirm = _confirmController.text;

                  if (firstName.isEmpty || lastName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vui lòng nhập họ và tên')),
                    );
                    return;
                  }

                  if (username.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng nhập tên người dùng'),
                      ),
                    );
                    return;
                  }

                  if (email.isEmpty || !email.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng nhập email hợp lệ'),
                      ),
                    );
                    return;
                  }

                  if (password.length < 6 || password != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mật khẩu quá ngắn hoặc không khớp'),
                      ),
                    );
                    return;
                  }

                  // Show loading dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                  );

                  // Call register usecase via provider
                  final success = await context.read<AuthProvider>().register(
                    username,
                    password,
                    email,
                    firstName,
                    lastName,
                  );

                  if (!context.mounted) return;
                  Navigator.of(context).pop(); // close loading

                  if (success) {
                    // Registration succeeded — show success and clear form
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đăng ký thành công')),
                    );
                    _firstNameController.clear();
                    _lastNameController.clear();
                    _usernameController.clear();
                    _emailController.clear();
                    _passwordController.clear();
                    _confirmController.clear();
                  } else {
                    final err =
                        context.read<AuthProvider>().errorMessage ??
                        'Đăng ký thất bại';
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(err)));
                  }
                },
              ),

              const SizedBox(height: 12),

              Center(
                child: Text('hoặc', style: TextStyle(color: Colors.grey)),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {},
                icon: Image.asset(
                  'assets/images/google.png',
                  height: 24,
                  width: 24,
                ),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Đăng nhập với Google',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 18),

              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.login),
                  child: RichText(
                    text: TextSpan(
                      text: 'Tôi đã có tài khoản rồi. ',
                      style: const TextStyle(color: Colors.black54),
                      children: const [
                        TextSpan(
                          text: 'Đăng nhập',
                          style: TextStyle(
                            color: Color(0xFF3797EF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
