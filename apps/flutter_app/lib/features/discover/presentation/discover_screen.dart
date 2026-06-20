import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../domain/models/user_model.dart';
import '../../../features/activity/activity_provider.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../features/interactions/interactions_provider.dart';
import '../../../features/profile/profile_provider.dart';
import '../discover_provider.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  // Track per-card swipe overlay direction
  double _dragOffset = 0;
  bool _isDragging = false;
  bool _filtersInitialized = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_bootstrapDiscover);
  }

  Future<void> _bootstrapDiscover() async {
    if (!mounted) return; // Exit early if widget was disposed
    
    if (!_filtersInitialized) {
      try {
        final profile = await ref.read(userProfileProvider.future);
        if (!mounted) return; // Check again after async operation
        ref.read(discoverStateProvider.notifier).updateFilters(
              distanceKm: profile.discoveryRadius,
              minAge: profile.minAgeRange,
              maxAge: profile.maxAgeRange,
            );
        _filtersInitialized = true;
      } catch (_) {
        // Keep default discover filters if profile bootstrap fails.
        if (!mounted) return;
      }
    }

    if (!mounted) return;
    await ref.read(discoverLocationProvider.notifier).refresh(syncToBackend: true);
    if (!mounted) return;
    final locationState = ref.read(discoverLocationProvider);
    ref.read(discoverStateProvider.notifier).updateLocation(
          latitude: locationState.latitude,
          longitude: locationState.longitude,
        );

    if (!mounted) return;
    await _loadProfiles();
  }

  Future<void> _loadProfiles({bool append = false}) async {
    final auth = ref.read(authStateProvider);
    final discoverState = ref.read(discoverStateProvider);
    await ref.read(discoverStateProvider.notifier).fetchProfiles(
          actorUserId: auth.user?.id ?? '',
          latitude: discoverState.latitude,
          longitude: discoverState.longitude,
          distanceKm: discoverState.distanceKm,
          minAge: discoverState.minAge,
          maxAge: discoverState.maxAge,
          append: append,
        );
  }

  Future<void> _loadMoreIfNeeded() async {
    final auth = ref.read(authStateProvider);
    final discoverState = ref.read(discoverStateProvider);
    final remainingCount = discoverState.profiles.length - discoverState.currentIndex;
    if (remainingCount <= 3 && discoverState.hasMore && !discoverState.isLoadingMore) {
      await ref
          .read(discoverStateProvider.notifier)
          .loadNextPage(actorUserId: auth.user?.id ?? '');
    }
  }

  Future<void> _refreshLocation() async {
    await ref.read(discoverLocationProvider.notifier).refresh(syncToBackend: true);
    final locationState = ref.read(discoverLocationProvider);
    ref.read(discoverStateProvider.notifier).updateLocation(
          latitude: locationState.latitude,
          longitude: locationState.longitude,
        );
    await _loadProfiles();
  }

  Future<void> _openFilters() async {
    final discoverState = ref.read(discoverStateProvider);
    double tempDistance = discoverState.distanceKm.toDouble();
    RangeValues tempAges = RangeValues(
      discoverState.minAge.toDouble(),
      discoverState.maxAge.toDouble(),
    );

    final applied = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface
          : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor =
            isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        final primaryRed =
            isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Discover filters',
                    style: AppTextStyles.headerSemiBold(
                      color: textColor,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Distance: ${tempDistance.round()} km',
                    style: AppTextStyles.bodyRegular(
                      color: textColor,
                      fontSize: 15,
                    ),
                  ),
                  Slider(
                    value: tempDistance,
                    min: 1,
                    max: 500,
                    divisions: 99,
                    activeColor: primaryRed,
                    onChanged: (value) => setModalState(() => tempDistance = value),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Age range: ${tempAges.start.round()} - ${tempAges.end.round()}',
                    style: AppTextStyles.bodyRegular(
                      color: textColor,
                      fontSize: 15,
                    ),
                  ),
                  RangeSlider(
                    values: tempAges,
                    min: 18,
                    max: 80,
                    divisions: 62,
                    activeColor: primaryRed,
                    onChanged: (value) => setModalState(() => tempAges = value),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryRed,
                          ),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (applied != true) return;

    ref.read(discoverStateProvider.notifier).updateFilters(
          distanceKm: tempDistance.round(),
          minAge: tempAges.start.round(),
          maxAge: tempAges.end.round(),
        );

    try {
      final profile = await ref.read(userProfileProvider.future);
      await ref.read(profileStateProvider.notifier).updateProfile(
            profile.copyWith(
              discoveryRadius: tempDistance.round(),
              minAgeRange: tempAges.start.round(),
              maxAgeRange: tempAges.end.round(),
            ),
          );
      ref.invalidate(userProfileProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save filters right now.')),
        );
      }
    }

    await _loadProfiles();
  }

  Future<void> _like(User profile) async {
    final result = await ref
        .read(interactionsDataSourceProvider)
        .recordInteraction(targetId: profile.id, type: 'LIKE');
    ref.read(discoverStateProvider.notifier).likeProfile(profile.id);
    ref.invalidateInboxMatchCaches();
    await _loadMoreIfNeeded();

    if (!mounted) return;
    if (result.matchCreated) {
      _showMatchBanner(profile.name);
    }
  }

  Future<void> _pass(User profile) async {
    await ref
        .read(interactionsDataSourceProvider)
        .recordInteraction(targetId: profile.id, type: 'PASS');
    ref.read(discoverStateProvider.notifier).passProfile(profile.id);
    await _loadMoreIfNeeded();
  }

  void _showMatchBanner(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.darkPrimaryAction,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "It's a match with $name! 🎉",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final primaryRed = isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    final discoverState = ref.watch(discoverStateProvider);
    final locationState = ref.watch(discoverLocationProvider);
    final remaining = discoverState.profiles
        .skip(discoverState.currentIndex)
        .toList();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const AppBrandLogo(size: 36, borderRadius: 10),
                  const SizedBox(width: 10),
                  Text(
                    'Discover',
                    style: AppTextStyles.headerSemiBold(color: textColor, fontSize: 22),
                  ),
                  const SizedBox(width: 12),
                  if (discoverState.distanceKm > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${discoverState.distanceKm} km · ${discoverState.minAge}-${discoverState.maxAge}',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      locationState.hasPermission ? Icons.my_location : Icons.location_searching,
                      color: textColor.withOpacity(0.6),
                    ),
                    onPressed: _refreshLocation,
                  ),
                  IconButton(
                    icon: Icon(Icons.tune, color: textColor.withOpacity(0.6)),
                    onPressed: _openFilters,
                  ),
                ],
              ),
            ),

            // ── Card stack or empty state ──
            Expanded(
              child: discoverState.isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryRed))
                  : discoverState.error != null
                      ? _ErrorView(
                          message: discoverState.error!,
                          onRetry: _loadProfiles,
                          textColor: textColor,
                          primaryRed: primaryRed,
                        )
                      : remaining.isEmpty
                          ? _EmptyState(
                              onRefresh: _bootstrapDiscover,
                              textColor: textColor,
                              primaryRed: primaryRed,
                              surfaceColor: surfaceColor,
                            )
                          : _CardStack(
                              profiles: remaining,
                              isDark: isDark,
                              textColor: textColor,
                              primaryRed: primaryRed,
                              surfaceColor: surfaceColor,
                              dragOffset: _dragOffset,
                              isDragging: _isDragging,
                              onDragUpdate: (dx) => setState(() {
                                _dragOffset = dx;
                                _isDragging = true;
                              }),
                              onDragEnd: (dx) {
                                setState(() {
                                  _dragOffset = 0;
                                  _isDragging = false;
                                });
                                if (dx > 80) {
                                  _like(remaining.first);
                                } else if (dx < -80) {
                                  _pass(remaining.first);
                                }
                              },
                              onLike: () => _like(remaining.first),
                              onPass: () => _pass(remaining.first),
                              onCardTap: () => context.push('/profile/${remaining.first.id}'),
                              isLoadingMore: discoverState.isLoadingMore,
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Card Stack
// ──────────────────────────────────────────────
class _CardStack extends StatelessWidget {
  final List<User> profiles;
  final bool isDark;
  final Color textColor;
  final Color primaryRed;
  final Color surfaceColor;
  final double dragOffset;
  final bool isDragging;
  final ValueChanged<double> onDragUpdate;
  final ValueChanged<double> onDragEnd;
  final VoidCallback onLike;
  final VoidCallback onPass;
  final VoidCallback onCardTap;
  final bool isLoadingMore;

  const _CardStack({
    required this.profiles,
    required this.isDark,
    required this.textColor,
    required this.primaryRed,
    required this.surfaceColor,
    required this.dragOffset,
    required this.isDragging,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onLike,
    required this.onPass,
    required this.onCardTap,
    required this.isLoadingMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(                onTap: () {
                  // Only navigate if not mid-swipe
                  if (dragOffset.abs() < 10) onCardTap();
                },              onHorizontalDragUpdate: (d) => onDragUpdate(dragOffset + d.delta.dx),
              onHorizontalDragEnd: (d) => onDragEnd(dragOffset),
              child: Transform.rotate(
                angle: dragOffset / 1200,
                child: Transform.translate(
                  offset: Offset(dragOffset * 0.15, 0),
                  child: Stack(
                    children: [
                      // Background card peek (next card)
                      if (profiles.length > 1) ...[
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12, left: 8, right: 8),
                            child: _ProfileCard(
                              profile: profiles[1],
                              isDark: isDark,
                              textColor: textColor,
                              surfaceColor: surfaceColor,
                              dragLabel: null,
                            ),
                          ),
                        ),
                      ],
                      // Top card
                      _ProfileCard(
                        profile: profiles.first,
                        isDark: isDark,
                        textColor: textColor,
                        surfaceColor: surfaceColor,
                        dragLabel: dragOffset > 50
                            ? 'LIKE'
                            : dragOffset < -50
                                ? 'PASS'
                                : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // PASS button
              _ActionButton(
                icon: Icons.close,
                color: Colors.grey.shade400,
                size: 60,
                onTap: onPass,
              ),
              // LIKE button
              _ActionButton(
                icon: Icons.favorite,
                color: primaryRed,
                size: 72,
                onTap: onLike,
              ),
            ],
          ),
        ),
        if (isLoadingMore)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: primaryRed,
              ),
            ),
          ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Profile Card
// ──────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final User profile;
  final bool isDark;
  final Color textColor;
  final Color surfaceColor;
  final String? dragLabel;

  const _ProfileCard({
    required this.profile,
    required this.isDark,
    required this.textColor,
    required this.surfaceColor,
    required this.dragLabel,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = profile.photoUrls.cast<String?>().firstWhere(
          (url) => url != null && url.trim().isNotEmpty,
          orElse: () => null,
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo background
          if (photoUrl != null)
            CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: surfaceColor),
              errorWidget: (_, __, ___) => _PlaceholderAvatar(
                name: profile.name,
                surfaceColor: surfaceColor,
                textColor: textColor,
              ),
            )
          else
            _PlaceholderAvatar(
              name: profile.name,
              surfaceColor: surfaceColor,
              textColor: textColor,
            ),

          // Gradient overlay (bottom)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 200,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Color(0xDD000000), Colors.transparent],
                ),
              ),
            ),
          ),

          // Profile info
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${profile.name}, ${profile.age}',
                  style: AppTextStyles.headerBold(
                    color: Colors.white,
                    fontSize: 26,
                  ),
                ),
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
                if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    profile.bio!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyRegular(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Drag label overlay
          if (dragLabel != null)
            Positioned(
              top: 32,
              left: dragLabel == 'LIKE' ? 20 : null,
              right: dragLabel == 'PASS' ? 20 : null,
              child: Transform.rotate(
                angle: dragLabel == 'LIKE' ? -0.3 : 0.3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: dragLabel == 'LIKE' ? Colors.green : Colors.red,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dragLabel!,
                    style: TextStyle(
                      color: dragLabel == 'LIKE' ? Colors.green : Colors.red,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────

class _PlaceholderAvatar extends StatelessWidget {
  final String name;
  final Color surfaceColor;
  final Color textColor;
  const _PlaceholderAvatar({
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
          style: AppTextStyles.headerBold(color: textColor, fontSize: 72),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.12),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Icon(icon, color: color, size: size * 0.44),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onRefresh;
  final Color textColor;
  final Color primaryRed;
  final Color surfaceColor;
  const _EmptyState({
    required this.onRefresh,
    required this.textColor,
    required this.primaryRed,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_off, size: 72, color: textColor.withOpacity(0.25)),
            const SizedBox(height: 20),
            Text(
              'No new people around you',
              style: AppTextStyles.headerSemiBold(color: textColor, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Try expanding your distance or check back later.',
              style: AppTextStyles.bodyRegular(
                color: textColor.withOpacity(0.55),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: Icon(Icons.refresh, color: primaryRed),
              label: Text('Refresh', style: TextStyle(color: primaryRed)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryRed.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final Color textColor;
  final Color primaryRed;
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.textColor,
    required this.primaryRed,
  });

  @override
  Widget build(BuildContext context) {
    final lowerMessage = message.toLowerCase();
    final isNetworkError =
        lowerMessage.contains('no internet') || lowerMessage.contains('network');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isNetworkError ? Icons.wifi_off : Icons.error_outline,
              size: 56,
              color: textColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isNetworkError ? 'No internet connection' : 'Could not load profiles',
              style: AppTextStyles.headerSemiBold(color: textColor, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyRegular(
                color: textColor.withOpacity(0.55),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(backgroundColor: primaryRed),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

