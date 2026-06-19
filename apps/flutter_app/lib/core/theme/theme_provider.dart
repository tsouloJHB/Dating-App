import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _themeModePrefKey = 'theme_mode';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
	return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
	ThemeNotifier() : super(ThemeMode.dark) {
		_loadFromStorage();
	}

	Future<void> _loadFromStorage() async {
		final prefs = await SharedPreferences.getInstance();
		final stored = prefs.getString(_themeModePrefKey);
		if (stored == 'light') {
			state = ThemeMode.light;
			return;
		}
		state = ThemeMode.dark;
	}

	Future<void> setThemeMode(ThemeMode mode) async {
		state = mode;
		final prefs = await SharedPreferences.getInstance();
		await prefs.setString(_themeModePrefKey, mode == ThemeMode.dark ? 'dark' : 'light');
	}

	Future<void> toggle(bool isDark) async {
		await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
	}
}
