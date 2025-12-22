import 'package:json_annotation/json_annotation.dart';

part 'requisition_request.g.dart';

@JsonSerializable()
class RequisitionRequest {
  @JsonKey(name: 'brick_type_id')
  final int brickTypeId;
  final String quantity;
  @JsonKey(name: 'price_per_unit')
  final String pricePerUnit;
  @JsonKey(name: 'entered_price')
  final String enteredPrice;
  @JsonKey(name: 'total_amount')
  final String totalAmount;
  @JsonKey(name: 'customer_name')
  final String customerName;
  @JsonKey(name: 'customer_phone')
  final String customerPhone;
  @JsonKey(name: 'customer_address')
  final String customerAddress;
  @JsonKey(name: 'customer_location')
  final String customerLocation;

  RequisitionRequest({
    required this.brickTypeId,
    required this.quantity,
    required this.pricePerUnit,
    required this.enteredPrice,
    required this.totalAmount,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.customerLocation,
  });

  factory RequisitionRequest.fromJson(Map<String, dynamic> json) =>
      _$RequisitionRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RequisitionRequestToJson(this);
}
