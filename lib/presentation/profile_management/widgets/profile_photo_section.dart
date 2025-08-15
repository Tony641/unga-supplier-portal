import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProfilePhotoSection extends StatefulWidget {
  final String? currentPhotoUrl;
  final Function(String?) onPhotoChanged;

  const ProfilePhotoSection({
    super.key,
    this.currentPhotoUrl,
    required this.onPhotoChanged,
  });

  @override
  State<ProfilePhotoSection> createState() => _ProfilePhotoSectionState();
}

class _ProfilePhotoSectionState extends State<ProfilePhotoSection> {
  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: _isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                            color: theme.colorScheme.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : _buildProfileImage(),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showPhotoOptions,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: CustomIconWidget(
                      iconName: 'camera_alt',
                      color: theme.colorScheme.onPrimary,
                      size: 4.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Profile Photo',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Tap the camera icon to update',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_selectedImagePath != null) {
      if (kIsWeb) {
        return CustomImageWidget(
          imageUrl: _selectedImagePath!,
          width: 25.w,
          height: 25.w,
          fit: BoxFit.cover,
        );
      } else {
        return Image.file(
          File(_selectedImagePath!),
          width: 25.w,
          height: 25.w,
          fit: BoxFit.cover,
        );
      }
    } else if (widget.currentPhotoUrl != null &&
        widget.currentPhotoUrl!.isNotEmpty) {
      return CustomImageWidget(
        imageUrl: widget.currentPhotoUrl!,
        width: 25.w,
        height: 25.w,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: 25.w,
        height: 25.w,
        color: Theme.of(context).colorScheme.surface,
        child: CustomIconWidget(
          iconName: 'person',
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          size: 12.w,
        ),
      );
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(1.w),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                'Update Profile Photo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: 3.h),
              _buildPhotoOption(
                icon: 'camera_alt',
                title: 'Take Photo',
                subtitle: 'Use camera to capture new photo',
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              SizedBox(height: 2.h),
              _buildPhotoOption(
                icon: 'photo_library',
                title: 'Choose from Gallery',
                subtitle: 'Select from existing photos',
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              if (widget.currentPhotoUrl != null ||
                  _selectedImagePath != null) ...[
                SizedBox(height: 2.h),
                _buildPhotoOption(
                  icon: 'delete',
                  title: 'Remove Photo',
                  subtitle: 'Use default profile icon',
                  onTap: () {
                    Navigator.pop(context);
                    _removePhoto();
                  },
                  isDestructive: true,
                ),
              ],
              SizedBox(height: 2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color =
        isDestructive ? theme.colorScheme.error : theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(2.w),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: color,
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isDestructive ? theme.colorScheme.error : null,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

  Future<void> _takePhoto() async {
    try {
      if (!kIsWeb && !await _requestCameraPermission()) {
        _showPermissionDeniedDialog();
        return;
      }

      setState(() => _isLoading = true);

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() => _selectedImagePath = photo.path);
        widget.onPhotoChanged(photo.path);
        _showSuccessMessage('Photo captured successfully');
      }
    } catch (e) {
      _showErrorMessage('Failed to capture photo');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      setState(() => _isLoading = true);

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() => _selectedImagePath = photo.path);
        widget.onPhotoChanged(photo.path);
        _showSuccessMessage('Photo selected successfully');
      }
    } catch (e) {
      _showErrorMessage('Failed to select photo');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removePhoto() {
    setState(() => _selectedImagePath = null);
    widget.onPhotoChanged(null);
    _showSuccessMessage('Photo removed');
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Permission Required'),
        content: Text('Please grant camera permission to take photos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
