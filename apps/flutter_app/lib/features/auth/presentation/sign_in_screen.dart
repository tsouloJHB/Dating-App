import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../auth_provider.dart';
import 'widgets/continue_with_google_button.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authStateProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    // Use State.mounted — `context.mounted` reads `context` and throws if disposed.
    if (!mounted) return;
    final authState = ref.read(authStateProvider);
    if (authState.isAuthenticated) {
      if (authState.profileSetupPending && authState.profileSetupRoute != null) {
        context.go(authState.profileSetupRoute!);
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primaryRed = isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      onPressed: () =>
                          context.canPop() ? context.pop() : context.go('/'),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: textColor,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Brand (aligns with sign-in template: mark + headline + subtitle)
                  Center(
                    child: Column(
                      children: [
                        const AppBrandLogo(size: 88, borderRadius: 22),
                        const SizedBox(height: 28),
                        Text(
                          'Sign in',
                          style: AppTextStyles.headerBold(
                            color: textColor,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Welcome back to JustHookups',
                          style: AppTextStyles.bodyRegular(
                            color: textColor.withOpacity(0.55),
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Email field
                  Text(
                    'Email',
                    style: AppTextStyles.bodyRegular(color: textColor, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _emailController,
                    hint: 'you@example.com',
                    keyboardType: TextInputType.emailAddress,
                    surfaceColor: surfaceColor,
                    textColor: textColor,
                    validator: (v) {
                      final value = v?.trim() ?? '';
                      if (value.isEmpty) return 'Email is required';
                      if (!_emailRegex.hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Password field
                  Text(
                    'Password',
                    style: AppTextStyles.bodyRegular(color: textColor, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _passwordController,
                    hint: '••••••••',
                    obscureText: _obscurePassword,
                    surfaceColor: surfaceColor,
                    textColor: textColor,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: textColor.withOpacity(0.5),
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      final value = v ?? '';
                      if (value.isEmpty) return 'Password is required';
                      if (value.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Error message
                  if (authState.error != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: primaryRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: primaryRed, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _friendlyError(authState.error!),
                              style: AppTextStyles.bodyRegular(
                                color: primaryRed,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 8),

                  // Sign in button
                  RedButton(
                    label: 'Sign In',
                    isLoading: authState.isLoading,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 16),

                  ContinueWithGoogleButton(textColor: textColor),

                  const SizedBox(height: 28),

                  // Sign up link
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/sign-up'),
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: AppTextStyles.bodyRegular(
                            color: textColor.withOpacity(0.6),
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: AppTextStyles.bodyRegular(
                                color: primaryRed,
                                fontSize: 14,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _friendlyError(String raw) {
    final normalized = raw.toLowerCase();
    if (normalized.contains('incorrect email or password') ||
        normalized.contains('invalid credentials') ||
        normalized.contains('401')) {
      return 'Incorrect email or password.';
    }
    if (normalized.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (normalized.contains('no internet') || normalized.contains('network')) {
      return 'No internet connection. Check your network and try again.';
    }
    if (normalized.contains('too many')) {
      return 'Too many login attempts. Please wait and try again.';
    }
    return raw.trim().isEmpty ? 'Sign in failed. Please try again.' : raw;
  }
}

// ──────────────────────────────────────────────
// Shared input field widget (local to auth screens)
// ──────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Color surfaceColor;
  final Color textColor;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.surfaceColor,
    required this.textColor,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor, fontSize: 15),
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textColor.withOpacity(0.35), fontSize: 15),
        filled: true,
        fillColor: surfaceColor,
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: textColor.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorStyle: TextStyle(color: accent, fontSize: 12),
      ),
    );
  }
}
