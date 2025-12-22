import 'package:json_annotation/json_annotation.dart';

part 'order_history.g.dart';

// Helper function to parse dynamic values as strings
String _parseStringFromDynamic(dynamic value) {
  if (value == null) return '0';
  return value.toString();
}

@JsonSerializable()
class OrderHistory {
  final int id;
  @JsonKey(name: 'order_number')
  final String orderNumber;
  @JsonKey(name: 'customer_name')
  final String customerName;
  @JsonKey(name: 'customer_phone')
  final String customerPhone;
  @JsonKey(name: 'brick_type')
  final String brickType;
  final String quantity;
  @JsonKey(name: 'total_amount', fromJson: _parseStringFromDynamic)
  final String totalAmount;
  @JsonKey(name: 'order_date')
  final String orderDate;
  @JsonKey(name: 'order_status')
  final String orderStatus;
  @JsonKey(name: 'delivery_status')
  final String deliveryStatus;
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  @JsonKey(name: 'amount_received', fromJson: _parseStringFromDynamic)
  final String amountReceived;
  @JsonKey(name: 'outstanding_amount', fromJson: _parseStringFromDynamic)
  final String outstandingAmount;
  @JsonKey(name: 'sales_executive')
  final String salesExecutive;

  OrderHistory({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.brickType,
    required this.quantity,
    required this.totalAmount,
    required this.orderDate,
    required this.orderStatus,
    required this.deliveryStatus,
    required this.paymentStatus,
    required this.amountReceived,
    required this.outstandingAmount,
    required this.salesExecutive,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) =>
      _$OrderHistoryFromJson(json);

  Map<String, dynamic> toJson() => _$OrderHistoryToJson(this);

  // Helper getters
  double get totalAmountValue => double.tryParse(totalAmount) ?? 0.0;
  double get amountReceivedValue => double.tryParse(amountReceived) ?? 0.0;
  double get outstandingAmountValue => double.tryParse(outstandingAmount) ?? 0.0;
  double get quantityValue => double.tryParse(quantity) ?? 0.0;
  int get quantityInt => quantityValue.toInt();

  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case 'pending':
        return 'Pending';
      case 'partial':
        return 'Partial';
      case 'paid':
        return 'Paid';
      case 'approved':
        return 'Approved';
      case 'overdue':
        return 'Overdue';
      case 'no_payment':
        return 'No Payment';
      default:
        return paymentStatus;
    }
  }

  String get deliveryStatusDisplay {
    switch (deliveryStatus) {
      case 'pending':
        return 'Pending';
      case 'delivered':
        return 'Delivered';
      case 'not_assigned':
        return 'Not Assigned';
      default:
        return deliveryStatus;
    }
  }
}

@JsonSerializable()
class OrderDetails {
  final int id;
  @JsonKey(name: 'order_number')
  final String orderNumber;
  @JsonKey(name: 'order_date')
  final String orderDate;
  final String status;
  final CustomerDetails customer;
  @JsonKey(name: 'order_details')
  final OrderDetailsInfo orderDetails;
  @JsonKey(name: 'sales_details')
  final SalesDetails salesDetails;
  @JsonKey(name: 'logistics_details')
  final LogisticsDetails? logisticsDetails;
  @JsonKey(name: 'payment_details')
  final PaymentDetails? paymentDetails;
  @JsonKey(name: 'account_details')
  final AccountDetails? accountDetails;

