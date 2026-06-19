import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../domain/models/message_model.dart';
import '../chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      ref.invalidate(messageThreadsProvider);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final primary =
        isDark ? AppColors.darkPrimaryAction : AppColors.lightPrimaryAction;
    final subColor = textColor.withOpacity(0.6);

    final threadsAsync = ref.watch(messageThreadsProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Row(
          children: [
            const AppBrandLogo(size: 30, borderRadius: 9),
            const SizedBox(width: 12),
            Text(
              'Messages',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: threadsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Could not load messages.\n$e',
            textAlign: TextAlign.center,
            style: TextStyle(color: subColor),
          ),
        ),
        data: (threads) {
          if (threads.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'No conversations yet',
                  style: TextStyle(color: subColor, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
            itemCount: threads.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final t = threads[index];
              return _ThreadTile(
                thread: t,
                surface: surface,
                textColor: textColor,
                subColor: subColor,
                primary: primary,
                onTap: () => context.push('/chat/${Uri.encodeComponent(t.otherUserId)}'),
              );
            },
          );
        },
      ),
    );
  }
}

class _ThreadTile extends StatelessWidget {
  const _ThreadTile({
    required this.thread,
    required this.surface,
    required this.textColor,
    required this.subColor,
    required this.primary,
    required this.onTap,
  });

  final MessageThread thread;
  final Color surface;
  final Color textColor;
  final Color subColor;
  final Color primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = thread.otherUserName.trim().isEmpty ? 'Unknown' : thread.otherUserName;
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join()
        .toUpperCase();

    final stamp = _formatThreadRelativeTime(thread.lastMessageAt);

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: primary.withOpacity(0.15),
                backgroundImage: thread.otherUserPhoto != null
                    ? NetworkImage(thread.otherUserPhoto!)
                    : null,
                child: thread.otherUserPhoto == null
                    ? Text(
                        initials.isEmpty ? '?' : initials,
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      thread.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: subColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                stamp,
                style: TextStyle(color: subColor, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatThreadRelativeTime(DateTime at) {
  final now = DateTime.now();
  var diff = now.difference(at);
  if (diff.isNegative) diff = Duration.zero;
  if (diff.inSeconds < 45) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  if (diff.inDays < 365) return DateFormat.MMMd().format(at);
  return DateFormat.yMMMd().format(at);
}
