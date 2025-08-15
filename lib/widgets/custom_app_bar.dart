import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomAppBarVariant {
  standard,
  withSearch,
  withActions,
  minimal,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final VoidCallback? onSearchTap;
  final String? searchHint;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool showNotificationBadge;
  final int notificationCount;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.standard,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.onSearchTap,
    this.searchHint,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: _buildTitle(context),
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: _buildActions(context),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      elevation: elevation ?? 2.0,
      shadowColor: isDark ? Colors.black26 : Colors.black12,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: foregroundColor ?? theme.appBarTheme.foregroundColor,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    switch (variant) {
      case CustomAppBarVariant.withSearch:
        return GestureDetector(
          onTap: onSearchTap,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  Icons.search,
                  size: 20,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    searchHint ?? 'Search invoices...',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      case CustomAppBarVariant.minimal:
        return Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        );
      default:
        return Text(title);
    }
  }

  List<Widget>? _buildActions(BuildContext context) {
    final List<Widget> defaultActions = [];

    // Add notification icon for relevant screens
    if (_shouldShowNotifications()) {
      defaultActions.add(
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () =>
                  Navigator.pushNamed(context, '/notifications-center'),
              tooltip: 'Notifications',
            ),
            if (showNotificationBadge && notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount > 99
                        ? '99+'
                        : notificationCount.toString(),
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Add profile icon
    if (variant != CustomAppBarVariant.minimal) {
      defaultActions.add(
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () => Navigator.pushNamed(context, '/profile-management'),
          tooltip: 'Profile',
        ),
      );
    }

    // Combine with custom actions
    if (actions != null) {
      defaultActions.addAll(actions!);
    }

    return defaultActions.isNotEmpty ? defaultActions : null;
  }

  bool _shouldShowNotifications() {
    // Show notifications on main screens
    return variant == CustomAppBarVariant.standard ||
        variant == CustomAppBarVariant.withActions;
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
