// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_challan.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryChallan _$DeliveryChallanFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'DeliveryChallan',
  json,
  ($checkedConvert) {
    final val = DeliveryChallan(
      id: $checkedConvert('id', (v) => (v as num).toInt()),
      challanNumber: $checkedConvert('challan_number', (v) => v as String),
      requisitionId: $checkedConvert(
        'requisition_id',
        (v) => (v as num).toInt(),
      ),
      orderNumber: $checkedConvert('order_number', (v) => v as String),
      date: $checkedConvert('date', (v) => v as String),
      vehicleNumber: $checkedConvert('vehicle_number', (v) => v as String),
      driverName: $checkedConvert('driver_name', (v) => v as String?),
      vehicleType: $checkedConvert('vehicle_type', (v) => v as String?),
      location: $checkedConvert('location', (v) => v as String),
      remarks: $checkedConvert('remarks', (v) => v as String?),
      deliveryStatus: $checkedConvert('delivery_status', (v) => v as String?),
      deliveryDate: $checkedConvert('delivery_date', (v) => v as String?),
      printCount: $checkedConvert('print_count', (v) => (v as num?)?.toInt()),
      requisition: $checkedConvert(
        'requisition',
        (v) =>
            v == null ? null : Requisition.fromJson(v as Map<String, dynamic>),
      ),
      payment: $checkedConvert(
        'payment',
        (v) => v == null ? null : Payment.fromJson(v as Map<String, dynamic>),
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
    'challanNumber': 'challan_number',
    'requisitionId': 'requisition_id',
    'orderNumber': 'order_number',
    'vehicleNumber': 'vehicle_number',
    'driverName': 'driver_name',
    'vehicleType': 'vehicle_type',
    'deliveryStatus': 'delivery_status',
    'deliveryDate': 'delivery_date',
    'printCount': 'print_count',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$DeliveryChallanToJson(DeliveryChallan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'challan_number': instance.challanNumber,
      'requisition_id': instance.requisitionId,
      'order_number': instance.orderNumber,
      'date': instance.date,
      'vehicle_number': instance.vehicleNumber,
      'driver_name': ?instance.driverName,
      'vehicle_type': ?instance.vehicleType,
      'location': instance.location,
      'remarks': ?instance.remarks,
      'delivery_status': ?instance.deliveryStatus,
      'delivery_date': ?instance.deliveryDate,
      'print_count': ?instance.printCount,
      'requisition': ?instance.requisition?.toJson(),
      'payment': ?instance.payment?.toJson(),
      'created_at': ?instance.createdAt?.toIso8601String(),
      'updated_at': ?instance.updatedAt?.toIso8601String(),
    };
