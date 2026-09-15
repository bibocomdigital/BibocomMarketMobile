import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/providers/core_providers.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/shared/helpers/context_extensions.dart';
import 'package:bibomarketmobile/shared/widgets/otp_code_field.dart';
import 'package:bibomarketmobile/shared/widgets/ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final role = ref.read(localStorageServiceProvider).getString(StorageKeys.selectedRole) ??
        UserRoles.client;
    final email = _email.text.trim();
    final result = await ref.read(authNotifierProvider.notifier).register(
          RegisterParams(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            phoneNumber: _phone.text.trim(),
            password: _password.text,
            role: role,
            email: email,
          ),
        );
    if (!mounted) return;
    setState(() => _loading = false);
    result.fold(
      failure: (failure) => context.showSnack(failure.message),
      success: (message) {
        context.showSnack(message);
        if (email.isNotEmpty) {
          context.go('${AppRoutes.verify}?email=${Uri.encodeComponent(email)}');
        } else {
          context.go(AppRoutes.login);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Inscription — Étape 1',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _firstName,
              decoration: const InputDecoration(labelText: 'Prénom'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastName,
              decoration: const InputDecoration(labelText: 'Nom'),
              validator: (value) => value == null || value.trim().isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                hintText: '+223 70 00 00 00',
              ),
              validator: (value) =>
                  value == null || value.trim().length < 8 ? 'Numéro invalide' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              validator: (value) =>
                  value == null || value.length < 6 ? 'Au moins 6 caractères' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _confirm,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
              validator: (value) => value != _password.text ? 'Les mots de passe ne correspondent pas' : null,
            ),
            const SizedBox(height: 24),
            CoralButton(label: 'Continuer', loading: _loading, onPressed: _submit),
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('J’ai déjà un compte'),
            ),
          ],
        ),
      ),
    );
  }
}

class RoleSelectPage extends ConsumerStatefulWidget {
  const RoleSelectPage({super.key});

  @override
  ConsumerState<RoleSelectPage> createState() => _RoleSelectPageState();
}

class _RoleSelectPageState extends ConsumerState<RoleSelectPage> {
  String _role = UserRoles.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Choisissez votre rôle',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              _RoleCard(
                title: 'Client',
                subtitle: 'Achetez en un clic',
                selected: _role == UserRoles.client,
                highlighted: true,
                onTap: () => setState(() => _role = UserRoles.client),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                title: 'Commerçant',
                subtitle: 'Vendez vos produits',
                selected: _role == UserRoles.merchant,
                onTap: () => setState(() => _role = UserRoles.merchant),
              ),
              const SizedBox(height: 12),
              _RoleCard(
                title: 'Fournisseur',
                subtitle: 'Approvisionnez les commerces',
                selected: _role == UserRoles.supplier,
                onTap: () => setState(() => _role = UserRoles.supplier),
              ),
              const Spacer(),
              CoralButton(
                label: 'S’inscrire',
                onPressed: () async {
                  await ref.read(localStorageServiceProvider).setString(
                        StorageKeys.selectedRole,
                        _role,
                      );
                  if (!context.mounted) return;
                  context.go(
                    _role == UserRoles.merchant
                        ? AppRoutes.merchantRegister
                        : AppRoutes.register,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.highlighted = false,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            highlighted ? LucideIcons.shoppingBag : LucideIcons.store,
            color: highlighted ? AppColors.accent : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(subtitle),
              ],
            ),
          ),
          Icon(
            selected ? LucideIcons.circleCheck : LucideIcons.circle,
            color: selected ? AppColors.accent : Colors.grey,
          ),
        ],
      ),
    );
  }
}

class VerifyCodePage extends ConsumerStatefulWidget {
  const VerifyCodePage({super.key, required this.email});

  final String email;

