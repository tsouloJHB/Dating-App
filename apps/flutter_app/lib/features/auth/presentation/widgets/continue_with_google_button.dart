import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/bootstrap/google_sign_in_bootstrap.dart';
import '../../../../core/theme/app_theme.dart';
import '../../auth_provider.dart';
import 'google_web_sign_in_button.dart';

/// Mobile/desktop: outline button that runs signInWithGoogle.
/// Web: GIS renderButton; completion is handled by googleSignInWebAuthListenerProvider.
class ContinueWithGoogleButton extends ConsumerWidget {
  const ContinueWithGoogleButton({
    super.key,
    required this.textColor,
  });

  final Color textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final loading = authState.isLoading;
    final webFlow = !GoogleSignIn.instance.supportsAuthenticate();

    if (webFlow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isGoogleWebClientIdConfigured)
            Text(
              missingGoogleClientIdUserMessage(),
              style: AppTextStyles.bodyRegular(
                color: textColor.withOpacity(0.55),
                fontSize: 12,
              ),
            )
          else ...[
            Align(
              alignment: Alignment.center,
              child: googleWebSignInButton(minimumWidth: 320),
            ),
            if (loading) ...[
              const SizedBox(height: 16),
              Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: loading
                ? null
                : () => ref.read(authStateProvider.notifier).signInWithGoogle(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: textColor.withOpacity(0.25)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: loading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : Icon(Icons.login_rounded, color: textColor, size: 22),
            label: Text(
              'Continue with Google',
              style: AppTextStyles.bodyRegular(color: textColor, fontSize: 15)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        if (!isGoogleWebClientIdConfigured) ...[
          const SizedBox(height: 12),
          Text(
            missingGoogleClientIdUserMessage(),
            style: AppTextStyles.bodyRegular(
              color: textColor.withOpacity(0.55),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}
