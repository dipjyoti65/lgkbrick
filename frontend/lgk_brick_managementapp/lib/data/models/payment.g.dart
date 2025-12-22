// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payment _$PaymentFromJson(Map<String, dynamic> json) => $checkedCreate(
  'Payment',
  json,
  ($checkedConvert) {
    final val = Payment(
      id: $checkedConvert('id', (v) => (v as num?)?.toInt()),
      deliveryChallanId: $checkedConvert(
        'delivery_challan_id',
        (v) => (v as num).toInt(),
      ),
      paymentStatus: $checkedConvert('payment_status', (v) => v as String),
      totalAmount: $checkedConvert('total_amount', (v) => v as String),
      amountReceived: $checkedConvert('amount_received', (v) => v as String),
      paymentDate: $checkedConvert('payment_date', (v) => v as String?),
      paymentMethod: $checkedConvert('payment_method', (v) => v as String?),
      referenceNumber: $checkedConvert('reference_number', (v) => v as String?),
      remarks: $checkedConvert('remarks', (v) => v as String?),
      approvedBy: $checkedConvert('approved_by', (v) => (v as num?)?.toInt()),
      approvedAt: $checkedConvert(
        'approved_at',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      deliveryChallan: $checkedConvert(
        'delivery_challan',
        (v) => v == null
            ? null
            : DeliveryChallan.fromJson(v as Map<String, dynamic>),
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
    'deliveryChallanId': 'delivery_challan_id',
    'paymentStatus': 'payment_status',
    'totalAmount': 'total_amount',
    'amountReceived': 'amount_received',
    'paymentDate': 'payment_date',
    'paymentMethod': 'payment_method',
    'referenceNumber': 'reference_number',
    'approvedBy': 'approved_by',
    'approvedAt': 'approved_at',
    'deliveryChallan': 'delivery_challan',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$PaymentToJson(Payment instance) => <String, dynamic>{
  'id': ?instance.id,
  'delivery_challan_id': instance.deliveryChallanId,
  'payment_status': instance.paymentStatus,
  'total_amount': instance.totalAmount,
  'amount_received': instance.amountReceived,
  'payment_date': ?instance.paymentDate,
  'payment_method': ?instance.paymentMethod,
  'reference_number': ?instance.referenceNumber,
  'remarks': ?instance.remarks,
  'approved_by': ?instance.approvedBy,
  'approved_at': ?instance.approvedAt?.toIso8601String(),
  'delivery_challan': ?instance.deliveryChallan?.toJson(),
  'created_at': ?instance.createdAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
};
