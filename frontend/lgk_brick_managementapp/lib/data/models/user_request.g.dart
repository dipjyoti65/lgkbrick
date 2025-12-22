// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateUserRequest _$CreateUserRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CreateUserRequest',
      json,
      ($checkedConvert) {
        final val = CreateUserRequest(
          name: $checkedConvert('name', (v) => v as String),
          email: $checkedConvert('email', (v) => v as String),
          password: $checkedConvert('password', (v) => v as String),
          passwordConfirmation: $checkedConvert(
            'password_confirmation',
            (v) => v as String,
          ),
          roleId: $checkedConvert('role_id', (v) => (v as num).toInt()),
          departmentId: $checkedConvert(
            'department_id',
            (v) => (v as num?)?.toInt(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'passwordConfirmation': 'password_confirmation',
        'roleId': 'role_id',
        'departmentId': 'department_id',
      },
    );

Map<String, dynamic> _$CreateUserRequestToJson(CreateUserRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'password_confirmation': instance.passwordConfirmation,
      'role_id': instance.roleId,
      'department_id': ?instance.departmentId,
    };

UpdateUserRequest _$UpdateUserRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'UpdateUserRequest',
      json,
      ($checkedConvert) {
        final val = UpdateUserRequest(
          name: $checkedConvert('name', (v) => v as String),
          email: $checkedConvert('email', (v) => v as String),
          roleId: $checkedConvert('role_id', (v) => (v as num).toInt()),
          departmentId: $checkedConvert(
            'department_id',
            (v) => (v as num?)?.toInt(),
          ),
          status: $checkedConvert('status', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {'roleId': 'role_id', 'departmentId': 'department_id'},
    );

Map<String, dynamic> _$UpdateUserRequestToJson(UpdateUserRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'role_id': instance.roleId,
      'department_id': ?instance.departmentId,
      'status': ?instance.status,
    };
