import 'package:json_annotation/json_annotation.dart';

part 'payment_request.g.dart';

@JsonSerializable()
class PaymentRequest {
  @JsonKey(name: 'delivery_challan_id')
  final int deliveryChallanId;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  @JsonKey(name: 'amount_received')
  final double amountReceived;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'reference_number')
  final String? referenceNumber;
  final String? remarks;

  PaymentRequest({
    required this.deliveryChallanId,
    required this.totalAmount,
    required this.amountReceived,
    this.paymentMethod,
    this.referenceNumber,
    this.remarks,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentRequestToJson(this);
}

@JsonSerializable()
class PaymentApprovalRequest {
  @JsonKey(name: 'payment_status')
  final String paymentStatus;

  PaymentApprovalRequest({
    required this.paymentStatus,
  });

  factory PaymentApprovalRequest.fromJson(Map<String, dynamic> json) =>
      _$PaymentApprovalRequestFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentApprovalRequestToJson(this);
}
