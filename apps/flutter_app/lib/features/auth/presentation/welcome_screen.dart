import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../auth_provider.dart';
import 'widgets/continue_with_google_button.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark; // for Google error + hint styling
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Brand
              Center(
                child: Column(
                  children: [
                    const AppBrandLogo(size: 96, borderRadius: 24),
                    const SizedBox(height: 22),
                    Text(
                      'JustHookups',
                      style: AppTextStyles.headerBold(color: textColor, fontSize: 34),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Premium Social Discovery',
                      style: AppTextStyles.bodyRegular(
                        color: textColor.withOpacity(0.55),
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Tagline card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meet people near you',
                      style: AppTextStyles.headerSemiBold(color: textColor, fontSize: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Swipe, match, and connect with bold people in your area.',
                      style: AppTextStyles.bodyRegular(
                        color: textColor.withOpacity(0.55),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // CTA buttons
              RedButton(
                label: 'Get Started',
                onPressed: () => context.go('/sign-up'),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => context.go('/sign-in'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: textColor.withOpacity(0.25)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Sign In',
                    style: AppTextStyles.bodyRegular(color: textColor, fontSize: 16)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              ContinueWithGoogleButton(textColor: textColor),

              if (authState.error != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction)
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction)
                          .withOpacity(0.35),
                    ),
                  ),
                  child: Text(
                    authState.error!,
                    style: AppTextStyles.bodyRegular(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
