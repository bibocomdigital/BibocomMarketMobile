import 'package:bibomarketmobile/core/theme/app_colors.dart';
import 'package:bibomarketmobile/shared/helpers/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class BiboAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BiboAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.showBack = true,
    this.fallbackRoute,
  });

  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool showBack;
  final String? fallbackRoute;

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: Text(title),
      actions: actions,
      bottom: bottom,
      leading: showBack
          ? IconButton(
              tooltip: 'Retour',
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => context.popOrFallback(fallback: fallbackRoute),
            )
          : null,
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x140A2540),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = LucideIcons.inbox,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.secondary),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class CoralButton extends StatelessWidget {
  const CoralButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Text(label),
    );
  }
}

class ClientBottomBar extends StatelessWidget {
  const ClientBottomBar({
    super.key,
    required this.index,
    required this.onTap,
  });

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: onTap,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.secondary.withValues(alpha: 0.35),
      destinations: const [
        NavigationDestination(
          icon: Icon(LucideIcons.house),
          selectedIcon: Icon(LucideIcons.house),
          label: 'Accueil',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.layoutGrid),
          selectedIcon: Icon(LucideIcons.layoutGrid),
          label: 'Catégories',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.shoppingBag),
          selectedIcon: Icon(LucideIcons.shoppingBag),
          label: 'Panier',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.messageCircle),
          selectedIcon: Icon(LucideIcons.messageCircle),
          label: 'Messages',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.user),
          selectedIcon: Icon(LucideIcons.user),
          label: 'Profil',
        ),
      ],
    );
  }
}
