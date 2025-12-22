import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/responsive_utils.dart';

/// Enhanced text form field with improved UX features
/// 
/// Provides real-time validation, appropriate keyboard types,
/// and enhanced user interaction feedback.
class EnhancedTextFormField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
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
  final bool enableRealTimeValidation;
  final bool showCharacterCount;
  final String? successMessage;
  final Duration validationDelay;
  final bool enableSuggestions;
  final bool autocorrect;
  
  const EnhancedTextFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
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
    this.enableRealTimeValidation = true,
    this.showCharacterCount = false,
    this.successMessage,
    this.validationDelay = const Duration(milliseconds: 500),
    this.enableSuggestions = true,
    this.autocorrect = true,
  });
  
  @override
  State<EnhancedTextFormField> createState() => _EnhancedTextFormFieldState();
}

class _EnhancedTextFormFieldState extends State<EnhancedTextFormField> {
  late FocusNode _focusNode;
  String? _validationError;
  String? _currentValue;
  bool _isValidating = false;
  bool _hasBeenFocused = false;
  
  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _currentValue = widget.initialValue ?? widget.controller?.text ?? '';
    
    _focusNode.addListener(_onFocusChanged);
  }
  
  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChanged);
    }
    super.dispose();
  }
  
  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _hasBeenFocused = true;
    }
    setState(() {});
  }
  
  void _onChanged(String value) {
    setState(() {
      _currentValue = value;
      _isValidating = false;
    });
    
    widget.onChanged?.call(value);
    
    if (widget.enableRealTimeValidation && _hasBeenFocused && widget.validator != null) {
      _validateWithDelay(value);
    }
  }
  
  void _validateWithDelay(String value) {
    setState(() {
      _isValidating = true;
    });
    
    Future.delayed(widget.validationDelay, () {
      if (mounted && _currentValue == value) {
        final error = widget.validator?.call(value);
        setState(() {
          _validationError = error;
          _isValidating = false;
        });
      }
    });
  }
  
  String? _getDisplayError() {
    if (!_hasBeenFocused || _isValidating) {
      return null;
    }
    return _validationError;
  }
  
  Widget? _getSuffixIcon() {
    if (_isValidating) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    
    if (_hasBeenFocused && !_focusNode.hasFocus && _validationError == null && _currentValue?.isNotEmpty == true) {
      return Icon(
        Icons.check_circle,
        color: Colors.green.shade600,
        size: 20,
      );
    }
    
    return widget.suffixIcon;
  }
  
  String? _getHelperText() {
    if (widget.showCharacterCount && widget.maxLength != null) {
      final currentLength = _currentValue?.length ?? 0;
      final countText = '$currentLength/${widget.maxLength}';
      
      if (widget.helperText != null) {
        return '${widget.helperText} • $countText';
      }
      return countText;
    }
    
    if (_hasBeenFocused && !_focusNode.hasFocus && _validationError == null && widget.successMessage != null) {
      return widget.successMessage;
    }
    
    return widget.helperText;
  }
  
  @override
  Widget build(BuildContext context) {
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    return TextFormField(
      initialValue: widget.initialValue,
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: _onChanged,
      onSaved: widget.onSaved,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      autofocus: widget.autofocus,
      enableSuggestions: widget.enableSuggestions,
      autocorrect: widget.autocorrect,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16) *
            ResponsiveUtils.getFontSizeMultiplier(context),
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: _getHelperText(),
        errorText: _getDisplayError(),
        prefixIcon: widget.prefixIcon,
        suffixIcon: _getSuffixIcon(),
        prefixText: widget.prefixText,
        suffixText: widget.suffixText,
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 16),
          vertical: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 12),
        ),
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
        helperStyle: TextStyle(
          color: _hasBeenFocused && !_focusNode.hasFocus && _validationError == null && widget.successMessage != null
              ? Colors.green.shade600
              : null,
        ),
      ),
    );
  }
}

/// Enhanced dropdown with loading state and refresh capability
class EnhancedDropdownFormField<T> extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final bool enabled;
  final bool isExpanded;
  final bool isLoading;
  final VoidCallback? onRefresh;
  final String? emptyText;
  final bool enableRealTimeValidation;
  
  const EnhancedDropdownFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
    this.isExpanded = true,
    this.isLoading = false,
    this.onRefresh,
    this.emptyText,
    this.enableRealTimeValidation = true,
  });
  
  @override
  State<EnhancedDropdownFormField<T>> createState() => _EnhancedDropdownFormFieldState<T>();
}

