import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomBottomBarVariant {
  standard,
  floating,
  minimal,
}

class CustomBottomBar extends StatefulWidget {
  final CustomBottomBarVariant variant;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final double? elevation;

  const CustomBottomBar({
    super.key,
    this.variant = CustomBottomBarVariant.standard,
    this.currentIndex = 0,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.elevation,
  });

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  final List<_BottomBarItem> _items = [
    _BottomBarItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard',
    ),
    _BottomBarItem(
      icon: Icons.upload_file_outlined,
      activeIcon: Icons.upload_file,
      label: 'Submit',
      route: '/invoice-submission',
    ),
    _BottomBarItem(
      icon: Icons.document_scanner_outlined,
      activeIcon: Icons.document_scanner,
      label: 'Scan',
      route: '/document-scanner',
    ),
    _BottomBarItem(
      icon: Icons.track_changes_outlined,
      activeIcon: Icons.track_changes,
      label: 'Track',
      route: '/invoice-status-tracking',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (widget.variant) {
      case CustomBottomBarVariant.floating:
        return _buildFloatingBottomBar(context);
      case CustomBottomBarVariant.minimal:
        return _buildMinimalBottomBar(context);
      default:
        return _buildStandardBottomBar(context);
    }
  }

  Widget _buildStandardBottomBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: widget.currentIndex,
          onTap: _handleTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor:
              widget.selectedItemColor ?? theme.colorScheme.primary,
          unselectedItemColor: widget.unselectedItemColor ??
              theme.colorScheme.onSurface.withValues(alpha: 0.6),
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: _items
              .map((item) => BottomNavigationBarItem(
                    icon: _buildIcon(item, false),
                    activeIcon: _buildIcon(item, true),
                    label: item.label,
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFloatingBottomBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: BottomNavigationBar(
              currentIndex: widget.currentIndex,
              onTap: _handleTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor:
                  widget.selectedItemColor ?? theme.colorScheme.primary,
              unselectedItemColor: widget.unselectedItemColor ??
                  theme.colorScheme.onSurface.withValues(alpha: 0.6),
              selectedLabelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              items: _items
                  .map((item) => BottomNavigationBarItem(
                        icon: _buildIcon(item, false),
                        activeIcon: _buildIcon(item, true),
                        label: item.label,
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalBottomBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == widget.currentIndex;

            return Expanded(
              child: GestureDetector(
                onTap: () => _handleTap(index),
                child: Container(
                  height: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.1 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? (widget.selectedItemColor ??
                                  theme.colorScheme.primary)
                              : (widget.unselectedItemColor ??
                                  theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6)),
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                          color: isSelected
                              ? (widget.selectedItemColor ??
                                  theme.colorScheme.primary)
                              : (widget.unselectedItemColor ??
                                  theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildIcon(_BottomBarItem item, bool isActive) {
    final index = _items.indexOf(item);
    final isSelected = index == widget.currentIndex;

    return AnimatedScale(
      scale: isSelected && isActive ? 1.1 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Icon(
        isActive ? item.activeIcon : item.icon,
        size: 24,
      ),
    );
  }

  void _handleTap(int index) {
    if (index == widget.currentIndex) return;

    // Haptic feedback for better UX
    HapticFeedback.lightImpact();

    // Scale animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Navigate to the selected route
    final route = _items[index].route;
    Navigator.pushNamedAndRemoveUntil(
      context,
      route,
      (route) => false,
    );

    // Call the onTap callback
    widget.onTap?.call(index);
  }
}

class _BottomBarItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const _BottomBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
