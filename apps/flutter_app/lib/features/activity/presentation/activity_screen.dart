import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/sources/inbox_data_source.dart';
import '../../../features/activity/activity_provider.dart';
import '../../../features/premium/premium_provider.dart';
import '../../../shared/widgets/app_widgets.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final primaryRed = isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final isFreeTier = !ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const AppBrandLogo(size: 34, borderRadius: 10),
                  const SizedBox(width: 12),
                  Text(
                    'Activity',
                    style: AppTextStyles.headerSemiBold(color: textColor, fontSize: 22),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, color: textColor.withOpacity(0.6)),
                    tooltip: 'Refresh',
                    onPressed: () => ref.invalidateInboxMatchCaches(),
                  ),
                ],
              ),
            ),

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: primaryRed,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: textColor.withOpacity(0.55),
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(fontSize: 12),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Liked Me'),
                    Tab(text: 'Visitors'),
                    Tab(text: 'Matches'),
                    Tab(text: 'My Likes'),
                  ],
                ),
              ),
            ),

            // Tab views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Who Liked Me tab — premium blurred for FREE users
                  _LikesInTab(
                    isBlurred: isFreeTier,
                    isDark: isDark,
                    textColor: textColor,
                    primaryRed: primaryRed,
                    surfaceColor: surfaceColor,
                  ),
                  // Visitors tab — premium blurred for FREE users
                  _VisitorsTab(
                    isBlurred: isFreeTier,
                    isDark: isDark,
                    textColor: textColor,
                    primaryRed: primaryRed,
                    surfaceColor: surfaceColor,
                  ),
                  // Matches tab — always visible
                  _MatchesTab(
                    isDark: isDark,
                    textColor: textColor,
                    primaryRed: primaryRed,
                    surfaceColor: surfaceColor,
                  ),
                  _MyLikesTab(
                    isDark: isDark,
                    textColor: textColor,
                    primaryRed: primaryRed,
                    surfaceColor: surfaceColor,
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

// ──────────────────────────────────────────────
// Who Liked Me tab
// ──────────────────────────────────────────────
class _LikesInTab extends ConsumerWidget {
  final bool isBlurred;
  final bool isDark;
  final Color textColor;
  final Color primaryRed;
  final Color surfaceColor;

  const _LikesInTab({
    required this.isBlurred,
    required this.isDark,
    required this.textColor,
    required this.primaryRed,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likesAsync = ref.watch(likesInProvider(null));

    return RefreshIndicator(
      color: primaryRed,
      onRefresh: () async => ref.invalidate(likesInProvider),
      child: likesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: primaryRed)),
        error: (e, _) => ListView(
          children: [
            SizedBox(
              height: 300,
              child: _ErrorMessage(message: e.toString(), textColor: textColor),
            ),
          ],
        ),
        data: (data) {
          final users = data['users'] as List<InboxUser>? ?? [];
          if (users.isEmpty) {
            return ListView(
              children: [
                SizedBox(
                  height: 300,
                  child: _EmptyMessage(
                    icon: Icons.favorite_border,
                    text: 'No one has liked you yet',
                    subtext: 'Keep your profile active and start swiping!',
                    textColor: textColor,
                  ),
                ),
              ],
            );
          }
          return _UserGrid(
            users: users,
            isBlurred: isBlurred,
            gateFullGrid: true,
            isDark: isDark,
            textColor: textColor,
            primaryRed: primaryRed,
            surfaceColor: surfaceColor,
            premiumLabel: 'See who likes you',
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Visitors tab
// ──────────────────────────────────────────────
class _VisitorsTab extends ConsumerWidget {
  final bool isBlurred;
  final bool isDark;
  final Color textColor;
  final Color primaryRed;
  final Color surfaceColor;

  const _VisitorsTab({
    required this.isBlurred,
    required this.isDark,
    required this.textColor,
    required this.primaryRed,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visitorsAsync = ref.watch(visitorsListProvider(null));

    return RefreshIndicator(
      color: primaryRed,
      onRefresh: () async => ref.invalidate(visitorsListProvider),
      child: visitorsAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: primaryRed)),
        error: (e, _) => ListView(
          children: [
            SizedBox(
              height: 300,
              child: _ErrorMessage(message: e.toString(), textColor: textColor),
            ),
          ],
        ),
        data: (data) {
          final users = data['users'] as List<InboxUser>? ?? [];
          if (users.isEmpty) {
            return ListView(
              children: [
                SizedBox(
                  height: 300,
                  child: _EmptyMessage(
                    icon: Icons.visibility_outlined,
                    text: 'No profile visitors yet',
                    subtext: 'People who view your profile will appear here.',
                    textColor: textColor,
                  ),
                ),
              ],
            );
          }
          return _UserGrid(
            users: users,
            isBlurred: isBlurred,
            gateFullGrid: true,
            isDark: isDark,
            textColor: textColor,
            primaryRed: primaryRed,
            surfaceColor: surfaceColor,
            premiumLabel: 'See who visited you',
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Matches tab
// ──────────────────────────────────────────────
class _MatchesTab extends ConsumerWidget {
  final bool isDark;
  final Color textColor;
  final Color primaryRed;
  final Color surfaceColor;

  const _MatchesTab({
    required this.isDark,
    required this.textColor,
    required this.primaryRed,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(matchesListProvider(null));

    return RefreshIndicator(
      color: primaryRed,
      onRefresh: () async => ref.invalidate(matchesListProvider),
      child: matchesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: primaryRed)),
        error: (e, _) => ListView(
          children: [
            SizedBox(
              height: 300,
              child: _ErrorMessage(message: e.toString(), textColor: textColor),
            ),
          ],
        ),
        data: (data) {
          final users = data['matches'] as List<InboxUser>? ?? [];
          if (users.isEmpty) {
            return ListView(
              children: [
                SizedBox(
                  height: 300,
                  child: _EmptyMessage(
                    icon: Icons.people_outline,
                    text: 'No matches yet',
                    subtext: 'Start swiping to connect with people!',
                    textColor: textColor,
                  ),
                ),
              ],
            );
          }
          return _MatchesHorizontalList(
            users: users,
            textColor: textColor,
            primaryRed: primaryRed,
            surfaceColor: surfaceColor,
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────
// My likes tab (outgoing likes — always visible)
// ──────────────────────────────────────────────
class _MyLikesTab extends ConsumerWidget {
  final bool isDark;
  final Color textColor;
  final Color primaryRed;
  final Color surfaceColor;

  const _MyLikesTab({
    required this.isDark,
    required this.textColor,
    required this.primaryRed,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myLikesAsync = ref.watch(myLikesListProvider(null));

    return RefreshIndicator(
      color: primaryRed,
      onRefresh: () async => ref.invalidate(myLikesListProvider),
      child: myLikesAsync.when(
        loading: () => Center(child: CircularProgressIndicator(color: primaryRed)),
        error: (e, _) => ListView(
          children: [
            SizedBox(
              height: 300,
              child: _ErrorMessage(message: e.toString(), textColor: textColor),
            ),
          ],
        ),
        data: (data) {
          final users = data['users'] as List<InboxUser>? ?? [];
          if (users.isEmpty) {
            return ListView(
              children: [
                SizedBox(
                  height: 300,
                  child: _EmptyMessage(
                    icon: Icons.favorite_outline,
                    text: 'No likes sent yet',
                    subtext: 'Profiles you swipe right on will show up here.',
                    textColor: textColor,
                  ),
                ),
              ],
            );
          }
          return _UserGrid(
            users: users,
            isBlurred: false,
            gateFullGrid: false,
            isDark: isDark,
            textColor: textColor,
            primaryRed: primaryRed,
            surfaceColor: surfaceColor,
            premiumLabel: '',
          );
        },
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Matches — horizontal row with profile + chat
// ──────────────────────────────────────────────
class _MatchesHorizontalList extends StatelessWidget {
  final List<InboxUser> users;
  final Color textColor;
  final Color primaryRed;
  final Color surfaceColor;

  const _MatchesHorizontalList({
    required this.users,
    required this.textColor,
    required this.primaryRed,
    required this.surfaceColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(width: 14),
      itemBuilder: (context, i) {
        final u = users[i];
        final photoUrl = u.photoUrls.isNotEmpty ? u.photoUrls.first : null;
        return SizedBox(
          width: 108,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => context.push('/profile/${u.id}'),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: 0.78,
                    child: photoUrl != null
                        ? CachedNetworkImage(
                            imageUrl: photoUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: surfaceColor),
                            errorWidget: (_, __, ___) => Container(
                              color: surfaceColor,
                              child: Center(
                                child: Text(
                                  u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                                  style: AppTextStyles.headerBold(
                                    color: textColor,
                                    fontSize: 28,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: surfaceColor,
                            child: Center(
                              child: Text(
                                u.name.isNotEmpty ? u.name[0].toUpperCase() : '?',
                                style: AppTextStyles.headerBold(
                                  color: textColor,
                                  fontSize: 28,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                u.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyRegular(
                  color: textColor,
                  fontSize: 13,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    onPressed: () => context.push('/profile/${u.id}'),
                    icon: Icon(Icons.person_outline, color: textColor.withOpacity(0.75), size: 22),
                    tooltip: 'Profile',
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    onPressed: () =>
                        context.push('/chat/${Uri.encodeComponent(u.id)}'),
                    icon: Icon(Icons.chat_bubble_outline, color: primaryRed, size: 22),
                    tooltip: 'Chat',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────
// Shared grid
// ──────────────────────────────────────────────
class _UserGrid extends StatelessWidget {
  final List<InboxUser> users;
  final bool isBlurred;
  /// When [isBlurred] is true, blur every cell and send taps to premium (who liked / visitors).
  final bool gateFullGrid;
  final bool isDark;
  final Color textColor;
  final Color primaryRed;
  final Color surfaceColor;
  final String premiumLabel;

  const _UserGrid({
    required this.users,
    required this.isBlurred,
    this.gateFullGrid = false,
    required this.isDark,
    required this.textColor,
    required this.primaryRed,
    required this.surfaceColor,
    required this.premiumLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemCount: users.length,
          itemBuilder: (context, i) {
            final cardBlurred = isBlurred && (gateFullGrid || i > 0);
            return _UserGridCard(
              user: users[i],
              isBlurred: cardBlurred,
              isDark: isDark,
              textColor: textColor,
              surfaceColor: surfaceColor,
              onTap: cardBlurred
                  ? () => context.push('/premium')
                  : () => context.push('/profile/${users[i].id}'),
            );
          },
        ),

        // Premium overlay when blurred
        if (isBlurred)
          PremiumUnlockBanner(
            isDark: isDark,
            primaryColor: primaryRed,
            label: premiumLabel,
            onTap: () => context.push('/premium'),
          ),
      ],
    );
  }
}

class _UserGridCard extends StatelessWidget {
  final InboxUser user;
  final bool isBlurred;
  final bool isDark;
  final Color textColor;
  final Color surfaceColor;
  final VoidCallback onTap;

  const _UserGridCard({
    required this.user,
    required this.isBlurred,
    required this.isDark,
    required this.textColor,
    required this.surfaceColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = user.photoUrls.isNotEmpty ? user.photoUrls.first : null;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Photo
          if (photoUrl != null)
            CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: surfaceColor),
              errorWidget: (_, __, ___) => Container(
                color: surfaceColor,
                child: Center(
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                    style: AppTextStyles.headerBold(color: textColor, fontSize: 36),
                  ),
                ),
              ),
            )
          else
            Container(
              color: surfaceColor,
              child: Center(
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: AppTextStyles.headerBold(color: textColor, fontSize: 36),
                ),
              ),
            ),

          // Blur overlay for locked cards
          if (isBlurred)
            const PremiumLockedOverlay(),

          // Gradient + name
          if (!isBlurred) ...[
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Color(0xCC000000), Colors.transparent],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyRegular(
                  color: Colors.white,
                  fontSize: 13,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    ),
  );
  }
}

// ──────────────────────────────────────────────
// Utility widgets
// ──────────────────────────────────────────────
class _EmptyMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  final String subtext;
  final Color textColor;
  const _EmptyMessage({
    required this.icon,
    required this.text,
    required this.subtext,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: textColor.withOpacity(0.2)),
            const SizedBox(height: 16),
            Text(
              text,
              style: AppTextStyles.headerSemiBold(color: textColor, fontSize: 17),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtext,
              style: AppTextStyles.bodyRegular(
                color: textColor.withOpacity(0.5),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String message;
  final Color textColor;
  const _ErrorMessage({required this.message, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Could not load: $message',
        style: AppTextStyles.bodyRegular(color: textColor.withOpacity(0.55)),
        textAlign: TextAlign.center,
      ),
    );
  }
}

