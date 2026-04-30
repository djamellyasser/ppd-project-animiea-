import 'package:anemia_lens/screens/profile_setup_screen.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.signUp(_emailController.text, _passwordController.text);
      if (mounted) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
    (r) => false,
  );
}
    }  catch (e) {
  print('SIGNUP ERROR: $e');
  setState(() => _error = e.toString());
} finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1510), Color(0xFF3B2218), Color(0xFF5C2E1A)],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    Positioned(
                      top: -60, right: -60,
                      child: Container(
                        width: 280, height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [AppColors.accent.withOpacity(0.25), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 48, 28, 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Create account',
                            style: TextStyle(
                              fontFamily: AppTextStyles.displayFont,
                              fontSize: 32,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start monitoring your health',
                            style: TextStyle(
                              fontFamily: AppTextStyles.bodyFont,
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.55),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  const SizedBox(height: 16),
                  _InputField(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress, hint: 'your@email.com'),
                  const SizedBox(height: 16),
                  _InputField(
                    label: 'Password',
                    controller: _passwordController,
                    obscure: _obscure,
                    hint: 'Min. 6 characters',
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscure = !_obscure),
                      child: Icon(
                        _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.inkSoft, size: 20,
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.redLight,
                        borderRadius: BorderRadius.circular(AppRadius.cardSm),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!, style: const TextStyle(fontSize: 13, color: AppColors.red, fontFamily: AppTextStyles.bodyFont))),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: _loading ? null : _signup,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(AppRadius.card),
                        boxShadow: AppShadow.accent,
                      ),
                      child: Center(
                        child: _loading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                            : const Text('Create Account', style: TextStyle(fontFamily: AppTextStyles.bodyFont, fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: AppTextStyles.caption),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Text('Sign In', style: TextStyle(fontFamily: AppTextStyles.bodyFont, fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reuse same _InputField widget from login_screen.dart
class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final String hint;
  final TextInputType? keyboardType;
  final Widget? suffix;

  const _InputField({
    required this.label,
    required this.controller,
    this.obscure = false,
    this.hint = '',
    this.keyboardType,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.cardSm),
            boxShadow: AppShadow.card,
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.caption,
              suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.only(right: 14), child: suffix) : null,
              suffixIconConstraints: const BoxConstraints(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }
}