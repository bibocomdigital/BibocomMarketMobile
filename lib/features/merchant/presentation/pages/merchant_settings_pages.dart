import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/client/domain/client_models.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:bibomarketmobile/features/merchant/providers/merchant_providers.dart';
import 'package:bibomarketmobile/shared/helpers/context_extensions.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

enum _NotifTab { all, orders, messages, reviews }

class MerchantNotificationsPage extends ConsumerStatefulWidget {
  const MerchantNotificationsPage({super.key});

  @override
  ConsumerState<MerchantNotificationsPage> createState() =>
      _MerchantNotificationsPageState();
}

class _MerchantNotificationsPageState
    extends ConsumerState<MerchantNotificationsPage> {
  _NotifTab _tab = _NotifTab.all;

  bool _matches(AppNotification item) {
    final haystack = '${item.type} ${item.message}'.toLowerCase();
    return switch (_tab) {
      _NotifTab.all => true,
      _NotifTab.orders =>
        haystack.contains('order') || haystack.contains('commande'),
      _NotifTab.messages =>
        haystack.contains('message') || haystack.contains('chat'),
      _NotifTab.reviews =>
        haystack.contains('review') ||
            haystack.contains('avis') ||
            haystack.contains('comment') ||
            haystack.contains('rating'),
    };
  }

  String _title(AppNotification item) {
    final type = item.type.toLowerCase();
    if (type.contains('order') || type.contains('commande')) {
      return 'Nouvelle commande';
    }
    if (type.contains('message') || type.contains('chat')) {
      return 'Nouveau message';
    }
    if (type.contains('review') || type.contains('avis') || type.contains('comment')) {
      return 'Avis client';
    }
    if (item.message.trim().isNotEmpty) {
      return item.message.split('\n').first;
    }
    return 'Notification';
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(merchantNotificationsProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          MerchantCenteredHeader(
            title: 'Notifications',
            action: IconButton(
              onPressed: () =>
                  context.push(AppRoutes.merchantNotificationSettings),
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                _NotifChip(
                  label: 'Toutes',
                  selected: _tab == _NotifTab.all,
                  onTap: () => setState(() => _tab = _NotifTab.all),
                ),
                _NotifChip(
                  label: 'Commandes',
                  selected: _tab == _NotifTab.orders,
                  onTap: () => setState(() => _tab = _NotifTab.orders),
                ),
                _NotifChip(
                  label: 'Messages',
                  selected: _tab == _NotifTab.messages,
                  onTap: () => setState(() => _tab = _NotifTab.messages),
                ),
                _NotifChip(
                  label: 'Avis',
                  selected: _tab == _NotifTab.reviews,
                  onTap: () => setState(() => _tab = _NotifTab.reviews),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.when(
              loading: () => const AppLoader(),
              error: (error, _) => Center(
                child: Text(error.toString().replaceFirst('Exception: ', '')),
              ),
              data: (list) {
                final visible = list.where(_matches).toList();
                if (visible.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune notification',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 20 + bottom),
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = visible[index];
                    return MerchantCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 6, right: 10),
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            )
                          else
                            const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _title(item),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.message,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifChip extends StatelessWidget {
  const _NotifChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? AppColors.accent : AppColors.navySoft,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 2.5,
                width: selected ? 28 : 0,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MerchantNotificationSettingsPage extends ConsumerStatefulWidget {
  const MerchantNotificationSettingsPage({super.key});

  @override
  ConsumerState<MerchantNotificationSettingsPage> createState() =>
      _MerchantNotificationSettingsPageState();
}

class _MerchantNotificationSettingsPageState
    extends ConsumerState<MerchantNotificationSettingsPage> {
  late bool _orders;
  late bool _messages;
  late bool _reviews;
  late bool _promo;
  late bool _email;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(merchantLocalPrefsProvider);
    _orders = prefs.notifyOrders;
    _messages = prefs.notifyMessages;
    _reviews = prefs.notifyReviews;
    _promo = prefs.notifyPromo;
    _email = prefs.notifyEmail;
  }

  Future<void> _set(String key, bool value, void Function(bool) apply) async {
    apply(value);
    setState(() {});
    await ref.read(merchantLocalPrefsProvider).setFlag(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const MerchantCenteredHeader(title: 'Notifications'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                const Text(
                  'Paramètres de notification',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _SwitchRow(
                  label: 'Commandes',
                  value: _orders,
                  onChanged: (value) => _set(
                    StorageKeys.notifyOrders,
                    value,
                    (next) => _orders = next,
                  ),
                ),
                _SwitchRow(
                  label: 'Messages',
                  value: _messages,
                  onChanged: (value) => _set(
                    StorageKeys.notifyMessages,
                    value,
                    (next) => _messages = next,
                  ),
                ),
                _SwitchRow(
                  label: 'Avis',
                  value: _reviews,
                  onChanged: (value) => _set(
                    StorageKeys.notifyReviews,
                    value,
                    (next) => _reviews = next,
                  ),
                ),
                _SwitchRow(
                  label: 'Promo',
                  value: _promo,
                  onChanged: (value) => _set(
                    StorageKeys.notifyPromo,
                    value,
                    (next) => _promo = next,
                  ),
                ),
                _SwitchRow(
                  label: 'Via mail',
                  value: _email,
                  onChanged: (value) => _set(
                    StorageKeys.notifyEmail,
                    value,
                    (next) => _email = next,
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

class MerchantSecurityPage extends ConsumerStatefulWidget {
  const MerchantSecurityPage({super.key});

  @override
  ConsumerState<MerchantSecurityPage> createState() =>
      _MerchantSecurityPageState();
}

class _MerchantSecurityPageState extends ConsumerState<MerchantSecurityPage> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _loading = false;
  late bool _twoFactor;

  @override
  void initState() {
    super.initState();
    _twoFactor = ref.read(merchantLocalPrefsProvider).twoFactor;
  }

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_current.text.length < 6 || _next.text.length < 6) {
      context.showSnack('Mot de passe trop court');
      return;
    }
    setState(() => _loading = true);
    final ok = await ref.read(authNotifierProvider.notifier).changePassword(
          currentPassword: _current.text,
          newPassword: _next.text,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    context.showSnack(
      ok ? 'Mot de passe mis à jour' : 'Impossible de changer le mot de passe',
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const MerchantCenteredHeader(title: 'Sécurité'),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
              children: [
                const Text(
                  'Mot de passe',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _current,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Mot de passe actuel',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _next,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Nouveau mot de passe',
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _loading ? null : _changePassword,
                    child: Text(_loading ? 'Enregistrement...' : 'Modifier'),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sessions actives',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const MerchantCard(
                  child: Row(
                    children: [
                      Icon(Icons.smartphone_rounded, color: AppColors.primary),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cet appareil',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'Session en cours',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _SwitchRow(
                  label: '2FA',
                  value: _twoFactor,
                  onChanged: (value) async {
                    setState(() => _twoFactor = value);
                    await ref.read(merchantLocalPrefsProvider).setFlag(
                          StorageKeys.twoFactorEnabled,
                          value,
                        );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: () async {
                      final confirmed = await AppAlert.confirm(
                        context,
                        title: 'Supprimer le compte',
                        message: 'Cette action est irréversible.',
                        confirmLabel: 'Supprimer',
                        destructive: true,
                      );
                      if (confirmed == true) {
                        await ref
                            .read(authNotifierProvider.notifier)
                            .deleteAccount();
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Supprimer le compte',
                      style: TextStyle(fontWeight: FontWeight.w700),
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

class MerchantPreferencesPage extends ConsumerStatefulWidget {
  const MerchantPreferencesPage({super.key});

  @override
  ConsumerState<MerchantPreferencesPage> createState() =>
      _MerchantPreferencesPageState();
}

class _MerchantPreferencesPageState
    extends ConsumerState<MerchantPreferencesPage> {
  late String _language;
  late String _timezone;
  late String _dateFormat;
  late String _currency;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(merchantLocalPrefsProvider);
    _language = prefs.language;
    _timezone = prefs.timezone;
    _dateFormat = prefs.dateFormat;
    _currency = prefs.currency;
  }

  Future<void> _pick({
    required String title,
    required String current,
    required List<String> options,
    required String storageKey,
    required void Function(String) apply,
  }) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ),
              ...options.map(
                (option) => ListTile(
                  title: Text(option),
                  trailing: option == current
                      ? const Icon(Icons.check_rounded, color: AppColors.accent)
                      : null,
                  onTap: () => Navigator.pop(context, option),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (selected == null) return;
    apply(selected);
    setState(() {});
    await ref.read(merchantLocalPrefsProvider).setText(storageKey, selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const MerchantCenteredHeader(title: 'Préférences'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                _PrefRow(
                  label: 'Langue',
                  value: _language,
                  onTap: () => _pick(
                    title: 'Langue',
                    current: _language,
                    options: const ['Français', 'English', 'Wolof'],
                    storageKey: StorageKeys.prefLanguage,
                    apply: (value) => _language = value,
                  ),
                ),
                _PrefRow(
                  label: 'Fuseau',
                  value: _timezone,
                  onTap: () => _pick(
                    title: 'Fuseau horaire',
                    current: _timezone,
                    options: const [
                      'Africa/Dakar (GMT+0)',
                      'Africa/Abidjan (GMT+0)',
                      'Africa/Bamako (GMT+0)',
                    ],
                    storageKey: StorageKeys.prefTimezone,
                    apply: (value) => _timezone = value,
                  ),
                ),
                _PrefRow(
                  label: 'Format de date',
                  value: _dateFormat,
                  onTap: () => _pick(
                    title: 'Format de date',
                    current: _dateFormat,
                    options: const ['JJ/MM/AAAA', 'MM/JJ/AAAA', 'AAAA-MM-JJ'],
                    storageKey: StorageKeys.prefDateFormat,
                    apply: (value) => _dateFormat = value,
                  ),
                ),
                _PrefRow(
                  label: 'Devise',
                  value: _currency,
                  onTap: () => _pick(
                    title: 'Devise',
                    current: _currency,
                    options: const ['FCFA', 'EUR', 'USD'],
                    storageKey: StorageKeys.prefCurrency,
                    apply: (value) => _currency = value,
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

class MerchantWhatsAppPage extends ConsumerWidget {
  const MerchantWhatsAppPage({super.key});

  String _digits(String raw) {
    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00')) digits = digits.substring(2);
    if (digits.length == 9 && (digits.startsWith('7') || digits.startsWith('77'))) {
      digits = '221$digits';
    }
    return digits;
  }

  Future<void> _open(BuildContext context, String? phone) async {
    final digits = _digits(phone ?? '');
    if (digits.isEmpty) {
      context.showSnack('Numéro WhatsApp indisponible pour ce client');
      return;
    }
    await launchUrl(
      Uri.parse('https://wa.me/$digits'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(conversationsProvider);
    final overview = ref.watch(merchantOverviewProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const MerchantCenteredHeader(title: 'Contacter via WhatsApp'),
          Expanded(
            child: conversations.when(
              loading: () => const AppLoader(),
              error: (error, _) => Center(
                child: Text(error.toString().replaceFirst('Exception: ', '')),
              ),
              data: (items) {
                final phones = <String, String>{};
                for (final order in overview.value?.orders ?? const []) {
                  final name = order.clientName ?? 'Client';
                  final phone = order.clientPhone;
                  if (phone != null && phone.trim().isNotEmpty) {
                    phones[name] = phone;
                  }
                }

                final rows = <({String name, String? phone, String? preview})>[
                  ...items.map(
                    (item) => (
                      name: item.partnerName,
                      phone: item.partnerPhone ?? phones[item.partnerName],
                      preview: item.lastMessage,
                    ),
                  ),
                ];

                for (final entry in phones.entries) {
                  final exists = rows.any((row) => row.name == entry.key);
                  if (!exists) {
                    rows.add((name: entry.key, phone: entry.value, preview: null));
                  }
                }

                if (rows.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aucune conversation pour le moment',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 20 + bottom),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    return MerchantCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFFE8F0F6),
                            child: Text(
                              row.name.trim().isEmpty
                                  ? 'C'
                                  : row.name.trim()[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row.name,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (row.preview != null &&
                                    row.preview!.isNotEmpty)
                                  Text(
                                    row.preview!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 13,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed: () => _open(context, row.phone),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              minimumSize: const Size(0, 36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'WhatsApp',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.success,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _PrefRow extends StatelessWidget {
  const _PrefRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}
