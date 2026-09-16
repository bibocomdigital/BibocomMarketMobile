import 'dart:io';

import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/providers/core_providers.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/core/theme/merchant_dimens.dart';
import 'package:bibomarketmobile/features/merchant/domain/entities/merchant_entities.dart';
import 'package:bibomarketmobile/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:bibomarketmobile/shared/helpers/context_extensions.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:bibomarketmobile/shared/widgets/image_source_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _about = TextEditingController();
  bool _loading = false;
  int? _shopId;
  int? _categorieShopId;
  String _countryCode = '+221';
  String? _logoPath;
  Shop? _created;

  bool get _isCreate => _shopId == null;

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
    _about.text =
        shop?.description ?? prefs.getString(StorageKeys.pendingShopSector) ?? '';
    final rawPhone =
        shop?.phoneNumber ?? prefs.getString(StorageKeys.pendingShopPhone) ?? '';
    _applyPhone(rawPhone);
    _address.text = shop?.address ?? '';
    _categorieShopId = shop?.categorieShopId ??
        int.tryParse(prefs.getString(StorageKeys.pendingShopCategoryId) ?? '');
    if (mounted) setState(() {});
  }

  void _applyPhone(String raw) {
    final value = raw.replaceAll(' ', '');
    const codes = ['+221', '+223', '+225', '+226', '+227', '+228'];
    for (final code in codes) {
      if (value.startsWith(code)) {
        _countryCode = code;
        _phone.text = value.substring(code.length);
        return;
      }
    }
    _phone.text = raw;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _about.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final path = await pickAppImage(context);
    if (path != null) setState(() => _logoPath = path);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final params = CreateShopParams(
      name: _name.text.trim(),
      description: _about.text.trim(),
      phoneNumber: '$_countryCode ${_phone.text.trim()}',
      address: _address.text.trim(),
      categorieShopId: _categorieShopId,
      logoPath: _logoPath,
    );
    final repo = ref.read(merchantRepositoryProvider);
    final result = _shopId == null
        ? await repo.createShop(params)
        : await repo.updateShop(_shopId!, params);
    if (!mounted) return;
    setState(() => _loading = false);
    result.fold(
      failure: (failure) => context.showSnack(failure.message),
      success: (shop) {
        ref.invalidate(merchantOverviewProvider);
        if (_isCreate) {
          setState(() => _created = shop);
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }

  String get _categoryLabel {
    final items = ref.read(shopCategoriesProvider).value;
    return items
            ?.where((item) => item.id == _categorieShopId)
            .firstOrNull
            ?.name ??
        '';
  }

  String get _cityLabel {
    final address = _created?.address ?? _address.text.trim();
    if (address.isEmpty) return '';
    return address.split(',').first.trim();
  }

  @override
  Widget build(BuildContext context) {
    if (_created != null) {
      return _ShopCreatedView(
        shopName: _created!.name,
        category: _categoryLabel,
        city: _cityLabel,
        logoPath: _logoPath,
        logoUrl: _created!.logo,
        onAddProducts: () => context.go(AppRoutes.addProduct),
        onDashboard: () => context.go(AppRoutes.merchantHome),
      );
    }

    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.paddingOf(context).top),
          Expanded(
            child: Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(MerchantDimens.headerRadius),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 14, 20, 8),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.popOrFallback(
                            fallback: AppRoutes.shopProfile,
                          ),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                          color: AppColors.primary,
                        ),
                        Expanded(
                          child: Text(
                            _isCreate
                                ? 'Créer votre boutique'
                                : 'Modifier la boutique',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        MerchantDimens.pagePadding,
                        12,
                        MerchantDimens.pagePadding,
                        20 + bottom,
                      ),
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _FieldLabel(
                                text: 'Nom de la boutique',
                                required: true,
                              ),
                              _ShopInput(
                                controller: _name,
                                hint: 'Ex. Boutique Alima',
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Requis'
                                        : null,
                              ),
                              const SizedBox(height: 18),
                              const _FieldLabel(
                                text: 'Description',
                                required: true,
                              ),
                              _ShopInput(
                                controller: _about,
                                hint:
                                    'Décrivez votre boutique en quelques mots...',
                                maxLines: 3,
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Requis'
                                        : null,
                              ),
                              const SizedBox(height: 18),
                              const _FieldLabel(
                                text: 'Téléphone',
                                required: true,
                              ),
                              Row(
                                children: [
                                  _CountryCodeField(
                                    value: _countryCode,
                                    onChanged: (value) =>
                                        setState(() => _countryCode = value),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _ShopInput(
                                      controller: _phone,
                                      hint: '+221 77 121 45 67',
                                      keyboardType: TextInputType.phone,
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().length < 8) {
                                          return 'Numéro invalide';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              const _FieldLabel(
                                text: 'Adresse',
                                required: true,
                              ),
                              _ShopInput(
                                controller: _address,
                                hint: 'Ex. Dakar, Yoff, Rue 10',
                                validator: (value) =>
                                    value == null || value.trim().isEmpty
                                        ? 'Requis'
                                        : null,
                              ),
                              const SizedBox(height: 18),
                              const _FieldLabel(text: 'Logo de la boutique'),
                              _LogoPicker(
                                path: _logoPath,
                                onTap: _pickLogo,
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                height: 52,
                                child: FilledButton(
                                  onPressed: _loading ? null : _submit,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.accent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MerchantDimens.buttonRadius,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    _loading
                                        ? 'Enregistrement...'
                                        : _isCreate
                                            ? 'Créer la boutique'
                                            : 'Enregistrer',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

InputDecoration _shopInputDecoration({String? hint}) {
  const borderColor = Color(0xFFD4E3F0);
  return InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    hintStyle: const TextStyle(color: Color(0xFF9BB0C3), fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.secondary, width: 1.4),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Color(0xFFE11D48),
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CountryCodeField extends StatelessWidget {
  const _CountryCodeField({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: 108,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD4E3F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.muted,
            size: 20,
          ),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          items: const [
            DropdownMenuItem(value: '+221', child: Text('+221')),
            DropdownMenuItem(value: '+223', child: Text('+223')),
            DropdownMenuItem(value: '+225', child: Text('+225')),
            DropdownMenuItem(value: '+226', child: Text('+226')),
          ],
          onChanged: (code) {
            if (code != null) onChanged(code);
          },
        ),
      ),
    );
  }
}

class _ShopInput extends StatelessWidget {
  const _ShopInput({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _shopInputDecoration(hint: hint),
    );
  }
}

class _LogoPicker extends StatelessWidget {
  const _LogoPicker({required this.onTap, this.path});

  final VoidCallback onTap;
  final String? path;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedRoundedPainter(),
        child: Container(
          height: 92,
          alignment: Alignment.center,
          child: path == null
              ? const Icon(
                  Icons.photo_camera_outlined,
                  color: AppColors.primary,
                  size: 32,
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    File(path!),
                    height: 84,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }
}

class _DashedRoundedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF9BB8CC)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0.65, 0.65, size.width - 1.3, size.height - 1.3),
          const Radius.circular(16),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + 5).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ShopCreatedView extends StatelessWidget {
  const _ShopCreatedView({
    required this.shopName,
    required this.category,
    required this.city,
    required this.onAddProducts,
    required this.onDashboard,
    this.logoPath,
    this.logoUrl,
  });

  final String shopName;
  final String category;
  final String city;
  final VoidCallback onAddProducts;
  final VoidCallback onDashboard;
  final String? logoPath;
  final String? logoUrl;

  static const _navy = Color(0xFF073B63);
  static const _success = Color(0xFF16B88A);
  static const _coral = Color(0xFFFF6B52);
  static const _border = Color(0xFFD7EAF3);
  static const _meta = Color(0xFF8AA3B5);

  @override
  Widget build(BuildContext context) {
    final meta = [category, city].where((item) => item.isNotEmpty).join('  •  ');
    final bottom = MediaQuery.paddingOf(context).bottom;
    final top = MediaQuery.paddingOf(context).top;
    final hasLogo = (logoPath != null && logoPath!.isNotEmpty) ||
        (logoUrl != null && logoUrl!.isNotEmpty);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FCFD),
        body: Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + bottom),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                children: [
                  ColoredBox(
                    color: _navy,
                    child: SizedBox(width: double.infinity, height: top + 6),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth;
                        final checkSize = (wide * 0.26).clamp(84.0, 108.0);
                        return SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            wide * 0.06,
                            36,
                            wide * 0.06,
                            24,
                          ),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - 60,
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: checkSize,
                                  height: checkSize,
                                  decoration: const BoxDecoration(
                                    color: _success,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: checkSize * 0.52,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                const Text(
                                  'Boutique créée avec succès !',
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: _success,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: _border),
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
                                      CircleAvatar(
                                        radius: 32,
                                        backgroundColor: _navy,
                                        backgroundImage: !hasLogo
                                            ? null
                                            : (logoPath != null
                                                ? FileImage(File(logoPath!))
                                                : NetworkImage(logoUrl!)),
                                        child: hasLogo
                                            ? null
                                            : const Icon(
                                                Icons.storefront_rounded,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              shopName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: _navy,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                                height: 1.2,
                                              ),
                                            ),
                                            if (meta.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Text(
                                                meta,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: _meta,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 28),
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: FilledButton(
                                    onPressed: onAddProducts,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _coral,
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
                                    child: const Text(
                                      'Commencer à ajouter des produits',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextButton(
                                  onPressed: onDashboard,
                                  style: TextButton.styleFrom(
                                    foregroundColor: _coral,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text(
                                    'Aller au dashboard',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
