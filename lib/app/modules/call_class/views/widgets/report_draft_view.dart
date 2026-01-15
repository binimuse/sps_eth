import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sps_eth_app/app/theme/app_colors.dart';
import 'package:sps_eth_app/app/modules/call_class/controllers/call_class_controller.dart';

/// Widget to display report draft form data during active calls
class ReportDraftView extends StatelessWidget {
  const ReportDraftView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CallClassController>();
    
    return Obx(() {
      final draftData = controller.reportDraft.value;
      final pollingStatus = controller.pollingStatus.value;
      
      // Show status message when no draft exists yet
      if (draftData == null || draftData.formData == null || draftData.formData!.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grayLight, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined,
                color: AppColors.grayDefault,
                size: 24,
              ),
              const SizedBox(height: 12),
              Text(
                pollingStatus,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grayDark,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }
      
      // Show success message when report is submitted
      if (draftData.reportSubmitted == true) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.successLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Report Submitted Successfully',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.successDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (draftData.caseNumber != null && draftData.caseNumber!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Case Number: ${draftData.caseNumber}',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.successDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (draftData.reportId != null && draftData.reportId!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Report ID: ${draftData.reportId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grayDark,
                  ),
                ),
              ],
            ],
          ),
        );
      }
      
      // Display form data with enhanced UI
      final formData = draftData.formData!;
      final lastUpdated = draftData.lastUpdated;
      
      return Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: AppColors.whiteOff,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grayLight, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Report',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (lastUpdated != null && lastUpdated.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Last updated: ${_formatTimestamp(lastUpdated)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.grayDefault,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Group fields by category
                    ..._buildFieldGroups(formData, controller.recentlyUpdatedFields),
                    const SizedBox(height: 12),
                    // Info message
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLighter,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryLight, width: 1),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Please Verify',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Please review the information above. If anything is incorrect, please inform the officer during the call.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryDark,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
  
  /// Build field groups organized by category
  List<Widget> _buildFieldGroups(
    Map<String, dynamic> formData,
    RxSet<String> recentlyUpdatedFields,
  ) {
    // Define field categories
    final personalInfoFields = [
      'fullName', 'firstName', 'lastName', 'middleName',
      'age', 'dateOfBirth', 'birthDate', 'gender', 'nationality',
      'idNumber', 'passportNumber', 'idType',
    ];
    
    final contactInfoFields = [
      'phoneMobile', 'phone', 'mobile', 'phoneNumber',
      'email', 'address', 'street', 'city', 'region',
      'subcity', 'woreda', 'kebele', 'houseNumber',
    ];
    
    final statementInfoFields = [
      'statement', 'incidentDescription', 'description',
      'incidentDate', 'incidentTime', 'date', 'time',
      'location', 'incidentLocation', 'witnesses',
    ];
    
    final reportInfoFields = [
      'reportType', 'type', 'category', 'caseNumber',
      'reportId', 'status', 'priority', 'severity',
    ];
    
    // Categorize fields
    final personalInfo = <String, dynamic>{};
    final contactInfo = <String, dynamic>{};
    final statementInfo = <String, dynamic>{};
    final reportInfo = <String, dynamic>{};
    final otherFields = <String, dynamic>{};
    
    formData.forEach((key, value) {
      final lowerKey = key.toLowerCase();
      if (personalInfoFields.any((field) => lowerKey.contains(field.toLowerCase()))) {
        personalInfo[key] = value;
      } else if (contactInfoFields.any((field) => lowerKey.contains(field.toLowerCase()))) {
        contactInfo[key] = value;
      } else if (statementInfoFields.any((field) => lowerKey.contains(field.toLowerCase()))) {
        statementInfo[key] = value;
      } else if (reportInfoFields.any((field) => lowerKey.contains(field.toLowerCase()))) {
        reportInfo[key] = value;
      } else {
        otherFields[key] = value;
      }
    });
    
    final widgets = <Widget>[];
    
    // Report Information (if available)
    if (reportInfo.isNotEmpty) {
      widgets.add(_FieldGroup(
        title: 'Report Information',
        icon: Icons.assignment,
        fields: reportInfo,
        recentlyUpdatedFields: recentlyUpdatedFields,
      ));
      widgets.add(const SizedBox(height: 16));
    }
    
    // Personal Information
    if (personalInfo.isNotEmpty) {
      widgets.add(_FieldGroup(
        title: 'Personal Information',
        icon: Icons.person,
        fields: personalInfo,
        recentlyUpdatedFields: recentlyUpdatedFields,
      ));
      widgets.add(const SizedBox(height: 16));
    }
    
    // Contact Information
    if (contactInfo.isNotEmpty) {
      widgets.add(_FieldGroup(
        title: 'Contact Information',
        icon: Icons.contact_phone,
        fields: contactInfo,
        recentlyUpdatedFields: recentlyUpdatedFields,
      ));
      widgets.add(const SizedBox(height: 16));
    }
    
    // Statement Information
    if (statementInfo.isNotEmpty) {
      widgets.add(_FieldGroup(
        title: 'Statement & Incident Details',
        icon: Icons.description,
        fields: statementInfo,
        recentlyUpdatedFields: recentlyUpdatedFields,
      ));
      widgets.add(const SizedBox(height: 16));
    }
    
    // Other fields
    if (otherFields.isNotEmpty) {
      widgets.add(_FieldGroup(
        title: 'Additional Information',
        icon: Icons.info,
        fields: otherFields,
        recentlyUpdatedFields: recentlyUpdatedFields,
      ));
    }
    
    return widgets;
  }
  
  String _formatTimestamp(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}

