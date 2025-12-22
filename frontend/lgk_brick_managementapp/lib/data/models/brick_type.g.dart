// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brick_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrickType _$BrickTypeFromJson(Map<String, dynamic> json) => $checkedCreate(
  'BrickType',
  json,
  ($checkedConvert) {
    final val = BrickType(
      id: $checkedConvert('id', (v) => (v as num).toInt()),
      name: $checkedConvert('name', (v) => v as String),
      description: $checkedConvert('description', (v) => v as String?),
      currentPrice: $checkedConvert('current_price', (v) => v as String?),
      unit: $checkedConvert('unit', (v) => v as String?),
      category: $checkedConvert('category', (v) => v as String?),
      status: $checkedConvert('status', (v) => v as String),
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
    'currentPrice': 'current_price',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$BrickTypeToJson(BrickType instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': ?instance.description,
  'current_price': ?instance.currentPrice,
  'unit': ?instance.unit,
  'category': ?instance.category,
  'status': instance.status,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
};
