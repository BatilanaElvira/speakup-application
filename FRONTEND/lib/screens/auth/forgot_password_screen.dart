import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../widgets/botanical_header.dart';
import '../../widgets/speakup_logo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String? initialEmail;
  const ForgotPasswordScreen({super.key, this.initialEmail});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  static final RegExp _emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");

  int _currentStep = 1; // 1: Email, 2: Code, 3: New Password
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _generatedCode;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null && widget.initialEmail!.isNotEmpty) {
      _emailController.text = widget.initialEmail!;
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: isError ? AppColors.primaryCoral : AppColors.secondaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  bool _isValidEmail(String email) => _emailRegex.hasMatch(email.trim());

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_isValidEmail(email)) {
      _showSnackBar('Please enter a valid email address in the format name@example.com.');
      return;
    }

    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    final res = await provider.forgotPassword(email);

    if (mounted) {
      setState(() => _isLoading = false);
      if (res != null && res['success'] == true) {
        _generatedCode = res['code'];
        if (_generatedCode != null) {
          _codeController.text = _generatedCode!;
        }
        setState(() => _currentStep = 2);
        _showSnackBar('Verification code generated: ${_generatedCode ?? "Sent to your email"}', isError: false);
      } else {
        _showSnackBar(res?['error'] ?? 'Could not find an account with this email.');
      }
    }
  }

  Future<void> _handleVerifyCode() async {
    final code = _codeController.text.trim();
    final email = _emailController.text.trim();

    if (code.isEmpty || code.length < 4) {
      _showSnackBar('Please enter the 6-digit verification code.');
      return;
    }

    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    final isValid = await provider.verifyResetCode(email, code);

    if (mounted) {
      setState(() => _isLoading = false);
      if (isValid) {
        setState(() => _currentStep = 3);
        _showSnackBar('Code verified successfully!', isError: false);
      } else {
        _showSnackBar('Invalid or expired verification code.');
      }
    }
  }

  Future<void> _handleResetPassword() async {
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();

    if (newPass.length < 6) {
      _showSnackBar('Password must be at least 6 characters.');
      return;
    }
    if (newPass != confirmPass) {
      _showSnackBar('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    final success = await provider.resetPassword(email, code, newPass);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _showSnackBar('Password reset successfully! Logged in.', isError: false);
        Navigator.pop(context);
      } else {
        _showSnackBar('Could not reset password. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BotanicalHeaderDecoration(
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D0B26) : AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : AppColors.mainText, size: 20),
            onPressed: () {
              if (_currentStep > 1) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          centerTitle: true,
          title: Text(
            'Reset Password',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.mainText,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpeakUpLogoWidget(size: 64, showTagline: false),
                  const SizedBox(height: 16),

                  // Step Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepDot(1, 'Email'),
                      _buildStepConnector(1),
                      _buildStepDot(2, 'Verify'),
                      _buildStepConnector(2),
                      _buildStepDot(3, 'Password'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Form Container
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B164C) : AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppColors.cardShadow,
                      border: Border.all(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_currentStep == 1) ...[
                          Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.mainText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Enter your email address to receive a secure verification code.',
                            style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            controller: _emailController,
                            label: 'Your Email Address',
                            icon: Icons.email_outlined,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 24),
                          _buildActionButton(
                            label: 'Send Verification Code',
                            onPressed: _isLoading ? null : _handleSendCode,
                          ),
                        ] else if (_currentStep == 2) ...[
                          Text(
                            'Enter Verification Code',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.mainText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Enter the 6-digit code sent to ${_emailController.text}',
                            style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            controller: _codeController,
                            label: '6-Digit Verification Code',
                            icon: Icons.shield_outlined,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 24),
                          _buildActionButton(
                            label: 'Verify Code',
                            onPressed: _isLoading ? null : _handleVerifyCode,
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: _isLoading ? null : _handleSendCode,
                              child: const Text('Resend Code', style: TextStyle(color: AppColors.primaryCoral, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                        ] else ...[
                          Text(
                            'Set New Password',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.mainText,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Create a strong password for your SpeakUp account.',
                            style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            controller: _newPasswordController,
                            label: 'New Password',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 14),
                          _buildInputField(
                            controller: _confirmPasswordController,
                            label: 'Confirm New Password',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 24),
                          _buildActionButton(
                            label: 'Reset Password & Log In',
                            onPressed: _isLoading ? null : _handleResetPassword,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Back to login
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.secondaryText),
                    label: const Text('Back to Sign In', style: TextStyle(color: AppColors.secondaryText, fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryPurple : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? AppColors.primaryPurple : AppColors.cardBorder, width: 2),
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.secondaryText,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primaryPurple : AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(int step) {
    final isActive = _currentStep > step;
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 14),
      color: isActive ? AppColors.primaryPurple : AppColors.cardBorder,
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131038) : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && _obscurePassword,
        style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.mainText),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(color: AppColors.lightText, fontSize: 13),
          prefixIcon: Icon(icon, color: isDark ? const Color(0xFF9E8EFF) : AppColors.secondaryText, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: AppColors.secondaryText,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required VoidCallback? onPressed}) {
    return Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.glowShadow(AppColors.primaryPurple),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
