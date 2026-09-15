import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/constants/app_constants.dart';
import 'package:bibomarketmobile/core/providers/core_providers.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Onboarding hérité. Ne pas y ajouter de métier.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text(
                'BiboMarket',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Marketplace au Mali, au même endroit.',
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  await ref.read(localStorageServiceProvider).setBool(
                        StorageKeys.onboardingDone,
                        value: true,
                      );
                  if (context.mounted) context.go(AppRoutes.roleSelect);
                },
                child: const Text('Commencer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
