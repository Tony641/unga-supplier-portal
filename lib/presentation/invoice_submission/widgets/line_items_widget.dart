import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class LineItemsWidget extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onLineItemsChanged;
  final List<Map<String, dynamic>> initialLineItems;

  const LineItemsWidget({
    super.key,
    required this.onLineItemsChanged,
    required this.initialLineItems,
  });

  @override
  State<LineItemsWidget> createState() => _LineItemsWidgetState();
}

class _LineItemsWidgetState extends State<LineItemsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  bool _isExpanded = false;
  List<Map<String, dynamic>> _lineItems = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _lineItems = List.from(widget.initialLineItems);
    if (_lineItems.isEmpty) {
      _addNewLineItem();
    }
  }

  void _addNewLineItem() {
    setState(() {
      _lineItems.add({
        'description': '',
        'quantity': '',
        'unitPrice': '',
        'total': 0.0,
      });
    });
    _notifyParent();
  }

  void _removeLineItem(int index) {
    if (_lineItems.length > 1) {
      setState(() {
        _lineItems.removeAt(index);
      });
      _notifyParent();
    }
  }

  void _updateLineItem(int index, String field, String value) {
    setState(() {
      _lineItems[index][field] = value;
      _calculateTotal(index);
    });
    _notifyParent();
  }

  void _calculateTotal(int index) {
    final quantity = double.tryParse(_lineItems[index]['quantity'] ?? '0') ?? 0;
    final unitPrice =
        double.tryParse(_lineItems[index]['unitPrice'] ?? '0') ?? 0;
    _lineItems[index]['total'] = quantity * unitPrice;
  }

  double _getGrandTotal() {
    return _lineItems.fold(0.0, (sum, item) => sum + (item['total'] ?? 0.0));
  }

  void _notifyParent() {
    widget.onLineItemsChanged(_lineItems);
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(theme),
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _expandAnimation.value,
                child: child,
              ),
            );
          },
          child: _buildLineItemsList(theme),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Line Items',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    _isExpanded
                        ? 'Detailed breakdown of invoice items'
                        : 'Optional: Add detailed breakdown',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: CustomIconWidget(
                iconName: 'keyboard_arrow_down',
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItemsList(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(top: 2.h),
      child: Column(
        children: [
          ..._lineItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return _buildLineItemCard(theme, index, item);
          }).toList(),
          SizedBox(height: 2.h),
          _buildAddButton(theme),
          SizedBox(height: 2.h),
          _buildTotalSection(theme),
        ],
      ),
    );
  }

  Widget _buildLineItemCard(
      ThemeData theme, int index, Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Item ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (_lineItems.length > 1)
                GestureDetector(
                  onTap: () => _removeLineItem(index),
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: CustomIconWidget(
                      iconName: 'delete_outline',
                      color: theme.colorScheme.error,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 2.h),
          TextFormField(
            initialValue: item['description'] ?? '',
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Enter item description',
            ),
            onChanged: (value) => _updateLineItem(index, 'description', value),
            textCapitalization: TextCapitalization.sentences,
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  initialValue: item['quantity'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    hintText: '0',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (value) =>
                      _updateLineItem(index, 'quantity', value),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 3,
                child: TextFormField(
                  initialValue: item['unitPrice'] ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Unit Price (KES)',
                    hintText: '0.00',
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  onChanged: (value) =>
                      _updateLineItem(index, 'unitPrice', value),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'KES ${(item['total'] ?? 0.0).toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(ThemeData theme) {
    return GestureDetector(
      onTap: _addNewLineItem,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'add',
              color: theme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Text(
              'Add Another Item',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection(ThemeData theme) {
    final grandTotal = _getGrandTotal();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.0),
        border:
            Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Grand Total:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'KES ${grandTotal.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
