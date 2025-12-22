import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes and orientations
/// 
/// Provides methods to determine device type, get responsive values, and
/// handle layout adaptations for phones and tablets.
class ResponsiveUtils {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;
  
  // Grid columns
  static const int mobileColumns = 1;
  static const int tabletColumns = 2;
  static const int desktopColumns = 3;
  
  /// Check if device is mobile (phone)
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
  
  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }
  
  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }
  
  /// Get device type enum
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }
  
  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  /// Check if device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }
  
  /// Get responsive padding based on device type
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }
  
  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32);
    } else {
      return const EdgeInsets.symmetric(horizontal: 48);
    }
  }
  
  /// Get responsive vertical padding
  static EdgeInsets getResponsiveVerticalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(vertical: 16);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(vertical: 24);
    } else {
      return const EdgeInsets.symmetric(vertical: 32);
    }
  }
  
  /// Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(8);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.all(16);
    }
  }
  
  /// Get responsive font size multiplier
  static double getFontSizeMultiplier(BuildContext context) {
    if (isMobile(context)) {
      return 1.0;
    } else if (isTablet(context)) {
      return 1.1;
    } else {
      return 1.2;
    }
  }
  
  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, {double baseSize = 24}) {
    final multiplier = getFontSizeMultiplier(context);
    return baseSize * multiplier;
  }
  
  /// Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 48;
    } else if (isTablet(context)) {
      return 52;
    } else {
      return 56;
    }
  }
  
  /// Get responsive card elevation
  static double getResponsiveCardElevation(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 4;
    } else {
      return 6;
    }
  }
  
  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, {double baseRadius = 8}) {
    final multiplier = getFontSizeMultiplier(context);
    return baseRadius * multiplier;
  }
  
  /// Get responsive grid column count
  static int getResponsiveGridColumns(BuildContext context) {
    if (isMobile(context)) {
      return isLandscape(context) ? 2 : 1;
    } else if (isTablet(context)) {
      return isLandscape(context) ? 3 : 2;
    } else {
      return isLandscape(context) ? 4 : 3;
    }
  }
  
  /// Get responsive cross axis count for grid
  static int getResponsiveCrossAxisCount(BuildContext context, {
    int mobileCount = 1,
    int tabletCount = 2,
    int desktopCount = 3,
  }) {
    if (isMobile(context)) {
      return isLandscape(context) ? (mobileCount + 1) : mobileCount;
    } else if (isTablet(context)) {
      return isLandscape(context) ? (tabletCount + 1) : tabletCount;
    } else {
      return isLandscape(context) ? (desktopCount + 1) : desktopCount;
    }
  }
  
  /// Get responsive dialog width
  static double getResponsiveDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return screenWidth * 0.9;
    } else if (isTablet(context)) {
      return screenWidth * 0.7;
    } else {
      return screenWidth * 0.5;
    }
  }
  
  /// Get responsive max width for content
  static double getResponsiveMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 600;
    } else {
      return 800;
    }
  }
  
  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, {double baseSpacing = 16}) {
    final multiplier = getFontSizeMultiplier(context);
    return baseSpacing * multiplier;
  }
  
  /// Get responsive app bar height
  static double getResponsiveAppBarHeight(BuildContext context) {
    if (isMobile(context)) {
      return kToolbarHeight;
    } else if (isTablet(context)) {
      return kToolbarHeight + 8;
    } else {
      return kToolbarHeight + 16;
    }
  }
  
  /// Get responsive bottom navigation height
  static double getResponsiveBottomNavHeight(BuildContext context) {
    if (isMobile(context)) {
      return kBottomNavigationBarHeight;
    } else if (isTablet(context)) {
      return kBottomNavigationBarHeight + 8;
    } else {
      return kBottomNavigationBarHeight + 16;
    }
  }
  
  /// Get responsive form field spacing
  static double getResponsiveFormSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 16;
    } else if (isTablet(context)) {
      return 20;
    } else {
      return 24;
    }
  }
  
  /// Get responsive card margin
  static EdgeInsets getResponsiveCardMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }
  
  /// Get responsive list tile padding
  static EdgeInsets getResponsiveListTilePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }
}

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Responsive widget that adapts based on device type
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });
  
  @override
  Widget build(BuildContext context) {
    if (ResponsiveUtils.isDesktop(context) && desktop != null) {
      return desktop!;
    } else if (ResponsiveUtils.isTablet(context) && tablet != null) {
      return tablet!;
    } else {
      return mobile;
    }
  }
}

/// Responsive builder widget
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;
  
  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    return builder(context, deviceType);
  }
}

/// Responsive grid view
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final EdgeInsets? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  
  const ResponsiveGridView({
    super.key,
    required this.children,
    this.childAspectRatio,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.getResponsiveGridColumns(context);
    final spacing = ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 8);
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio ?? 1.0,
      mainAxisSpacing: mainAxisSpacing ?? spacing,
      crossAxisSpacing: crossAxisSpacing ?? spacing,
      padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }
}

/// Responsive container with max width constraint
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Decoration? decoration;
  final double? maxWidth;
  
  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.maxWidth,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
      margin: margin,
      color: color,
      decoration: decoration,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? ResponsiveUtils.getResponsiveMaxWidth(context),
          ),
          child: child,
        ),
      ),
    );
  }
}