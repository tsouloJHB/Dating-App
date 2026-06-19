import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationServiceImpl();
});

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettingsState>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationSettingsNotifier(service);
});

class NotificationSettingsState {
  const NotificationSettingsState({
    this.isEnabled = false,
    this.isLoading = false,
    this.error,
  });

  final bool isEnabled;
  final bool isLoading;
  final String? error;

  NotificationSettingsState copyWith({
    bool? isEnabled,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return NotificationSettingsState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettingsState> {
  NotificationSettingsNotifier(this._service)
      : super(const NotificationSettingsState(isLoading: true)) {
    Future.microtask(_load);
  }

  final NotificationService _service;

  Future<void> _load() async {
    try {
      final enabled = await _service.isEnabled();
      state = state.copyWith(
        isEnabled: enabled,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> setEnabled(bool enabled) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final isEnabled = await _service.setEnabled(enabled);
      state = state.copyWith(
        isEnabled: isEnabled,
        isLoading: false,
      );
      return isEnabled;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }
}