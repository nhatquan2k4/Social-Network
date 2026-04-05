import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/presentation/widgets/common/custom_button.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/presentation/screens/auth/reset_password_screen.dart';

enum OtpPurpose { register, reset }

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final OtpPurpose purpose;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.purpose = OtpPurpose.register,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String _maskedEmail(String email) {
    // Simple mask: keep prefix up to 3 chars then show '***' then domain
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    final visible = name.length <= 3 ? name : name.substring(0, 3);
    return '$visible***@$domain';
  }

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
              Image.asset('assets/images/logo.jpg', height: 100, width: 220),

              const SizedBox(height: 18),

              Text(
                l10n.otpEnterCodeTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              Text(
                l10n.otpDescription(_maskedEmail(widget.email)),
                style: const TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  hintText: l10n.otpCodeHint,
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              CustomButton(
                label: l10n.next,
                onPressed: () {
                  final code = _codeController.text.trim();
                  if (code.length != 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.pleaseEnterSixDigitCode)),
                    );
                    return;
                  }
                  // TODO: verify code via API
                  if (widget.purpose == OtpPurpose.register) {
                    // show success and navigate to login/messages
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  } else {
                    // reset password flow -> go to reset password screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ResetPasswordScreen(),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: trigger resend code
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(l10n.resendCode)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    l10n.didNotReceiveCode,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Center(
                child: GestureDetector(
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
                  child: Text(
                    l10n.alreadyHaveAccount,
                    style: const TextStyle(color: Color(0xFF3797EF)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
