import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:bibomarketmobile/features/auth/presentation/widgets/login_form.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:bibomarketmobile/shared/widgets/brand_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          MerchantHeader(
            height: 210,
            child: Column(
              children: [
                const SizedBox(height: 12),
                const BrandMark(size: 56, dark: true),
                const SizedBox(height: 14),
                const Text(
                  'Bibo Market',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Connectez-vous pour continuer',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -18),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  MerchantCard(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        LoginForm(
                          isLoading: auth.isLoading,
                          errorMessage: auth.failure?.message,
                          onSubmit: (email, phone, password) {
                            ref.read(authNotifierProvider.notifier).login(
                                  LoginParams(
                                    email: email.isEmpty ? null : email,
                                    phoneNumber: phone.isEmpty ? null : phone,
                                    password: password,
                                  ),
                                );
                          },
                        ),
                        const SizedBox(height: 18),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'Ou continuer avec',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: auth.isLoading
                              ? null
                              : () => ref
                                  .read(authNotifierProvider.notifier)
                                  .loginWithGoogle(),
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: const Text('Continuer avec Google'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Pas de compte ? ',
                        style: TextStyle(color: AppColors.muted),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.roleSelect),
                        child: const Text(
                          "S'inscrire",
                          style: TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
