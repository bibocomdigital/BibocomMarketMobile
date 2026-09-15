import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/helpers/formatters.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/client/domain/client_models.dart';
import 'package:bibomarketmobile/features/client/presentation/widgets/product_card.dart';
import 'package:bibomarketmobile/features/client/providers/client_providers.dart';
import 'package:bibomarketmobile/shared/helpers/context_extensions.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:bibomarketmobile/shared/widgets/category_icon.dart';
import 'package:bibomarketmobile/shared/widgets/error_view.dart';
import 'package:bibomarketmobile/shared/widgets/ui_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key, this.categoryId, this.categoryName});

  final int? categoryId;
  final String? categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(productCategoriesProvider);
    return Scaffold(
      appBar: AppBar(title: Text(categoryName ?? 'Catégories')),
      body: categories.when(
        loading: () => const AppLoader(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(productCategoriesProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(message: 'Aucune catégorie.');
          }
          if (categoryId != null) {
            return _CategoryProducts(categoryId: categoryId!);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(productCategoriesProvider),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final item = items[index];
                return AppCard(
                  onTap: () => context.push(
                    '${AppRoutes.categories}?id=${item.id}&name=${Uri.encodeComponent(item.name)}',
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.secondary.withValues(alpha: 0.35),
                        child: Icon(categoryLucideIcon(item.name), color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                      ),
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

class _CategoryProducts extends ConsumerWidget {
  const _CategoryProducts({required this.categoryId});

  final int categoryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(clientRepositoryProvider).products(categoryId: categoryId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const AppLoader();
        return snapshot.data!.fold(
          failure: (failure) => ErrorView(message: failure.message),
          success: (items) {
            if (items.isEmpty) return const EmptyState(message: 'Aucun produit dans cette catégorie.');
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, index) => ProductCard(product: items[index]),
            );
          },
        );
      },
    );
  }
}

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _query = TextEditingController();
  final _min = TextEditingController();
  final _max = TextEditingController();
  List<CatalogProduct> _results = const [];
  bool _loading = false;
  String? _error;
  String _sort = 'createdAt';
  int _page = 1;
  bool _hasMore = false;

  @override
  void dispose() {
    _query.dispose();
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  Future<void> _search({bool append = false}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (!append) _page = 1;
    });
    final result = await ref.read(clientRepositoryProvider).products(
          page: _page,
          search: _query.text.trim().isEmpty ? null : _query.text.trim(),
          minPrice: double.tryParse(_min.text),
          maxPrice: double.tryParse(_max.text),
          sortBy: _sort,
          order: _sort == 'price' ? 'asc' : 'desc',
        );
    if (!mounted) return;
    result.fold(
      failure: (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      success: (items) => setState(() {
        _loading = false;
        _results = append ? [..._results, ...items] : items;
        _hasMore = items.length >= 20;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recherche & Filtres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _query,
            decoration: const InputDecoration(
              hintText: 'Téléphone, accessoire…',
              prefixIcon: Icon(LucideIcons.search),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _min,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Prix min'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _max,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Prix max'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Récents'),
                selected: _sort == 'createdAt',
                onSelected: (_) => setState(() => _sort = 'createdAt'),
              ),
              ChoiceChip(
                label: const Text('Prix'),
                selected: _sort == 'price',
                onSelected: (_) => setState(() => _sort = 'price'),
              ),
              ChoiceChip(
                label: const Text('Likes'),
                selected: _sort == 'likesCount',
                onSelected: (_) => setState(() => _sort = 'likesCount'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CoralButton(label: 'Filtrer', loading: _loading, onPressed: _search),
          const SizedBox(height: 16),
          if (_error != null) Text(_error!, style: const TextStyle(color: AppColors.error)),
          if (!_loading && _results.isEmpty)
            const EmptyState(message: 'Lancez une recherche pour voir les produits.'),
          ..._results.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProductCard(product: product),
            ),
          ),
          if (_hasMore)
            TextButton(
              onPressed: _loading
                  ? null
                  : () {
                      _page += 1;
                      _search(append: true);
                    },
              child: const Text('Charger plus'),
            ),
        ],
      ),
    );
  }
}

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final int productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  final _comment = TextEditingController();
  bool _sending = false;
  bool _liking = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = ref.watch(productProvider(widget.productId));
    final comments = ref.watch(productCommentsProvider(widget.productId));
    return Scaffold(
      appBar: AppBar(title: const Text('Détail produit')),
      body: product.when(
        loading: () => const AppLoader(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(productProvider(widget.productId)),
        ),
        data: (item) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 1,
                child: item.imageUrl == null
                    ? const ColoredBox(color: Color(0xFFE2E8F0), child: Icon(LucideIcons.image, size: 48))
                    : CachedNetworkImage(imageUrl: item.imageUrl!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Text(item.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(
              MoneyFormat.fcfa(item.price),
              style: const TextStyle(color: AppColors.accent, fontSize: 20, fontWeight: FontWeight.w800),
            ),
            if (item.shopName != null) Text(item.shopName!),
            const SizedBox(height: 8),
            Text(
              item.inStock ? 'En stock' : 'Rupture',
              style: TextStyle(color: item.inStock ? AppColors.success : AppColors.error, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(item.description ?? ''),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: _liking
                      ? null
                      : () async {
                          setState(() => _liking = true);
                          final result = await ref.read(clientRepositoryProvider).likeProduct(item.id);
                          if (!mounted) return;
                          setState(() => _liking = false);
                          result.fold(
                            failure: (failure) => context.showSnack(failure.message),
                            success: (_) {
                              ref.invalidate(productProvider(widget.productId));
                              ref.invalidate(featuredProductsProvider);
                            },
                          );
                        },
                  icon: Icon(
                    LucideIcons.heart,
                    color: item.isLiked ? AppColors.accent : AppColors.primary,
                  ),
                ),
                Text('${item.likesCount} j’aime'),
                const SizedBox(width: 16),
                const Icon(LucideIcons.messageCircle, size: 18, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('${item.commentsCount} commentaires'),
              ],
            ),
            const SizedBox(height: 12),
            CoralButton(
              label: 'Ajouter au panier',
              onPressed: !item.inStock
                  ? null
                  : () async {
                      final result = await ref.read(clientRepositoryProvider).addToCart(item.id);
                      if (!context.mounted) return;
                      result.fold(
                        failure: (failure) => context.showSnack(failure.message),
                        success: (_) {
                          ref.invalidate(cartProvider);
                          context.showSnack('Produit ajouté au panier');
                        },
                      );
                    },
            ),
            if (item.shopId != null)
              TextButton(
                onPressed: () => context.push('${AppRoutes.shop}/${item.shopId}'),
                child: const Text('Voir la boutique'),
              ),
            const SizedBox(height: 8),
            const Text('Commentaires', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            comments.when(
              loading: () => const AppLoader(),
              error: (error, _) => Text(error.toString(), style: const TextStyle(color: AppColors.error)),
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyState(message: 'Aucun commentaire pour le moment.');
                }
                return Column(
                  children: items
                      .map(
                        (comment) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.author.isEmpty ? 'Client' : comment.author,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                Text(comment.comment),
                                if (comment.createdAt != null)
                                  Text(
                                    DateFormatFr.day(comment.createdAt!),
                                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _comment,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Ajouter un commentaire'),
            ),
            const SizedBox(height: 8),
            CoralButton(
              label: 'Publier',
              loading: _sending,
              onPressed: () async {
                final text = _comment.text.trim();
                if (text.isEmpty) {
                  context.showSnack('Commentaire requis');
                  return;
                }
                setState(() => _sending = true);
                final result = await ref.read(clientRepositoryProvider).addComment(widget.productId, text);
                if (!mounted) return;
                setState(() => _sending = false);
                result.fold(
                  failure: (failure) => context.showSnack(failure.message),
                  success: (_) {
                    _comment.clear();
                    ref.invalidate(productCommentsProvider(widget.productId));
                    ref.invalidate(productProvider(widget.productId));
                    context.showSnack('Commentaire publié');
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
