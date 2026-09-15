import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/client/providers/client_providers.dart';
import 'package:bibomarketmobile/shared/helpers/context_extensions.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:bibomarketmobile/shared/widgets/error_view.dart';
import 'package:bibomarketmobile/shared/widgets/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ConversationsPage extends ConsumerWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: conversations.when(
        loading: () => const AppLoader(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(conversationsProvider),
        ),
        data: (items) {
          if (items.isEmpty) return const EmptyState(message: 'Aucun message.');
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(conversationsProvider),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.secondary,
                    child: Text(item.partnerName.isEmpty ? 'B' : item.partnerName[0]),
                  ),
                  title: Text(item.partnerName),
                  subtitle: Text(item.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: item.unreadCount > 0
                      ? CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.accent,
                          child: Text('${item.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                        )
                      : null,
                  onTap: () => context.push(
                    '${AppRoutes.chat}?partnerId=${item.partnerId}&name=${Uri.encodeComponent(item.partnerName)}',
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.partnerId, required this.partnerName});

  final int partnerId;
  final String partnerName;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(authNotifierProvider).user?.id;
    final thread = ref.watch(threadProvider(widget.partnerId));
    return Scaffold(
      appBar: AppBar(title: Text(widget.partnerName)),
      body: Column(
        children: [
          Expanded(
            child: thread.when(
              loading: () => const AppLoader(),
              error: (error, _) => ErrorView(message: error.toString()),
              data: (messages) {
                if (messages.isEmpty) return const EmptyState(message: 'Démarrez la conversation.');
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final mine = message.senderId == me;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: mine ? AppColors.accent : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              message.content,
                              style: TextStyle(color: mine ? Colors.white : AppColors.dark),
                            ),
                            if (mine)
                              Text(
                                message.isRead ? 'Lu' : 'Envoyé',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: mine ? Colors.white70 : Colors.black45,
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Écrire un message'),
                  ),
                ),
                IconButton(
                  onPressed: _sending
                      ? null
                      : () async {
                          final text = _controller.text.trim();
                          if (text.isEmpty) return;
                          setState(() => _sending = true);
                          final result = await ref
                              .read(clientRepositoryProvider)
                              .sendMessage(widget.partnerId, text);
                          if (!mounted) return;
                          setState(() => _sending = false);
                          result.fold(
                            failure: (failure) => context.showSnack(failure.message),
                            success: (_) {
                              _controller.clear();
                              ref.invalidate(threadProvider(widget.partnerId));
                              ref.invalidate(conversationsProvider);
                            },
                          );
                        },
                  icon: const Icon(LucideIcons.send, color: AppColors.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
