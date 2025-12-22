import 'package:json_annotation/json_annotation.dart';
import 'requisition.dart';
import 'payment.dart';

part 'delivery_challan.g.dart';

@JsonSerializable()
class DeliveryChallan {
  final int id;
  @JsonKey(name: 'challan_number')
  final String challanNumber;
  @JsonKey(name: 'requisition_id')
  final int requisitionId;
  @JsonKey(name: 'order_number')
  final String orderNumber;
  final String date;
  @JsonKey(name: 'vehicle_number')
  final String vehicleNumber;
  @JsonKey(name: 'driver_name')
  final String? driverName;
  @JsonKey(name: 'vehicle_type')
  final String? vehicleType;
  final String location;
  final String? remarks;
  @JsonKey(name: 'delivery_status')
  final String? deliveryStatus;
  @JsonKey(name: 'delivery_date')
  final String? deliveryDate;
  @JsonKey(name: 'print_count')
  final int? printCount;
  final Requisition? requisition;
  final Payment? payment;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  DeliveryChallan({
    required this.id,
    required this.challanNumber,
    required this.requisitionId,
    required this.orderNumber,
    required this.date,
    required this.vehicleNumber,
    this.driverName,
    this.vehicleType,
    required this.location,
    this.remarks,
    this.deliveryStatus,
    this.deliveryDate,
    this.printCount,
    this.requisition,
    this.payment,
    this.createdAt,
    this.updatedAt,
  });

  factory DeliveryChallan.fromJson(Map<String, dynamic> json) =>
      _$DeliveryChallanFromJson(json);
  Map<String, dynamic> toJson() => _$DeliveryChallanToJson(this);

  // Helper methods
  bool get isPending => deliveryStatus == 'pending';
  bool get isAssigned => deliveryStatus == 'assigned';
  bool get isInTransit => deliveryStatus == 'in_transit';
  bool get isDelivered => deliveryStatus == 'delivered';
  bool get isFailed => deliveryStatus == 'failed';
  
  bool get hasBeenPrinted => (printCount ?? 0) > 0;
}