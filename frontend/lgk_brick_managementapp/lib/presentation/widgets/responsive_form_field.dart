import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/responsive_utils.dart';

/// Responsive text form field that adapts to different screen sizes
/// 
/// Provides consistent styling and behavior across different device types
/// with appropriate keyboard types and input formatting.
class ResponsiveTextFormField extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final bool autofocus;
  final FocusNode? focusNode;
  final EdgeInsets? contentPadding;
  
  const ResponsiveTextFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.autofocus = false,
    this.focusNode,
    this.contentPadding,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsivePadding = contentPadding ?? EdgeInsets.symmetric(
      horizontal: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 16),
      vertical: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 12),
    );
    
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    return TextFormField(
      initialValue: initialValue,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      autofocus: autofocus,
      focusNode: focusNode,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16) *
            ResponsiveUtils.getFontSizeMultiplier(context),
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        prefixText: prefixText,
        suffixText: suffixText,
        contentPadding: responsivePadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// Responsive dropdown form field
class ResponsiveDropdownFormField<T> extends StatelessWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool isExpanded;
  final EdgeInsets? contentPadding;
  
  const ResponsiveDropdownFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.isExpanded = true,
    this.contentPadding,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsivePadding = contentPadding ?? EdgeInsets.symmetric(
      horizontal: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 16),
      vertical: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 12),
    );
    
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: isExpanded,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16) *
            ResponsiveUtils.getFontSizeMultiplier(context),
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        contentPadding: responsivePadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
      ),
    );
  }
}

/// Responsive button with adaptive sizing
class ResponsiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final bool isLoading;
  final String? loadingText;
  final ButtonType type;
  final bool fullWidth;
  
  const ResponsiveButton({
    super.key,
    required this.child,
    this.onPressed,
    this.style,
    this.isLoading = false,
    this.loadingText,
    this.type = ButtonType.elevated,
    this.fullWidth = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final buttonHeight = ResponsiveUtils.getResponsiveButtonHeight(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    final fontSize = 16 * ResponsiveUtils.getFontSizeMultiplier(context);
    
    final baseStyle = ButtonStyle(
      minimumSize: MaterialStateProperty.all(
        Size(fullWidth ? double.infinity : 120, buttonHeight),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      textStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    
    final mergedStyle = style != null ? baseStyle.merge(style) : baseStyle;
    
    Widget buttonChild = isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    type == ButtonType.elevated
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                  ),
                ),
              ),
              if (loadingText != null) ...[
                const SizedBox(width: 8),
                Text(loadingText!),
              ],
            ],
          )
        : child;
    
    Widget button;
    switch (type) {
      case ButtonType.elevated:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: mergedStyle,
          child: buttonChild,
        );
        break;
      case ButtonType.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: mergedStyle,
          child: buttonChild,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: mergedStyle,
          child: buttonChild,
        );
        break;
    }
    
    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }
}

/// Button type enumeration
enum ButtonType {
  elevated,
  outlined,
  text,
}

/// Responsive form section with title and spacing
class ResponsiveFormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsets? padding;
  final double? spacing;
  final Widget? titleWidget;
  final CrossAxisAlignment crossAxisAlignment;
  
  const ResponsiveFormSection({
    super.key,
    required this.title,
    required this.children,
    this.padding,
    this.spacing,
    this.titleWidget,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsiveSpacing = spacing ?? ResponsiveUtils.getResponsiveFormSpacing(context);
    final responsivePadding = padding ?? ResponsiveUtils.getResponsiveVerticalPadding(context);
    
    return Padding(
      padding: responsivePadding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          titleWidget ??
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: (Theme.of(context).textTheme.titleLarge?.fontSize ?? 20) *
                      ResponsiveUtils.getFontSizeMultiplier(context),
                ),
              ),
          SizedBox(height: responsiveSpacing),
          ...children.expand((child) => [
            child,
            SizedBox(height: responsiveSpacing),
          ]).take(children.length * 2 - 1),
        ],
      ),
    );
  }
}

/// Responsive card with adaptive elevation and spacing
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? color;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  
  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.onTap,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsivePadding = padding ?? ResponsiveUtils.getResponsivePadding(context);
    final responsiveMargin = margin ?? ResponsiveUtils.getResponsiveCardMargin(context);
    final responsiveElevation = elevation ?? ResponsiveUtils.getResponsiveCardElevation(context);
    final responsiveBorderRadius = borderRadius ??
        BorderRadius.circular(
          ResponsiveUtils.getResponsiveBorderRadius(context, baseRadius: 12),
        );
    
    return Card(
      elevation: responsiveElevation,
      margin: responsiveMargin,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: responsiveBorderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: responsiveBorderRadius,
        child: Padding(
          padding: responsivePadding,
          child: child,
        ),
      ),
    );
  }
}