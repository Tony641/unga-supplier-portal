import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ScannerSettingsWidget extends StatefulWidget {
  final bool showGrid;
  final bool autoCapture;
  final bool flashEnabled;
  final String imageQuality;
  final Function(bool)? onGridToggle;
  final Function(bool)? onAutoCaptureToggle;
  final Function(bool)? onFlashToggle;
  final Function(String)? onQualityChanged;
  final VoidCallback? onClose;

  const ScannerSettingsWidget({
    super.key,
    this.showGrid = false,
    this.autoCapture = true,
    this.flashEnabled = false,
    this.imageQuality = 'High',
    this.onGridToggle,
    this.onAutoCaptureToggle,
    this.onFlashToggle,
    this.onQualityChanged,
    this.onClose,
  });

  @override
  State<ScannerSettingsWidget> createState() => _ScannerSettingsWidgetState();
}

class _ScannerSettingsWidgetState extends State<ScannerSettingsWidget>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeSettings,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withValues(alpha: 0.5),
        child: GestureDetector(
          onTap: () {}, // Prevent closing when tapping on the settings panel
          child: SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(context),
                      _buildSettingsList(context),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Scanner Settings',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          IconButton(
            onPressed: _closeSettings,
            icon: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          _buildToggleSetting(
            context: context,
            title: 'Grid Lines',
            subtitle: 'Show alignment grid for better document positioning',
            icon: 'grid_on',
            value: widget.showGrid,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              widget.onGridToggle?.call(value);
            },
          ),
          _buildToggleSetting(
            context: context,
            title: 'Auto Capture',
            subtitle: 'Automatically capture when document is detected',
            icon: 'auto_mode',
            value: widget.autoCapture,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              widget.onAutoCaptureToggle?.call(value);
            },
          ),
          _buildToggleSetting(
            context: context,
            title: 'Flash',
            subtitle: 'Enable flash for better lighting conditions',
            icon: 'flash_on',
            value: widget.flashEnabled,
            onChanged: (value) {
              HapticFeedback.lightImpact();
              widget.onFlashToggle?.call(value);
            },
          ),
          _buildQualitySetting(context),
          SizedBox(height: 2.h),
          _buildResetButton(context),
        ],
      ),
    );
  }

  Widget _buildToggleSetting({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String icon,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: value
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: value
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.dividerColor,
                width: 1,
              ),
            ),
            child: CustomIconWidget(
              iconName: icon,
              color: value
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildQualitySetting(BuildContext context) {
    final qualityOptions = ['Low', 'Medium', 'High', 'Ultra'];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
                width: 1,
              ),
            ),
            child: CustomIconWidget(
              iconName: 'high_quality',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Image Quality',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Higher quality produces larger file sizes',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppTheme.lightTheme.dividerColor,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: widget.imageQuality,
                isDense: true,
                items: qualityOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    HapticFeedback.lightImpact();
                    widget.onQualityChanged?.call(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          HapticFeedback.lightImpact();
          _showResetDialog(context);
        },
        icon: CustomIconWidget(
          iconName: 'refresh',
          color:
              AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.7),
          size: 5.w,
        ),
        label: Text(
          'Reset to Default',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppTheme.lightTheme.dividerColor,
            width: 1,
          ),
          padding: EdgeInsets.symmetric(vertical: 3.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _closeSettings() {
    _slideController.reverse().then((_) {
      widget.onClose?.call();
    });
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Reset Settings',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            'Are you sure you want to reset all scanner settings to their default values?',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Reset all settings to default
                widget.onGridToggle?.call(false);
                widget.onAutoCaptureToggle?.call(true);
                widget.onFlashToggle?.call(false);
                widget.onQualityChanged?.call('High');
                HapticFeedback.lightImpact();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Reset',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}