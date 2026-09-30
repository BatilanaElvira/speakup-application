import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_provider.dart';
import '../../widgets/botanical_header.dart';
import '../../widgets/speakup_logo.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  static final RegExp _emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  bool _isValidEmail(String email) => _emailRegex.hasMatch(email.trim());

  Future<void> _handleAuthentication() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Please enter your email address.');
      return;
    }

    if (!_isValidEmail(email)) {
      _showSnackBar('Please enter a valid email address in the format name@example.com.');
      return;
    }

    if (password.isEmpty) {
      _showSnackBar('Please enter your password.');
      return;
    }

    if (_isSignUp) {
      if (name.isEmpty) {
        _showSnackBar('Please enter your full name.');
        return;
      }
      if (password != confirmPassword) {
        _showSnackBar('Passwords do not match.');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<AppProvider>(context, listen: false);

    bool success = false;
    if (_isSignUp) {
      success = await provider.register(name: name, email: email, password: password);
    } else {
      success = await provider.login(email, password);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (!success) {
        _showSnackBar(_isSignUp ? 'Registration failed. Email might already exist.' : 'Invalid email or password.');
      }
    }
  }

  Future<void> _handleSocialAuth(String providerName) async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    final success = await provider.loginWithSocial(provider: providerName);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        _showSnackBar('Signed in with $providerName successfully!', isError: false);
      }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BotanicalHeaderDecoration(
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0D0B26) : AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SpeakUpLogoWidget(size: 70, showTagline: false),
                  const SizedBox(height: 20),

                  Text(
                    _isSignUp ? 'Create Account' : 'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.mainText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isSignUp
                        ? 'Get started on your public speaking journey'
                        : 'Sign in to your SpeakUp account to practice',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1B164C) : AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppColors.cardShadow,
                      border: Border.all(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isSignUp) ...[
                          _buildTextField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline_rounded,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 14),
                        ],

                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Address',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 14),

                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isDark: isDark,
                        ),

                        if (_isSignUp) ...[
                          const SizedBox(height: 14),
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            isDark: isDark,
                          ),
                        ],

                        if (!_isSignUp) ...[
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgotPasswordScreen(
                                      initialEmail: _emailController.text.trim(),
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ] else
                          const SizedBox(height: 14),

                        // Action Button
                        Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: _isSignUp ? AppColors.coralGradient : AppColors.purpleGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.glowShadow(
                              _isSignUp ? AppColors.primaryCoral : AppColors.primaryPurple,
                            ),
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleAuthentication,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isSignUp ? 'Create Account' : 'Sign In',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Social Login Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'or continue with',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder)),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Google & Apple Buttons
                        Row(
                          children: [
                            Expanded(
                              child: _buildSocialButton(
                                'Google',
                                Icons.g_mobiledata_rounded,
                                isDark: isDark,
                                onTap: () => _handleSocialAuth('Google'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSocialButton(
                                'Apple',
                                Icons.apple_rounded,
                                isDark: isDark,
                                onTap: () => _handleSocialAuth('Apple'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottom Switch Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp ? 'Already have an account? ' : 'Don\'t have an account? ',
                        style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSignUp = !_isSignUp;
                          });
                        },
                        child: Text(
                          _isSignUp ? 'Sign In' : 'Sign Up',
                          style: const TextStyle(
                            color: AppColors.primaryCoral,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
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
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildSocialButton(String label, IconData icon, {required bool isDark, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF131038) : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? const Color(0xFF2B246A) : AppColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: isDark ? Colors.white : AppColors.mainText),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.mainText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
