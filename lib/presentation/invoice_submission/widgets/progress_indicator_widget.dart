import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProgressIndicatorWidget extends StatefulWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  const ProgressIndicatorWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
  });

  @override
  State<ProgressIndicatorWidget> createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(ProgressIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          _buildProgressBar(theme),
          SizedBox(height: 1.h),
          _buildStepLabels(theme),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme) {
    return Row(
      children: List.generate(widget.totalSteps, (index) {
        final isCompleted = index < widget.currentStep - 1;
        final isCurrent = index == widget.currentStep - 1;
        final isUpcoming = index > widget.currentStep - 1;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return _buildStepIndicator(
                      theme,
                      index + 1,
                      isCompleted,
                      isCurrent,
                      isUpcoming,
                    );
                  },
                ),
              ),
              if (index < widget.totalSteps - 1)
                Expanded(
                  flex: 2,
                  child: _buildConnector(theme, isCompleted),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStepIndicator(
    ThemeData theme,
    int stepNumber,
    bool isCompleted,
    bool isCurrent,
    bool isUpcoming,
  ) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    Widget icon;

    if (isCompleted) {
      backgroundColor =
          AppTheme.getSuccessColor(theme.brightness == Brightness.light);
      borderColor = backgroundColor;
      textColor = Colors.white;
      icon = CustomIconWidget(
        iconName: 'check',
        color: Colors.white,
        size: 16,
      );
    } else if (isCurrent) {
      backgroundColor = theme.colorScheme.primary;
      borderColor = backgroundColor;
      textColor = Colors.white;
      icon = Text(
        stepNumber.toString(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      backgroundColor = theme.colorScheme.surface;
      borderColor = theme.dividerColor;
      textColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
      icon = Text(
        stepNumber.toString(),
        style: theme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w400,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(child: icon),
    );
  }

  Widget _buildConnector(ThemeData theme, bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 2,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.getSuccessColor(theme.brightness == Brightness.light)
            : theme.dividerColor,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildStepLabels(ThemeData theme) {
    return Row(
      children: List.generate(widget.totalSteps, (index) {
        final isCompleted = index < widget.currentStep - 1;
        final isCurrent = index == widget.currentStep - 1;
        final isUpcoming = index > widget.currentStep - 1;

        Color textColor;
        FontWeight fontWeight;

        if (isCompleted) {
          textColor =
              AppTheme.getSuccessColor(theme.brightness == Brightness.light);
          fontWeight = FontWeight.w500;
        } else if (isCurrent) {
          textColor = theme.colorScheme.primary;
          fontWeight = FontWeight.w600;
        } else {
          textColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
          fontWeight = FontWeight.w400;
        }

        return Expanded(
          child: Text(
            widget.stepLabels[index],
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: fontWeight,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
