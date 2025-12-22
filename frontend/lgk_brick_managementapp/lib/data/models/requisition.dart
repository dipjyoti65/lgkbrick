import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'brick_type.dart';

part 'requisition.g.dart';

@JsonSerializable()
class Requisition {
  final int id;
  @JsonKey(name: 'order_number')
  final String orderNumber;
  final String date;
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'brick_type_id')
  final int brickTypeId;
  final String quantity;
  @JsonKey(name: 'price_per_unit')
  final String pricePerUnit;
  @JsonKey(name: 'entered_price')
  final String? enteredPrice;
  @JsonKey(name: 'total_amount')
  final String totalAmount;
  @JsonKey(name: 'customer_name')
  final String customerName;
  @JsonKey(name: 'customer_phone')
  final String customerPhone;
  @JsonKey(name: 'customer_address')
  final String customerAddress;
  @JsonKey(name: 'customer_location')
  final String? customerLocation;
  final String status;
  final User? user;
  @JsonKey(name: 'brick_type')
  final BrickType? brickType;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Requisition({
    required this.id,
    required this.orderNumber,
    required this.date,
    required this.userId,
    required this.brickTypeId,
    required this.quantity,
    required this.pricePerUnit,
    this.enteredPrice,
    required this.totalAmount,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    this.customerLocation,
    required this.status,
    this.user,
    this.brickType,
    this.createdAt,
    this.updatedAt,
  });

  factory Requisition.fromJson(Map<String, dynamic> json) =>
      _$RequisitionFromJson(json);
  Map<String, dynamic> toJson() => _$RequisitionToJson(this);

  // Helper methods
  double get quantityAsDouble => double.tryParse(quantity) ?? 0.0;
  double get pricePerUnitAsDouble => double.tryParse(pricePerUnit) ?? 0.0;
  double? get enteredPriceAsDouble => enteredPrice != null ? double.tryParse(enteredPrice!) : null;
  double get totalAmountAsDouble => double.tryParse(totalAmount) ?? 0.0;

  bool get isSubmitted => status == 'submitted';
  bool get isAssigned => status == 'assigned';
  bool get isDelivered => status == 'delivered';
  bool get isPaid => status == 'paid';
  bool get isComplete => status == 'complete';
  
  bool get canBeModified => status == 'submitted';
  bool get isImmutable => !canBeModified;
}
