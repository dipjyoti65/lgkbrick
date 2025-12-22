// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requisition.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Requisition _$RequisitionFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Requisition',
  json,
  ($checkedConvert) {
    final val = Requisition(
      id: $checkedConvert('id', (v) => (v as num).toInt()),
      orderNumber: $checkedConvert('order_number', (v) => v as String),
      date: $checkedConvert('date', (v) => v as String),
      userId: $checkedConvert('user_id', (v) => (v as num).toInt()),
      brickTypeId: $checkedConvert('brick_type_id', (v) => (v as num).toInt()),
      quantity: $checkedConvert('quantity', (v) => v as String),
      pricePerUnit: $checkedConvert('price_per_unit', (v) => v as String),
      enteredPrice: $checkedConvert('entered_price', (v) => v as String?),
      totalAmount: $checkedConvert('total_amount', (v) => v as String),
      customerName: $checkedConvert('customer_name', (v) => v as String),
      customerPhone: $checkedConvert('customer_phone', (v) => v as String),
      customerAddress: $checkedConvert('customer_address', (v) => v as String),
      customerLocation: $checkedConvert(
        'customer_location',
        (v) => v as String?,
      ),
      status: $checkedConvert('status', (v) => v as String),
      user: $checkedConvert(
        'user',
        (v) => v == null ? null : User.fromJson(v as Map<String, dynamic>),
      ),
      brickType: $checkedConvert(
        'brick_type',
        (v) => v == null ? null : BrickType.fromJson(v as Map<String, dynamic>),
      ),
      createdAt: $checkedConvert(
        'created_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      updatedAt: $checkedConvert(
        'updated_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'orderNumber': 'order_number',
    'userId': 'user_id',
    'brickTypeId': 'brick_type_id',
    'pricePerUnit': 'price_per_unit',
    'enteredPrice': 'entered_price',
    'totalAmount': 'total_amount',
    'customerName': 'customer_name',
    'customerPhone': 'customer_phone',
    'customerAddress': 'customer_address',
    'customerLocation': 'customer_location',
    'brickType': 'brick_type',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$RequisitionToJson(Requisition instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_number': instance.orderNumber,
      'date': instance.date,
      'user_id': instance.userId,
      'brick_type_id': instance.brickTypeId,
      'quantity': instance.quantity,
      'price_per_unit': instance.pricePerUnit,
      'entered_price': ?instance.enteredPrice,
      'total_amount': instance.totalAmount,
      'customer_name': instance.customerName,
      'customer_phone': instance.customerPhone,
      'customer_address': instance.customerAddress,
      'customer_location': ?instance.customerLocation,
      'status': instance.status,
      'user': ?instance.user?.toJson(),
      'brick_type': ?instance.brickType?.toJson(),
      'created_at': ?instance.createdAt?.toIso8601String(),
      'updated_at': ?instance.updatedAt?.toIso8601String(),
    };