  OrderDetails({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.status,
    required this.customer,
    required this.orderDetails,
    required this.salesDetails,
    this.logisticsDetails,
    this.paymentDetails,
    this.accountDetails,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailsToJson(this);
}

@JsonSerializable()
class CustomerDetails {
  final String name;
  final String phone;
  final String address;

  CustomerDetails({
    required this.name,
    required this.phone,
    required this.address,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) =>
      _$CustomerDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerDetailsToJson(this);
}

@JsonSerializable()
class OrderDetailsInfo {
  @JsonKey(name: 'brick_type')
  final BrickTypeInfo brickType;
  final String quantity;
  @JsonKey(name: 'price_per_unit')
  final String pricePerUnit;
  @JsonKey(name: 'total_amount')
  final String totalAmount;
  @JsonKey(name: 'special_instructions')
  final String? specialInstructions;

  OrderDetailsInfo({
    required this.brickType,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalAmount,
    this.specialInstructions,
  });

  factory OrderDetailsInfo.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailsInfoFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailsInfoToJson(this);

  // Helper getters
  double get quantityValue => double.tryParse(quantity) ?? 0.0;
  int get quantityInt => quantityValue.toInt();
}

@JsonSerializable()
class BrickTypeInfo {
  final String name;
  final String? description;
  final String? unit;
  final String? category;

  BrickTypeInfo({
    required this.name,
    this.description,
    this.unit,
    this.category,
  });

  factory BrickTypeInfo.fromJson(Map<String, dynamic> json) =>
      _$BrickTypeInfoFromJson(json);

  Map<String, dynamic> toJson() => _$BrickTypeInfoToJson(this);
}

@JsonSerializable()
class SalesDetails {
  @JsonKey(name: 'executive_name')
  final String executiveName;
  @JsonKey(name: 'executive_email')
  final String executiveEmail;
  @JsonKey(name: 'executive_phone')
  final String executivePhone;
  final String department;
  final String role;

  SalesDetails({
    required this.executiveName,
    required this.executiveEmail,
    required this.executivePhone,
    required this.department,
    required this.role,
  });

  factory SalesDetails.fromJson(Map<String, dynamic> json) =>
      _$SalesDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$SalesDetailsToJson(this);
}

@JsonSerializable()
class LogisticsDetails {
  @JsonKey(name: 'challan_number')
  final String challanNumber;
  @JsonKey(name: 'delivery_status')
  final String deliveryStatus;
  @JsonKey(name: 'delivery_date')
  final String? deliveryDate;
  @JsonKey(name: 'delivery_time')
  final String? deliveryTime;
  @JsonKey(name: 'driver_name')
  final String? driverName;
  @JsonKey(name: 'vehicle_number')
  final String? vehicleNumber;
  @JsonKey(name: 'vehicle_type')
  final String? vehicleType;
  final String? remarks;

  LogisticsDetails({
    required this.challanNumber,
    required this.deliveryStatus,
    this.deliveryDate,
    this.deliveryTime,
    this.driverName,
    this.vehicleNumber,
    this.vehicleType,
    this.remarks,
  });

  factory LogisticsDetails.fromJson(Map<String, dynamic> json) =>
      _$LogisticsDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$LogisticsDetailsToJson(this);
}

@JsonSerializable()
class PaymentDetails {
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  @JsonKey(name: 'total_amount')
  final String totalAmount;
  @JsonKey(name: 'amount_received')
  final String amountReceived;
  @JsonKey(name: 'remaining_amount')
  final String remainingAmount;
  @JsonKey(name: 'payment_date')
  final String? paymentDate;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'reference_number')
  final String? referenceNumber;
  final String? remarks;

  PaymentDetails({
    required this.paymentStatus,
    required this.totalAmount,
    required this.amountReceived,
    required this.remainingAmount,
    this.paymentDate,
    this.paymentMethod,
    this.referenceNumber,
    this.remarks,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) =>
      _$PaymentDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentDetailsToJson(this);
}

@JsonSerializable()
class AccountDetails {
  @JsonKey(name: 'approved_by')
  final String approvedBy;
  @JsonKey(name: 'approved_by_email')
  final String approvedByEmail;
  @JsonKey(name: 'approved_at')
  final String approvedAt;

  AccountDetails({
    required this.approvedBy,
    required this.approvedByEmail,
    required this.approvedAt,
  });

  factory AccountDetails.fromJson(Map<String, dynamic> json) =>
      _$AccountDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$AccountDetailsToJson(this);
}

@JsonSerializable()
class OrderStatistics {
  @JsonKey(name: 'total_orders')
  final int totalOrders;
  @JsonKey(name: 'total_value')
  final String totalValue;
  @JsonKey(name: 'pending_payments')
  final int pendingPayments;
  @JsonKey(name: 'partial_payments')
  final int partialPayments;
  @JsonKey(name: 'paid_orders')
  final int paidOrders;
  @JsonKey(name: 'approved_orders')
  final int approvedOrders;
  @JsonKey(name: 'outstanding_amount')
  final String outstandingAmount;
  @JsonKey(name: 'total_received')
  final String totalReceived;

  OrderStatistics({
    required this.totalOrders,
    required this.totalValue,
    required this.pendingPayments,
    required this.partialPayments,
    required this.paidOrders,
    required this.approvedOrders,
    required this.outstandingAmount,
    required this.totalReceived,
  });

  factory OrderStatistics.fromJson(Map<String, dynamic> json) =>
      _$OrderStatisticsFromJson(json);

  Map<String, dynamic> toJson() => _$OrderStatisticsToJson(this);
}
