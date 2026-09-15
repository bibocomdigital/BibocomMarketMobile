import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:bibomarketmobile/features/auth/presentation/widgets/login_form.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/shared/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary,
                  child: Text('B', style: TextStyle(color: Colors.white, fontSize: 28)),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Bibo Market',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Connectez-vous à l’espace client', textAlign: TextAlign.center),
                const SizedBox(height: 32),
                LoginForm(
                  isLoading: auth.isLoading,
                  errorMessage: auth.failure?.message,
                  onSubmit: (identifier, password) {
                    final isEmail = identifier.contains('@');
                    ref.read(authNotifierProvider.notifier).login(
                          LoginParams(
                            email: isEmail ? identifier : null,
                            phoneNumber: isEmail ? null : identifier,
                            password: password,
                          ),
                        );
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go(AppRoutes.roleSelect),
                  child: const Text('S’inscrire'),
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