/// Widget for displaying a group of related form fields
class _FieldGroup extends StatelessWidget {
  final String title;
  final IconData icon;
  final Map<String, dynamic> fields;
  final RxSet<String> recentlyUpdatedFields;
  
  const _FieldGroup({
    required this.title,
    required this.icon,
    required this.fields,
    required this.recentlyUpdatedFields,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Group header
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Fields in this group
        ...fields.entries.map((entry) {
          final fieldName = _formatFieldName(entry.key);
          final fieldValue = entry.value;
          final isRecentlyUpdated = recentlyUpdatedFields.contains(entry.key);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FormFieldRow(
              label: fieldName,
              value: fieldValue?.toString() ?? '',
              isRecentlyUpdated: isRecentlyUpdated,
            ),
          );
        }),
      ],
    );
  }
  
  String _formatFieldName(String key) {
    // Convert camelCase or snake_case to Title Case
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty 
            ? '' 
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ')
        .trim();
  }
}

/// Widget for displaying a single form field row with update highlighting
class _FormFieldRow extends StatefulWidget {
  final String label;
  final String value;
  final bool isRecentlyUpdated;
  
  const _FormFieldRow({
    required this.label,
    required this.value,
    this.isRecentlyUpdated = false,
  });
  
  @override
  State<_FormFieldRow> createState() => _FormFieldRowState();
}

class _FormFieldRowState extends State<_FormFieldRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _colorAnimation = ColorTween(
      begin: AppColors.backgroundLight,
      end: AppColors.secondaryLighter,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    if (widget.isRecentlyUpdated) {
      _animationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            _animationController.reverse();
          }
        });
      });
    }
  }
  
  @override
  void didUpdateWidget(_FormFieldRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecentlyUpdated && !oldWidget.isRecentlyUpdated) {
      _animationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            _animationController.reverse();
          }
        });
      });
    } else if (!widget.isRecentlyUpdated && oldWidget.isRecentlyUpdated) {
      _animationController.reverse();
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final formattedValue = _formatValue(widget.value);
    
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grayDefault,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.isRecentlyUpdated)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.update,
                          size: 10,
                          color: AppColors.whiteOff,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Updated',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.whiteOff,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _colorAnimation.value ?? AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.isRecentlyUpdated 
                      ? AppColors.secondary 
                      : AppColors.grayLighter,
                  width: widget.isRecentlyUpdated ? 1.5 : 1,
                ),
              ),
              child: Text(
                formattedValue.isEmpty ? '—' : formattedValue,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  String _formatValue(String value) {
    if (value.isEmpty) return value;
    
    // Format phone numbers
    if (RegExp(r'^\+?\d{10,15}$').hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      if (cleaned.startsWith('+251')) {
        return '+251 ${cleaned.substring(4, 7)} ${cleaned.substring(7, 10)} ${cleaned.substring(10)}';
      } else if (cleaned.startsWith('251')) {
        return '+251 ${cleaned.substring(3, 6)} ${cleaned.substring(6, 9)} ${cleaned.substring(9)}';
      } else if (cleaned.startsWith('0')) {
        return '+251 ${cleaned.substring(1, 4)} ${cleaned.substring(4, 7)} ${cleaned.substring(7)}';
      }
    }
    
    // Format dates (ISO format)
    try {
      final dateTime = DateTime.parse(value);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      // Not a date, return as is
    }
    
    // Format email (just return as is, but could add validation)
    if (value.contains('@') && value.contains('.')) {
      return value;
    }
    
    return value;
  }
}
