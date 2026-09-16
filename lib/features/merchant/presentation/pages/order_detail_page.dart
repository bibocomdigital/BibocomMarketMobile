import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/helpers/formatters.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/core/theme/merchant_dimens.dart';
import 'package:bibomarketmobile/features/merchant/domain/entities/merchant_entities.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:bibomarketmobile/shared/helpers/context_extensions.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OrderDetailPage extends ConsumerStatefulWidget {
  const OrderDetailPage({super.key, required this.orderId});

  final int orderId;

  @override
  ConsumerState<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends ConsumerState<OrderDetailPage> {
  bool _busy = false;

  String _title(MerchantOrder order) {
    if (order.isCanceled) return 'Commande annulée';
    if (order.isDelivered) return 'Commande livrée';
    if (order.isShipped) return 'Commande Expédiée';
    if (order.isConfirmed) return 'Commande Confirmée';
    return 'Commande #CMD-${order.id.toString().padLeft(3, '0')}';
  }

  Color _badgeColor(MerchantOrder order) {
    if (order.isCanceled) return AppColors.error;
    if (order.isDelivered || order.isShipped || order.isConfirmed) {
      return AppColors.success;
    }
    return const Color(0xFFF5A524);
  }

  Future<void> _setStatus(String status) async {
    if (_busy) return;
    setState(() => _busy = true);
    final result = await ref
        .read(merchantRepositoryProvider)
        .updateOrderStatus(widget.orderId, status);
    if (!mounted) return;
    setState(() => _busy = false);
    result.fold(
      failure: (failure) => context.showSnack(failure.message),
      success: (_) {
        ref.invalidate(orderDetailProvider(widget.orderId));
        ref.invalidate(merchantOverviewProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(orderDetailProvider(widget.orderId));
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: detail.when(
        loading: () => const Column(
          children: [
            MerchantCenteredHeader(title: 'Détail commande'),
            Expanded(child: AppLoader()),
          ],
        ),
        error: (error, _) => Column(
          children: [
            const MerchantCenteredHeader(title: 'Détail commande'),
            Expanded(
              child: Center(
                child: Text(error.toString().replaceFirst('Exception: ', '')),
              ),
            ),
          ],
        ),
        data: (order) {
          final item = order.items.isEmpty ? null : order.items.first;
          final badge = _badgeColor(order);
          return Column(
            children: [
              MerchantCenteredHeader(title: _title(order)),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottom),
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFFE8F0F6),
                          child: Text(
                            (order.clientName ?? 'C').trim().isEmpty
                                ? 'C'
                                : order.clientName!.trim()[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.clientName ?? 'Client',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                              if (order.clientPhone != null &&
                                  order.clientPhone!.isNotEmpty)
                                Text(
                                  order.clientPhone!,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: badge.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            OrderStatuses.label(order.status),
                            style: TextStyle(
                              color: badge,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (item != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            MerchantDimens.cardRadius,
                          ),
                          border: Border.all(color: const Color(0xFFE8F0F6)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 64,
                                height: 64,
                                child: item.imageUrl == null ||
                                        item.imageUrl!.isEmpty
                                    ? const ColoredBox(
                                        color: Color(0xFFF1F5F9),
                                        child: Icon(
                                          Icons.image_outlined,
                                          color: AppColors.muted,
                                        ),
                                      )
                                    : Image.network(
                                        item.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) =>
                                            const ColoredBox(
                                          color: Color(0xFFF1F5F9),
                                          child: Icon(
                                            Icons.image_outlined,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'x${item.quantity}',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              MoneyFormat.fcfa(item.price * item.quantity),
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (order.items.length > 1) ...[
                      const SizedBox(height: 10),
                      ...order.items.skip(1).map(
                            (extra) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '${extra.quantity} x ${extra.name}',
                                style: const TextStyle(color: AppColors.muted),
                              ),
                            ),
                          ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          MoneyFormat.fcfa(order.totalAmount),
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    if (_busy) const LinearProgressIndicator(minHeight: 2),
                    if (order.isPending) ...[
                      _CoralButton(
                        label: 'Confirmer la commande',
                        onPressed: _busy
                            ? null
                            : () => _setStatus(OrderStatuses.confirmed),
                      ),
                      const SizedBox(height: 10),
                      _GhostButton(
                        label: 'Annuler',
                        onPressed: _busy
                            ? null
                            : () => _setStatus(OrderStatuses.canceled),
                      ),
                    ] else if (order.isConfirmed) ...[
                      _CoralButton(
                        label: 'Marquer comme expédiée',
                        onPressed: _busy
                            ? null
                            : () => _setStatus(OrderStatuses.shipped),
                      ),
                    ] else if (order.isShipped) ...[
                      _CoralButton(
                        label: 'Marquer comme livrée',
                        onPressed: _busy
                            ? null
                            : () => _setStatus(OrderStatuses.delivered),
                      ),
                      const SizedBox(height: 10),
                      _GhostButton(
                        label: 'Contacter le client',
                        onPressed: () =>
                            context.push(AppRoutes.merchantMessages),
                      ),
                    ] else if (order.isDelivered) ...[
                      _GhostButton(
                        label: 'Contacter le client',
                        onPressed: () =>
                            context.push(AppRoutes.merchantMessages),
                      ),
                    ],
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

class _CoralButton extends StatelessWidget {
  const _CoralButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  const _GhostButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: Color(0xFFD7E4EE)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}
