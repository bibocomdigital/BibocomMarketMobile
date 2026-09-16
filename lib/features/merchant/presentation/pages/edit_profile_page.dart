import 'dart:io';

import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:bibomarketmobile/shared/helpers/context_extensions.dart';
import 'package:bibomarketmobile/shared/widgets/image_source_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MerchantEditProfilePage extends ConsumerStatefulWidget {
  const MerchantEditProfilePage({super.key});

  @override
  ConsumerState<MerchantEditProfilePage> createState() =>
      _MerchantEditProfilePageState();
}

class _MerchantEditProfilePageState
    extends ConsumerState<MerchantEditProfilePage> {
  static const _pageBg = Color(0xFFF3F8FC);
  static const _fieldBorder = Color(0xFFD5E4F0);
  static const _asterisk = Color(0xFFFF7E5F);
  static const _navBlue = Color(0xFF0A2340);

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _bio;
  String? _photoPath;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _firstName = TextEditingController(text: user?.firstName ?? '');
    _lastName = TextEditingController(text: user?.lastName ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _phone = TextEditingController(text: user?.phoneNumber ?? '');
    _address = TextEditingController(
      text: _joinAddress(user?.city, user?.country),
    );
    _bio = TextEditingController();
    Future.microtask(_hydrateShop);
  }

  Future<void> _hydrateShop() async {
    final overview = await ref.read(merchantOverviewProvider.future);
    if (!mounted) return;
    final shop = overview.shop;
    if (shop == null) return;
    setState(() {
      if (shop.description.isNotEmpty) _bio.text = shop.description;
      if (shop.address.isNotEmpty) _address.text = shop.address;
    });
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _changePhoto() async {
    final path = await pickAppImage(context);
    if (path == null || !mounted) return;
    setState(() => _photoPath = path);
  }

  Future<void> _save() async {
    if (_firstName.text.trim().isEmpty) {
      context.showSnack('Le prénom est requis');
      return;
    }
    setState(() => _saving = true);
    final parts = _address.text
        .split(',')
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    final city = parts.isNotEmpty ? parts.first : '';
    final country = parts.length > 1 ? parts.sublist(1).join(', ') : '';

    if (_photoPath != null) {
      final photoOk = await ref
          .read(authNotifierProvider.notifier)
          .uploadProfilePhoto(_photoPath!);
      if (!mounted) return;
      if (!photoOk) {
        setState(() => _saving = false);
        context.showSnack(
          ref.read(authNotifierProvider).failure?.message ??
              'Impossible de mettre à jour la photo',
        );
        return;
      }
    }

    final ok = await ref.read(authNotifierProvider.notifier).updateProfile({
      'firstName': _firstName.text.trim(),
      'lastName': _lastName.text.trim(),
      'phoneNumber': _phone.text.trim(),
      if (city.isNotEmpty) 'city': city,
      if (country.isNotEmpty) 'country': country,
    });
    if (!mounted) return;
    if (!ok) {
      setState(() => _saving = false);
      context.showSnack(
        ref.read(authNotifierProvider).failure?.message ??
            'Impossible de mettre à jour le profil',
      );
      return;
    }

    final overview = await ref.read(merchantOverviewProvider.future);
    final shop = overview.shop;
    if (shop != null) {
      await ref.read(merchantRepositoryProvider).updateShop(
            shop.id,
            CreateShopParams(
              name: shop.name,
              description: _bio.text.trim(),
              phoneNumber: shop.phoneNumber,
              address: _address.text.trim(),
              categorieShopId: shop.categorieShopId,
            ),
          );
      ref.invalidate(merchantOverviewProvider);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    context.showSnack('Profil mis à jour');
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final shop = ref.watch(merchantOverviewProvider).asData?.value.shop;
    final photoUrl = user?.photo ?? shop?.logo;
    final initials = shop?.initials ??
        ((user?.firstName.isNotEmpty ?? false)
            ? user!.firstName[0].toUpperCase()
            : 'B');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _pageBg,
        body: Column(
          children: [
            const _EditProfileHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _AvatarPicker(
                        initials: initials,
                        photoUrl: photoUrl,
                        filePath: _photoPath,
                        onTap: _changePhoto,
                      ),
                      const SizedBox(width: 18),
                      SizedBox(
                        height: 40,
                        child: TextButton(
                          onPressed: _changePhoto,
                          style: TextButton.styleFrom(
                            foregroundColor: _navBlue,
                            backgroundColor: const Color(0xFFEAF2F8),
                            padding: const EdgeInsets.symmetric(horizontal: 22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Changer'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const _TwoFields(
                    leftLabel: 'Prénom',
                    leftRequired: true,
                    rightLabel: 'Nom',
                  ),
                  const SizedBox(height: 8),
                  _TwoFieldRow(
                    left: _ProfileField(controller: _firstName),
                    right: _ProfileField(controller: _lastName),
                  ),
                  const SizedBox(height: 14),
                  const _TwoFields(
                    leftLabel: 'Email',
                    leftRequired: true,
                    rightLabel: 'Téléphone',
                    rightRequired: true,
                  ),
                  const SizedBox(height: 8),
                  _TwoFieldRow(
                    left: _ProfileField(
                      controller: _email,
                      readOnly: true,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    right: _ProfileField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _FieldLabel(text: 'Adresse', required: true),
                  const SizedBox(height: 8),
                  _ProfileField(controller: _address),
                  const SizedBox(height: 14),
                  const _FieldLabel(text: 'Bio'),
                  const SizedBox(height: 8),
                  _ProfileField(
                    controller: _bio,
                    minLines: 3,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        disabledBackgroundColor:
                            AppColors.accent.withValues(alpha: 0.7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const _EditProfileNavBar(),
      ),
    );
  }

  static String _joinAddress(String? city, String? country) {
    return [city, country]
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .join(', ');
  }
}

class _EditProfileHeader extends StatelessWidget {
  const _EditProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        12,
        MediaQuery.paddingOf(context).top + 6,
        20,
        16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.popOrFallback(
              fallback: AppRoutes.merchantProfile,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Modifier le profil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _TwoFields extends StatelessWidget {
  const _TwoFields({
    required this.leftLabel,
    required this.rightLabel,
    this.leftRequired = false,
    this.rightRequired = false,
  });

  final String leftLabel;
  final String rightLabel;
  final bool leftRequired;
  final bool rightRequired;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _FieldLabel(text: leftLabel, required: leftRequired)),
        const SizedBox(width: 12),
        Expanded(child: _FieldLabel(text: rightLabel, required: rightRequired)),
      ],
    );
  }
}

class _TwoFieldRow extends StatelessWidget {
  const _TwoFieldRow({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, this.required = false});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          fontSize: 13.5,
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: _MerchantEditProfilePageState._asterisk,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    this.keyboardType,
    this.readOnly = false,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.25,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: minLines > 1 ? 14 : 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _MerchantEditProfilePageState._fieldBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: _MerchantEditProfilePageState._fieldBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.secondary, width: 1.3),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.initials,
    required this.onTap,
    this.photoUrl,
    this.filePath,
  });

  final String initials;
  final String? photoUrl;
  final String? filePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    ImageProvider? image;
    if (filePath != null && filePath!.isNotEmpty) {
      image = FileImage(File(filePath!));
    } else if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      image = NetworkImage(photoUrl!.trim());
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        height: 72,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF0A2340),
                image: image == null
                    ? null
                    : DecorationImage(image: image, fit: BoxFit.cover),
              ),
              alignment: Alignment.center,
              child: image == null
                  ? Text(
                      initials,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        height: 1.05,
                      ),
                    )
                  : null,
            ),
            Positioned(
              right: -1,
              bottom: 2,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A2340),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.6),
                ),
                child: const Icon(
                  Icons.photo_camera_rounded,
                  size: 11,
                  color: Color(0xFFFFB347),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileNavBar extends StatelessWidget {
  const _EditProfileNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x140A2340),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Dashboard',
                selected: true,
                onTap: () => context.go(AppRoutes.merchantHome),
              ),
              _NavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Commandes',
                onTap: () => context.go(AppRoutes.merchantOrders),
              ),
              _NavItem(
                icon: Icons.location_on_outlined,
                label: 'Produits',
                onTap: () => context.go(AppRoutes.products),
              ),
              _NavItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Messages',
                onTap: () => context.go(AppRoutes.merchantMessages),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profil',
                onTap: () => context.go(AppRoutes.merchantProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.accent
        : _MerchantEditProfilePageState._navBlue;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
