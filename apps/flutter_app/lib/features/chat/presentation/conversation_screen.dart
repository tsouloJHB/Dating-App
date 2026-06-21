import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../../domain/models/message_model.dart';
import '../../auth/auth_provider.dart';
import '../chat_provider.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key, required this.threadId});

  final String threadId;

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      ref.invalidate(messagesProvider(widget.threadId));
      ref.invalidate(messageThreadsProvider);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    ref.read(chatStateProvider.notifier).clearMessages();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await ref.read(chatStateProvider.notifier).sendMessage(
          recipientId: widget.threadId,
          content: text,
        );
    if (mounted) {
      ref.invalidate(messagesProvider(widget.threadId));
      ref.invalidate(messageThreadsProvider);
    }
  }

  Future<void> _pickAndSend({
    required ImageSource source,
    required bool video,
  }) async {
    final picked = video
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    await ref.read(chatStateProvider.notifier).sendAttachment(
          recipientId: widget.threadId,
          filePath: picked.path,
        );

    if (mounted) {
      ref.invalidate(messagesProvider(widget.threadId));
      ref.invalidate(messageThreadsProvider);
    }
  }

  Future<void> _showAttachSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Photo from camera'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _pickAndSend(source: ImageSource.camera, video: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Photo from gallery'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _pickAndSend(source: ImageSource.gallery, video: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: const Text('Video from camera'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _pickAndSend(source: ImageSource.camera, video: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library_outlined),
                title: const Text('Video from gallery'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _pickAndSend(source: ImageSource.gallery, video: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isImageUrl(String text) {
    final lower = text.toLowerCase();
    return (lower.startsWith('http://') || lower.startsWith('https://')) &&
        (lower.contains('.jpg') ||
            lower.contains('.jpeg') ||
            lower.contains('.png') ||
            lower.contains('.webp') ||
            lower.contains('/api/media/'));
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

    final auth = ref.watch(authStateProvider);
    final myUserId = auth.user?.id ?? '';
    final messagesAsync = ref.watch(messagesProvider(widget.threadId));
    final chatState = ref.watch(chatStateProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Row(
          children: [
            const AppBrandLogo(size: 30, borderRadius: 9),
            const SizedBox(width: 12),
            Text(
              'Chat',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Could not load messages.\n$e',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: subColor),
                ),
              ),
              data: (messages) {
                final merged = [
                  ...messages,
                  ...chatState.messages.where((m) =>
                      (m.senderId == myUserId && m.recipientId == widget.threadId) ||
                      (m.senderId == widget.threadId && m.recipientId == myUserId)),
                ];

                // de-duplicate by id while preserving order
                final seen = <String>{};
                final unique = <Message>[];
                for (final m in merged) {
                  if (seen.add(m.id)) unique.add(m);
                }

                if (unique.isEmpty) {
                  return Center(
                    child: Text(
                      'Say hi 👋',
                      style: TextStyle(color: subColor, fontSize: 14),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  itemCount: unique.length,
                  itemBuilder: (context, index) {
                    final m = unique[index];
                    final mine = m.senderId == myUserId;
                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 9),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.74,
                        ),
                        decoration: BoxDecoration(
                          color: mine ? primary : surface,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.content,
                              style: TextStyle(
                                color: mine ? Colors.white : textColor,
                                fontSize: 14,
                              ),
                            ),
                            if (_isImageUrl(m.content)) ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  m.content,
                                  width: 180,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 180,
                                    height: 80,
                                    alignment: Alignment.center,
                                    color: Colors.black12,
                                    child: const Text('Attachment'),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              '${m.sentAt.hour.toString().padLeft(2, '0')}:${m.sentAt.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: mine
                                    ? Colors.white.withOpacity(0.75)
                                    : subColor,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: chatState.isSending ? null : _showAttachSheet,
                  icon: const Icon(Icons.attach_file),
                  color: subColor,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Type a message…',
                      hintStyle: TextStyle(color: subColor),
                      filled: true,
                      fillColor: surface,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: chatState.isSending ? null : _send,
                  icon: chatState.isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
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
