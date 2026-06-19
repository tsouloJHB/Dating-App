import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../features/activity/activity_provider.dart';
import '../../../features/interactions/interactions_provider.dart';
import '../../../features/premium/premium_provider.dart';
import '../../../features/profile/profile_provider.dart';
import '../../../shared/widgets/app_widgets.dart';

class ProfileDetailScreen extends ConsumerStatefulWidget {
  final String userId;
  const ProfileDetailScreen({super.key, required this.userId});

  @override
  ConsumerState<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends ConsumerState<ProfileDetailScreen> {
  int _selectedPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final primaryRed = isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final gold = isDark ? AppColors.darkPremiumAccent : AppColors.lightPremiumAccent;

    final isFreeTier = !ref.watch(isPremiumProvider);
    final profileAsync = ref.watch(userDetailProvider(widget.userId));

    return Scaffold(
      backgroundColor: bg,
      body: profileAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: primaryRed)),
        error: (e, _) => _ErrorBody(
          error: e.toString(),
          textColor: textColor,
          onBack: () => context.pop(),
        ),
        data: (profile) {
          final isLiked = profile.viewerHasLiked;
          final canMessage = profile.hasMatch || !isFreeTier;

          return CustomScrollView(
            slivers: [
              // ── Hero image area ──
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Main photo
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: _selectedPhotoIndex < profile.photoUrls.length
                          ? CachedNetworkImage(
                              imageUrl: profile.photoUrls[_selectedPhotoIndex],
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: surfaceColor),
                              errorWidget: (_, __, ___) => _InitialAvatar(
                                name: profile.name,
                                surfaceColor: surfaceColor,
                                textColor: textColor,
                              ),
                            )
                          : _InitialAvatar(
                              name: profile.name,
                              surfaceColor: surfaceColor,
                              textColor: textColor,
                            ),
                    ),

                    // Bottom gradient on hero
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 160,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xEE000000), Colors.transparent],
                          ),
                        ),
                      ),
                    ),

                    // Back button
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8,
                      left: 12,
                      child: GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),

                    // Name + info on hero
                    Positioned(
                      left: 20,
                      right: 80,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${profile.name}, ${profile.age}',
                            style: AppTextStyles.headerBold(
                                color: Colors.white, fontSize: 28),
                          ),
                          if (profile.distanceKm != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${profile.distanceKm!.round()} km away',
                              style: AppTextStyles.bodyRegular(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 14,
                              ),
                            ),
                          ],
                          if (profile.gender.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              profile.gender,
                              style: AppTextStyles.bodyRegular(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Premium badge
                    if (profile.isPremium)
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: gold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 13),
                              SizedBox(width: 4),
                              Text(
                                'Premium',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // ── Action buttons ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                  child: Row(
                    children: [
                      // LIKE button
                      Expanded(
                        child: _ActionBtn(
                          icon: isLiked ? Icons.favorite : Icons.favorite_border,
                          label: isLiked ? 'Liked' : 'Like',
                          color: primaryRed,
                          filled: isLiked,
                          onTap: isLiked
                              ? null
                              : () => _onLike(context, profile.id),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // MESSAGE button
                      Expanded(
                        child: _ActionBtn(
                          icon: Icons.chat_bubble_outline,
                          label: 'Message',
                          color: canMessage ? primaryRed : textColor.withOpacity(0.4),
                          filled: canMessage,
                          onTap: canMessage
                              ? () => context.push('/chat/${Uri.encodeComponent(profile.id)}')
                              : () => context.push('/premium'),
                          suffix: canMessage
                              ? null
                              : Icon(Icons.lock, size: 14,
                                  color: textColor.withOpacity(0.4)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Media thumbnails ──
              if (profile.photoUrls.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Photos',
                          style: AppTextStyles.headerSemiBold(
                              color: textColor, fontSize: 17),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: profile.photoUrls.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, i) {
                              final isLocked = isFreeTier && i > 0;
                              final isSelected = _selectedPhotoIndex == i;
                              return GestureDetector(
                                onTap: isLocked
                                    ? () => context.push('/premium')
                                    : () => setState(
                                        () => _selectedPhotoIndex = i),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        height: 100,
                                        child: CachedNetworkImage(
                                          imageUrl: profile.photoUrls[i],
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) =>
                                              Container(color: surfaceColor),
                                          errorWidget: (_, __, ___) =>
                                              Container(color: surfaceColor),
                                        ),
                                      ),
                                      // Blur locked photos
                                      if (isLocked)
                                        const PremiumLockedOverlay(
                                          darkness: 0.2,
                                          child: Center(
                                            child: Icon(
                                              Icons.lock,
                                              color: Colors.white,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                      // Selected border
                                      if (isSelected && !isLocked)
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                  color: primaryRed, width: 3),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Bio ──
              if (profile.bio != null && profile.bio!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About',
                          style: AppTextStyles.headerSemiBold(
                              color: textColor, fontSize: 17),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          profile.bio!,
                          style: AppTextStyles.bodyRegular(
                            color: textColor.withOpacity(0.8),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Details chips ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (profile.gender.isNotEmpty)
                        _InfoChip(
                          icon: Icons.person_outline,
                          label: profile.gender,
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                        ),
                      if (profile.sexualOrientation.isNotEmpty)
                        _InfoChip(
                          icon: Icons.favorite_border,
                          label: profile.sexualOrientation,
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                        ),
                      if (profile.distanceKm != null)
                        _InfoChip(
                          icon: Icons.near_me_outlined,
                          label: '${profile.distanceKm!.round()} km away',
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                        ),
                      _InfoChip(
                        icon: Icons.cake_outlined,
                        label: '${profile.age} years old',
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onLike(BuildContext context, String profileId) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryRed =
        isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction;

    try {
      final response = await ref
          .read(interactionsDataSourceProvider)
          .recordInteraction(targetId: profileId, type: 'LIKE');

      ref.invalidate(userDetailProvider(profileId));
      ref.invalidateInboxMatchCaches();

      if (response.matchCreated) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: primaryRed,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              behavior: SnackBarBehavior.floating,
              content: const Row(
                children: [
                  Icon(Icons.favorite, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "It's a match! You can now message each other 🎉",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (_) {
      // Non-critical — like failed silently, user can retry
    }
  }
}

// ──────────────────────────────────────────────
// Sub-widgets
// ──────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback? onTap;
  final Widget? suffix;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.filled,
    this.onTap,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 52,
        decoration: BoxDecoration(
          color: filled ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: filled ? color : color.withOpacity(0.45),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: filled ? Colors.white : color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : color,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (suffix != null) ...[
              const SizedBox(width: 6),
              suffix!,
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color surfaceColor;
  final Color textColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.surfaceColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor.withOpacity(0.6), size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodyRegular(color: textColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String name;
  final Color surfaceColor;
  final Color textColor;

  const _InitialAvatar({
    required this.name,
    required this.surfaceColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: surfaceColor,
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: AppTextStyles.headerBold(color: textColor, fontSize: 80),
        ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String error;
  final Color textColor;
  final VoidCallback onBack;

  const _ErrorBody({
    required this.error,
    required this.textColor,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_off_outlined,
              size: 64, color: textColor.withOpacity(0.25)),
          const SizedBox(height: 16),
          Text(
            'Profile not found',
            style: AppTextStyles.headerSemiBold(color: textColor, fontSize: 18),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: onBack,
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
