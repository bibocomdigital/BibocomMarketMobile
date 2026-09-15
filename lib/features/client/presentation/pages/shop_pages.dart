import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/helpers/formatters.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/client/presentation/widgets/product_card.dart';
import 'package:bibomarketmobile/features/client/providers/client_providers.dart';
import 'package:bibomarketmobile/shared/helpers/context_extensions.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:bibomarketmobile/shared/widgets/error_view.dart';
import 'package:bibomarketmobile/shared/widgets/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopsPage extends ConsumerWidget {
  const ShopsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shops = ref.watch(shopsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Boutiques')),
      body: shops.when(
        loading: () => const AppLoader(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(shopsProvider),
        ),
        data: (items) {
          if (items.isEmpty) return const EmptyState(message: 'Aucune boutique.');
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(shopsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final shop = items[index];
                return AppCard(
                  onTap: () => context.push('${AppRoutes.shop}/${shop.id}'),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          shop.name.isEmpty ? 'B' : shop.name[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(shop.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(shop.categoryName ?? shop.address ?? ''),
                            Text(PhoneFormat.mali(shop.phoneNumber)),
                          ],
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight, color: AppColors.primary),
                    ],
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

class ShopDetailPage extends ConsumerStatefulWidget {
  const ShopDetailPage({super.key, required this.shopId});

  final int shopId;

  @override
  ConsumerState<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends ConsumerState<ShopDetailPage> {
  bool _followLoading = false;

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(shopDetailsProvider(widget.shopId));
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Boutique'),
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Produits'),
              Tab(text: 'À propos'),
              Tab(text: 'Contact'),
            ],
          ),
        ),
        body: details.when(
          loading: () => const AppLoader(),
          error: (error, _) => ErrorView(message: error.toString()),
          data: (data) {
            final ownerId = data.shop.ownerId;
            final follow = ownerId == null ? null : ref.watch(followInfoProvider(ownerId));
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.shop.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        if (data.shop.categoryName != null) Text(data.shop.categoryName!),
                        follow?.when(
                              loading: () => const SizedBox.shrink(),
                              error: (_, __) => const SizedBox.shrink(),
                              data: (info) => Text('${info.followerCount} abonnés'),
                            ) ??
                            const SizedBox.shrink(),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (ownerId != null)
                              Expanded(
                                child: CoralButton(
                                  label: follow?.value?.isFollowing == true ? 'Abonné' : 'S’abonner',
                                  loading: _followLoading,
                                  onPressed: () async {
                                    setState(() => _followLoading = true);
                                    final result = await ref.read(clientRepositoryProvider).toggleFollow(ownerId);
                                    if (!mounted) return;
                                    setState(() => _followLoading = false);
                                    result.fold(
                                      failure: (failure) => context.showSnack(failure.message),
                                      success: (_) {
                                        ref.invalidate(followInfoProvider(ownerId));
                                        ref.invalidate(followingProvider);
                                      },
                                    );
                                  },
                                ),
                              ),
                            if (ownerId != null) const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: data.shop.phoneNumber.isEmpty
                                    ? null
                                    : () => launchUrl(
                                          Uri.parse(
                                            'https://wa.me/${PhoneFormat.digitsForWhatsApp(data.shop.phoneNumber)}',
                                          ),
                                          mode: LaunchMode.externalApplication,
                                        ),
                                icon: const Icon(LucideIcons.messageCircle),
                                label: const Text('WhatsApp'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      data.products.isEmpty
                          ? const EmptyState(message: 'Aucun produit publié.')
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: data.products.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.68,
                              ),
                              itemBuilder: (context, index) => ProductCard(product: data.products[index]),
                            ),
                      ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data.shop.description?.isNotEmpty == true
                                    ? data.shop.description!
                                    : 'Aucune description.'),
                                const SizedBox(height: 8),
                                if (data.shop.address != null)
                                  Text('Adresse : ${data.shop.address}'),
                                Text('Téléphone : ${PhoneFormat.mali(data.shop.phoneNumber)}'),
                                if (data.shop.totalProducts != null)
                                  Text('${data.shop.totalProducts} produits'),
                                if (data.shop.memberSince != null)
                                  Text('Membre depuis ${DateFormatFr.day(data.shop.memberSince!)}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        children: [
                          CoralButton(
                            label: 'Contacter la boutique',
                            onPressed: () => context.push('${AppRoutes.shopContact}/${widget.shopId}'),
                          ),
                          if (ownerId != null)
                            TextButton(
                              onPressed: () => context.push(
                                '${AppRoutes.chat}?partnerId=$ownerId&name=${Uri.encodeComponent(data.shop.name)}',
                              ),
                              child: const Text('Ouvrir le chat'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ShopContactPage extends ConsumerStatefulWidget {
  const ShopContactPage({super.key, required this.shopId});

  final int shopId;

  @override
  ConsumerState<ShopContactPage> createState() => _ShopContactPageState();
}

class _ShopContactPageState extends ConsumerState<ShopContactPage> {
  final _subject = TextEditingController();
  final _message = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(shopDetailsProvider(widget.shopId)).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Contacter la boutique')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(details?.shop.name ?? 'Boutique', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          const SizedBox(height: 12),
          TextField(controller: _subject, decoration: const InputDecoration(labelText: 'Sujet')),
          const SizedBox(height: 12),
          TextField(
            controller: _message,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          const SizedBox(height: 24),
          CoralButton(
            label: 'Envoyer',
            loading: _loading,
            onPressed: () async {
              if (_message.text.trim().isEmpty) {
                context.showSnack('Message requis');
                return;
              }
              setState(() => _loading = true);
              final result = await ref.read(clientRepositoryProvider).contactShop(
                    shopId: widget.shopId,
                    subject: _subject.text.trim().isEmpty ? 'Contact boutique' : _subject.text.trim(),
                    message: _message.text.trim(),
                  );
              if (!mounted) return;
              setState(() => _loading = false);
              result.fold(
                failure: (failure) => context.showSnack(failure.message),
                success: (_) {
                  context.showSnack('Message envoyé');
                  context.pop();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
