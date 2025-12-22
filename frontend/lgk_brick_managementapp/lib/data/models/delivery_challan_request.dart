import 'package:json_annotation/json_annotation.dart';

part 'delivery_challan_request.g.dart';

@JsonSerializable()
class DeliveryChallanRequest {
  @JsonKey(name: 'requisition_id')
  final int requisitionId;
  @JsonKey(name: 'vehicle_number')
  final String vehicleNumber;
  @JsonKey(name: 'driver_name')
  final String? driverName;
  @JsonKey(name: 'vehicle_type')
  final String? vehicleType;
  final String location;
  final String? remarks;

  DeliveryChallanRequest({
    required this.requisitionId,
    required this.vehicleNumber,
    this.driverName,
    this.vehicleType,
    required this.location,
    this.remarks,
  });

  factory DeliveryChallanRequest.fromJson(Map<String, dynamic> json) =>
      _$DeliveryChallanRequestFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryChallanRequestToJson(this);
}