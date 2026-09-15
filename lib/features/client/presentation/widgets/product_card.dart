import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/helpers/formatters.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/client/domain/client_models.dart';
import 'package:bibomarketmobile/shared/widgets/ui_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});

  final CatalogProduct product;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      onTap: () => context.push('${AppRoutes.product}/${product.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 1.1,
              child: product.imageUrl == null
                  ? const ColoredBox(
                      color: Color(0xFFE2E8F0),
                      child: Icon(LucideIcons.image),
                    )
                  : CachedNetworkImage(imageUrl: product.imageUrl!, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  MoneyFormat.fcfa(product.price),
                  style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700),
                ),
                if (product.shopName != null)
                  Text(product.shopName!, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      product.isLiked ? LucideIcons.heart : LucideIcons.heart,
                      size: 14,
                      color: product.isLiked ? AppColors.accent : Colors.black38,
                    ),
                    const SizedBox(width: 4),
                    Text('${product.likesCount}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
