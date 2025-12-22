import 'package:json_annotation/json_annotation.dart';

part 'user_request.g.dart';

@JsonSerializable()
class CreateUserRequest {
  final String name;
  final String email;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;
  @JsonKey(name: 'role_id')
  final int roleId;
  @JsonKey(name: 'department_id')
  final int? departmentId;

  CreateUserRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
    required this.roleId,
    this.departmentId,
  });

  factory CreateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateUserRequestToJson(this);
}

@JsonSerializable()
class UpdateUserRequest {
  final String name;
  final String email;
  @JsonKey(name: 'role_id')
  final int roleId;
  @JsonKey(name: 'department_id')
  final int? departmentId;
  final String? status;

  UpdateUserRequest({
    required this.name,
    required this.email,
    required this.roleId,
    this.departmentId,
    this.status,
  });

  factory UpdateUserRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateUserRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateUserRequestToJson(this);
}
