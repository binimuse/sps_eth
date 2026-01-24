import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_pages.dart';

class LineBusyDialog extends StatelessWidget {
  final VoidCallback? onTryAgain;

  const LineBusyDialog({
    super.key,
    this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          // Navigate to home instead of closing the dialog
          Get.offAllNamed(Routes.HOME);
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: AppColors.black.withOpacity(0.3),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 90.w,
                  maxHeight: 80.h,
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 6.w),
                  padding: EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                    color: AppColors.whiteOff,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icon
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.phone_disabled,
                            color: AppColors.danger,
                            size: 10.w,
                          ),
                        ),
                        
                        SizedBox(height: 3.h),
                        
                        // Title
                        Text(
                          'Line Busy',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                            fontFamily: 'DMSans',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        SizedBox(height: 1.5.h),
                        
                        // Message
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 2.w),
                          child: Text(
                            'No Office are currently available. Please try again later.',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.grayDefault,
                              fontFamily: 'DMSans',
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        SizedBox(height: 3.h),
                        
                        // Buttons Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Try Again Button
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                onTryAgain?.call();
                              },
                              child: Container(
                                width: 15.w,
                                height: 7.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    'Try Again',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.whiteOff,
                                      fontFamily: 'DMSans',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(width: 3.w),
                            
                            // Go to Home Button
                            GestureDetector(
                              onTap: () {
                                Get.offAllNamed(Routes.HOME);
                              },
                              child: Container(
                                width: 15.w,
                                height: 7.w,
                                decoration: BoxDecoration(
                                  color: AppColors.whiteOff,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'Go to Home',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontFamily: 'DMSans',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Helper class to show the line busy dialog
class LineBusyDialogHelper {
  static void show({
    required BuildContext context,
    VoidCallback? onTryAgain,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LineBusyDialog(
          onTryAgain: onTryAgain,
        );
      },
    );
  }
}
