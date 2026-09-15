import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/providers/core_providers.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShopProfilePage extends ConsumerWidget {
  const ShopProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(merchantOverviewProvider);

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          const MerchantBackHeader(title: 'Profil boutique'),
          Expanded(
            child: overview.when(
              loading: () => const AppLoader(),
              error: (error, _) => Center(
                child: Text(error.toString().replaceFirst('Exception: ', '')),
              ),
              data: (data) {
                final shop = data.shop;
                if (shop == null) {
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      MerchantCard(
                        child: Column(
                          children: [
                            const Text('Aucune boutique pour le moment.'),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => context.push(AppRoutes.editShop),
                              child: const Text('Créer ma boutique'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  children: [
                    MerchantCard(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.secondary,
                            child: Text(
                              shop.initials,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            shop.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            shop.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.muted),
                          ),
                          const SizedBox(height: 12),
                          Text(shop.address),
                          Text(shop.phoneNumber),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => context.push(AppRoutes.editShop),
                            child: const Text('Modifier'),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EditShopPage extends ConsumerStatefulWidget {
  const EditShopPage({super.key});

  @override
  ConsumerState<EditShopPage> createState() => _EditShopPageState();
}

class _EditShopPageState extends ConsumerState<EditShopPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _sector = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _about = TextEditingController();
  bool _loading = false;
  int? _shopId;
  int? _categorieShopId;

  @override
  void initState() {
    super.initState();
    _hydrate();
  }

  Future<void> _hydrate() async {
    final prefs = ref.read(localStorageServiceProvider);
    final overview = await ref.read(merchantOverviewProvider.future);
    final shop = overview.shop;
    _shopId = shop?.id;
    _name.text = shop?.name ?? prefs.getString(StorageKeys.pendingShopName) ?? '';
    _sector.text =
        shop?.description ?? prefs.getString(StorageKeys.pendingShopSector) ?? '';
    _phone.text =
        shop?.phoneNumber ?? prefs.getString(StorageKeys.pendingShopPhone) ?? '';
    _address.text = shop?.address ?? '';
    _about.text = shop?.description ?? '';
    _categorieShopId = shop?.categorieShopId ??
        int.tryParse(prefs.getString(StorageKeys.pendingShopCategoryId) ?? '');
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _name.dispose();
    _sector.dispose();
    _phone.dispose();
    _address.dispose();
    _about.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final params = CreateShopParams(
      name: _name.text.trim(),
      description: _about.text.trim().isEmpty
          ? _sector.text.trim()
          : _about.text.trim(),
      phoneNumber: _phone.text.trim(),
      address: _address.text.trim(),
      categorieShopId: _categorieShopId,
    );
    final repo = ref.read(merchantRepositoryProvider);
    final result = _shopId == null
        ? await repo.createShop(params)
        : await repo.updateShop(_shopId!, params);
    if (!mounted) return;
    setState(() => _loading = false);
    result.fold(
      failure: (failure) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure.message)));
      },
      success: (_) {
        ref.invalidate(merchantOverviewProvider);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(shopCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          MerchantBackHeader(
            title: _shopId == null ? 'Créer la boutique' : 'Modifier la boutique',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                MerchantCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MerchantTextField(
                          controller: _name,
                          hint: 'Nom de la boutique',
                          validator: (value) =>
                              value == null || value.isEmpty ? 'Requis' : null,
                        ),
                        const SizedBox(height: 12),
                        categories.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (error, _) => Text(
                            error.toString().replaceFirst('Exception: ', ''),
                            style: const TextStyle(color: AppColors.error),
                          ),
                          data: (items) {
                            final ids = items.map((item) => item.id).toSet();
                            final selected =
                                ids.contains(_categorieShopId)
                                    ? _categorieShopId
                                    : null;
                            return MerchantDropdown<int>(
                              hint: 'Catégorie boutique',
                              value: selected,
                              items: items
                                  .map(
                                    (item) => DropdownMenuItem(
                                      value: item.id,
                                      child: Text(item.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _categorieShopId = value),
                              validator: (value) =>
                                  value == null ? 'Catégorie requise' : null,
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        MerchantTextField(
                          controller: _phone,
                          hint: 'Téléphone',
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),
                        MerchantTextField(
                          controller: _address,
                          hint: 'Adresse',
                        ),
                        const SizedBox(height: 12),
                        MerchantTextField(
                          controller: _about,
                          hint: 'À propos',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _loading ? null : _submit,
                          child: Text(
                            _loading ? 'Enregistrement...' : 'Enregistrer',
                          ),
                        ),
                      ],
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

class ShopStatusPage extends ConsumerWidget {
  const ShopStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(merchantOverviewProvider);
    final verified = overview.value?.shop?.verified ?? false;

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          const MerchantBackHeader(title: 'Statut de la boutique'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                MerchantCard(
                  child: Column(
                    children: [
                      Icon(
                        verified ? Icons.verified_rounded : Icons.hourglass_top,
                        color: verified ? AppColors.success : AppColors.warning,
                        size: 64,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        verified
                            ? 'Votre boutique est vérifiée !'
                            : 'Votre boutique n’est pas encore vérifiée',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        verified
                            ? 'Vous pouvez maintenant vendre en toute confiance.'
                            : 'Complétez votre profil pour accélérer la validation.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.push(AppRoutes.products),
                        child: const Text('Voir mes produits'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Avantages',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const MerchantCard(
                  child: Column(
                    children: [
                      _Benefit(text: 'Plus de visibilité'),
                      _Benefit(text: 'Confiance des clients'),
                      _Benefit(text: 'Accès aux promotions'),
                    ],
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

class _Benefit extends StatelessWidget {
  const _Benefit({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
