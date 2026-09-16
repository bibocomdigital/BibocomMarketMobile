import 'dart:async';
import 'dart:ui';

import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppToastKind { success, error, warning, info }

extension AppToastKindX on AppToastKind {
  static AppToastKind fromMessage(String message) {
    final text = message.toLowerCase();
    const success = [
      'succès',
      'reussi',
      'réussi',
      'ajouté',
      'envoy',
      'mis à jour',
      'publié',
      'confirm',
      'complét',
      'annul',
    ];
    const warning = [
      'choisissez',
      'attention',
      'requis',
      'manquant',
    ];
    const info = [
      'disponible',
      'bientôt',
      'backend',
      'api sera',
      'sera trait',
    ];
    const error = [
      'erreur',
      'impossible',
      'invalide',
      'échec',
      'echéc',
      'failed',
    ];

    bool matches(List<String> keys) => keys.any(text.contains);

    if (matches(success)) return AppToastKind.success;
    if (matches(warning)) return AppToastKind.warning;
    if (matches(info)) return AppToastKind.info;
    if (matches(error)) return AppToastKind.error;
    return AppToastKind.error;
  }

  Color get color => switch (this) {
        AppToastKind.success => AppColors.success,
        AppToastKind.error => AppColors.error,
        AppToastKind.warning => const Color(0xFFF59E0B),
        AppToastKind.info => AppColors.primary,
      };

  IconData get icon => switch (this) {
        AppToastKind.success => Icons.check_rounded,
        AppToastKind.error => Icons.close_rounded,
        AppToastKind.warning => Icons.priority_high_rounded,
        AppToastKind.info => Icons.info_rounded,
      };
}

class AppToast {
  AppToast._();

  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required String message,
    AppToastKind? kind,
    Duration duration = const Duration(milliseconds: 3200),
  }) {
    hide();
    if (message.trim().isEmpty) return;

    final resolved = kind ?? AppToastKindX.fromMessage(message);
    HapticFeedback.lightImpact();

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      _showSnackFallback(context, message, resolved);
      return;
    }

    _entry = OverlayEntry(
      builder: (overlayContext) {
        final top = MediaQuery.paddingOf(overlayContext).top;
        return Positioned(
          top: top + 8,
          left: 16,
          right: 16,
          child: _AppToastHost(
            message: message,
            kind: resolved,
            onDismiss: hide,
          ),
        );
      },
    );
    overlay.insert(_entry!);
    _timer = Timer(duration, hide);
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }

  static void _showSnackFallback(
    BuildContext context,
    String message,
    AppToastKind kind,
  ) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          duration: const Duration(milliseconds: 3200),
          content: AppToastCard(message: message, kind: kind),
        ),
      );
  }
}

class AppToastCard extends StatelessWidget {
  const AppToastCard({
    super.key,
    required this.message,
    required this.kind,
  });

  final String message;
  final AppToastKind kind;

  @override
  Widget build(BuildContext context) {
    final tint = kind.color;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0A2340),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            decoration: BoxDecoration(
              color: const Color(0xF2FFFFFF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0x80FFFFFF)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: tint.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(kind.icon, color: tint, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AppToastHost extends StatefulWidget {
  const _AppToastHost({
    required this.message,
    required this.kind,
    required this.onDismiss,
  });

  final String message;
  final AppToastKind kind;
  final VoidCallback onDismiss;

  @override
  State<_AppToastHost> createState() => _AppToastHostState();
}

class _AppToastHostState extends State<_AppToastHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 240),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Dismissible(
        key: const ValueKey('app-toast'),
        direction: DismissDirection.up,
        onDismissed: (_) => widget.onDismiss(),
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: GestureDetector(
              onTap: widget.onDismiss,
              child: AppToastCard(
                message: widget.message,
                kind: widget.kind,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppAlert {
  AppAlert._();

  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirmer',
    String cancelLabel = 'Annuler',
    bool destructive = false,
  }) async {
    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: cancelLabel,
      barrierColor: const Color(0x660A2340),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondary, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Material(
                  color: Colors.white,
                  elevation: 0,
                  shadowColor: const Color(0x330A2340),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 22, 22, 16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: (destructive
                                      ? AppColors.error
                                      : AppColors.primary)
                                  .withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              destructive
                                  ? Icons.delete_outline_rounded
                                  : Icons.info_outline_rounded,
                              color: destructive
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: Text(cancelLabel),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  style: destructive
                                      ? FilledButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                        )
                                      : null,
                                  child: Text(confirmLabel),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    return result ?? false;
  }
}