class _EnhancedDropdownFormFieldState<T> extends State<EnhancedDropdownFormField<T>> {
  String? _validationError;
  bool _hasBeenTouched = false;
  
  void _onChanged(T? value) {
    setState(() {
      _hasBeenTouched = true;
    });
    
    widget.onChanged?.call(value);
    
    if (widget.enableRealTimeValidation && widget.validator != null) {
      setState(() {
        _validationError = widget.validator?.call(value);
      });
    }
  }
  
  Widget? _getSuffixIcon() {
    if (widget.isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    
    if (widget.onRefresh != null) {
      return IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: widget.enabled ? widget.onRefresh : null,
        tooltip: 'Refresh options',
      );
    }
    
    return null;
  }
  
  String? _getDisplayError() {
    if (!_hasBeenTouched) {
      return null;
    }
    return _validationError;
  }
  
  @override
  Widget build(BuildContext context) {
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    
    if (widget.items.isEmpty && !widget.isLoading) {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 16),
          vertical: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 12),
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Row(
          children: [
            if (widget.prefixIcon != null) ...[
              widget.prefixIcon!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                widget.emptyText ?? 'No options available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            if (widget.onRefresh != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: widget.onRefresh,
                tooltip: 'Refresh options',
              ),
          ],
        ),
      );
    }
    
    return DropdownButtonFormField<T>(
      value: widget.value,
      items: widget.items,
      onChanged: widget.enabled && !widget.isLoading ? _onChanged : null,
      validator: widget.validator,
      isExpanded: widget.isExpanded,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: (Theme.of(context).textTheme.bodyLarge?.fontSize ?? 16) *
            ResponsiveUtils.getFontSizeMultiplier(context),
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        errorText: _getDisplayError(),
        prefixIcon: widget.prefixIcon,
        suffixIcon: _getSuffixIcon(),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 16),
          vertical: ResponsiveUtils.getResponsiveSpacing(context, baseSpacing: 12),
        ),
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

/// Enhanced submit button with loading state and validation
class EnhancedSubmitButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isLoading;
  final String? loadingText;
  final bool fullWidth;
  final GlobalKey<FormState>? formKey;
  final bool validateBeforeSubmit;
  final Duration debounceDelay;
  final ButtonStyle? style;
  
  const EnhancedSubmitButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.loadingText,
    this.fullWidth = true,
    this.formKey,
    this.validateBeforeSubmit = true,
    this.debounceDelay = const Duration(milliseconds: 300),
    this.style,
  });
  
  @override
  State<EnhancedSubmitButton> createState() => _EnhancedSubmitButtonState();
}

class _EnhancedSubmitButtonState extends State<EnhancedSubmitButton> {
  bool _isDebouncing = false;
  
  void _handlePress() async {
    if (_isDebouncing || widget.isLoading) return;
    
    // Validate form if required
    if (widget.validateBeforeSubmit && widget.formKey != null) {
      if (!widget.formKey!.currentState!.validate()) {
        return;
      }
    }
    
    setState(() {
      _isDebouncing = true;
    });
    
    // Call the onPressed callback
    widget.onPressed?.call();
    
    // Debounce to prevent rapid taps
    await Future.delayed(widget.debounceDelay);
    
    if (mounted) {
      setState(() {
        _isDebouncing = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final buttonHeight = ResponsiveUtils.getResponsiveButtonHeight(context);
    final borderRadius = ResponsiveUtils.getResponsiveBorderRadius(context);
    final fontSize = 16 * ResponsiveUtils.getFontSizeMultiplier(context);
    
    final isDisabled = widget.isLoading || _isDebouncing || widget.onPressed == null;
    
    Widget buttonChild = widget.isLoading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              if (widget.loadingText != null) ...[
                const SizedBox(width: 8),
                Text(widget.loadingText!),
              ],
            ],
          )
        : widget.child;
    
    final button = ElevatedButton(
      onPressed: isDisabled ? null : _handlePress,
      style: (widget.style ?? ElevatedButton.styleFrom()).copyWith(
        minimumSize: MaterialStateProperty.all(
          Size(widget.fullWidth ? double.infinity : 120, buttonHeight),
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
      ),
      child: buttonChild,
    );
    
    if (widget.fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }
}