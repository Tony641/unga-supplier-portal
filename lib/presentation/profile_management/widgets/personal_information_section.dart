import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PersonalInformationSection extends StatefulWidget {
  final Map<String, dynamic> personalData;
  final Function(Map<String, dynamic>) onDataChanged;

  const PersonalInformationSection({
    super.key,
    required this.personalData,
    required this.onDataChanged,
  });

  @override
  State<PersonalInformationSection> createState() =>
      _PersonalInformationSectionState();
}

class _PersonalInformationSectionState
    extends State<PersonalInformationSection> {
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  final Map<String, bool> _fieldValidation = {};
  final Map<String, String> _fieldErrors = {};
  bool _isPhoneVerified = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _isPhoneVerified = widget.personalData['phoneVerified'] ?? true;
    _selectedLanguage = widget.personalData['preferredLanguage'] ?? 'English';
  }

  void _initializeControllers() {
    _fullNameController =
        TextEditingController(text: widget.personalData['fullName'] ?? '');
    _phoneController =
        TextEditingController(text: widget.personalData['phoneNumber'] ?? '');
    _emailController =
        TextEditingController(text: widget.personalData['email'] ?? '');

    _fullNameController.addListener(
        () => _validateField('fullName', _fullNameController.text));
    _phoneController.addListener(
        () => _validateField('phoneNumber', _phoneController.text));
    _emailController
        .addListener(() => _validateField('email', _emailController.text));
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'person',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Personal Information',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildTextField(
            controller: _fullNameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: 'person_outline',
            fieldKey: 'fullName',
            required: true,
          ),
          SizedBox(height: 2.h),
          _buildPhoneField(),
          SizedBox(height: 2.h),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email address',
            icon: 'email',
            fieldKey: 'email',
            keyboardType: TextInputType.emailAddress,
            required: true,
          ),
          SizedBox(height: 3.h),
          _buildLanguageSelector(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String icon,
    required String fieldKey,
    TextInputType? keyboardType,
    bool required = false,
  }) {
    final theme = Theme.of(context);
    final hasError = _fieldErrors.containsKey(fieldKey);
    final isValid = _fieldValidation[fieldKey] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            if (required) ...[
              SizedBox(width: 1.w),
              Text(
                '*',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: icon,
                color: hasError
                    ? theme.colorScheme.error
                    : isValid
                        ? AppTheme.getSuccessColor(
                            theme.brightness == Brightness.light)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 5.w,
              ),
            ),
            suffixIcon: isValid
                ? Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.getSuccessColor(
                          theme.brightness == Brightness.light),
                      size: 5.w,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide(
                color: hasError ? theme.colorScheme.error : theme.dividerColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide(
                color: hasError ? theme.colorScheme.error : theme.dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide(
                color: hasError
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) => _onFieldChanged(fieldKey, value),
        ),
        if (hasError) ...[
          SizedBox(height: 0.5.h),
          Text(
            _fieldErrors[fieldKey]!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneField() {
    final theme = Theme.of(context);
    final hasError = _fieldErrors.containsKey('phoneNumber');
    final isValid = _fieldValidation['phoneNumber'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Phone Number',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 1.w),
            Text(
              '*',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 14.sp,
              ),
            ),
            Spacer(),
            if (_isPhoneVerified)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.getSuccessColor(
                          theme.brightness == Brightness.light)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(1.w),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'verified',
                      color: AppTheme.getSuccessColor(
                          theme.brightness == Brightness.light),
                      size: 3.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      'Verified',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.getSuccessColor(
                            theme.brightness == Brightness.light),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter your phone number',
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'phone',
                color: hasError
                    ? theme.colorScheme.error
                    : isValid
                        ? AppTheme.getSuccessColor(
                            theme.brightness == Brightness.light)
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 5.w,
              ),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isValid && _isPhoneVerified)
                  Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'check_circle',
                      color: AppTheme.getSuccessColor(
                          theme.brightness == Brightness.light),
                      size: 5.w,
                    ),
                  ),
                if (!_isPhoneVerified)
                  TextButton(
                    onPressed: _triggerPhoneVerification,
                    child: Text(
                      'Verify',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide(
                color: hasError ? theme.colorScheme.error : theme.dividerColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide(
                color: hasError ? theme.colorScheme.error : theme.dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(2.w),
              borderSide: BorderSide(
                color: hasError
                    ? theme.colorScheme.error
                    : theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            _onFieldChanged('phoneNumber', value);
            if (value != widget.personalData['phoneNumber']) {
              setState(() => _isPhoneVerified = false);
            }
          },
        ),
        if (hasError) ...[
          SizedBox(height: 0.5.h),
          Text(
            _fieldErrors['phoneNumber']!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLanguageSelector() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Language',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'language',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 5.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedLanguage,
                    isExpanded: true,
                    items: ['English', 'Swahili'].map((String language) {
                      return DropdownMenuItem<String>(
                        value: language,
                        child: Text(
                          language,
                          style: theme.textTheme.bodyLarge,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => _selectedLanguage = newValue);
                        _onFieldChanged('preferredLanguage', newValue);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _validateField(String fieldKey, String value) {
    String? error;
    bool isValid = false;

    switch (fieldKey) {
      case 'fullName':
        if (value.isEmpty) {
          error = 'Full name is required';
        } else if (value.length < 2) {
          error = 'Name must be at least 2 characters';
        } else {
          isValid = true;
        }
        break;
      case 'phoneNumber':
        if (value.isEmpty) {
          error = 'Phone number is required';
        } else if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
          error = 'Please enter a valid phone number';
        } else {
          isValid = true;
        }
        break;
      case 'email':
        if (value.isEmpty) {
          error = 'Email address is required';
        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(value)) {
          error = 'Please enter a valid email address';
        } else {
          isValid = true;
        }
        break;
    }

    setState(() {
      if (error != null) {
        _fieldErrors[fieldKey] = error;
        _fieldValidation[fieldKey] = false;
      } else {
        _fieldErrors.remove(fieldKey);
        _fieldValidation[fieldKey] = isValid;
      }
    });
  }

  void _onFieldChanged(String fieldKey, String value) {
    final updatedData = Map<String, dynamic>.from(widget.personalData);
    updatedData[fieldKey] = value;
    widget.onDataChanged(updatedData);
  }

  void _triggerPhoneVerification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Phone Verification'),
        content: Text(
            'A verification code will be sent to ${_phoneController.text}. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _simulateVerification();
            },
            child: Text('Send Code'),
          ),
        ],
      ),
    );
  }

  void _simulateVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Verification code sent to ${_phoneController.text}'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      setState(() => _isPhoneVerified = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Phone number verified successfully'),
          backgroundColor: AppTheme.getSuccessColor(
              Theme.of(context).brightness == Brightness.light),
        ),
      );
    });
  }
}
