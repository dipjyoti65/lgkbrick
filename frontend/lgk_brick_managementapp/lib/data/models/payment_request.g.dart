// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentRequest _$PaymentRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PaymentRequest',
      json,
      ($checkedConvert) {
        final val = PaymentRequest(
          deliveryChallanId: $checkedConvert(
            'delivery_challan_id',
            (v) => (v as num).toInt(),
          ),
          totalAmount: $checkedConvert(
            'total_amount',
            (v) => (v as num).toDouble(),
          ),
          amountReceived: $checkedConvert(
            'amount_received',
            (v) => (v as num).toDouble(),
          ),
          paymentMethod: $checkedConvert('payment_method', (v) => v as String?),
          referenceNumber: $checkedConvert(
            'reference_number',
            (v) => v as String?,
          ),
          remarks: $checkedConvert('remarks', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'deliveryChallanId': 'delivery_challan_id',
        'totalAmount': 'total_amount',
        'amountReceived': 'amount_received',
        'paymentMethod': 'payment_method',
        'referenceNumber': 'reference_number',
      },
    );

Map<String, dynamic> _$PaymentRequestToJson(PaymentRequest instance) =>
    <String, dynamic>{
      'delivery_challan_id': instance.deliveryChallanId,
      'total_amount': instance.totalAmount,
      'amount_received': instance.amountReceived,
      'payment_method': ?instance.paymentMethod,
      'reference_number': ?instance.referenceNumber,
      'remarks': ?instance.remarks,
    };

PaymentApprovalRequest _$PaymentApprovalRequestFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'PaymentApprovalRequest',
  json,
  ($checkedConvert) {
    final val = PaymentApprovalRequest(
      paymentStatus: $checkedConvert('payment_status', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {'paymentStatus': 'payment_status'},
);

Map<String, dynamic> _$PaymentApprovalRequestToJson(
  PaymentApprovalRequest instance,
) => <String, dynamic>{'payment_status': instance.paymentStatus};
