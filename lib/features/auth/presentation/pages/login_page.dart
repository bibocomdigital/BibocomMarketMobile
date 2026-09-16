import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:bibomarketmobile/features/auth/presentation/widgets/auth_chrome.dart';
import 'package:bibomarketmobile/features/auth/presentation/widgets/login_form.dart';
import 'package:bibomarketmobile/features/auth/providers/auth_providers.dart';
import 'package:bibomarketmobile/shared/widgets/google_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            ColoredBox(
              color: AppColors.primary,
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: CustomPaint(painter: AuthAuraPainter()),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 20, 20),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go(AppRoutes.onboarding);
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                              ),
                              icon: const Icon(Icons.chevron_left, size: 28),
                              label: const Text(
                                'Connexion',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const AuthBrandMark(),
                          const SizedBox(height: 12),
                          const Text(
                            'Bibo Market',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Espace Commerçant',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Material(
                  color: Colors.white,
                  elevation: 0,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(36),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 40, 24, 12 + bottom),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  children: [
                                    LoginForm(
                                      isLoading: auth.isLoading,
                                      errorMessage: auth.failure?.message,
                                      onSubmit: (email, phone, password) {
                                        ref
                                            .read(authNotifierProvider.notifier)
                                            .login(
                                              LoginParams(
                                                email: email.isEmpty
                                                    ? null
                                                    : email,
                                                phoneNumber: phone.isEmpty
                                                    ? null
                                                    : phone,
                                                password: password,
                                              ),
                                            );
                                      },
                                    ),
                                    const SizedBox(height: 22),
                                    const Text(
                                      'Ou se connecter avec',
                                      style: TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 52,
                                      child: OutlinedButton.icon(
                                        onPressed: auth.isLoading
                                            ? null
                                            : () => ref
                                                .read(
                                                  authNotifierProvider.notifier,
                                                )
                                                .loginWithGoogle(),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(
                                            color: Color(0xFFE6EDF4),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          textStyle: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        icon: const GoogleLogo(size: 22),
                                        label: const Text(
                                          'Continuer avec Google',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Pas de compte ? ',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () =>
                                          context.go(AppRoutes.roleSelect),
                                      child: const Text(
                                        "S'inscrire",
                                        style: TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

