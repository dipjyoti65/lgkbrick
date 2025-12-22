import 'package:json_annotation/json_annotation.dart';
import 'delivery_challan.dart';

part 'payment.g.dart';

@JsonSerializable()
class Payment {
  final int? id;
  @JsonKey(name: 'delivery_challan_id')
  final int deliveryChallanId;
  @JsonKey(name: 'payment_status')
  final String paymentStatus;
  @JsonKey(name: 'total_amount')
  final String totalAmount;
  @JsonKey(name: 'amount_received')
  final String amountReceived;
  @JsonKey(name: 'payment_date')
  final String? paymentDate;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'reference_number')
  final String? referenceNumber;
  final String? remarks;
  @JsonKey(name: 'approved_by')
  final int? approvedBy;
  @JsonKey(name: 'approved_at')
  final DateTime? approvedAt;
  @JsonKey(name: 'delivery_challan')
  final DeliveryChallan? deliveryChallan;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Payment({
    this.id,
    required this.deliveryChallanId,
    required this.paymentStatus,
    required this.totalAmount,
    required this.amountReceived,
    this.paymentDate,
    this.paymentMethod,
    this.referenceNumber,
    this.remarks,
    this.approvedBy,
    this.approvedAt,
    this.deliveryChallan,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentToJson(this);

  // Helper methods
  double get totalAmountAsDouble => double.tryParse(totalAmount) ?? 0.0;
  double get amountReceivedAsDouble => double.tryParse(amountReceived) ?? 0.0;
  
  double get remainingAmount =>
      totalAmountAsDouble - amountReceivedAsDouble;

  bool get isApproved => paymentStatus == 'approved';
  bool get isFullyPaid => amountReceivedAsDouble >= totalAmountAsDouble;
  bool get isPartial =>
      amountReceivedAsDouble > 0 && amountReceivedAsDouble < totalAmountAsDouble;
  bool get isPending => paymentStatus == 'pending';
}
