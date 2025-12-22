// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_challan_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeliveryChallanRequest _$DeliveryChallanRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'DeliveryChallanRequest',
  json,
  ($checkedConvert) {
    final val = DeliveryChallanRequest(
      requisitionId: $checkedConvert(
        'requisition_id',
        (v) => (v as num).toInt(),
      ),
      vehicleNumber: $checkedConvert('vehicle_number', (v) => v as String),
      driverName: $checkedConvert('driver_name', (v) => v as String?),
      vehicleType: $checkedConvert('vehicle_type', (v) => v as String?),
      location: $checkedConvert('location', (v) => v as String),
      remarks: $checkedConvert('remarks', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'requisitionId': 'requisition_id',
    'vehicleNumber': 'vehicle_number',
    'driverName': 'driver_name',
    'vehicleType': 'vehicle_type',
  },
);

Map<String, dynamic> _$DeliveryChallanRequestToJson(
  DeliveryChallanRequest instance,
) => <String, dynamic>{
  'requisition_id': instance.requisitionId,
  'vehicle_number': instance.vehicleNumber,
  'driver_name': ?instance.driverName,
  'vehicle_type': ?instance.vehicleType,
  'location': instance.location,
  'remarks': ?instance.remarks,
};
