import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Application text styles
/// 
/// Provides consistent typography throughout the app with support for
/// responsive design and different text contexts.
class AppTextStyles {
  // ============================================================================
  // Headings
  // ============================================================================
  
  /// Large heading for main titles (32px, bold)
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  /// Medium heading for section titles (24px, bold)
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
  );
  
  /// Small heading for subsections (20px, semi-bold)
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
    letterSpacing: -0.2,
  );
  
  /// Extra small heading for card titles (18px, semi-bold)
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  /// Tiny heading for list items (16px, semi-bold)
  static const TextStyle h5 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  // ============================================================================
  // Body Text
  // ============================================================================
  
  /// Large body text for main content (16px, regular)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  /// Medium body text for general content (14px, regular)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  /// Small body text for secondary content (12px, regular)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  // ============================================================================
  // Special Styles
  // ============================================================================
  
  /// Caption text for labels and hints (12px, regular, hint color)
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
    height: 1.4,
  );
  
  /// Overline text for categories and tags (10px, medium, uppercase)
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.6,
    letterSpacing: 1.5,
  );
  
  /// Button text style (14px, semi-bold)
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  /// Large button text style (16px, semi-bold)
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  /// Link text style (14px, medium, primary color)
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    height: 1.5,
    decoration: TextDecoration.underline,
  );
  
  // ============================================================================
  // Status and Feedback Styles
  // ============================================================================
  
  /// Error text style (12px, regular, error color)
  static const TextStyle error = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
    height: 1.4,
  );
  
  /// Success text style (12px, regular, success color)
  static const TextStyle success = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.success,
    height: 1.4,
  );
  
  /// Warning text style (12px, regular, warning color)
  static const TextStyle warning = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.warning,
    height: 1.4,
  );
  
  /// Info text style (12px, regular, info color)
  static const TextStyle info = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.info,
    height: 1.4,
  );
  
  // ============================================================================
  // Role-Specific Styles
  // ============================================================================
  
  /// Admin role badge text
  static const TextStyle adminBadge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.adminColor,
    height: 1.2,
  );
  
  /// Sales role badge text
  static const TextStyle salesBadge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.salesColor,
    height: 1.2,
  );
  
  /// Logistics role badge text
  static const TextStyle logisticsBadge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.logisticsColor,
    height: 1.2,
  );
  
  /// Accounts role badge text
  static const TextStyle accountsBadge = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.accountsColor,
    height: 1.2,
  );
  
  // ============================================================================
  // Numeric and Data Display Styles
  // ============================================================================
  
  /// Large numeric display (24px, bold)
  static const TextStyle numericLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  /// Medium numeric display (18px, semi-bold)
  static const TextStyle numericMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  /// Small numeric display (14px, medium)
  static const TextStyle numericSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  // ============================================================================
  // Helper Methods
  // ============================================================================
  
  /// Get responsive text style based on screen width
  static TextStyle getResponsiveStyle(TextStyle baseStyle, BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final multiplier = width > 600 ? 1.1 : 1.0;
    return baseStyle.copyWith(fontSize: baseStyle.fontSize! * multiplier);
  }
  
  /// Apply color to text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Apply weight to text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}
