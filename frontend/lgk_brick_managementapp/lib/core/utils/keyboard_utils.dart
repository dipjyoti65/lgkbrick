import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility class for keyboard types and input formatters
/// 
/// Provides appropriate keyboard types and input formatters
/// for different types of form fields.
class KeyboardUtils {
  /// Get keyboard type for email input
  static TextInputType get email => TextInputType.emailAddress;
  
  /// Get keyboard type for phone number input
  static TextInputType get phone => TextInputType.phone;
  
  /// Get keyboard type for numeric input
  static TextInputType get number => const TextInputType.numberWithOptions(decimal: false);
  
  /// Get keyboard type for decimal number input
  static TextInputType get decimal => const TextInputType.numberWithOptions(decimal: true);
  
  /// Get keyboard type for currency input
  static TextInputType get currency => const TextInputType.numberWithOptions(decimal: true, signed: false);
  
  /// Get keyboard type for URL input
  static TextInputType get url => TextInputType.url;
  
  /// Get keyboard type for multiline text
  static TextInputType get multiline => TextInputType.multiline;
  
  /// Get keyboard type for name input
  static TextInputType get name => TextInputType.name;
  
  /// Get keyboard type for address input
  static TextInputType get streetAddress => TextInputType.streetAddress;
  
  /// Get keyboard type for password input
  static TextInputType get visiblePassword => TextInputType.visiblePassword;
  
  /// Get text input action for next field
  static TextInputAction get next => TextInputAction.next;
  
  /// Get text input action for done
  static TextInputAction get done => TextInputAction.done;
  
  /// Get text input action for search
  static TextInputAction get search => TextInputAction.search;
  
  /// Get text input action for send
  static TextInputAction get send => TextInputAction.send;
  
  /// Get text input action for go
  static TextInputAction get go => TextInputAction.go;
  
  /// Get input formatter for phone numbers
  static List<TextInputFormatter> get phoneFormatter => [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
    LengthLimitingTextInputFormatter(20),
  ];
  
  /// Get input formatter for numeric input only
  static List<TextInputFormatter> get numericFormatter => [
    FilteringTextInputFormatter.digitsOnly,
  ];
  
  /// Get input formatter for decimal numbers
  static List<TextInputFormatter> get decimalFormatter => [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
  ];
  
  /// Get input formatter for currency (2 decimal places)
  static List<TextInputFormatter> get currencyFormatter => [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
  ];
  
  /// Get input formatter for email addresses
  static List<TextInputFormatter> get emailFormatter => [
    FilteringTextInputFormatter.deny(RegExp(r'\s')), // No spaces
    LengthLimitingTextInputFormatter(254), // RFC 5321 limit
  ];
  
  /// Get input formatter for names (letters, spaces, hyphens, apostrophes)
  static List<TextInputFormatter> get nameFormatter => [
    FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z\s\-']")),
    LengthLimitingTextInputFormatter(50),
  ];
  
  /// Get input formatter for alphanumeric input
  static List<TextInputFormatter> get alphanumericFormatter => [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
  ];
  
  /// Get input formatter for alphanumeric with spaces
  static List<TextInputFormatter> get alphanumericWithSpacesFormatter => [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
  ];
  
  /// Get input formatter for uppercase text
  static List<TextInputFormatter> get uppercaseFormatter => [
    UpperCaseTextFormatter(),
  ];
  
  /// Get input formatter for lowercase text
  static List<TextInputFormatter> get lowercaseFormatter => [
    LowerCaseTextFormatter(),
  ];
  
  /// Get input formatter for title case text
  static List<TextInputFormatter> get titleCaseFormatter => [
    TitleCaseTextFormatter(),
  ];
  
  /// Get input formatter for quantity (positive numbers with decimals)
  static List<TextInputFormatter> get quantityFormatter => [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
    _PositiveNumberFormatter(),
  ];
  
  /// Get input formatter for percentage (0-100 with decimals)
  static List<TextInputFormatter> get percentageFormatter => [
    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
    _PercentageFormatter(),
  ];
  
  /// Get input formatter for vehicle number
  static List<TextInputFormatter> get vehicleNumberFormatter => [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-\s]')),
    UpperCaseTextFormatter(),
    LengthLimitingTextInputFormatter(15),
  ];
  
  /// Get text capitalization for names
  static TextCapitalization get nameCapitalization => TextCapitalization.words;
  
  /// Get text capitalization for sentences
  static TextCapitalization get sentenceCapitalization => TextCapitalization.sentences;
  
  /// Get text capitalization for characters
  static TextCapitalization get characterCapitalization => TextCapitalization.characters;
  
  /// Get text capitalization for none
  static TextCapitalization get noCapitalization => TextCapitalization.none;
}

/// Custom formatter for uppercase text
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Custom formatter for lowercase text
class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}

