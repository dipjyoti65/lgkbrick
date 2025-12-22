import 'package:json_annotation/json_annotation.dart';
import 'role.dart';
import 'department.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String name;
  final String email;
  @JsonKey(name: 'role_id')
  final int roleId;
  @JsonKey(name: 'department_id')
  final int? departmentId;
  final String status;
  @JsonKey(name: 'created_by')
  final int? createdBy;
  final Role? role;
  final Department? department;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    this.departmentId,
    required this.status,
    this.createdBy,
    this.role,
    this.department,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Helper methods
  bool get isActive => status == 'active';
  
  bool hasPermission(String permission) {
    return role?.permissions?.contains(permission) ?? false;
  }

  String get roleName => role?.name ?? '';
  String get departmentName => department?.name ?? '';
}
