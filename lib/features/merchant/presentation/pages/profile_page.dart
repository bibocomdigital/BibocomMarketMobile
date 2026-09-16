import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final overview = ref.watch(merchantOverviewProvider);
    final shop = overview.asData?.value.shop;
    final data = overview.asData?.value;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: Column(
          children: [
            SizedBox(height: MediaQuery.paddingOf(context).top),
            Expanded(
              child: Material(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                clipBehavior: Clip.antiAlias,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 28, 22, 16),
                  children: [
                    Row(
                      children: [
                        _Avatar(
                          initials: shop?.initials ?? 'B',
                          imageUrl: user?.photo ?? shop?.logo,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                shop?.name ?? user?.displayName ?? 'Commerçant',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? '',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: FilledButton(
                        onPressed: () =>
                            context.push(AppRoutes.merchantEditProfile),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Modifier mon profil'),
                      ),
                    ),
                    const SizedBox(height: 26),
                    _StatsRow(
                      products: data?.stats.totalProducts ?? data?.products.length ?? 0,
                      rating: shop?.verified == true ? '4,8' : '—',
                      followers: '0',
                    ),
                    const SizedBox(height: 8),
                    _MenuRow(
                      icon: Icons.storefront_outlined,
                      label: 'Ma boutique',
                      onTap: () => context.push(AppRoutes.shopProfile),
                    ),
                    _MenuRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Mes produits',
                      onTap: () => context.go(AppRoutes.products),
                    ),
                    _MenuRow(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Commandes',
                      onTap: () => context.go(AppRoutes.merchantOrders),
                    ),
                    _MenuRow(
                      icon: Icons.notifications_none_rounded,
                      label: 'Notifications',
                      onTap: () =>
                          context.push(AppRoutes.merchantNotifications),
                    ),
                    _MenuRow(
                      icon: Icons.chat_outlined,
                      label: 'WhatsApp',
                      onTap: () => context.push(AppRoutes.merchantWhatsapp),
                    ),
                    _MenuRow(
                      icon: Icons.show_chart_rounded,
                      label: 'Statistiques',
                      onTap: () => context.go(AppRoutes.stats),
                    ),
                    _MenuRow(
                      icon: Icons.settings_outlined,
                      label: 'Paramètres',
                      onTap: () => context.push(AppRoutes.settings),
                    ),
                    _MenuRow(
                      icon: Icons.lock_outline_rounded,
                      label: 'Sécurité',
                      onTap: () => context.push(AppRoutes.merchantSecurity),
                    ),
                    _MenuRow(
                      icon: Icons.tune_rounded,
                      label: 'Préférences',
                      onTap: () =>
                          context.push(AppRoutes.merchantPreferences),
                    ),
                    _MenuRow(
                      icon: Icons.help_outline_rounded,
                      label: 'Aide et support',
                      onTap: () => context.push(AppRoutes.support),
                      showDivider: false,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => context.push(AppRoutes.logoutConfirm),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: AppColors.accent,
                              size: 22,
                            ),
                            SizedBox(width: 14),
                            Text(
                              'Se déconnecter',
                              style: TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
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
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials, this.imageUrl});

  final String initials;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    return CircleAvatar(
      radius: 34,
      backgroundColor: const Color(0xFFE8EEF5),
      backgroundImage: url != null && url.isNotEmpty ? NetworkImage(url) : null,
      child: url == null || url.isEmpty
          ? Text(
              initials,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            )
          : null,
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.products,
    required this.rating,
    required this.followers,
  });

  final int products;
  final String rating;
  final String followers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _StatCell(value: '$products', label: 'Produits'),
          _divider(),
          _StatCell(value: rating, label: 'Note'),
          _divider(),
          _StatCell(value: followers, label: 'Abonnés'),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE6EDF4),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
        if (showDivider) const Divider(height: 1, color: Color(0xFFEEF2F6)),
      ],
    );
  }
}
