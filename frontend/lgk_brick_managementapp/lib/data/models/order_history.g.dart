// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderHistory _$OrderHistoryFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'OrderHistory',
  json,
  ($checkedConvert) {
    final val = OrderHistory(
      id: $checkedConvert('id', (v) => (v as num).toInt()),
      orderNumber: $checkedConvert('order_number', (v) => v as String),
      customerName: $checkedConvert('customer_name', (v) => v as String),
      customerPhone: $checkedConvert('customer_phone', (v) => v as String),
      brickType: $checkedConvert('brick_type', (v) => v as String),
      quantity: $checkedConvert('quantity', (v) => v as String),
      totalAmount: $checkedConvert(
        'total_amount',
        (v) => _parseStringFromDynamic(v),
      ),
      orderDate: $checkedConvert('order_date', (v) => v as String),
      orderStatus: $checkedConvert('order_status', (v) => v as String),
      deliveryStatus: $checkedConvert('delivery_status', (v) => v as String),
      paymentStatus: $checkedConvert('payment_status', (v) => v as String),
      amountReceived: $checkedConvert(
        'amount_received',
        (v) => _parseStringFromDynamic(v),
      ),
      outstandingAmount: $checkedConvert(
        'outstanding_amount',
        (v) => _parseStringFromDynamic(v),
      ),
      salesExecutive: $checkedConvert('sales_executive', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'orderNumber': 'order_number',
    'customerName': 'customer_name',
    'customerPhone': 'customer_phone',
    'brickType': 'brick_type',
    'totalAmount': 'total_amount',
    'orderDate': 'order_date',
    'orderStatus': 'order_status',
    'deliveryStatus': 'delivery_status',
    'paymentStatus': 'payment_status',
    'amountReceived': 'amount_received',
    'outstandingAmount': 'outstanding_amount',
    'salesExecutive': 'sales_executive',
  },
);

Map<String, dynamic> _$OrderHistoryToJson(OrderHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_number': instance.orderNumber,
      'customer_name': instance.customerName,
      'customer_phone': instance.customerPhone,
      'brick_type': instance.brickType,
      'quantity': instance.quantity,
      'total_amount': instance.totalAmount,
      'order_date': instance.orderDate,
      'order_status': instance.orderStatus,
      'delivery_status': instance.deliveryStatus,
      'payment_status': instance.paymentStatus,
      'amount_received': instance.amountReceived,
      'outstanding_amount': instance.outstandingAmount,
      'sales_executive': instance.salesExecutive,
    };

OrderDetails _$OrderDetailsFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'OrderDetails',
      json,
      ($checkedConvert) {
        final val = OrderDetails(
          id: $checkedConvert('id', (v) => (v as num).toInt()),
          orderNumber: $checkedConvert('order_number', (v) => v as String),
          orderDate: $checkedConvert('order_date', (v) => v as String),
          status: $checkedConvert('status', (v) => v as String),
          customer: $checkedConvert(
            'customer',
            (v) => CustomerDetails.fromJson(v as Map<String, dynamic>),
          ),
          orderDetails: $checkedConvert(
            'order_details',
            (v) => OrderDetailsInfo.fromJson(v as Map<String, dynamic>),
          ),
          salesDetails: $checkedConvert(
            'sales_details',
            (v) => SalesDetails.fromJson(v as Map<String, dynamic>),
          ),
          logisticsDetails: $checkedConvert(
            'logistics_details',
            (v) => v == null
                ? null
                : LogisticsDetails.fromJson(v as Map<String, dynamic>),
          ),
          paymentDetails: $checkedConvert(
            'payment_details',
            (v) => v == null
                ? null
                : PaymentDetails.fromJson(v as Map<String, dynamic>),
          ),
          accountDetails: $checkedConvert(
            'account_details',
            (v) => v == null
                ? null
                : AccountDetails.fromJson(v as Map<String, dynamic>),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'orderNumber': 'order_number',
        'orderDate': 'order_date',
        'orderDetails': 'order_details',
        'salesDetails': 'sales_details',
        'logisticsDetails': 'logistics_details',
        'paymentDetails': 'payment_details',
        'accountDetails': 'account_details',
      },
    );

Map<String, dynamic> _$OrderDetailsToJson(OrderDetails instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_number': instance.orderNumber,
      'order_date': instance.orderDate,
      'status': instance.status,
      'customer': instance.customer.toJson(),
      'order_details': instance.orderDetails.toJson(),
      'sales_details': instance.salesDetails.toJson(),
      'logistics_details': ?instance.logisticsDetails?.toJson(),
      'payment_details': ?instance.paymentDetails?.toJson(),
      'account_details': ?instance.accountDetails?.toJson(),
    };

CustomerDetails _$CustomerDetailsFromJson(Map<String, dynamic> json) =>
    $checkedCreate('CustomerDetails', json, ($checkedConvert) {
      final val = CustomerDetails(
        name: $checkedConvert('name', (v) => v as String),
        phone: $checkedConvert('phone', (v) => v as String),
        address: $checkedConvert('address', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$CustomerDetailsToJson(CustomerDetails instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'address': instance.address,
    };

OrderDetailsInfo _$OrderDetailsInfoFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'OrderDetailsInfo',
      json,
      ($checkedConvert) {
        final val = OrderDetailsInfo(
          brickType: $checkedConvert(
            'brick_type',
            (v) => BrickTypeInfo.fromJson(v as Map<String, dynamic>),
          ),
          quantity: $checkedConvert('quantity', (v) => v as String),
          pricePerUnit: $checkedConvert('price_per_unit', (v) => v as String),
          totalAmount: $checkedConvert('total_amount', (v) => v as String),
          specialInstructions: $checkedConvert(
            'special_instructions',
            (v) => v as String?,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'brickType': 'brick_type',
        'pricePerUnit': 'price_per_unit',
        'totalAmount': 'total_amount',
        'specialInstructions': 'special_instructions',
      },
    );

Map<String, dynamic> _$OrderDetailsInfoToJson(OrderDetailsInfo instance) =>
    <String, dynamic>{
      'brick_type': instance.brickType.toJson(),
      'quantity': instance.quantity,
      'price_per_unit': instance.pricePerUnit,
      'total_amount': instance.totalAmount,
      'special_instructions': ?instance.specialInstructions,
    };

BrickTypeInfo _$BrickTypeInfoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BrickTypeInfo', json, ($checkedConvert) {
      final val = BrickTypeInfo(
        name: $checkedConvert('name', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String?),
        unit: $checkedConvert('unit', (v) => v as String?),
        category: $checkedConvert('category', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$BrickTypeInfoToJson(BrickTypeInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': ?instance.description,
      'unit': ?instance.unit,
      'category': ?instance.category,
    };

SalesDetails _$SalesDetailsFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'SalesDetails',
  json,
  ($checkedConvert) {
    final val = SalesDetails(
      executiveName: $checkedConvert('executive_name', (v) => v as String),
      executiveEmail: $checkedConvert('executive_email', (v) => v as String),
      executivePhone: $checkedConvert('executive_phone', (v) => v as String),
      department: $checkedConvert('department', (v) => v as String),
      role: $checkedConvert('role', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'executiveName': 'executive_name',
    'executiveEmail': 'executive_email',
    'executivePhone': 'executive_phone',
  },
);

Map<String, dynamic> _$SalesDetailsToJson(SalesDetails instance) =>
    <String, dynamic>{
      'executive_name': instance.executiveName,
      'executive_email': instance.executiveEmail,
      'executive_phone': instance.executivePhone,
      'department': instance.department,
      'role': instance.role,
    };

LogisticsDetails _$LogisticsDetailsFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'LogisticsDetails',
      json,
      ($checkedConvert) {
        final val = LogisticsDetails(
          challanNumber: $checkedConvert('challan_number', (v) => v as String),
          deliveryStatus: $checkedConvert(
            'delivery_status',
            (v) => v as String,
          ),
          deliveryDate: $checkedConvert('delivery_date', (v) => v as String?),
          deliveryTime: $checkedConvert('delivery_time', (v) => v as String?),
          driverName: $checkedConvert('driver_name', (v) => v as String?),
          vehicleNumber: $checkedConvert('vehicle_number', (v) => v as String?),
          vehicleType: $checkedConvert('vehicle_type', (v) => v as String?),
          remarks: $checkedConvert('remarks', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'challanNumber': 'challan_number',
        'deliveryStatus': 'delivery_status',
        'deliveryDate': 'delivery_date',
        'deliveryTime': 'delivery_time',
        'driverName': 'driver_name',
        'vehicleNumber': 'vehicle_number',
        'vehicleType': 'vehicle_type',
      },
    );

Map<String, dynamic> _$LogisticsDetailsToJson(LogisticsDetails instance) =>
    <String, dynamic>{
      'challan_number': instance.challanNumber,
      'delivery_status': instance.deliveryStatus,
      'delivery_date': ?instance.deliveryDate,
      'delivery_time': ?instance.deliveryTime,
      'driver_name': ?instance.driverName,
      'vehicle_number': ?instance.vehicleNumber,
      'vehicle_type': ?instance.vehicleType,
      'remarks': ?instance.remarks,
    };

PaymentDetails _$PaymentDetailsFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PaymentDetails',
  json,
  ($checkedConvert) {
    final val = PaymentDetails(
      paymentStatus: $checkedConvert('payment_status', (v) => v as String),
      totalAmount: $checkedConvert('total_amount', (v) => v as String),
      amountReceived: $checkedConvert('amount_received', (v) => v as String),
      remainingAmount: $checkedConvert('remaining_amount', (v) => v as String),
      paymentDate: $checkedConvert('payment_date', (v) => v as String?),
      paymentMethod: $checkedConvert('payment_method', (v) => v as String?),
      referenceNumber: $checkedConvert('reference_number', (v) => v as String?),
      remarks: $checkedConvert('remarks', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'paymentStatus': 'payment_status',
    'totalAmount': 'total_amount',
    'amountReceived': 'amount_received',
    'remainingAmount': 'remaining_amount',
    'paymentDate': 'payment_date',
    'paymentMethod': 'payment_method',
    'referenceNumber': 'reference_number',
  },
);

Map<String, dynamic> _$PaymentDetailsToJson(PaymentDetails instance) =>
    <String, dynamic>{
      'payment_status': instance.paymentStatus,
      'total_amount': instance.totalAmount,
      'amount_received': instance.amountReceived,
      'remaining_amount': instance.remainingAmount,
      'payment_date': ?instance.paymentDate,
      'payment_method': ?instance.paymentMethod,
      'reference_number': ?instance.referenceNumber,
      'remarks': ?instance.remarks,
    };

AccountDetails _$AccountDetailsFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'AccountDetails',
      json,
      ($checkedConvert) {
        final val = AccountDetails(
          approvedBy: $checkedConvert('approved_by', (v) => v as String),
          approvedByEmail: $checkedConvert(
            'approved_by_email',
            (v) => v as String,
          ),
          approvedAt: $checkedConvert('approved_at', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'approvedBy': 'approved_by',
        'approvedByEmail': 'approved_by_email',
        'approvedAt': 'approved_at',
      },
    );

Map<String, dynamic> _$AccountDetailsToJson(AccountDetails instance) =>
    <String, dynamic>{
      'approved_by': instance.approvedBy,
      'approved_by_email': instance.approvedByEmail,
      'approved_at': instance.approvedAt,
    };

OrderStatistics _$OrderStatisticsFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'OrderStatistics',
      json,
      ($checkedConvert) {
        final val = OrderStatistics(
          totalOrders: $checkedConvert(
            'total_orders',
            (v) => (v as num).toInt(),
          ),
          totalValue: $checkedConvert('total_value', (v) => v as String),
          pendingPayments: $checkedConvert(
            'pending_payments',
            (v) => (v as num).toInt(),
          ),
          partialPayments: $checkedConvert(
            'partial_payments',
            (v) => (v as num).toInt(),
          ),
          paidOrders: $checkedConvert('paid_orders', (v) => (v as num).toInt()),
          approvedOrders: $checkedConvert(
            'approved_orders',
            (v) => (v as num).toInt(),
          ),
          outstandingAmount: $checkedConvert(
            'outstanding_amount',
            (v) => v as String,
          ),
          totalReceived: $checkedConvert('total_received', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'totalOrders': 'total_orders',
        'totalValue': 'total_value',
        'pendingPayments': 'pending_payments',
        'partialPayments': 'partial_payments',
        'paidOrders': 'paid_orders',
        'approvedOrders': 'approved_orders',
        'outstandingAmount': 'outstanding_amount',
        'totalReceived': 'total_received',
      },
    );

Map<String, dynamic> _$OrderStatisticsToJson(OrderStatistics instance) =>
    <String, dynamic>{
      'total_orders': instance.totalOrders,
      'total_value': instance.totalValue,
      'pending_payments': instance.pendingPayments,
      'partial_payments': instance.partialPayments,
      'paid_orders': instance.paidOrders,
      'approved_orders': instance.approvedOrders,
      'outstanding_amount': instance.outstandingAmount,
      'total_received': instance.totalReceived,
    };
