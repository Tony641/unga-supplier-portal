import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BusinessDetailsSection extends StatefulWidget {
  final Map<String, dynamic> businessData;
  final Function(Map<String, dynamic>) onDataChanged;

  const BusinessDetailsSection({
    super.key,
    required this.businessData,
    required this.onDataChanged,
  });

  @override
  State<BusinessDetailsSection> createState() => _BusinessDetailsSectionState();
}

class _BusinessDetailsSectionState extends State<BusinessDetailsSection> {
  late TextEditingController _companyNameController;
  late TextEditingController _registrationNumberController;
  late TextEditingController _primaryContactController;

  final Map<String, bool> _fieldValidation = {};
  final Map<String, String> _fieldErrors = {};
  String _selectedBusinessType = 'Agricultural Supplier';

  final List<String> _businessTypes = [
    'Agricultural Supplier',
    'Maize Farmer',
    'Commodity Trader',
    'Logistics Provider',
    'Equipment Supplier',
    'Service Provider',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _selectedBusinessType =
        widget.businessData['businessType'] ?? 'Agricultural Supplier';
  }

  void _initializeControllers() {
    _companyNameController =
        TextEditingController(text: widget.businessData['companyName'] ?? '');
    _registrationNumberController = TextEditingController(
        text: widget.businessData['registrationNumber'] ?? '');
    _primaryContactController = TextEditingController(
        text: widget.businessData['primaryContact'] ?? '');

    _companyNameController.addListener(
        () => _validateField('companyName', _companyNameController.text));
    _registrationNumberController.addListener(() => _validateField(
        'registrationNumber', _registrationNumberController.text));
    _primaryContactController.addListener(
        () => _validateField('primaryContact', _primaryContactController.text));
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _registrationNumberController.dispose();
    _primaryContactController.dispose();
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
                iconName: 'business',
                color: theme.colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 3.w),
              Text(
                'Business Details',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildTextField(
            controller: _companyNameController,
            label: 'Company Name',
            hint: 'Enter your company name',
            icon: 'business_center',
            fieldKey: 'companyName',
            required: true,
          ),
          SizedBox(height: 2.h),
          _buildTextField(
            controller: _registrationNumberController,
            label: 'Registration Number',
            hint: 'Enter business registration number',
            icon: 'assignment',
            fieldKey: 'registrationNumber',
            required: true,
          ),
          SizedBox(height: 2.h),
          _buildBusinessTypeDropdown(),
          SizedBox(height: 2.h),
          _buildTextField(
            controller: _primaryContactController,
            label: 'Primary Contact',
            hint: 'Enter primary contact person',
            icon: 'contact_phone',
            fieldKey: 'primaryContact',
            required: true,
          ),
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

  Widget _buildBusinessTypeDropdown() {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Business Type',
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
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(2.w),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedBusinessType,
            isExpanded: true,
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'category',
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 5.w,
                ),
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            ),
            items: _businessTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(
                  type,
                  style: theme.textTheme.bodyLarge,
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() => _selectedBusinessType = newValue);
                _onFieldChanged('businessType', newValue);
              }
            },
          ),
        ),
      ],
    );
  }

  void _validateField(String fieldKey, String value) {
    String? error;
    bool isValid = false;

    switch (fieldKey) {
      case 'companyName':
        if (value.isEmpty) {
          error = 'Company name is required';
        } else if (value.length < 2) {
          error = 'Company name must be at least 2 characters';
        } else {
          isValid = true;
        }
        break;
      case 'registrationNumber':
        if (value.isEmpty) {
          error = 'Registration number is required';
        } else if (value.length < 3) {
          error = 'Registration number must be at least 3 characters';
        } else {
          isValid = true;
        }
        break;
      case 'primaryContact':
        if (value.isEmpty) {
          error = 'Primary contact is required';
        } else if (value.length < 2) {
          error = 'Contact name must be at least 2 characters';
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
    final updatedData = Map<String, dynamic>.from(widget.businessData);
    updatedData[fieldKey] = value;
    widget.onDataChanged(updatedData);
  }
}
