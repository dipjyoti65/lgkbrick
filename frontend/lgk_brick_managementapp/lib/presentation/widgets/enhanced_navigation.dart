import 'package:flutter/material.dart';
import '../../core/utils/responsive_utils.dart';

/// Enhanced navigation components with consistent styling and animations
/// 
/// Provides consistent navigation patterns across all screens with
/// smooth transitions and visual feedback.

/// Enhanced app bar with responsive design
class EnhancedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  
  const EnhancedAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.automaticallyImplyLeading = true,
    this.bottom,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsiveHeight = ResponsiveUtils.getResponsiveAppBarHeight(context);
    
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20 * ResponsiveUtils.getFontSizeMultiplier(context),
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom,
      toolbarHeight: responsiveHeight,
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(
    ResponsiveUtils.getResponsiveAppBarHeight(
      // We can't access context here, so use a default value
      // This will be overridden by the actual context when built
      // ignore: invalid_use_of_protected_member
      WidgetsBinding.instance.rootElement ?? 
      WidgetsBinding.instance.renderViewElement!,
    ) + (bottom?.preferredSize.height ?? 0),
  );
}

/// Enhanced navigation button with ripple effect and feedback
class EnhancedNavigationButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? tooltip;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius? borderRadius;
  final bool showRipple;
  final Duration animationDuration;
  
  const EnhancedNavigationButton({
    super.key,
    required this.child,
    this.onPressed,
    this.tooltip,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.showRipple = true,
    this.animationDuration = const Duration(milliseconds: 200),
  });
  
  @override
  State<EnhancedNavigationButton> createState() => _EnhancedNavigationButtonState();
}

class _EnhancedNavigationButtonState extends State<EnhancedNavigationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }
  
  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }
  
  void _handleTapCancel() {
    _animationController.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final responsivePadding = widget.padding ?? ResponsiveUtils.getResponsivePadding(context);
    final responsiveBorderRadius = widget.borderRadius ??
        BorderRadius.circular(ResponsiveUtils.getResponsiveBorderRadius(context));
    
    Widget button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: responsivePadding,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: responsiveBorderRadius,
            ),
            child: widget.child,
          ),
        );
      },
    );
    
    if (widget.showRipple) {
      button = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPressed,
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: responsiveBorderRadius,
          child: button,
        ),
      );
    } else {
      button = GestureDetector(
        onTap: widget.onPressed,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: button,
      );
    }
    
    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }
    
    return button;
  }
}

/// Enhanced floating action button with responsive sizing
class EnhancedFloatingActionButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool mini;
  final String? heroTag;
  
  const EnhancedFloatingActionButton({
    super.key,
    required this.child,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.mini = false,
    this.heroTag,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsiveElevation = elevation ?? ResponsiveUtils.getResponsiveCardElevation(context);
    
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: responsiveElevation,
      mini: mini,
      heroTag: heroTag,
      child: child,
    );
  }
}

/// Enhanced bottom navigation bar with responsive design
class EnhancedBottomNavigationBar extends StatelessWidget {
  final List<BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final BottomNavigationBarType? type;
  final double? elevation;
  
  const EnhancedBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.type,
    this.elevation,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsiveHeight = ResponsiveUtils.getResponsiveBottomNavHeight(context);
    final responsiveElevation = elevation ?? ResponsiveUtils.getResponsiveCardElevation(context);
    
    return Container(
      height: responsiveHeight,
      child: BottomNavigationBar(
        items: items,
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: backgroundColor,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
        type: type ?? BottomNavigationBarType.fixed,
        elevation: responsiveElevation,
        selectedFontSize: 12 * ResponsiveUtils.getFontSizeMultiplier(context),
        unselectedFontSize: 10 * ResponsiveUtils.getFontSizeMultiplier(context),
      ),
    );
  }
}

/// Enhanced drawer with responsive design
class EnhancedDrawer extends StatelessWidget {
  final Widget? header;
  final List<Widget> children;
  final Color? backgroundColor;
  final double? elevation;
  final EdgeInsets? padding;
  
