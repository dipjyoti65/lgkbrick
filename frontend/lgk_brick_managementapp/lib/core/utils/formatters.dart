import 'package:intl/intl.dart';

/// Formatting utilities for display
class Formatters {
  /// Format currency amount
  static String currency(double amount) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    return formatter.format(amount);
  }
  
  /// Format currency amount (alias for currency method)
  static String formatCurrency(double amount) {
    return currency(amount);
  }
  
  /// Format date
  static String date(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
  
  /// Format date and time
  static String dateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
  }
  
  /// Format phone number
  static String phone(String phone) {
    // Remove all non-numeric characters
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Format as (XXX) XXX-XXXX if 10 digits
    if (cleaned.length == 10) {
      return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}';
    }
    
    return phone;
  }
  
  /// Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  /// Format order number
  static String orderNumber(int number) {
    return 'ORD${number.toString().padLeft(6, '0')}';
  }
}
