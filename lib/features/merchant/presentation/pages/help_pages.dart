import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          const MerchantBackHeader(title: 'Support'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                MerchantMenuTile(
                  icon: Icons.help_outline,
                  label: 'FAQ',
                  onTap: () => context.push(AppRoutes.faq),
                ),
                const SizedBox(height: 8),
                MerchantMenuTile(
                  icon: Icons.chat_bubble_outline,
                  label: 'Contacter l’équipe',
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                MerchantMenuTile(
                  icon: Icons.report_gmailerrorred_outlined,
                  label: 'Signaler un problème',
                  onTap: () {},
                ),
                const SizedBox(height: 18),
                MerchantCard(
                  child: Column(
                    children: [
                      const Text(
                        'Besoin d’aide ?',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Notre équipe est disponible pour vous accompagner.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Nous contacter'),
                      ),
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

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        'Livraison standard (2-3 jours)',
        'Dakar et environs, à partir de 1 500 CFA',
      ),
      (
        'Livraison express (24h)',
        'Disponible selon les zones, 3 000 CFA',
      ),
      (
        'Retrait en boutique',
        'Gratuit',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          const MerchantBackHeader(title: 'Aide & FAQ'),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return MerchantCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.$1,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          const MerchantBackHeader(title: 'Paramètres'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                MerchantMenuTile(
                  icon: Icons.verified_user_outlined,
                  label: 'Statut boutique',
                  onTap: () => context.push(AppRoutes.shopStatus),
                ),
                const SizedBox(height: 8),
                MerchantMenuTile(
                  icon: Icons.chat_outlined,
                  label: 'Messages clients',
                  onTap: () => context.push(AppRoutes.merchantMessages),
                ),
                const SizedBox(height: 8),
                MerchantMenuTile(
                  icon: Icons.inventory_outlined,
                  label: 'Demandes produits',
                  onTap: () => context.push(AppRoutes.productRequests),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LogoutConfirmPage extends ConsumerWidget {
  const LogoutConfirmPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          const MerchantBackHeader(title: 'Déconnexion'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                MerchantCard(
                  child: Column(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Êtes-vous sûr de vouloir vous déconnecter ?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                        ),
                        onPressed: () =>
                            ref.read(authNotifierProvider.notifier).logout(),
                        child: const Text('Se déconnecter'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Annuler'),
                      ),
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
