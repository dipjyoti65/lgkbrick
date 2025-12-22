import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/responsive_utils.dart';

/// Visual feedback components for enhanced user experience
/// 
/// Provides consistent visual feedback patterns including loading states,
/// success/error indicators, and interactive animations.

/// Enhanced loading indicator with customizable appearance
class EnhancedLoadingIndicator extends StatefulWidget {
  final String? message;
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool showPulse;
  final Duration animationDuration;
  
  const EnhancedLoadingIndicator({
    super.key,
    this.message,
    this.size = 24,
    this.color,
    this.strokeWidth = 2,
    this.showPulse = false,
    this.animationDuration = const Duration(milliseconds: 1500),
  });
  
  @override
  State<EnhancedLoadingIndicator> createState() => _EnhancedLoadingIndicatorState();
}

class _EnhancedLoadingIndicatorState extends State<EnhancedLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..repeat();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.showPulse) {
      _pulseController.repeat(reverse: true);
    }
  }
  
  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    Widget indicator = SizedBox(
      width: widget.size,
      height: widget.size,
      child: CircularProgressIndicator(
        strokeWidth: widget.strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(
          widget.color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
    
    if (widget.showPulse) {
      indicator = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: indicator,
          );
        },
      );
    }
    
    if (widget.message != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          indicator,
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 8)),
          Text(
            widget.message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: (Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14) *
                  ResponsiveUtils.getFontSizeMultiplier(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    
    return indicator;
  }
}

/// Success indicator with animation
class SuccessIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration animationDuration;
  final VoidCallback? onComplete;
  
  const SuccessIndicator({
    super.key,
    this.size = 48,
    this.color,
    this.animationDuration = const Duration(milliseconds: 600),
    this.onComplete,
  });
  
  @override
  State<SuccessIndicator> createState() => _SuccessIndicatorState();
}

class _SuccessIndicatorState extends State<SuccessIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));
    
    _checkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));
    
    _animationController.forward().then((_) {
      widget.onComplete?.call();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Colors.green.shade600;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: AnimatedBuilder(
              animation: _checkAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CheckmarkPainter(
                    progress: _checkAnimation.value,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Error indicator with animation
class ErrorIndicator extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration animationDuration;
  final VoidCallback? onComplete;
  
  const ErrorIndicator({
    super.key,
    this.size = 48,
    this.color,
    this.animationDuration = const Duration(milliseconds: 600),
    this.onComplete,
  });
  
  @override
  State<ErrorIndicator> createState() => _ErrorIndicatorState();
}

class _ErrorIndicatorState extends State<ErrorIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _crossAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
    ));
    
    _crossAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
    ));
    
    _animationController.forward().then((_) {
      widget.onComplete?.call();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Colors.red.shade600;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: AnimatedBuilder(
              animation: _crossAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CrossPainter(
                    progress: _crossAnimation.value,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Ripple effect widget
class RippleEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? rippleColor;
  final Duration duration;
  final BorderRadius? borderRadius;
  
  const RippleEffect({
    super.key,
    required this.child,
    this.onTap,
    this.rippleColor,
    this.duration = const Duration(milliseconds: 300),
    this.borderRadius,
  });
  
  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Offset? _tapPosition;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _tapPosition = details.localPosition;
    });
    _animationController.forward().then((_) {
      _animationController.reset();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        child: Stack(
          children: [
            widget.child,
            if (_tapPosition != null)
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: RipplePainter(
                      center: _tapPosition!,
                      progress: _animation.value,
                      color: widget.rippleColor ?? 
                          Theme.of(context).primaryColor.withOpacity(0.3),
                    ),
                    size: Size.infinite,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Haptic feedback helper
class AppHapticFeedback {
  /// Light impact feedback
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }
  
  /// Medium impact feedback
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }
  
  /// Heavy impact feedback
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }
  
  /// Selection feedback
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }
  
  /// Vibrate feedback
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}

/// Custom painters for indicators

class CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  CheckmarkPainter({
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final checkSize = size.width * 0.3;
    
    // Define checkmark path
    final start = Offset(center.dx - checkSize / 2, center.dy);
    final middle = Offset(center.dx - checkSize / 6, center.dy + checkSize / 3);
    final end = Offset(center.dx + checkSize / 2, center.dy - checkSize / 3);
    
    if (progress <= 0.5) {
      // First part of checkmark
      final currentProgress = progress * 2;
      final currentPoint = Offset.lerp(start, middle, currentProgress)!;
      path.moveTo(start.dx, start.dy);
      path.lineTo(currentPoint.dx, currentPoint.dy);
    } else {
      // Complete first part and draw second part
      path.moveTo(start.dx, start.dy);
      path.lineTo(middle.dx, middle.dy);
      
      final currentProgress = (progress - 0.5) * 2;
      final currentPoint = Offset.lerp(middle, end, currentProgress)!;
      path.lineTo(currentPoint.dx, currentPoint.dy);
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class CrossPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  CrossPainter({
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    final center = Offset(size.width / 2, size.height / 2);
    final crossSize = size.width * 0.3;
    
    if (progress <= 0.5) {
      // First line of cross
      final currentProgress = progress * 2;
      final start = Offset(center.dx - crossSize / 2, center.dy - crossSize / 2);
      final end = Offset(center.dx + crossSize / 2, center.dy + crossSize / 2);
      final currentEnd = Offset.lerp(start, end, currentProgress)!;
      
      canvas.drawLine(start, currentEnd, paint);
    } else {
      // Complete first line and draw second line
      canvas.drawLine(
        Offset(center.dx - crossSize / 2, center.dy - crossSize / 2),
        Offset(center.dx + crossSize / 2, center.dy + crossSize / 2),
        paint,
      );
      
      final currentProgress = (progress - 0.5) * 2;
      final start = Offset(center.dx + crossSize / 2, center.dy - crossSize / 2);
      final end = Offset(center.dx - crossSize / 2, center.dy + crossSize / 2);
      final currentEnd = Offset.lerp(start, end, currentProgress)!;
      
      canvas.drawLine(start, currentEnd, paint);
    }
  }
  
  @override
  bool shouldRepaint(CrossPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class RipplePainter extends CustomPainter {
  final Offset center;
  final double progress;
  final Color color;
  
  RipplePainter({
    required this.center,
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity((1 - progress) * 0.3)
      ..style = PaintingStyle.fill;
    
    final maxRadius = (size.width > size.height ? size.width : size.height) * 0.7;
    final radius = maxRadius * progress;
    
    canvas.drawCircle(center, radius, paint);
  }
  
  @override
  bool shouldRepaint(RipplePainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}

/// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;
  
  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });
  
  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(_animationController);
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey.shade300;
    final highlightColor = widget.highlightColor ?? Colors.grey.shade100;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                0.0,
                0.5,
                1.0,
              ],
              transform: GradientRotation(_animation.value * 3.14159),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}