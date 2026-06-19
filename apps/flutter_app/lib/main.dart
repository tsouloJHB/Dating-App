import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/dio_provider.dart';
import 'core/services/location_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/app_widgets.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/google_sign_in_web_listener.dart';
import 'features/auth/presentation/welcome_screen.dart';
import 'features/auth/presentation/sign_in_screen.dart';
import 'features/auth/presentation/sign_up_screen.dart';
import 'features/discover/presentation/discover_screen.dart';
import 'features/activity/presentation/activity_screen.dart';
import 'features/chat/presentation/chat_screen.dart';
import 'features/chat/presentation/conversation_screen.dart';
import 'features/profile/profile_provider.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/profile/presentation/profile_detail_screen.dart';
import 'features/premium/presentation/premium_screen.dart';

import 'core/bootstrap/url_strategy_stub.dart'
    if (dart.library.html) 'core/bootstrap/url_strategy_web.dart'
    as url_strategy;
import 'core/bootstrap/firebase_bootstrap.dart';
import 'core/bootstrap/google_sign_in_bootstrap.dart';
import 'features/auth/presentation/google_profile_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ensureFirebaseInitialized();
  await ensureGoogleSignInInitialized();
  url_strategy.configureAppUrlStrategy();
  runApp(
    const ProviderScope(
      child: _AppBootstrap(),
    ),
  );
}

/// Waits for [dioProvider] so auth and API layers always see an initialized client.
class _AppBootstrap extends ConsumerWidget {
  const _AppBootstrap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dioInit = ref.watch(dioProvider);
    return dioInit.when(
      data: (_) => const JustHookupsApp(),
      loading: () => MaterialApp(
        theme: AppTheme.lightTheme(),
        home: const Scaffold(
          backgroundColor: AppColors.lightBackground,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppBrandLogo(size: 88, borderRadius: 22),
                SizedBox(height: 28),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
      error: (e, _) => MaterialApp(
        theme: AppTheme.lightTheme(),
        home: Scaffold(
          backgroundColor: AppColors.lightBackground,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Could not start app: $e', textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}

class JustHookupsApp extends ConsumerStatefulWidget {
  const JustHookupsApp({super.key});

  @override
  ConsumerState<JustHookupsApp> createState() => _JustHookupsAppState();
}

class _JustHookupsAppState extends ConsumerState<JustHookupsApp> {
  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      if (authState.bootstrapPending) {
        return null;
      }
      final isAuthenticated = authState.isAuthenticated;
      final profileSetupPending = authState.profileSetupPending;
      final profileSetupRoute = authState.profileSetupRoute;

      if (isAuthenticated &&
          profileSetupPending &&
          profileSetupRoute != null &&
          state.matchedLocation != profileSetupRoute) {
        return profileSetupRoute;
      }

      final isOnAuthRoute = state.matchedLocation == '/' ||
          state.matchedLocation == '/sign-in' ||
          state.matchedLocation == '/sign-up';

      if (isAuthenticated && isOnAuthRoute) {
        if (profileSetupPending && state.matchedLocation == '/sign-up') {
          return null;
        }
        return '/home';
      }

      if (state.matchedLocation == '/google-profile-setup') {
        if (!isAuthenticated) return '/';
        if (!profileSetupPending) return '/home';
      }

      final isProtectedRoute = !isOnAuthRoute &&
          state.matchedLocation != '/google-profile-setup';
      if (!isAuthenticated && isProtectedRoute) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/google-profile-setup',
        builder: (context, state) => const GoogleProfileSetupScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/discover',
        builder: (context, state) => const DiscoverScreen(),
      ),
      GoRoute(
        path: '/activity',
        builder: (context, state) => const ActivityScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/chat/:threadId',
        builder: (context, state) {
          final threadId = state.pathParameters['threadId'] ?? '';
          return ConversationScreen(threadId: threadId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: '/profile/:id',
        builder: (context, state) {
          final userId = state.pathParameters['id'] ?? '';
          return ProfileDetailScreen(userId: userId);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);
    final authState = ref.watch(authStateProvider);
    ref.watch(googleSignInWebAuthListenerProvider);

    ref.listen<AuthState>(authStateProvider, (_, __) {
      _router.refresh();
    });

    return MaterialApp.router(
      title: 'JustHookups',
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode:
          themeMode == ThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (authState.bootstrapPending) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppBrandLogo(size: 88, borderRadius: 22),
                  const SizedBox(height: 28),
                  CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          );
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}

/// App shell — restores session on first build then shows bottom nav.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _postLoginPermissionsAskedKey = 'post_login_permissions_asked';

  int _selectedIndex = 0;
  final _locationService = LocationServiceImpl();
  final _notificationService = NotificationServiceImpl();

  final _screens = const [
    DiscoverScreen(),
    ActivityScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPostLoginPermissionsIfNeeded();
    });
  }

  Future<void> _requestPostLoginPermissionsIfNeeded() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final alreadyAsked = prefs.getBool(_postLoginPermissionsAskedKey) ?? false;
    if (alreadyAsked) return;

    await prefs.setBool(_postLoginPermissionsAskedKey, true);

    if (!mounted) return;
    final wantsLocation = await _showPermissionRationale(
      title: 'Enable Location',
      message:
          'JustHookups uses your location to show people nearby and power distance filters in Discover.',
      confirmLabel: 'Allow Location',
    );

    if (wantsLocation && mounted) {
      try {
        final granted = await _locationService.requestLocationPermission();
        if (!granted && mounted) {
          _showSnack('Location permission denied. You can enable it later in settings.');
        } else {
          final location = await _locationService.getCurrentLocation();
          if (location?.latitude != null && location?.longitude != null) {
            try {
              await ref.read(profileStateProvider.notifier).syncLocation(
                    latitude: location!.latitude!,
                    longitude: location.longitude!,
                  );
            } catch (_) {
              if (mounted) {
                _showSnack('Could not sync location right now. We will try again later.');
              }
            }
          }
        }
      } catch (_) {
        if (mounted) {
          _showSnack('Location setup is unavailable on this device.');
        }
      }
    }

    if (!mounted) return;
    final wantsNotifications = await _showPermissionRationale(
      title: 'Enable Notifications',
      message:
          'Turn on notifications so you never miss new matches and incoming messages.',
      confirmLabel: 'Allow Notifications',
    );

    if (wantsNotifications && mounted) {
      try {
        final granted = await _notificationService.setEnabled(true);
        if (!granted && mounted) {
          _showSnack('Notifications are off. You can enable them later in settings.');
        }
      } catch (_) {
        if (mounted) {
          _showSnack('Notification setup is unavailable on this device.');
        }
      }
    }
  }

  Future<bool> _showPermissionRationale({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primaryRed =
        isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: surfaceColor,
          title: Text(
            title,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
          ),
          content: Text(
            message,
            style: TextStyle(color: textColor.withOpacity(0.75)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Not now',
                style: TextStyle(color: textColor.withOpacity(0.6)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                confirmLabel,
                style: TextStyle(color: primaryRed, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.darkPrimaryAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final selectedColor = isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction;
    final unselectedColor =
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary).withOpacity(0.45);
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: bg,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceColor,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_fire_department_outlined),
            activeIcon: Icon(Icons.local_fire_department),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox_outlined),
            activeIcon: Icon(Icons.inbox),
            label: 'Inbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'My Account',
          ),
        ],
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

