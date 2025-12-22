// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => $checkedCreate('ApiResponse', json, ($checkedConvert) {
  final val = ApiResponse<T>(
    status: $checkedConvert('status', (v) => v as String),
    message: $checkedConvert('message', (v) => v as String),
    data: $checkedConvert(
      'data',
      (v) => _$nullableGenericFromJson(v, fromJsonT),
    ),
    errors: $checkedConvert('errors', (v) => v as Map<String, dynamic>?),
  );
  return val;
});

Map<String, dynamic> _$ApiResponseToJson<T>(
  ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'status': instance.status,
  'message': instance.message,
  'data': ?_$nullableGenericToJson(instance.data, toJsonT),
  'errors': ?instance.errors,
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => $checkedCreate(
  'PaginatedResponse',
  json,
  ($checkedConvert) {
    final val = PaginatedResponse<T>(
      data: $checkedConvert(
        'data',
        (v) => (v as List<dynamic>).map(fromJsonT).toList(),
      ),
      currentPage: $checkedConvert('current_page', (v) => (v as num).toInt()),
      lastPage: $checkedConvert('last_page', (v) => (v as num).toInt()),
      perPage: $checkedConvert('per_page', (v) => (v as num).toInt()),
      total: $checkedConvert('total', (v) => (v as num).toInt()),
    );
    return val;
  },
  fieldKeyMap: const {
    'currentPage': 'current_page',
    'lastPage': 'last_page',
    'perPage': 'per_page',
  },
);

Map<String, dynamic> _$PaginatedResponseToJson<T>(
  PaginatedResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'data': instance.data.map(toJsonT).toList(),
  'current_page': instance.currentPage,
  'last_page': instance.lastPage,
  'per_page': instance.perPage,
  'total': instance.total,
};