  @override
  ConsumerState<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends ConsumerState<VerifyCodePage> {
  String _code = '';

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authNotifierProvider).isLoading;
    final error = ref.watch(authNotifierProvider).failure?.message;
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification du code')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Code envoyé à ${widget.email}', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OtpCodeField(onChanged: (value) => _code = value),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 24),
            CoralButton(
              label: 'Vérifier',
              loading: loading,
              onPressed: () async {
                final ok = await ref.read(authNotifierProvider.notifier).verifyEmail(
                      email: widget.email,
                      code: _code.trim(),
                    );
                if (!context.mounted) return;
                if (ok) {
                  context.go(AppRoutes.completeProfile);
                }
              },
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.verifyWait),
              child: const Text('Je n’ai pas encore reçu le code'),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}

class VerifyWaitingPage extends StatelessWidget {
  const VerifyWaitingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vérification en attente')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            const Icon(LucideIcons.clock, size: 64, color: AppColors.secondary),
            const SizedBox(height: 16),
            const Text(
              'En attente de vérification',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Le backend marque le compte comme vérifié dès l’inscription. Vous pouvez vous connecter.',
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            CoralButton(
              label: 'Se connecter',
              onPressed: () => context.go(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}

class CompleteProfilePage extends ConsumerStatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  ConsumerState<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends ConsumerState<CompleteProfilePage> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _city;
  late final TextEditingController _country;
  String? _gender;
  DateTime? _birthDate;
  bool _savingPersonal = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _firstName = TextEditingController(text: user?.firstName ?? '');
    _lastName = TextEditingController(text: user?.lastName ?? '');
    _city = TextEditingController(text: user?.city ?? '');
    _country = TextEditingController(text: user?.country ?? '');
    _gender = user?.gender;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _city.dispose();
    _country.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(authNotifierProvider).isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('Compléter le profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _firstName, decoration: const InputDecoration(labelText: 'Prénom')),
          const SizedBox(height: 12),
          TextField(controller: _lastName, decoration: const InputDecoration(labelText: 'Nom')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _gender,
            decoration: const InputDecoration(labelText: 'Genre'),
            items: const [
              DropdownMenuItem(value: 'MALE', child: Text('Homme')),
              DropdownMenuItem(value: 'FEMALE', child: Text('Femme')),
              DropdownMenuItem(value: 'OTHER', child: Text('Autre')),
            ],
            onChanged: (value) => setState(() => _gender = value),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Date de naissance'),
            subtitle: Text(
              _birthDate == null ? 'Non renseignée' : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
            ),
            trailing: const Icon(LucideIcons.calendar),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(1950),
                lastDate: DateTime.now(),
                initialDate: DateTime(2000),
              );
              if (picked != null) setState(() => _birthDate = picked);
            },
          ),
          const SizedBox(height: 12),
          TextField(controller: _country, decoration: const InputDecoration(labelText: 'Pays')),
          const SizedBox(height: 12),
          TextField(controller: _city, decoration: const InputDecoration(labelText: 'Ville')),
          const SizedBox(height: 24),
          CoralButton(
            label: 'Enregistrer',
            loading: loading || _savingPersonal,
            onPressed: () async {
              setState(() => _savingPersonal = true);
              await ref.read(authRepositoryProvider).completePersonalInfo({
                'firstName': _firstName.text.trim(),
                'lastName': _lastName.text.trim(),
                if (_gender != null) 'gender': _gender,
                if (_birthDate != null) 'dateOfBirth': _birthDate!.toIso8601String(),
              });
              final ok = await ref.read(authNotifierProvider.notifier).updateProfile({
                'firstName': _firstName.text.trim(),
                'lastName': _lastName.text.trim(),
                'city': _city.text.trim(),
                'country': _country.text.trim(),
              });
              if (!context.mounted) return;
              setState(() => _savingPersonal = false);
              if (ok) {
                context.showSnack('Profil complété');
                context.go(AppRoutes.home);
              }
            },
          ),
        ],
      ),
    );
  }
}
