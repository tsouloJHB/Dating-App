import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/constants/branding_assets.dart';
import '../../core/theme/app_theme.dart';

/// App mark from [BrandingAssets.appLogo] (24dp-style squircle per design system).
class AppBrandLogo extends StatelessWidget {
  final double size;
  final double borderRadius;

  const AppBrandLogo({
    super.key,
    this.size = 72,
    this.borderRadius = AppRadii.card,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark
        ? AppColors.darkPrimaryAction
        : AppColors.lightPrimaryAction;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          BrandingAssets.appLogo,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => ColoredBox(
            color: primary,
            child: Icon(Icons.bolt, color: Colors.white, size: size * 0.52),
          ),
        ),
      ),
    );
  }
}

class RedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double height;

  const RedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(label),
      ),
    );
  }
}

class GoldPremiumCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isBlurred;

  const GoldPremiumCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isBlurred = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(
              color: AppColors.darkPremiumAccent,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.headerSemiBold(
                  color: AppColors.darkPremiumAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: AppTextStyles.bodyRegular(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String name;
  final int age;
  final String? photoUrl;
  final String? bio;

  const ProfileCard({
    super.key,
    required this.name,
    required this.age,
    this.photoUrl,
    this.bio,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photoUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadii.card),
                topRight: Radius.circular(AppRadii.card),
              ),
              child: Image.network(
                photoUrl!,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name, $age',
                  style: AppTextStyles.headerSemiBold(),
                ),
                if (bio != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    bio!,
                    style: AppTextStyles.bodyRegular(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PremiumLockedOverlay extends StatelessWidget {
  final double sigma;
  final double darkness;
  final Widget? child;

  const PremiumLockedOverlay({
    super.key,
    this.sigma = 15,
    this.darkness = 0.18,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          color: Colors.black.withOpacity(darkness),
          child: child,
        ),
      ),
    );
  }
}

class PremiumUnlockBanner extends StatelessWidget {
  final bool isDark;
  final Color primaryColor;
  final String label;
  final VoidCallback onTap;

  const PremiumUnlockBanner({
    super.key,
    required this.isDark,
    required this.primaryColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 180,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                (isDark ? AppColors.darkBackground : AppColors.lightBackground)
                    .withOpacity(0.97),
                Colors.transparent,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(AppRadii.control),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_open, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
