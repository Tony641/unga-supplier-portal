import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/document_attachments_widget.dart';
import './widgets/invoice_header_widget.dart';
import './widgets/qr_code_widget.dart';
import './widgets/status_detail_card_widget.dart';
import './widgets/status_timeline_widget.dart';

class InvoiceStatusTracking extends StatefulWidget {
  const InvoiceStatusTracking({super.key});

  @override
  State<InvoiceStatusTracking> createState() => _InvoiceStatusTrackingState();
}

class _InvoiceStatusTrackingState extends State<InvoiceStatusTracking>
    with TickerProviderStateMixin {
  bool _isRefreshing = false;
  int _expandedCardIndex = -1;
  late AnimationController _refreshController;
  late Animation<double> _refreshAnimation;

  // Mock data for invoice tracking
  final Map<String, dynamic> _invoiceData = {
    "invoiceNumber": "INV-2024-08-001",
    "amount": "KES 125,000.00",
    "supplierName": "Kiambu Maize Suppliers Ltd",
    "currentStatus": InvoiceStatus.approved,
    "qrData": "INV-2024-08-001-TRACK-CODE",
  };

  final Map<InvoiceStatus, Map<String, dynamic>> _statusDetails = {
    InvoiceStatus.submitted: {
      "timestamp": "15 Aug 2024, 09:30 AM",
      "submittedBy": "John Kamau",
      "submissionMethod": "Mobile App",
      "documentCount": "3 documents",
      "notes": "Invoice submitted successfully with all required documents",
    },
    InvoiceStatus.underReview: {
      "timestamp": "15 Aug 2024, 11:45 AM",
      "reviewer": "Sarah Wanjiku - Finance Team",
      "reviewStarted": "15 Aug 2024, 11:45 AM",
      "estimatedTime": "2-3 business days",
      "notes": "Invoice is being reviewed for compliance and accuracy",
    },
    InvoiceStatus.approved: {
      "timestamp": "16 Aug 2024, 02:15 PM",
      "approvedBy": "Michael Ochieng - Finance Manager",
      "approvalDate": "16 Aug 2024, 02:15 PM",
      "approvalReference": "APP-2024-08-001",
      "notes": "Invoice approved for payment processing",
    },
    InvoiceStatus.paymentScheduled: {
      "estimatedTime": "3-5 business days",
      "scheduledDate": "20 Aug 2024",
      "paymentMethod": "Bank Transfer",
      "notes": "Payment has been scheduled and will be processed soon",
    },
    InvoiceStatus.paid: {
      "estimatedTime": "Completed",
      "paymentDate": "20 Aug 2024",
      "paymentReference": "PAY-2024-08-001",
      "amount": "KES 125,000.00",
      "notes": "Payment completed successfully",
    },
  };

  final List<Map<String, dynamic>> _documents = [
    {
      "name": "Invoice.pdf",
      "type": "pdf",
      "size": "2.4 MB",
      "thumbnail":
          "https://images.pexels.com/photos/6863183/pexels-photo-6863183.jpeg?auto=compress&cs=tinysrgb&w=400",
      "url": "https://example.com/invoice.pdf",
    },
    {
      "name": "Delivery_Note.jpg",
      "type": "jpg",
      "size": "1.8 MB",
      "thumbnail":
          "https://images.pexels.com/photos/4386321/pexels-photo-4386321.jpeg?auto=compress&cs=tinysrgb&w=400",
      "url": "https://example.com/delivery.jpg",
    },
    {
      "name": "Purchase_Order.pdf",
      "type": "pdf",
      "size": "1.2 MB",
      "thumbnail":
          "https://images.pexels.com/photos/6863183/pexels-photo-6863183.jpeg?auto=compress&cs=tinysrgb&w=400",
      "url": "https://example.com/po.pdf",
    },
  ];

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _refreshController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    _refreshController.forward();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    _refreshController.reverse();
    setState(() => _isRefreshing = false);

    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Status updated successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onStatusTap(InvoiceStatus status) {
    HapticFeedback.lightImpact();

    final statusIndex = InvoiceStatus.values.indexOf(status);
    setState(() {
      _expandedCardIndex = _expandedCardIndex == statusIndex ? -1 : statusIndex;
    });
  }

  void _onDownloadReceipt() {
    HapticFeedback.mediumImpact();
    Fluttertoast.showToast(
      msg: "Downloading receipt...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onContactSupport() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Support'),
        content:
            Text('Would you like to contact support regarding this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Support ticket created",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text('Contact'),
          ),
        ],
      ),
    );
  }

  void _onShareStatus() {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Sharing invoice status...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _onSetReminder() {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Reminder'),
        content: Text('Set a reminder for payment follow-up?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: "Reminder set successfully",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            },
            child: Text('Set'),
          ),
        ],
      ),
    );
  }

  void _onDocumentTap(Map<String, dynamic> document) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 90.w,
          height: 70.h,
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      document['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: CustomIconWidget(
                      iconName: 'close',
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: document['thumbnail'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomImageWidget(
                            imageUrl: document['thumbnail'] as String,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'picture_as_pdf',
                                color: Theme.of(context).colorScheme.primary,
                                size: 64,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Document Preview',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onQrShare() {
    HapticFeedback.lightImpact();
    Fluttertoast.showToast(
      msg: "Sharing QR code...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentStatus = _invoiceData['currentStatus'] as InvoiceStatus;
    final isPaid = currentStatus == InvoiceStatus.paid;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Invoice Tracking'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.appBarTheme.foregroundColor ??
                theme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refreshStatus,
            icon: AnimatedBuilder(
              animation: _refreshAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _refreshAnimation.value * 2 * 3.14159,
                  child: CustomIconWidget(
                    iconName: 'refresh',
                    color: theme.appBarTheme.foregroundColor ??
                        theme.colorScheme.onSurface,
                    size: 24,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshStatus,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              // Invoice Header
              InvoiceHeaderWidget(
                invoiceNumber: _invoiceData['invoiceNumber'] as String,
                amount: _invoiceData['amount'] as String,
                supplierName: _invoiceData['supplierName'] as String,
              ),

              SizedBox(height: 3.h),

              // Status Timeline
              StatusTimelineWidget(
                currentStatus: currentStatus,
                statusDetails: _statusDetails,
                onStatusTap: _onStatusTap,
              ),

              SizedBox(height: 3.h),

              // Expanded Status Details
              if (_expandedCardIndex >= 0 &&
                  _expandedCardIndex < InvoiceStatus.values.length)
                StatusDetailCardWidget(
                  title:
                      '${InvoiceStatus.values[_expandedCardIndex].toString().split('.').last} Details',
                  details: _statusDetails[
                          InvoiceStatus.values[_expandedCardIndex]] ??
                      {},
                  isExpanded: true,
                  onToggle: () => setState(() => _expandedCardIndex = -1),
                ),

              if (_expandedCardIndex >= 0) SizedBox(height: 3.h),

              // Action Buttons
              ActionButtonsWidget(
                showDownloadReceipt: isPaid,
                showContactSupport:
                    currentStatus.index < InvoiceStatus.paid.index,
                onDownloadReceipt: _onDownloadReceipt,
                onContactSupport: _onContactSupport,
                onShareStatus: _onShareStatus,
                onSetReminder: _onSetReminder,
              ),

              SizedBox(height: 3.h),

              // Document Attachments
              DocumentAttachmentsWidget(
                documents: _documents,
                onDocumentTap: _onDocumentTap,
              ),

              SizedBox(height: 3.h),

              // QR Code
              QrCodeWidget(
                invoiceNumber: _invoiceData['invoiceNumber'] as String,
                qrData: _invoiceData['qrData'] as String,
                onShare: _onQrShare,
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
