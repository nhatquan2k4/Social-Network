import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/presentation/widgets/common/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/providers/auth_provider.dart';
import 'package:frontend/presentation/controllers/auth/register_form_controller.dart';
// import 'package:frontend/presentation/screens/auth/otp_verification_screen.dart';
import 'package:frontend/core/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterFormController _registerFormController = RegisterFormController();
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
    final l10n = context.l10n;

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
                      decoration: _inputDecoration(l10n.firstNameHint),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _lastNameController,
                      decoration: _inputDecoration(l10n.lastNameHint),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                decoration: _inputDecoration(l10n.usernameHint),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(l10n.enterEmailHint),
              ),
              const SizedBox(height: 10),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: _inputDecoration(l10n.loginPasswordHint).copyWith(
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
                decoration: _inputDecoration(l10n.reenterPasswordHint).copyWith(
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
                label: l10n.register,
                onPressed: () async {
                  final authProvider = context.read<AuthProvider>();
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  final input = RegisterInput(
                    firstName: _firstNameController.text.trim(),
                    lastName: _lastNameController.text.trim(),
                    username: _usernameController.text.trim(),
                    email: _emailController.text.trim(),
                    password: _passwordController.text,
                    confirmPassword: _confirmController.text,
                  );

                  final validationError = _registerFormController.validate(input);
                  if (validationError != null) {
                    final message = switch (validationError) {
                      RegisterValidationError.missingFullName =>
                        l10n.pleaseEnterFullName,
                      RegisterValidationError.missingUsername =>
                        l10n.pleaseEnterUsername,
                      RegisterValidationError.invalidEmail =>
                        l10n.pleaseEnterValidEmail,
                      RegisterValidationError.invalidPassword =>
                        l10n.passwordTooShortOrMismatch,
                    };
                    scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
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
                  final result = await _registerFormController.submit(
                    authProvider: authProvider,
                    input: input,
                  );

                  navigator.pop(); // close loading

                  if (result.isSuccess) {
                    // Registration succeeded — show success and clear form
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(l10n.registerSuccess)),
                    );
                    _firstNameController.clear();
                    _lastNameController.clear();
                    _usernameController.clear();
                    _emailController.clear();
                    _passwordController.clear();
                    _confirmController.clear();
                  } else {
                    final errorMessage = result.errorMessage ?? l10n.registerFailed;
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  }
                },
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(l10n.orText, style: const TextStyle(color: Colors.grey)),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {},
                icon: Image.asset(
                  'assets/images/google.png',
                  height: 24,
                  width: 24,
                ),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    l10n.loginWithGoogle,
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
                      text: '${l10n.haveAccountQuestion} ',
                      style: const TextStyle(color: Colors.black54),
                      children: [
                        TextSpan(
                          text: l10n.login,
                          style: const TextStyle(
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
