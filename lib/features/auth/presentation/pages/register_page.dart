import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_state.dart';
import 'package:bibomarketmobile/features/merchant/domain/entities/merchant_entities.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:bibomarketmobile/shared/helpers/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MerchantRegisterPage extends ConsumerStatefulWidget {
  const MerchantRegisterPage({super.key});

  @override
  ConsumerState<MerchantRegisterPage> createState() =>
      _MerchantRegisterPageState();
}

class _MerchantRegisterPageState extends ConsumerState<MerchantRegisterPage> {
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _shopName = TextEditingController();
  final _ownerName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  int? _categorieShopId;
  int _step = 1;
  final _docs = <String>{};

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

  void _goBack() {
    if (_step == 3) {
      context.go(AppRoutes.login);
      return;
    }
    if (_step > 1) {
      setState(() => _step -= 1);
      return;
    }
    context.go(AppRoutes.roleSelect);
  }

  void _nextFromShop() {
    if (!(_step1Key.currentState?.validate() ?? false)) return;
    final categories = ref.read(shopCategoriesProvider);
    if (_categorieShopId == null && categories.hasValue) {
      context.showSnack('Choisissez une catégorie de boutique');
      return;
    }
    setState(() => _step = 2);
  }

  Future<void> _submitAccount() async {
    if (!(_step2Key.currentState?.validate() ?? false)) return;
    final parts = _ownerName.text.trim().split(RegExp(r'\s+'));
    final firstName = parts.isEmpty ? _shopName.text.trim() : parts.first;
    final lastName = parts.length > 1
        ? parts.sublist(1).join(' ')
        : _shopName.text.trim();

    final result = await ref.read(authNotifierProvider.notifier).register(
          RegisterParams(
            email: _email.text.trim(),
            password: _password.text,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: _phone.text.trim(),
            role: 'MERCHANT',
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
    result.fold(
      failure: (_) {},
      success: (_) => setState(() => _step = 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final categories = ref.watch(shopCategoriesProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: const Color(0xFFEDF3F8),
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _goBack,
                  icon: const Icon(Icons.chevron_left_rounded, size: 32),
                  color: AppColors.primary,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 20 + bottom),
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x140A2540),
                            blurRadius: 24,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Créer un compte commerçant',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _StepIndicator(current: _step),
                          const SizedBox(height: 24),
                          if (_step == 1) _shopStep(categories),
                          if (_step == 2) _ownerStep(auth),
                          if (_step == 3) _docsStep(),
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
    );
  }

  Widget _shopStep(AsyncValue<List<CatalogItem>> categories) {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Informations de la boutique',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 16),
          _RegisterField(
            controller: _shopName,
            hint: 'Nom de la boutique',
            validator: _required,
          ),
          const SizedBox(height: 12),
          categories.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: LinearProgressIndicator(minHeight: 2),
            ),
            error: (error, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error.toString().replaceFirst('Exception: ', ''),
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(shopCategoriesProvider),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
            data: (items) {
              final ids = items.map((item) => item.id).toSet();
              final selected =
                  ids.contains(_categorieShopId) ? _categorieShopId : null;
              return DropdownButtonFormField<int>(
                key: ValueKey(selected),
                initialValue: selected,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.muted,
                ),
                hint: const Text(
                  "Secteur d'activité",
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
                ),
                decoration: _inputDecoration(),
                items: items
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _categorieShopId = value),
                validator: (value) =>
                    value == null ? 'Catégorie requise' : null,
              );
            },
          ),
          const SizedBox(height: 12),
          _RegisterField(
            controller: _phone,
            hint: 'Numéro de téléphone',
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().length < 9) {
                return 'Numéro invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _RegisterField(
            controller: _email,
            hint: 'Email',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || !value.contains('@')) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _RegisterField(
            controller: _password,
            hint: 'Mot de passe',
            obscure: _obscurePassword,
            suffix: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.keyboard_arrow_up_rounded,
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
          _RegisterField(
            controller: _confirm,
            hint: 'Confirmer mot de passe',
            obscure: _obscureConfirm,
            suffix: IconButton(
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.muted,
              ),
            ),
            validator: (value) {
              if (value != _password.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),
          _PrimaryButton(label: 'Suivant', onPressed: _nextFromShop),
        ],
      ),
    );
  }

  Widget _ownerStep(AuthState auth) {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Informations du gérant',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 16),
          _RegisterField(
            controller: _ownerName,
            hint: 'Nom du gérant',
            validator: _required,
          ),
          if (auth.failure != null) ...[
            const SizedBox(height: 12),
            Text(
              auth.failure!.message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ],
          const SizedBox(height: 22),
          _PrimaryButton(
            label: auth.isLoading ? 'Inscription...' : 'Suivant',
            onPressed: auth.isLoading ? null : _submitAccount,
          ),
        ],
      ),
    );
  }

  Widget _docsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Vérification de votre identité',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Téléchargez vos pièces justificatives',
          style: TextStyle(color: AppColors.muted, fontSize: 13),
        ),
        const SizedBox(height: 16),
        _DocTile(
          title: "Pièce d'identité",
          subtitle: 'CNI ou passeport',
          selected: _docs.contains('id'),
          onTap: () => _toggleDoc('id'),
        ),
        const SizedBox(height: 10),
        _DocTile(
          title: 'Justificatif de domicile',
          subtitle: 'Facture ou quittance',
          selected: _docs.contains('address'),
          onTap: () => _toggleDoc('address'),
        ),
        const SizedBox(height: 10),
        _DocTile(
          title: 'Photo de vous',
          subtitle: 'Selfie de qualité',
          selected: _docs.contains('selfie'),
          onTap: () => _toggleDoc('selfie'),
        ),
        const SizedBox(height: 22),
        _PrimaryButton(
          label: 'Télécharger les documents',
          onPressed: () => context.go(AppRoutes.login),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text(
            'Plus tard',
            style: TextStyle(color: AppColors.muted),
          ),
        ),
      ],
    );
  }

  void _toggleDoc(String key) {
    setState(() {
      if (_docs.contains(key)) {
        _docs.remove(key);
      } else {
        _docs.add(key);
      }
    });
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Champ requis';
    return null;
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 28),
        _StepDot(number: 1, current: current),
        _StepLine(active: current > 1),
        _StepDot(number: 2, current: current),
        _StepLine(active: current > 2),
        _StepDot(number: 3, current: current),
        const SizedBox(width: 28),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({required this.number, required this.current});

  final int number;
  final int current;

  @override
  Widget build(BuildContext context) {
    final active = number <= current;
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.accent : Colors.white,
        border: Border.all(
          color: active ? AppColors.accent : const Color(0xFFD7E0EA),
          width: 1.4,
        ),
      ),
      child: Text(
        '$number',
        style: TextStyle(
          color: active ? Colors.white : const Color(0xFF8AA0B5),
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  const _StepLine({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: active ? AppColors.accent : const Color(0xFFD7E0EA),
      ),
    );
  }
}

InputDecoration _inputDecoration({Widget? suffix}) {
  return InputDecoration(
    filled: true,
    fillColor: Colors.white,
    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 15),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    suffixIcon: suffix,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.secondary, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.error),
    ),
  );
}

class _RegisterField extends StatelessWidget {
  const _RegisterField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.suffix,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(suffix: suffix).copyWith(hintText: hint),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.accent : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selected ? Icons.check_circle_rounded : Icons.upload_file_outlined,
                color: selected ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