/// Custom formatter for title case text
class TitleCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final words = newValue.text.split(' ');
    final titleCaseWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    });
    
    return TextEditingValue(
      text: titleCaseWords.join(' '),
      selection: newValue.selection,
    );
  }
}

/// Custom formatter for positive numbers
class _PositiveNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final number = double.tryParse(newValue.text);
    if (number == null || number < 0) {
      return oldValue;
    }
    
    return newValue;
  }
}

/// Custom formatter for percentage (0-100)
class _PercentageFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final number = double.tryParse(newValue.text);
    if (number == null || number < 0 || number > 100) {
      return oldValue;
    }
    
    return newValue;
  }
}

/// Phone number formatter with automatic formatting
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.length <= 3) {
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } else if (text.length <= 6) {
      final formatted = '${text.substring(0, 3)}-${text.substring(3)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else if (text.length <= 10) {
      final formatted = '${text.substring(0, 3)}-${text.substring(3, 6)}-${text.substring(6)}';
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } else {
      return oldValue;
    }
  }
}

/// Currency formatter with automatic decimal placement
class CurrencyFormatter extends TextInputFormatter {
  final int decimalPlaces;
  final String currencySymbol;
  
  CurrencyFormatter({
    this.decimalPlaces = 2,
    this.currencySymbol = '',
  });
  
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    // Remove non-digit characters except decimal point
    String text = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    
    // Ensure only one decimal point
    final parts = text.split('.');
    if (parts.length > 2) {
      text = '${parts[0]}.${parts.sublist(1).join('')}';
    }
    
    // Limit decimal places
    if (parts.length == 2 && parts[1].length > decimalPlaces) {
      text = '${parts[0]}.${parts[1].substring(0, decimalPlaces)}';
    }
    
    // Add currency symbol if provided
    final formattedText = currencySymbol.isNotEmpty ? '$currencySymbol$text' : text;
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Utility methods for form field configuration
class FormFieldConfig {
  /// Get configuration for email field
  static Map<String, dynamic> email() => {
    'keyboardType': KeyboardUtils.email,
    'textInputAction': KeyboardUtils.next,
    'inputFormatters': KeyboardUtils.emailFormatter,
    'textCapitalization': KeyboardUtils.noCapitalization,
    'enableSuggestions': true,
    'autocorrect': false,
  };
  
  /// Get configuration for password field
  static Map<String, dynamic> password() => {
    'keyboardType': KeyboardUtils.visiblePassword,
    'textInputAction': KeyboardUtils.done,
    'textCapitalization': KeyboardUtils.noCapitalization,
    'enableSuggestions': false,
    'autocorrect': false,
    'obscureText': true,
  };
  
  /// Get configuration for phone field
  static Map<String, dynamic> phone() => {
    'keyboardType': KeyboardUtils.phone,
    'textInputAction': KeyboardUtils.next,
    'inputFormatters': KeyboardUtils.phoneFormatter,
    'textCapitalization': KeyboardUtils.noCapitalization,
    'enableSuggestions': false,
    'autocorrect': false,
  };
  
  /// Get configuration for name field
  static Map<String, dynamic> name() => {
    'keyboardType': KeyboardUtils.name,
    'textInputAction': KeyboardUtils.next,
    'inputFormatters': KeyboardUtils.nameFormatter,
    'textCapitalization': KeyboardUtils.nameCapitalization,
    'enableSuggestions': true,
    'autocorrect': true,
  };
  
  /// Get configuration for address field
  static Map<String, dynamic> address() => {
    'keyboardType': KeyboardUtils.streetAddress,
    'textInputAction': KeyboardUtils.next,
    'textCapitalization': KeyboardUtils.sentenceCapitalization,
    'enableSuggestions': true,
    'autocorrect': true,
    'maxLines': 3,
  };
  
  /// Get configuration for quantity field
  static Map<String, dynamic> quantity() => {
    'keyboardType': KeyboardUtils.decimal,
    'textInputAction': KeyboardUtils.next,
    'inputFormatters': KeyboardUtils.quantityFormatter,
    'textCapitalization': KeyboardUtils.noCapitalization,
    'enableSuggestions': false,
    'autocorrect': false,
  };
  
  /// Get configuration for currency field
  static Map<String, dynamic> currency() => {
    'keyboardType': KeyboardUtils.currency,
    'textInputAction': KeyboardUtils.next,
    'inputFormatters': KeyboardUtils.currencyFormatter,
    'textCapitalization': KeyboardUtils.noCapitalization,
    'enableSuggestions': false,
    'autocorrect': false,
  };
  
  /// Get configuration for vehicle number field
  static Map<String, dynamic> vehicleNumber() => {
    'keyboardType': TextInputType.text,
    'textInputAction': KeyboardUtils.next,
    'inputFormatters': KeyboardUtils.vehicleNumberFormatter,
    'textCapitalization': KeyboardUtils.characterCapitalization,
    'enableSuggestions': false,
    'autocorrect': false,
  };
}