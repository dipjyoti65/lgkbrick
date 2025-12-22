// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requisition_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequisitionRequest _$RequisitionRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'RequisitionRequest',
  json,
  ($checkedConvert) {
    final val = RequisitionRequest(
      brickTypeId: $checkedConvert('brick_type_id', (v) => (v as num).toInt()),
      quantity: $checkedConvert('quantity', (v) => v as String),
      pricePerUnit: $checkedConvert('price_per_unit', (v) => v as String),
      enteredPrice: $checkedConvert('entered_price', (v) => v as String),
      totalAmount: $checkedConvert('total_amount', (v) => v as String),
      customerName: $checkedConvert('customer_name', (v) => v as String),
      customerPhone: $checkedConvert('customer_phone', (v) => v as String),
      customerAddress: $checkedConvert('customer_address', (v) => v as String),
      customerLocation: $checkedConvert(
        'customer_location',
        (v) => v as String,
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'brickTypeId': 'brick_type_id',
    'pricePerUnit': 'price_per_unit',
    'enteredPrice': 'entered_price',
    'totalAmount': 'total_amount',
    'customerName': 'customer_name',
    'customerPhone': 'customer_phone',
    'customerAddress': 'customer_address',
    'customerLocation': 'customer_location',
  },
);

Map<String, dynamic> _$RequisitionRequestToJson(RequisitionRequest instance) =>
    <String, dynamic>{
      'brick_type_id': instance.brickTypeId,
      'quantity': instance.quantity,
      'price_per_unit': instance.pricePerUnit,
      'entered_price': instance.enteredPrice,
      'total_amount': instance.totalAmount,
      'customer_name': instance.customerName,
      'customer_phone': instance.customerPhone,
      'customer_address': instance.customerAddress,
      'customer_location': instance.customerLocation,
    };
