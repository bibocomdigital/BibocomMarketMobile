import 'dart:io';

import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/helpers/formatters.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductAddedArgs {
  const ProductAddedArgs({
    required this.id,
    required this.name,
    required this.price,
    this.imageUrl,
    this.imagePath,
  });

  final int id;
  final String name;
  final double price;
  final String? imageUrl;
  final String? imagePath;
}

class ProductAddedPage extends StatelessWidget {
  const ProductAddedPage({
    super.key,
    required this.args,
    this.onViewProduct,
    this.onAddAnother,
  });

  final ProductAddedArgs args;
  final VoidCallback? onViewProduct;
  final VoidCallback? onAddAnother;

  static const _success = Color(0xFF16B88A);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final hasFile = args.imagePath != null && args.imagePath!.isNotEmpty;
    final hasUrl = args.imageUrl != null && args.imageUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const MerchantCenteredHeader(title: 'Produit ajouté !'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(24, 28, 24, 24 + bottom),
              children: [
                const Center(
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _success,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Produit ajouté !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _success,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFD7EAF3)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A073B63),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 72,
                          height: 72,
                          child: hasFile
                              ? Image.file(
                                  File(args.imagePath!),
                                  fit: BoxFit.cover,
                                )
                              : hasUrl
                                  ? Image.network(
                                      args.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          const _ThumbPlaceholder(),
                                    )
                                  : const _ThumbPlaceholder(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              args.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              MoneyFormat.fcfa(args.price),
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      if (onViewProduct != null) {
                        onViewProduct!();
                        return;
                      }
                      if (args.id > 0) {
                        context.push(AppRoutes.editProductPath(args.id));
                      } else {
                        context.go(AppRoutes.products);
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Voir le produit'),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onAddAnother ??
                      () => context.go(AppRoutes.addProduct),
                  style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                  child: const Text(
                    'Ajouter un autre produit',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
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

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF1F5F9),
      child: Icon(Icons.image_outlined, color: AppColors.muted),
    );
  }
}
