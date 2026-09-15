import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _shopName = TextEditingController();
  final _ownerName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  int? _categorieShopId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).clearFailure();
    });
  }

  @override
  void dispose() {
    _shopName.dispose();
    _ownerName.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final categories = ref.read(shopCategoriesProvider);
    if (_categorieShopId == null && categories.hasValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez une catégorie de boutique')),
      );
      return;
    }
    final parts = _ownerName.text.trim().split(RegExp(r'\s+'));
    final firstName = parts.isEmpty ? _shopName.text.trim() : parts.first;
    final lastName = parts.length > 1
        ? parts.sublist(1).join(' ')
        : _shopName.text.trim();

    final ok = await ref.read(authNotifierProvider.notifier).register(
          RegisterParams(
            email: _email.text.trim(),
            password: _password.text,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: _phone.text.trim(),
            shopName: _shopName.text.trim(),
            shopSector: ref
                .read(shopCategoriesProvider)
                .value
                ?.where((item) => item.id == _categorieShopId)
                .firstOrNull
                ?.name,
            categorieShopId: _categorieShopId,
          ),
        );
    if (!mounted) return;
    if (ok) {
      context.go(AppRoutes.identityVerification);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final categories = ref.watch(shopCategoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          MerchantBackHeader(
            title: 'Créer un compte commerçant',
            onBack: () => context.go(AppRoutes.login),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                children: [
                  MerchantCard(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Informations de la boutique',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 16),
                          MerchantTextField(
                            controller: _shopName,
                            hint: 'Nom de la boutique',
                            icon: Icons.storefront_outlined,
                            validator: _required,
                          ),
                          const SizedBox(height: 12),
                          MerchantTextField(
                            controller: _ownerName,
                            hint: 'Nom du gérant',
                            icon: Icons.person_outline_rounded,
                            validator: _required,
                          ),
                          const SizedBox(height: 12),
                          categories.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (error, _) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  error
                                      .toString()
                                      .replaceFirst('Exception: ', ''),
                                  style: const TextStyle(
                                    color: AppColors.error,
                                    fontSize: 13,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      ref.invalidate(shopCategoriesProvider),
                                  child: const Text('Réessayer'),
                                ),
                              ],
                            ),
                            data: (items) {
                              final ids = items.map((item) => item.id).toSet();
                              final selected = ids.contains(_categorieShopId)
                                  ? _categorieShopId
                                  : null;
                              return MerchantDropdown<int>(
                                hint: 'Catégorie de boutique',
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
                                validator: (value) => value == null
                                    ? 'Catégorie requise'
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          MerchantTextField(
                            controller: _phone,
                            hint: 'N° de téléphone',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().length < 9) {
                                return 'Numéro invalide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          MerchantTextField(
                            controller: _email,
                            hint: 'Email',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return 'Email invalide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          MerchantTextField(
                            controller: _password,
                            hint: 'Mot de passe',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscure,
                            suffix: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.muted,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Au moins 6 caractères';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          MerchantTextField(
                            controller: _confirm,
                            hint: 'Confirme mot de passe',
                            icon: Icons.lock_outline_rounded,
                            obscure: true,
                            validator: (value) {
                              if (value != _password.text) {
                                return 'Les mots de passe ne correspondent pas';
                              }
                              return null;
                            },
                          ),
                          if (auth.failure != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              auth.failure!.message,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: auth.isLoading ? null : _submit,
                            child: Text(
                              auth.isLoading ? 'Inscription...' : 'Suivant',
                            ),
                          ),
                        ],
                      ),
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

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ requis';
    return null;
  }
}
