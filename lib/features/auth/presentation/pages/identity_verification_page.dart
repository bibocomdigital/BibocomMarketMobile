import 'package:bibomarketmobile/config/router/app_routes.dart';
import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/features/merchant/presentation/widgets/merchant_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IdentityVerificationPage extends StatefulWidget {
  const IdentityVerificationPage({super.key});

  @override
  State<IdentityVerificationPage> createState() =>
      _IdentityVerificationPageState();
}

class _IdentityVerificationPageState extends State<IdentityVerificationPage> {
  final _selected = <String>{};

  void _toggle(String key) {
    setState(() {
      if (_selected.contains(key)) {
        _selected.remove(key);
      } else {
        _selected.add(key);
      }
    });
  }

  void _continue() {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,
      body: Column(
        children: [
          const MerchantBackHeader(title: 'Vérification de votre identité'),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -16),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                children: [
                  MerchantCard(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Téléchargez vos pièces justificatives',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _DocTile(
                          title: "Pièce d'identité",
                          subtitle: 'CNI ou passeport',
                          selected: _selected.contains('id'),
                          onTap: () => _toggle('id'),
                        ),
                        const SizedBox(height: 10),
                        _DocTile(
                          title: 'Justificatif de domicile',
                          subtitle: 'Facture ou quittance',
                          selected: _selected.contains('address'),
                          onTap: () => _toggle('address'),
                        ),
                        const SizedBox(height: 10),
                        _DocTile(
                          title: 'Photo de vous',
                          subtitle: 'Selfie de qualité',
                          selected: _selected.contains('selfie'),
                          onTap: () => _toggle('selfie'),
                        ),
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: _continue,
                          child: const Text('Télécharger les documents'),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _continue,
                          child: const Text(
                            'Plus tard',
                            style: TextStyle(color: AppColors.muted),
                          ),
                        ),
                      ],
                    ),
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

class _DocTile extends StatelessWidget {
  const _DocTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.light,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.upload_file_outlined,
                color: selected ? AppColors.success : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
