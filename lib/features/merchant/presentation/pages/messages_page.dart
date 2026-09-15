import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MessagesPage extends ConsumerWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          const MerchantBackHeader(title: 'Messages'),
          Expanded(
            child: conversations.when(
              loading: () => const AppLoader(),
              error: (error, _) => Center(
                child: Text(error.toString().replaceFirst('Exception: ', '')),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return const Center(child: Text('Aucun message'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return MerchantCard(
                      onTap: () => context.push(
                        AppRoutes.messageThreadPath(item.partnerId),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.secondary,
                            child: Text(
                              item.partnerName.isEmpty
                                  ? 'C'
                                  : item.partnerName[0].toUpperCase(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.partnerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  item.lastMessage ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (item.unreadCount > 0)
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: AppColors.accent,
                              child: Text(
                                '${item.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MessageThreadPage extends ConsumerStatefulWidget {
  const MessageThreadPage({super.key, required this.partnerId});

  final int partnerId;

  @override
  ConsumerState<MessageThreadPage> createState() => _MessageThreadPageState();
}

class _MessageThreadPageState extends ConsumerState<MessageThreadPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await ref.read(merchantRepositoryProvider).sendMessage(
          receiverId: widget.partnerId,
          content: text,
        );
    _controller.clear();
    ref.invalidate(messagesProvider(widget.partnerId));
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider(widget.partnerId));
    final myId = ref.watch(authNotifierProvider).user?.id;

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          const MerchantBackHeader(title: 'Messages'),
          Expanded(
            child: messages.when(
              loading: () => const AppLoader(),
              error: (error, _) => Center(
                child: Text(error.toString().replaceFirst('Exception: ', '')),
              ),
              data: (items) {
                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final message = items[index];
                    final mine = message.senderId == myId;
                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: mine ? AppColors.accent : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          message.content,
                          style: TextStyle(
                            color: mine ? Colors.white : AppColors.primary,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Écrire un message',
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded, color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
