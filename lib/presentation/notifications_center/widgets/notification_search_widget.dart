import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class NotificationSearchWidget extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onSearchClear;
  final bool isVisible;

  const NotificationSearchWidget({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    this.onSearchClear,
    this.isVisible = false,
  });

  @override
  State<NotificationSearchWidget> createState() =>
      _NotificationSearchWidgetState();
}

class _NotificationSearchWidgetState extends State<NotificationSearchWidget>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
    _focusNode = FocusNode();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NotificationSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isVisible != widget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _focusNode.requestFocus();
        });
      } else {
        _animationController.reverse();
        _focusNode.unfocus();
      }
    }

    if (oldWidget.searchQuery != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SlideTransition(
          position: Offset(0, _slideAnimation.value)
              .toTween()
              .animate(_animationController),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              height: 12.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _focusNode.hasFocus
                                  ? theme.colorScheme.primary
                                  : theme.dividerColor,
                              width: _focusNode.hasFocus ? 2 : 1,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            onChanged: (value) {
                              widget.onSearchChanged(value);
                            },
                            onSubmitted: (value) {
                              HapticFeedback.lightImpact();
                            },
                            decoration: InputDecoration(
                              hintText: 'Search notifications...',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.all(3.w),
                                child: CustomIconWidget(
                                  iconName: 'search',
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                  size: 5.w,
                                ),
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        _searchController.clear();
                                        widget.onSearchClear?.call();
                                        widget.onSearchChanged('');
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(3.w),
                                        child: CustomIconWidget(
                                          iconName: 'clear',
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: 0.5),
                                          size: 5.w,
                                        ),
                                      ),
                                    )
                                  : null,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 2.h,
                              ),
                            ),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                            textInputAction: TextInputAction.search,
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _focusNode.unfocus();
                          _searchController.clear();
                          widget.onSearchClear?.call();
                          widget.onSearchChanged('');
                        },
                        child: Container(
                          width: 12.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.primary
                                  .withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'close',
                              color: theme.colorScheme.primary,
                              size: 6.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

extension on Offset {
  Tween<Offset> toTween() => Tween<Offset>(begin: this, end: Offset.zero);
}
