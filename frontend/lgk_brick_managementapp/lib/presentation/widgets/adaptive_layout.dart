import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

/// Adaptive layout widget that adjusts based on screen size and orientation
/// 
/// Provides different layouts for mobile, tablet, and desktop devices
/// with proper spacing and responsive behavior.
class AdaptiveLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool centerContent;
  final double? maxWidth;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  
  const AdaptiveLayout({
    super.key,
    required this.child,
    this.padding,
    this.centerContent = true,
    this.maxWidth,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    final responsiveMaxWidth = maxWidth ?? ResponsiveUtils.getResponsiveMaxWidth(context);
    
    Widget content = Padding(
      padding: responsivePadding,
      child: child,
    );
    
    if (centerContent && !ResponsiveUtils.isMobile(context)) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: responsiveMaxWidth),
          child: content,
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Expanded(child: content),
      ],
    );
  }
}

/// Adaptive form layout for responsive forms
class AdaptiveFormLayout extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final double? spacing;
  final CrossAxisAlignment crossAxisAlignment;
  final bool wrapInCard;
  final String? title;
  final Widget? titleWidget;
  
  const AdaptiveFormLayout({
    super.key,
    required this.children,
    this.padding,
    this.spacing,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.wrapInCard = false,
    this.title,
    this.titleWidget,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsiveSpacing = spacing ?? ResponsiveUtils.getResponsiveFormSpacing(context);
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    
    Widget content = Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        if (titleWidget != null) ...[
          titleWidget!,
          SizedBox(height: responsiveSpacing),
        ] else if (title != null) ...[
          Text(
            title!,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsiveSpacing),
        ],
        ...children.expand((child) => [
          child,
          SizedBox(height: responsiveSpacing),
        ]).take(children.length * 2 - 1),
      ],
    );
    
    if (wrapInCard) {
      content = Card(
        elevation: ResponsiveUtils.getResponsiveCardElevation(context),
        margin: ResponsiveUtils.getResponsiveCardMargin(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 12),
          ),
        ),
        child: Padding(
          padding: responsivePadding,
          child: content,
        ),
      );
    }
    
    return ResponsiveContainer(
      padding: wrapInCard ? EdgeInsets.zero : responsivePadding,
      child: SingleChildScrollView(
        child: content,
      ),
    );
  }
}

/// Adaptive grid layout for dashboard cards and lists
class AdaptiveGridLayout extends StatelessWidget {
  final List<Widget> children;
  final double? childAspectRatio;
  final EdgeInsets? padding;
  final double? spacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  
  const AdaptiveGridLayout({
    super.key,
    required this.children,
    this.childAspectRatio,
    this.padding,
    this.spacing,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.physics,
    this.shrinkWrap = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.getResponsiveCrossAxisCount(
      context,
      mobileCount: mobileColumns ?? 1,
      tabletCount: tabletColumns ?? 2,
      desktopCount: desktopColumns ?? 3,
    );
    
    final responsiveSpacing = spacing ?? ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 8);
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio ?? 1.0,
      mainAxisSpacing: responsiveSpacing,
      crossAxisSpacing: responsiveSpacing,
      padding: responsivePadding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }
}

/// Adaptive two-column layout for tablets and desktop
class AdaptiveTwoColumnLayout extends StatelessWidget {
  final Widget leftChild;
  final Widget rightChild;
  final double? leftFlex;
  final double? rightFlex;
  final EdgeInsets? padding;
  final double? spacing;
  final bool forceVerticalOnMobile;
  
  const AdaptiveTwoColumnLayout({
    super.key,
    required this.leftChild,
    required this.rightChild,
    this.leftFlex,
    this.rightFlex,
    this.padding,
    this.spacing,
    this.forceVerticalOnMobile = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsiveSpacing = spacing ?? ResponsiveUtils.getResponsiveSpacing(context);
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    
    if (ResponsiveUtils.isMobile(context) && forceVerticalOnMobile) {
      return Padding(
        padding: responsivePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            leftChild,
            SizedBox(height: responsiveSpacing),
            rightChild,
          ],
        ),
      );
    }
    
    return Padding(
      padding: responsivePadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: (leftFlex ?? 1).round(),
            child: leftChild,
          ),
          SizedBox(width: responsiveSpacing),
          Expanded(
            flex: (rightFlex ?? 1).round(),
            child: rightChild,
          ),
        ],
      ),
    );
  }
}

/// Adaptive list layout with responsive spacing
class AdaptiveListLayout extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final double? spacing;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final CrossAxisAlignment crossAxisAlignment;
  
  const AdaptiveListLayout({
    super.key,
    required this.children,
    this.padding,
    this.spacing,
    this.shrinkWrap = false,
    this.physics,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsiveSpacing = spacing ?? ResponsiveUtils.getResponsiveSpacing(context);
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    
    return ListView.separated(
      padding: responsivePadding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: children.length,
      separatorBuilder: (context, index) => SizedBox(height: responsiveSpacing),
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Adaptive dialog wrapper for responsive dialogs
class AdaptiveDialog extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final EdgeInsets? contentPadding;
  final bool scrollable;
  
  const AdaptiveDialog({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.contentPadding,
    this.scrollable = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final dialogWidth = ResponsiveUtils.getResponsiveDialogWidth(context);
    final responsivePadding = contentPadding ?? ResponsiveUtils.getResponsivePadding(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 16),
        ),
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null)
              Padding(
                padding: responsivePadding.copyWith(bottom: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            Flexible(
              child: scrollable
                  ? SingleChildScrollView(
                      padding: responsivePadding,
                      child: child,
                    )
                  : Padding(
                      padding: responsivePadding,
                      child: child,
                    ),
            ),
            if (actions != null && actions!.isNotEmpty)
              Padding(
                padding: responsivePadding.copyWith(top: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: actions!
                      .expand((action) => [
                            action,
                            const SizedBox(width: 8),
                          ])
                      .take(actions!.length * 2 - 1)
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Adaptive scaffold with responsive app bar and body
class AdaptiveScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;
  final bool resizeToAvoidBottomInset;
  
  const AdaptiveScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.drawer,
    this.endDrawer,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        child: ResponsiveContainer(
          child: body,
        ),
      ),
    );
  }
}