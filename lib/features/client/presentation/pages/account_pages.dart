import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/helpers/formatters.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/client/providers/client_providers.dart';
import 'package:bibomarketmobile/shared/helpers/context_extensions.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:bibomarketmobile/shared/widgets/error_view.dart';
import 'package:bibomarketmobile/shared/widgets/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await ref.read(clientRepositoryProvider).markNotificationsRead();
              ref.invalidate(notificationsProvider);
            },
            child: const Text('Tout lu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: items.when(
        loading: () => const AppLoader(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (list) {
          if (list.isEmpty) return const EmptyState(message: 'Aucune notification.');
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = list[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.message, style: TextStyle(fontWeight: item.isRead ? FontWeight.w400 : FontWeight.w700)),
                      if (item.createdAt != null)
                        Text(DateFormatFr.day(item.createdAt!), style: const TextStyle(color: Colors.black54, fontSize: 12)),
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

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    (user?.firstName.isEmpty ?? true) ? 'C' : user!.firstName[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(user?.email ?? ''),
                      if (user?.phoneNumber != null) Text(PhoneFormat.mali(user!.phoneNumber)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _tile(context, LucideIcons.userRoundPen, 'Modifier le profil', AppRoutes.editProfile),
          _tile(context, LucideIcons.heart, 'Favoris', AppRoutes.favorites),
          _tile(context, LucideIcons.receipt, 'Mes commandes', AppRoutes.orders),
          _tile(context, LucideIcons.bell, 'Notifications', AppRoutes.notifications),
          _tile(context, LucideIcons.lock, 'Sécurité', AppRoutes.security),
          _tile(context, LucideIcons.settings, 'Préférences', AppRoutes.preferences),
          _tile(context, LucideIcons.messageCircle, 'WhatsApp', AppRoutes.whatsapp),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
            child: const Text('Se déconnecter', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label),
      trailing: const Icon(LucideIcons.chevronRight),
      onTap: () => context.push(route),
    );
  }
}

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _city;
  late final TextEditingController _country;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _firstName = TextEditingController(text: user?.firstName ?? '');
    _lastName = TextEditingController(text: user?.lastName ?? '');
    _phone = TextEditingController(text: user?.phoneNumber ?? '');
    _city = TextEditingController(text: user?.city ?? '');
    _country = TextEditingController(text: user?.country ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _city.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authNotifierProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _firstName, decoration: const InputDecoration(labelText: 'Prénom')),
          const SizedBox(height: 12),
          TextField(controller: _lastName, decoration: const InputDecoration(labelText: 'Nom')),
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Téléphone', hintText: '+223 70 00 00 00'),
          ),
          const SizedBox(height: 12),
          TextField(controller: _city, decoration: const InputDecoration(labelText: 'Ville')),
          const SizedBox(height: 12),
          TextField(controller: _country, decoration: const InputDecoration(labelText: 'Pays')),
          const SizedBox(height: 24),
          CoralButton(
            label: 'Enregistrer',
            loading: loading,
            onPressed: () async {
              final ok = await ref.read(authNotifierProvider.notifier).updateProfile({
                'firstName': _firstName.text.trim(),
                'lastName': _lastName.text.trim(),
                'phoneNumber': _phone.text.trim(),
                'city': _city.text.trim(),
                'country': _country.text.trim(),
              });
              if (!context.mounted) return;
              if (ok) {
                context.showSnack('Profil mis à jour');
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}

class SecurityPage extends ConsumerStatefulWidget {
  const SecurityPage({super.key});

  @override
  ConsumerState<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends ConsumerState<SecurityPage> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sécurité')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _current,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
              validator: (value) => value == null || value.length < 6 ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _next,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
              validator: (value) => value == null || value.length < 6 ? 'Au moins 6 caractères' : null,
            ),
            const SizedBox(height: 24),
            CoralButton(
              label: 'Changer le mot de passe',
              loading: _loading,
              onPressed: () async {
                if (!(_formKey.currentState?.validate() ?? false)) return;
                setState(() => _loading = true);
                final ok = await ref.read(authNotifierProvider.notifier).changePassword(
                      currentPassword: _current.text,
                      newPassword: _next.text,
                    );
                if (!mounted) return;
                setState(() => _loading = false);
                context.showSnack(ok ? 'Mot de passe mis à jour' : 'Impossible de changer le mot de passe');
              },
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Supprimer le compte'),
                    content: const Text('Cette action est irréversible.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(authNotifierProvider.notifier).deleteAccount();
                }
              },
              child: const Text('Supprimer le compte'),
            ),
          ],
        ),
      ),
    );
  }
}

class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    return Scaffold(
      appBar: AppBar(title: const Text('Préférences')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Valeurs du profil. PUT /users/profile n’accepte pas langue, fuseau ni devise.',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                ListTile(title: const Text('Langue'), trailing: Text(user?.language ?? 'fr')),
                ListTile(
                  title: const Text('Devise'),
                  trailing: Text(user?.currency == 'CFA' ? 'FCFA' : (user?.currency ?? 'FCFA')),
                ),
                ListTile(title: const Text('Fuseau'), trailing: Text(user?.timezone ?? 'Africa/Dakar')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final following = ref.watch(followingProvider);
    final shops = ref.watch(shopsProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('Favoris')),
      body: following.when(
        loading: () => const AppLoader(),
        error: (error, _) => ErrorView(
          message: error.toString(),
          onRetry: () => ref.invalidate(followingProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyState(
              message: 'Aucun abonnement.\nSuivez une boutique pour la retrouver ici.',
              icon: LucideIcons.heart,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(followingProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = items[index];
                final match = shops.where((item) => item.ownerId == user.id);
                final found = match.isEmpty ? null : match.first;
                return AppCard(
                  onTap: found == null ? null : () => context.push('${AppRoutes.shop}/${found.id}'),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          user.firstName.isEmpty ? 'U' : user.firstName[0],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(found?.name ?? user.role ?? ''),
                          ],
                        ),
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
