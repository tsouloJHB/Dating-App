import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../domain/models/subscription_model.dart';
import '../../auth/auth_provider.dart';
import '../google_play_billing_service.dart';
import '../premium_provider.dart';

class PremiumScreen extends ConsumerWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final primary =
        isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction;
    final gold =
        isDark ? AppColors.darkPremiumAccent : AppColors.lightPremiumAccent;
    final subColor = textColor.withOpacity(0.62);

    final subscriptionAsync = ref.watch(subscriptionProvider);
    final premiumState = ref.watch(premiumStateProvider);

    // Google Play billing state — only meaningful on Android.
    final isAndroid = !kIsWeb && Platform.isAndroid;
    final billingState =
        isAndroid ? ref.watch(googlePlayBillingProvider) : null;

    Future<void> refreshAppTier() async {
      ref.invalidate(subscriptionProvider);
      await ref.read(authStateProvider.notifier).getCurrentUser();
    }

    // ── Action: real Google Play purchase (Android) ───────────────────────
    Future<void> buyWithGooglePlay() async {
      await ref.read(googlePlayBillingProvider.notifier).buy();
      // UI updates are driven by the billing stream → premiumStateProvider.
    }

    // ── Action: restore previous Google Play subscription ─────────────────
    Future<void> restorePurchases() async {
      await ref.read(googlePlayBillingProvider.notifier).restorePurchases();
      await refreshAppTier();
    }

    // ── Action: dev / non-Android unlock for testing ──────────────────────
    Future<void> buyDevGold() async {
      final token = 'dev-token-${DateTime.now().millisecondsSinceEpoch}';
      await ref
          .read(premiumStateProvider.notifier)
          .createSubscription(token, platform: 'dev');
      await refreshAppTier();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xtra Class Premium unlocked (dev mode)')),
        );
      }
    }

    // ── Action: cancel ────────────────────────────────────────────────────
    Future<void> cancelPlan() async {
      await ref.read(premiumStateProvider.notifier).cancelSubscription();
      await refreshAppTier();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription cancelled')),
        );
      }
    }

    // Busy = either the premium notifier or the billing notifier is working.
    final isBusy = premiumState.isLoading ||
        (billingState?.isLoading ?? false) ||
        (billingState?.purchasePending ?? false);

    // Price label from Google Play product details (e.g. "R49,99/month").
    final priceLabel = billingState?.goldProduct?.price;

    // Combined error to show.
    final errorMsg = (premiumState.error?.isNotEmpty == true)
        ? premiumState.error
        : (billingState?.error?.isNotEmpty == true)
            ? billingState!.error
            : null;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Row(
          children: [
            const AppBrandLogo(size: 30, borderRadius: 9),
            const SizedBox(width: 10),
            Text(
              'Xtra Class Premium',
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: subscriptionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Could not load subscription.\n$e',
              textAlign: TextAlign.center,
              style: TextStyle(color: subColor),
            ),
          ),
        ),
        data: (subscription) {
          final isPremium = subscription.isActive &&
              subscription.tier != SubscriptionTier.free;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              // ── Hero card ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    colors: [gold.withOpacity(0.95), primary.withOpacity(0.95)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.workspace_premium,
                        color: Colors.white, size: 38),
                    const SizedBox(height: 14),
                    const Text(
                      'Unlock Xtra Class Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isPremium
                          ? 'You can message without a match and see locked content.'
                          : 'See who likes you, reveal extra media, and message without waiting for a match.',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9), fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Current plan ───────────────────────────────────────────
              _PlanCard(
                surface: surface,
                textColor: textColor,
                subColor: subColor,
                title: 'Current Plan',
                value: isPremium ? 'Xtra Class Premium Active' : 'Free Tier',
                accent: isPremium ? gold : subColor,
              ),

              // ── Expiry info ────────────────────────────────────────────
              if (isPremium && subscription.endDate != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Renews / expires: ${_formatDate(subscription.endDate!)}',
                    style: TextStyle(color: subColor, fontSize: 12),
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // ── Benefits ───────────────────────────────────────────────
              _BenefitCard(
                surface: surface,
                textColor: textColor,
                subColor: subColor,
                icon: Icons.favorite,
                title: 'See who likes you',
                subtitle: 'Remove blur from Likes and Visitors.',
              ),
              const SizedBox(height: 12),
              _BenefitCard(
                surface: surface,
                textColor: textColor,
                subColor: subColor,
                icon: Icons.photo_library,
                title: 'Unlock extra media',
                subtitle: 'Reveal gallery items after the first photo.',
              ),
              const SizedBox(height: 12),
              _BenefitCard(
                surface: surface,
                textColor: textColor,
                subColor: subColor,
                icon: Icons.chat_bubble,
                title: 'Message first',
                subtitle: 'Start chats even before a mutual match.',
              ),
              const SizedBox(height: 24),

              // ── Primary CTA ────────────────────────────────────────────
              if (!isPremium) ...[
                FilledButton(
                  onPressed: isBusy
                      ? null
                      : isAndroid
                          ? buyWithGooglePlay
                          : buyDevGold,
                  style: FilledButton.styleFrom(
                    backgroundColor: gold,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isBusy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          isAndroid
                              ? (priceLabel != null
                                  ? 'Subscribe · $priceLabel'
                                  : 'Subscribe with Google Play')
                              : 'Unlock Xtra Class Premium (Dev)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),

                // Restore purchases link (Android only)
                if (isAndroid) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton(
                      onPressed: isBusy ? null : restorePurchases,
                      child: Text(
                        'Restore purchases',
                        style: TextStyle(color: subColor, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ] else ...[
                // Already subscribed
                FilledButton(
                  onPressed: null,
                  style: FilledButton.styleFrom(
                    backgroundColor: gold.withOpacity(0.5),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Xtra Class Premium Active ✓',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: isBusy ? null : cancelPlan,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(color: subColor.withOpacity(0.35)),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Cancel Subscription'),
                ),
              ],

              // ── Pending / billing state feedback ───────────────────────
              if (billingState?.purchasePending == true) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Waiting for Google Play…',
                      style: TextStyle(color: subColor, fontSize: 13),
                    ),
                  ],
                ),
              ],

              // ── Error ──────────────────────────────────────────────────
              if (errorMsg != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    errorMsg,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                ),
              ],

              // ── Google Play legal note ─────────────────────────────────
              if (isAndroid && !isPremium) ...[
                const SizedBox(height: 20),
                Text(
                  'Subscription renews automatically. Cancel anytime in '
                  'Google Play > Subscriptions.',
                  style: TextStyle(color: subColor, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} '
      '${_months[d.month - 1]} '
      '${d.year}';

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
}

// ---------------------------------------------------------------------------
// Sub-widgets (unchanged design, extracted for readability)
// ---------------------------------------------------------------------------

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.surface,
    required this.textColor,
    required this.subColor,
    required this.title,
    required this.value,
    required this.accent,
  });

  final Color surface;
  final Color textColor;
  final Color subColor;
  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: subColor, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.surface,
    required this.textColor,
    required this.subColor,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Color surface;
  final Color textColor;
  final Color subColor;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(color: subColor, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
