import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/notification_settings_provider.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../domain/models/profile_model.dart';
import '../../auth/auth_provider.dart';
import '../profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // ── edit-profile state ──────────────────────────────────────────────────
  final _bioController = TextEditingController();
  bool _editingBio = false;

  // ── discovery settings ──────────────────────────────────────────────────
  RangeValues _ageRange = const RangeValues(18, 50);
  double _discoveryRadius = 50;
  String _preferredGender = '';

  bool _settingsDirty = false;
  bool _savingSettings = false;

  // ── filled from loaded profile ──────────────────────────────────────────
  bool _initialised = false;

  RangeValues _sanitizeAgeRange(int minAgeRange, int maxAgeRange) {
    var start = minAgeRange.clamp(18, 80).toDouble();
    var end = maxAgeRange.clamp(18, 80).toDouble();
    if (start > end) {
      final tmp = start;
      start = end;
      end = tmp;
    }
    return RangeValues(start, end);
  }

  void _initFromProfile(Profile p) {
    if (_initialised) return;
    _initialised = true;
    _bioController.text = p.bio;
    _ageRange = _sanitizeAgeRange(p.minAgeRange, p.maxAgeRange);
    _discoveryRadius = p.discoveryRadius.toDouble();
    _preferredGender = p.preferredGender;
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Future<void> _saveSettings(Profile current) async {
    setState(() => _savingSettings = true);
    final updated = current.copyWith(
      bio: _bioController.text.trim(),
      minAgeRange: _ageRange.start.round(),
      maxAgeRange: _ageRange.end.round(),
      discoveryRadius: _discoveryRadius.round(),
      preferredGender: _preferredGender,
    );
    await ref.read(profileStateProvider.notifier).updateProfile(updated);
    if (mounted) {
      setState(() {
        _savingSettings = false;
        _settingsDirty = false;
        _editingBio = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  Future<void> _logout() async {
    await ref.read(authStateProvider.notifier).logout();
    // GoRouter redirect guard will push back to '/' automatically.
  }

  Future<void> _hideAccount() async {
    final confirmed = await _confirm(
      title: 'Hide account?',
      body:
          'Your profile will disappear from Discover. You can restore it by toggling "Show me in Discover" in settings.',
      confirmLabel: 'Hide',
    );
    if (!confirmed) return;
    await ref.read(profileStateProvider.notifier).hideAccount();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account hidden')),
      );
      await _logout();
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await _confirm(
      title: 'Delete account?',
      body:
          'This is permanent. All your photos, matches, and messages will be deleted and cannot be recovered.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(profileStateProvider.notifier).deleteAccount();
    if (mounted) await _logout();
  }

  Future<bool> _confirm({
    required String title,
    required String body,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        title: Text(title,
            style: TextStyle(
                color: textColor, fontWeight: FontWeight.bold)),
        content: Text(body, style: TextStyle(color: textColor.withOpacity(0.75))),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: TextStyle(color: textColor.withOpacity(0.6))),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: destructive
                    ? Colors.red
                    : (isDark
                        ? AppColors.darkPrimaryAction
                        : AppColors.lightPrimaryAction),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ── orientation options ─────────────────────────────────────────────────
  static const _orientations = [
    'Any',
    'Straight',
    'Gay',
    'Bi',
    'Lesbian',
    'Couple',
  ];

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final primary =
        isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final subColor = textColor.withOpacity(0.55);

    final authState = ref.watch(authStateProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final themeMode = ref.watch(themeProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Row(
          children: [
            const AppBrandLogo(size: 32, borderRadius: 9),
            const SizedBox(width: 10),
            Text(
              'My Profile',
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        actions: [
          if (_settingsDirty)
            profileAsync.whenOrNull(
              data: (p) => _savingSettings
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))),
                    )
                  : TextButton(
                      onPressed: () => _saveSettings(p),
                      child: Text('Save',
                          style: TextStyle(
                              color: primary, fontWeight: FontWeight.bold)),
                    ),
            ) ??
            const SizedBox.shrink(),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Could not load profile.\n$e',
              textAlign: TextAlign.center,
              style: TextStyle(color: subColor)),
        ),
        data: (profile) {
          _initFromProfile(profile);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              const SizedBox(height: 12),

              // ── Header ────────────────────────────────────────────────
              _Header(
                name: authState.user?.name ?? '',
                email: authState.user?.email ?? '',
                surface: surface,
                textColor: textColor,
                subColor: subColor,
                primary: primary,
              ),
              const SizedBox(height: 20),

              // ── Bio ──────────────────────────────────────────────────
              _SectionCard(
                surface: surface,
                title: 'Bio',
                trailing: _editingBio
                    ? null
                    : TextButton(
                        onPressed: () =>
                            setState(() => _editingBio = true),
                        child: Text('Edit',
                            style: TextStyle(color: primary, fontSize: 13)),
                      ),
                child: _editingBio
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _bioController,
                            maxLines: 4,
                            maxLength: 2000,
                            style: TextStyle(color: textColor, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Tell people about yourself…',
                              hintStyle: TextStyle(color: subColor),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: primary.withOpacity(0.4)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: primary),
                              ),
                              counterStyle: TextStyle(color: subColor),
                            ),
                            onChanged: (_) =>
                                setState(() => _settingsDirty = true),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => setState(() {
                                _editingBio = false;
                                _bioController.text = profile.bio;
                              }),
                              child: Text('Cancel',
                                  style: TextStyle(
                                      color: subColor, fontSize: 13)),
                            ),
                          ),
                        ],
                      )
                    : Text(
                        profile.bio.isEmpty
                            ? 'Tap Edit to add a bio'
                            : profile.bio,
                        style: TextStyle(
                            color: profile.bio.isEmpty
                                ? subColor
                                : textColor,
                            fontSize: 14),
                      ),
              ),
              const SizedBox(height: 16),

              // ── Discovery Settings ────────────────────────────────────
              _SectionCard(
                surface: surface,
                title: 'Discovery Settings',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Orientation preference chips
                    Text('Show me',
                        style:
                            TextStyle(color: subColor, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _orientations.map((o) {
                        final selected = _preferredGender == o ||
                            (_preferredGender.isEmpty && o == 'Any');
                        return GestureDetector(
                          onTap: () => setState(() {
                            _preferredGender = o == 'Any' ? '' : o;
                            _settingsDirty = true;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: selected
                                  ? primary
                                  : surface.withOpacity(0.0),
                              border: Border.all(
                                  color: selected
                                      ? primary
                                      : subColor.withOpacity(0.35),
                                  width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(o,
                                style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : subColor,
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.normal)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // Age range
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Age range',
                            style: TextStyle(color: subColor, fontSize: 12)),
                        Text(
                          '${_ageRange.start.round()}–${_ageRange.end.round()}',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: primary,
                        thumbColor: primary,
                        inactiveTrackColor: subColor.withOpacity(0.25),
                        overlayColor: primary.withOpacity(0.15),
                      ),
                      child: RangeSlider(
                        values: _ageRange,
                        min: 18,
                        max: 80,
                        divisions: 62,
                        onChanged: (v) => setState(() {
                          _ageRange = v;
                          _settingsDirty = true;
                        }),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Discovery radius
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Discovery radius',
                            style: TextStyle(color: subColor, fontSize: 12)),
                        Text(
                          '${_discoveryRadius.round()} km',
                          style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: primary,
                        thumbColor: primary,
                        inactiveTrackColor: subColor.withOpacity(0.25),
                        overlayColor: primary.withOpacity(0.15),
                      ),
                      child: Slider(
                        value: _discoveryRadius,
                        min: 1,
                        max: 500,
                        divisions: 99,
                        onChanged: (v) => setState(() {
                          _discoveryRadius = v;
                          _settingsDirty = true;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── App Settings ─────────────────────────────────────────
              _SectionCard(
                surface: surface,
                title: 'App Settings',
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              themeMode == ThemeMode.dark
                                  ? Icons.dark_mode_outlined
                                  : Icons.light_mode_outlined,
                              color: subColor,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text('Dark mode',
                                style:
                                    TextStyle(color: textColor, fontSize: 15)),
                          ],
                        ),
                        Switch(
                          value: themeMode == ThemeMode.dark,
                          onChanged: (val) {
                            ref.read(themeProvider.notifier).toggle(val);
                          },
                          activeThumbColor: primary,
                        ),
                      ],
                    ),
                    Divider(color: subColor.withOpacity(0.12), height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications_outlined,
                                color: subColor,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Push notifications',
                                      style: TextStyle(color: textColor, fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Matches and messages on this device',
                                      style: TextStyle(color: subColor, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: notificationSettings.isEnabled,
                          onChanged: notificationSettings.isLoading
                              ? null
                              : (val) async {
                                  final enabled = await ref
                                      .read(notificationSettingsProvider.notifier)
                                      .setEnabled(val);
                                  if (!enabled && val && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Notifications permission was not granted.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                          activeThumbColor: primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Account ───────────────────────────────────────────────
              _SectionCard(
                surface: surface,
                title: 'Account',
                child: Column(
                  children: [
                    _AccountTile(
                      icon: Icons.logout,
                      label: 'Log out',
                      textColor: textColor,
                      iconColor: subColor,
                      onTap: _logout,
                    ),
                    Divider(color: subColor.withOpacity(0.12), height: 1),
                    _AccountTile(
                      icon: Icons.visibility_off_outlined,
                      label: 'Hide account',
                      textColor: textColor,
                      iconColor: subColor,
                      onTap: _hideAccount,
                    ),
                    Divider(color: subColor.withOpacity(0.12), height: 1),
                    _AccountTile(
                      icon: Icons.delete_outline,
                      label: 'Delete account',
                      textColor: Colors.red,
                      iconColor: Colors.red.withOpacity(0.7),
                      onTap: _deleteAccount,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Small helper widgets ───────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.email,
    required this.surface,
    required this.textColor,
    required this.subColor,
    required this.primary,
  });

  final String name;
  final String email;
  final Color surface;
  final Color textColor;
  final Color subColor;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';
    return Row(
      children: [
        CircleAvatar(
          radius: 38,
          backgroundColor: primary.withOpacity(0.15),
          child: Text(
            initials,
            style: TextStyle(
                color: primary,
                fontSize: 26,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'Your Name' : name,
                style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              if (email.isNotEmpty)
                Text(email,
                    style: TextStyle(color: subColor, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.surface,
    required this.title,
    required this.child,
    this.trailing,
  });

  final Color surface;
  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                    color: textColor.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.label,
    required this.textColor,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color textColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.chevron_right,
                color: iconColor.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }
}

