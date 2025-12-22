// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brick_type_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrickTypeRequest _$BrickTypeRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('BrickTypeRequest', json, ($checkedConvert) {
      final val = BrickTypeRequest(
        name: $checkedConvert('name', (v) => v as String),
        description: $checkedConvert('description', (v) => v as String?),
        currentPrice: $checkedConvert('current_price', (v) => v as String?),
        unit: $checkedConvert('unit', (v) => v as String?),
        category: $checkedConvert('category', (v) => v as String?),
        status: $checkedConvert('status', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'currentPrice': 'current_price'});

Map<String, dynamic> _$BrickTypeRequestToJson(BrickTypeRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': ?instance.description,
      'current_price': ?instance.currentPrice,
      'unit': ?instance.unit,
      'category': ?instance.category,
      'status': ?instance.status,
    };
