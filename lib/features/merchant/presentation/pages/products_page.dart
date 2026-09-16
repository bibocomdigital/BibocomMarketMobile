import 'package:bibomarketmobile/config/router/app_routes.dart';
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

enum _ProductFilter { all, online, paused }

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  _ProductFilter _filter = _ProductFilter.all;

  bool _isOnline(Product product) {
    final status = product.status.toUpperCase();
    return status == 'PUBLISHED' ||
        status == 'ACTIVE' ||
        status == 'ONLINE';
  }

  List<Product> _filtered(List<Product> products) {
    return switch (_filter) {
      _ProductFilter.all => products,
      _ProductFilter.online => products.where(_isOnline).toList(),
      _ProductFilter.paused => products.where((item) => !_isOnline(item)).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final overview = ref.watch(merchantOverviewProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFD),
      body: Column(
        children: [
          MerchantCenteredHeader(
            title: 'Mes produits',
            onBack: () => context.popOrFallback(fallback: AppRoutes.merchantHome),
          ),
          Expanded(
            child: overview.when(
              loading: () => const AppLoader(),
              error: (error, _) => Center(
                child: Text(error.toString().replaceFirst('Exception: ', '')),
              ),
              data: (data) {
                final all = data.products;
                final onlineCount = all.where(_isOnline).length;
                final pausedCount = all.length - onlineCount;
                final visible = _filtered(all);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
                      child: Row(
                        children: [
                          _FilterTab(
                            label: 'Tous (${all.length})',
                            selected: _filter == _ProductFilter.all,
                            onTap: () => setState(() => _filter = _ProductFilter.all),
                          ),
                          const SizedBox(width: 18),
                          _FilterTab(
                            label: 'En ligne ($onlineCount)',
                            selected: _filter == _ProductFilter.online,
                            onTap: () =>
                                setState(() => _filter = _ProductFilter.online),
                          ),
                          const SizedBox(width: 18),
                          _FilterTab(
                            label: 'En pause ($pausedCount)',
                            selected: _filter == _ProductFilter.paused,
                            onTap: () =>
                                setState(() => _filter = _ProductFilter.paused),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: visible.isEmpty
                          ? const Center(
                              child: Text(
                                'Aucun produit pour le moment',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                              itemCount: visible.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final product = visible[index];
                                return _ProductCard(
                                  product: product,
                                  online: _isOnline(product),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 58,
        height: 58,
        child: FloatingActionButton(
          onPressed: () => context.push(AppRoutes.addProduct),
          backgroundColor: AppColors.accent,
          elevation: 5,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.accent : AppColors.navySoft,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 2.5,
              width: selected ? 34 : 0,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.online,
  });

  final Product product;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final statusColor = online ? AppColors.success : const Color(0xFFF5A524);

    return Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: const Color(0x1A0A2340),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MerchantDimens.cardRadius),
        side: const BorderSide(color: Color(0xFFE8F0F6)),
      ),
      child: InkWell(
        onTap: () => context.push(AppRoutes.editProductPath(product.id)),
        borderRadius: BorderRadius.circular(MerchantDimens.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 78,
                  height: 78,
                  child: product.imageUrl == null || product.imageUrl!.isEmpty
                      ? const ColoredBox(
                          color: Color(0xFFF1F5F9),
                          child: Icon(
                            Icons.image_outlined,
                            color: AppColors.muted,
                          ),
                        )
                      : Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const ColoredBox(
                            color: Color(0xFFF1F5F9),
                            child: Icon(
                              Icons.image_outlined,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      MoneyFormat.fcfa(product.price),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          online ? 'En ligne' : 'En pause',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
