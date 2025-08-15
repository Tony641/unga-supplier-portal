import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class InvoiceFormWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFormChanged;
  final Map<String, dynamic> initialData;

  const InvoiceFormWidget({
    super.key,
    required this.onFormChanged,
    required this.initialData,
  });

  @override
  State<InvoiceFormWidget> createState() => _InvoiceFormWidgetState();
}

class _InvoiceFormWidgetState extends State<InvoiceFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _invoiceDate;
  DateTime? _dueDate;
  bool _isFormValid = false;
  Map<String, bool> _fieldValidation = {
    'invoiceNumber': false,
    'invoiceDate': false,
    'dueDate': false,
    'amount': false,
    'description': false,
  };

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _setupListeners();
  }

  void _initializeForm() {
    _invoiceNumberController.text = widget.initialData['invoiceNumber'] ?? '';
    _amountController.text = widget.initialData['amount'] ?? '';
    _descriptionController.text = widget.initialData['description'] ?? '';

    if (widget.initialData['invoiceDate'] != null) {
      _invoiceDate = DateTime.parse(widget.initialData['invoiceDate']);
    }
    if (widget.initialData['dueDate'] != null) {
      _dueDate = DateTime.parse(widget.initialData['dueDate']);
    }

    _validateForm();
  }

  void _setupListeners() {
    _invoiceNumberController.addListener(_onFormChanged);
    _amountController.addListener(_onFormChanged);
    _descriptionController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    _validateForm();
    _notifyParent();
  }

  void _validateForm() {
    setState(() {
      _fieldValidation['invoiceNumber'] =
          _validateInvoiceNumber(_invoiceNumberController.text);
      _fieldValidation['invoiceDate'] = _invoiceDate != null;
      _fieldValidation['dueDate'] =
          _dueDate != null && _validateDueDate(_dueDate!);
      _fieldValidation['amount'] = _validateAmount(_amountController.text);
      _fieldValidation['description'] =
          _descriptionController.text.trim().isNotEmpty;

      _isFormValid = _fieldValidation.values.every((isValid) => isValid);
    });
  }

  bool _validateInvoiceNumber(String value) {
    return RegExp(r'^[A-Za-z0-9]{3,20}$').hasMatch(value.trim());
  }

  bool _validateAmount(String value) {
    if (value.trim().isEmpty) return false;
    final cleanValue = value.replaceAll(',', '').replaceAll('KES', '').trim();
    final amount = double.tryParse(cleanValue);
    return amount != null && amount > 0;
  }

  bool _validateDueDate(DateTime dueDate) {
    if (_invoiceDate == null) return false;
    final difference = dueDate.difference(_invoiceDate!).inDays;
    return difference >= 7;
  }

  void _notifyParent() {
    final formData = {
      'invoiceNumber': _invoiceNumberController.text,
      'invoiceDate': _invoiceDate?.toIso8601String(),
      'dueDate': _dueDate?.toIso8601String(),
      'amount': _amountController.text,
      'description': _descriptionController.text,
      'isValid': _isFormValid,
    };
    widget.onFormChanged(formData);
  }

  Future<void> _selectDate(BuildContext context, bool isInvoiceDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isInvoiceDate
          ? (_invoiceDate ?? DateTime.now())
          : (_dueDate ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: isInvoiceDate
          ? DateTime.now().subtract(const Duration(days: 365))
          : (_invoiceDate ?? DateTime.now()),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.lightTheme.primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isInvoiceDate) {
          _invoiceDate = picked;
          // Reset due date if it's now invalid
          if (_dueDate != null && !_validateDueDate(_dueDate!)) {
            _dueDate = null;
          }
        } else {
          _dueDate = picked;
        }
      });
      _onFormChanged();
    }
  }

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';

    final cleanValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
    final amount = double.tryParse(cleanValue);

    if (amount == null) return value;

    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedAmount = amount
        .toStringAsFixed(2)
        .replaceAllMapped(formatter, (Match m) => '${m[1]},');

    return 'KES $formattedAmount';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInvoiceNumberField(theme),
          SizedBox(height: 3.h),
          _buildDateFields(theme),
          SizedBox(height: 3.h),
          _buildAmountField(theme),
          SizedBox(height: 3.h),
          _buildDescriptionField(theme),
        ],
      ),
    );
  }

  Widget _buildInvoiceNumberField(ThemeData theme) {
    final isValid = _fieldValidation['invoiceNumber'] ?? false;
    final hasError = _invoiceNumberController.text.isNotEmpty && !isValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Invoice Number *',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _invoiceNumberController,
          decoration: InputDecoration(
            hintText: 'Enter invoice number (e.g., INV001)',
            suffixIcon: _invoiceNumberController.text.isNotEmpty
                ? CustomIconWidget(
                    iconName: isValid ? 'check_circle' : 'error',
                    color: isValid
                        ? AppTheme.getSuccessColor(
                            theme.brightness == Brightness.light)
                        : theme.colorScheme.error,
                    size: 20,
                  )
                : null,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide:
                  BorderSide(color: theme.colorScheme.error, width: 1.0),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            LengthLimitingTextInputFormatter(20),
          ],
          textCapitalization: TextCapitalization.characters,
        ),
        if (hasError) ...[
          SizedBox(height: 0.5.h),
          Text(
            'Invoice number must be 3-20 alphanumeric characters',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateFields(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            theme,
            'Invoice Date *',
            _invoiceDate,
            'Select date',
            () => _selectDate(context, true),
            _fieldValidation['invoiceDate'] ?? false,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildDateField(
            theme,
            'Due Date *',
            _dueDate,
            'Select date',
            () => _selectDate(context, false),
            _fieldValidation['dueDate'] ?? false,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(
    ThemeData theme,
    String label,
    DateTime? date,
    String hint,
    VoidCallback onTap,
    bool isValid,
  ) {
    final hasError = date != null && !isValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError ? theme.colorScheme.error : theme.dividerColor,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
              color: theme.inputDecorationTheme.fillColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                        : hint,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: date != null
                          ? theme.colorScheme.onSurface
                          : theme.inputDecorationTheme.hintStyle?.color,
                    ),
                  ),
                ),
                CustomIconWidget(
                  iconName: date != null && isValid
                      ? 'check_circle'
                      : 'calendar_today',
                  color: date != null && isValid
                      ? AppTheme.getSuccessColor(
                          theme.brightness == Brightness.light)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 0.5.h),
          Text(
            label.contains('Due')
                ? 'Due date must be at least 7 days after invoice date'
                : 'Please select a valid date',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAmountField(ThemeData theme) {
    final isValid = _fieldValidation['amount'] ?? false;
    final hasError = _amountController.text.isNotEmpty && !isValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount (KES) *',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _amountController,
          decoration: InputDecoration(
            hintText: 'Enter amount (e.g., KES 10,000.00)',
            prefixText: 'KES ',
            suffixIcon: _amountController.text.isNotEmpty
                ? CustomIconWidget(
                    iconName: isValid ? 'check_circle' : 'error',
                    color: isValid
                        ? AppTheme.getSuccessColor(
                            theme.brightness == Brightness.light)
                        : theme.colorScheme.error,
                    size: 20,
                  )
                : null,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          onChanged: (value) {
            // Auto-format currency as user types
            final formatted = _formatCurrency(value);
            if (formatted != value) {
              _amountController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          },
        ),
        if (hasError) ...[
          SizedBox(height: 0.5.h),
          Text(
            'Please enter a valid amount greater than 0',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDescriptionField(ThemeData theme) {
    final isValid = _fieldValidation['description'] ?? false;
    final hasError = _descriptionController.text.isNotEmpty && !isValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description *',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            hintText: 'Enter invoice description or notes',
            suffixIcon: _descriptionController.text.isNotEmpty
                ? CustomIconWidget(
                    iconName: isValid ? 'check_circle' : 'error',
                    color: isValid
                        ? AppTheme.getSuccessColor(
                            theme.brightness == Brightness.light)
                        : theme.colorScheme.error,
                    size: 20,
                  )
                : null,
          ),
          maxLines: 3,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
        ),
        if (hasError) ...[
          SizedBox(height: 0.5.h),
          Text(
            'Description is required',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
