import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/helpers/formatters.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/client/providers/client_providers.dart';
import 'package:bibomarketmobile/shared/helpers/context_extensions.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:bibomarketmobile/shared/widgets/error_view.dart';
import 'package:bibomarketmobile/shared/widgets/order_timeline.dart';
import 'package:bibomarketmobile/shared/widgets/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  bool _checkingOut = false;
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mon panier')),
      body: cart.when(
        loading: () => const AppLoader(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(cartProvider),
        ),
        data: (data) {
          if (data.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const EmptyState(
                      message: 'Votre panier est vide.\nDécouvrez nos produits.',
                      icon: LucideIcons.shoppingBag,
                    ),
                    CoralButton(
                      label: 'Découvrir des produits',
                      onPressed: () => context.go(AppRoutes.home),
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => ref.invalidate(cartProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: data.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = data.items[index];
                      return AppCard(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  if (item.shopName != null) Text(item.shopName!, style: const TextStyle(fontSize: 12)),
                                  Text(MoneyFormat.fcfa(item.price), style: const TextStyle(color: AppColors.accent)),
                                  Text('x${item.quantity} · ${MoneyFormat.fcfa(item.subtotal)}'),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: item.quantity <= 1
                                  ? null
                                  : () async {
                                      await ref.read(clientRepositoryProvider).updateCartItem(item.id, item.quantity - 1);
                                      ref.invalidate(cartProvider);
                                    },
                              icon: const Icon(LucideIcons.minus),
                            ),
                            IconButton(
                              onPressed: item.quantity >= item.stock
                                  ? null
                                  : () async {
                                      await ref.read(clientRepositoryProvider).updateCartItem(item.id, item.quantity + 1);
                                      ref.invalidate(cartProvider);
                                    },
                              icon: const Icon(LucideIcons.plus),
                            ),
                            IconButton(
                              onPressed: () async {
                                await ref.read(clientRepositoryProvider).removeCartItem(item.id);
                                ref.invalidate(cartProvider);
                              },
                              icon: const Icon(LucideIcons.trash2, color: AppColors.error),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Moyen de paiement', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(LucideIcons.circleCheck, color: AppColors.success),
                            title: Text(PaymentMethods.label(PaymentMethods.cashOnDelivery)),
                            subtitle: const Text('Appliqué à la commande'),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(LucideIcons.circle, color: Colors.black26),
                            title: Text(PaymentMethods.label(PaymentMethods.mobileMoney)),
                            subtitle: const Text('Non disponible : POST /cart/order force CASH_ON_DELIVERY'),
                            enabled: false,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                        const Spacer(),
                        Text(
                          MoneyFormat.fcfa(data.totalPrice),
                          style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CoralButton(
                      label: 'Passer la commande',
                      loading: _checkingOut,
                      onPressed: () async {
                        setState(() => _checkingOut = true);
                        final result = await ref.read(clientRepositoryProvider).checkout();
                        if (!mounted) return;
                        setState(() => _checkingOut = false);
                        result.fold(
                          failure: (failure) => context.showSnack(failure.message),
                          success: (order) {
                            ref.invalidate(cartProvider);
                            ref.invalidate(clientOrdersProvider);
                            context.go(
                              '${AppRoutes.orderConfirmed}?id=${order.orderId}&total=${order.totalAmount}',
                            );
                          },
                        );
                      },
                    ),
                    TextButton.icon(
                      onPressed: _sharing
                          ? null
                          : () async {
                              setState(() => _sharing = true);
                              final result = await ref.read(clientRepositoryProvider).shareCartWhatsApp();
                              if (!mounted) return;
                              setState(() => _sharing = false);
                              result.fold(
                                failure: (failure) => context.showSnack(failure.message),
                                success: (_) => context.showSnack('Demande envoyée aux boutiques'),
                              );
                            },
                      icon: const Icon(LucideIcons.messageCircle),
                      label: const Text('Contacter via WhatsApp'),
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

class OrderConfirmedPage extends StatelessWidget {
  const OrderConfirmedPage({super.key, required this.orderId, required this.total});

  final int orderId;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            const CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.success,
              child: Icon(LucideIcons.check, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            const Text('Commande confirmée !', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('N° COM-${orderId.toString().padLeft(6, '0')}'),
            Text(MoneyFormat.fcfa(total)),
            const Text('Paiement à la livraison', style: TextStyle(color: Colors.black54)),
            const Spacer(),
            CoralButton(
              label: 'Voir ma commande',
              onPressed: () => context.go('${AppRoutes.orders}/$orderId'),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Retour à l’accueil'),
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(clientOrdersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: orders.when(
        loading: () => const AppLoader(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(clientOrdersProvider),
        ),
        data: (items) {
          if (items.isEmpty) return const EmptyState(message: 'Aucune commande.');
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(clientOrdersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = items[index];
                return AppCard(
                  onTap: () => context.push('${AppRoutes.orders}/${order.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'COM-${order.id.toString().padLeft(6, '0')}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          AppStatusChip(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(DateFormatFr.day(order.createdAt), style: const TextStyle(color: Colors.black54)),
                      Text(PaymentMethods.label(order.paymentMethod), style: const TextStyle(fontSize: 12)),
                      Text(MoneyFormat.fcfa(order.totalAmount), style: const TextStyle(fontWeight: FontWeight.w800)),
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

class OrderDetailPage extends ConsumerWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderProvider(orderId));
    return Scaffold(
      appBar: AppBar(title: Text('Commande COM-${orderId.toString().padLeft(6, '0')}')),
      body: order.when(
        loading: () => const AppLoader(),
        error: (error, _) => ErrorView(message: error.toString()),
        data: (current) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppCard(child: OrderTimeline(status: current.status)),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DateFormatFr.day(current.createdAt)),
                  Text(PaymentMethods.label(current.paymentMethod)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...current.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AppCard(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text('x${item.quantity}'),
                            if (item.shopName != null) Text(item.shopName!, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(MoneyFormat.fcfa(item.price * item.quantity)),
                      if (item.shopPhone != null && item.shopPhone!.isNotEmpty)
                        IconButton(
                          onPressed: () => launchUrl(
                            Uri.parse('https://wa.me/${PhoneFormat.digitsForWhatsApp(item.shopPhone)}'),
                            mode: LaunchMode.externalApplication,
                          ),
                          icon: const Icon(LucideIcons.messageCircle, color: AppColors.success),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
              trailing: Text(
                MoneyFormat.fcfa(current.totalAmount),
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w800),
              ),
            ),
            if (current.status == OrderStatuses.pending)
              CoralButton(
                label: 'Annuler la commande',
                onPressed: () async {
                  final result = await ref
                      .read(clientRepositoryProvider)
                      .updateOrderStatus(orderId, OrderStatuses.canceled);
                  if (!context.mounted) return;
                  result.fold(
                    failure: (failure) => context.showSnack(failure.message),
                    success: (_) {
                      ref.invalidate(orderProvider(orderId));
                      ref.invalidate(clientOrdersProvider);
                      context.showSnack('Commande annulée');
                    },
                  );
                },
              ),
            if (current.status == OrderStatuses.shipped)
              CoralButton(
                label: 'Confirmer la livraison',
                onPressed: () async {
                  final result = await ref
                      .read(clientRepositoryProvider)
                      .updateOrderStatus(orderId, OrderStatuses.delivered);
                  if (!context.mounted) return;
                  result.fold(
                    failure: (failure) => context.showSnack(failure.message),
                    success: (_) {
                      ref.invalidate(orderProvider(orderId));
                      context.showSnack('Livraison confirmée');
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class WhatsAppPage extends ConsumerWidget {
  const WhatsAppPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider).value;
    final shops = <String, String>{};
    for (final item in cart?.items ?? const []) {
      if (item.shopPhone != null && item.shopPhone!.isNotEmpty) {
        shops[item.shopPhone!] = item.shopName ?? 'Boutique';
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('WhatsApp')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Le backend n’expose pas d’API WhatsApp dédiée : le contact s’ouvre via wa.me avec phoneNumber de la boutique. POST /cart/share/whatsapp envoie un message in-app.',
          ),
          const SizedBox(height: 16),
          if (shops.isEmpty) const EmptyState(message: 'Ajoutez des articles au panier pour voir les boutiques.'),
          ...shops.entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                child: Row(
                  children: [
                    Expanded(child: Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w600))),
                    TextButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse('https://wa.me/${PhoneFormat.digitsForWhatsApp(entry.key)}'),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(LucideIcons.messageCircle),
                      label: const Text('Ouvrir'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