  const EnhancedDrawer({
    super.key,
    this.header,
    required this.children,
    this.backgroundColor,
    this.elevation,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    final responsiveElevation = elevation ?? ResponsiveUtils.getResponsiveCardElevation(context);
    
    return Drawer(
      backgroundColor: backgroundColor,
      elevation: responsiveElevation,
      child: Column(
        children: [
          if (header != null) header!,
          Expanded(
            child: ListView(
              padding: responsivePadding,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// Enhanced list tile with responsive design and animations
class EnhancedListTile extends StatefulWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final Color? selectedColor;
  final EdgeInsets? contentPadding;
  final bool dense;
  final bool enabled;
  final String? tooltip;
  
  const EnhancedListTile({
    super.key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.selectedColor,
    this.contentPadding,
    this.dense = false,
    this.enabled = true,
    this.tooltip,
  });
  
  @override
  State<EnhancedListTile> createState() => _EnhancedListTileState();
}

class _EnhancedListTileState extends State<EnhancedListTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.grey.withOpacity(0.1),
    ).animate(_animationController);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      _animationController.forward();
    }
  }
  
  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
  }
  
  void _handleTapCancel() {
    _animationController.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    final responsivePadding = widget.contentPadding ?? 
        ResponsiveUtils.getResponsiveListTilePadding(context);
    
    Widget listTile = AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          color: widget.selected 
              ? (widget.selectedColor ?? Theme.of(context).primaryColor.withOpacity(0.1))
              : _colorAnimation.value,
          child: ListTile(
            leading: widget.leading,
            title: widget.title,
            subtitle: widget.subtitle,
            trailing: widget.trailing,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            selected: widget.selected,
            contentPadding: responsivePadding,
            dense: widget.dense,
            enabled: widget.enabled,
          ),
        );
      },
    );
    
    listTile = GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: listTile,
    );
    
    if (widget.tooltip != null) {
      listTile = Tooltip(
        message: widget.tooltip!,
        child: listTile,
      );
    }
    
    return listTile;
  }
}

/// Page transition animations
class EnhancedPageTransitions {
  /// Slide transition from right
  static PageRouteBuilder slideFromRight<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
  
  /// Slide transition from bottom
  static PageRouteBuilder slideFromBottom<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
  
  /// Fade transition
  static PageRouteBuilder fadeTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
  
  /// Scale transition
  static PageRouteBuilder scaleTransition<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: 0.8, end: 1.0).chain(
          CurveTween(curve: curve),
        );
        
        return ScaleTransition(
          scale: animation.drive(tween),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

/// Navigation helper methods
class NavigationHelper {
  /// Navigate to page with slide from right animation
  static Future<T?> slideToPage<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      EnhancedPageTransitions.slideFromRight<T>(page) as Route<T>,
    );
  }
  
  /// Navigate to page with slide from bottom animation
  static Future<T?> slideFromBottomToPage<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      EnhancedPageTransitions.slideFromBottom<T>(page) as Route<T>,
    );
  }
  
  /// Navigate to page with fade animation
  static Future<T?> fadeToPage<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      EnhancedPageTransitions.fadeTransition<T>(page) as Route<T>,
    );
  }
  
  /// Navigate to page with scale animation
  static Future<T?> scaleToPage<T>(BuildContext context, Widget page) {
    return Navigator.of(context).push<T>(
      EnhancedPageTransitions.scaleTransition<T>(page) as Route<T>,
    );
  }
  
  /// Pop with result
  static void popWithResult<T>(BuildContext context, T result) {
    Navigator.of(context).pop<T>(result);
  }
  
  /// Pop until first route
  static void popToRoot(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
  
  /// Replace current page
  static Future<T?> replacePage<T>(BuildContext context, Widget page) {
    return Navigator.of(context).pushReplacement<T, void>(
      EnhancedPageTransitions.slideFromRight<T>(page) as Route<T>,
    );
  }
}