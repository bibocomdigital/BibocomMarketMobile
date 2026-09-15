import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:bibomarketmobile/features/auth/presentation/widgets/login_form.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              children: [
                const SizedBox(height: 24),
                const Text(
                  'BiboMarket',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connectez-vous pour continuer',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                LoginForm(
                  isLoading: auth.isLoading,
                  errorMessage: auth.failure?.message,
                  onSubmit: (email, password) {
                    ref.read(authNotifierProvider.notifier).login(
                          LoginParams(email: email, password: password),
                        );
                  },
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: auth.isLoading
                      ? null
                      : () => ref
                          .read(authNotifierProvider.notifier)
                          .loginWithGoogle(),
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Continuer avec Google'),
                ),
                if (auth.isLoading) ...[
                  const SizedBox(height: 24),
                  const AppLoader(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
