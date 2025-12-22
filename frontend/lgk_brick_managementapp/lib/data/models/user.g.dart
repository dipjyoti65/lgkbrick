// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => $checkedCreate(
  'User',
  json,
  ($checkedConvert) {
    final val = User(
      id: $checkedConvert('id', (v) => (v as num).toInt()),
      name: $checkedConvert('name', (v) => v as String),
      email: $checkedConvert('email', (v) => v as String),
      roleId: $checkedConvert('role_id', (v) => (v as num).toInt()),
      departmentId: $checkedConvert(
        'department_id',
        (v) => (v as num?)?.toInt(),
      ),
      status: $checkedConvert('status', (v) => v as String),
      createdBy: $checkedConvert('created_by', (v) => (v as num?)?.toInt()),
      role: $checkedConvert(
        'role',
        (v) => v == null ? null : Role.fromJson(v as Map<String, dynamic>),
      ),
      department: $checkedConvert(
        'department',
        (v) =>
            v == null ? null : Department.fromJson(v as Map<String, dynamic>),
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
    'roleId': 'role_id',
    'departmentId': 'department_id',
    'createdBy': 'created_by',
    'createdAt': 'created_at',
    'updatedAt': 'updated_at',
  },
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'email': instance.email,
  'role_id': instance.roleId,
  'department_id': ?instance.departmentId,
  'status': instance.status,
  'created_by': ?instance.createdBy,
  'role': ?instance.role?.toJson(),
  'department': ?instance.department?.toJson(),
  'created_at': ?instance.createdAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
};
