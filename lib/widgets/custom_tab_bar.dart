import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomTabBarVariant {
  standard,
  segmented,
  pills,
  underlined,
}

class CustomTabBar extends StatefulWidget {
  final List<String> tabs;
  final CustomTabBarVariant variant;
  final int initialIndex;
  final ValueChanged<int>? onTap;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final bool isScrollable;
  final EdgeInsetsGeometry? padding;
  final double? height;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.variant = CustomTabBarVariant.standard,
    this.initialIndex = 0,
    this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.backgroundColor,
    this.indicatorColor,
    this.isScrollable = false,
    this.padding,
    this.height,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      initialIndex: widget.initialIndex,
      vsync: this,
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        HapticFeedback.lightImpact();
        widget.onTap?.call(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.variant) {
      case CustomTabBarVariant.segmented:
        return _buildSegmentedTabBar(context);
      case CustomTabBarVariant.pills:
        return _buildPillsTabBar(context);
      case CustomTabBarVariant.underlined:
        return _buildUnderlinedTabBar(context);
      default:
        return _buildStandardTabBar(context);
    }
  }

  Widget _buildStandardTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: widget.height ?? 48,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: widget.isScrollable,
        labelColor: widget.selectedColor ?? theme.colorScheme.primary,
        unselectedLabelColor: widget.unselectedColor ??
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: widget.indicatorColor ?? theme.colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 2,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: widget.tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildSegmentedTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: widget.height ?? 40,
      padding: widget.padding ?? const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.backgroundColor ??
            theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: widget.isScrollable,
        labelColor: widget.selectedColor ?? theme.colorScheme.onPrimary,
        unselectedLabelColor: widget.unselectedColor ??
            theme.colorScheme.onSurface.withValues(alpha: 0.7),
        indicator: BoxDecoration(
          color: widget.indicatorColor ?? theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        tabs: widget.tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildPillsTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: widget.height ?? 40,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final tab = entry.value;
            final isSelected = index == _tabController.index;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  _tabController.animateTo(index);
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (widget.indicatorColor ?? theme.colorScheme.primary)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? (widget.indicatorColor ?? theme.colorScheme.primary)
                          : theme.dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tab,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.w400,
                      color: isSelected
                          ? (widget.selectedColor ??
                              theme.colorScheme.onPrimary)
                          : (widget.unselectedColor ??
                              theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7)),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUnderlinedTabBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: widget.height ?? 48,
      padding: widget.padding,
      child: TabBar(
        controller: _tabController,
        isScrollable: widget.isScrollable,
        labelColor: widget.selectedColor ?? theme.colorScheme.primary,
        unselectedLabelColor: widget.unselectedColor ??
            theme.colorScheme.onSurface.withValues(alpha: 0.6),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: widget.indicatorColor ?? theme.colorScheme.primary,
            width: 3,
          ),
          insets: const EdgeInsets.symmetric(horizontal: 16),
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        tabs: widget.tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  /// Get the current selected index
  int get currentIndex => _tabController.index;

  /// Programmatically change tab
  void animateToTab(int index) {
    _tabController.animateTo(index);
  }
}

/// Custom tab indicator for more control over appearance
class CustomTabIndicator extends Decoration {
  final Color color;
  final double height;
  final BorderRadius borderRadius;

  const CustomTabIndicator({
    required this.color,
    this.height = 3,
    this.borderRadius = const BorderRadius.all(Radius.circular(1.5)),
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CustomTabIndicatorPainter(
      color: color,
      height: height,
      borderRadius: borderRadius,
    );
  }
}

class _CustomTabIndicatorPainter extends BoxPainter {
  final Color color;
  final double height;
  final BorderRadius borderRadius;

  _CustomTabIndicatorPainter({
    required this.color,
    required this.height,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Rect rect = Rect.fromLTWH(
      offset.dx,
      configuration.size!.height - height,
      configuration.size!.width,
      height,
    );

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
        bottomLeft: borderRadius.bottomLeft,
        bottomRight: borderRadius.bottomRight,
      ),
      paint,
    );
  }
}
