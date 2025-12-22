// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LoginRequest', json, ($checkedConvert) {
      final val = LoginRequest(
        email: $checkedConvert('email', (v) => v as String),
        password: $checkedConvert('password', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LoginResponse', json, ($checkedConvert) {
      final val = LoginResponse(
        user: $checkedConvert(
          'user',
          (v) => User.fromJson(v as Map<String, dynamic>),
        ),
        token: $checkedConvert('token', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{'user': instance.user.toJson(), 'token': instance.token};

AuthState _$AuthStateFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AuthState', json, ($checkedConvert) {
      final val = AuthState(
        currentUser: $checkedConvert(
          'currentUser',
          (v) => v == null ? null : User.fromJson(v as Map<String, dynamic>),
        ),
        isAuthenticated: $checkedConvert('isAuthenticated', (v) => v as bool),
        isLoading: $checkedConvert('isLoading', (v) => v as bool),
        error: $checkedConvert('error', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$AuthStateToJson(AuthState instance) => <String, dynamic>{
  'currentUser': ?instance.currentUser?.toJson(),
  'isAuthenticated': instance.isAuthenticated,
  'isLoading': instance.isLoading,
  'error': ?instance.error,
};
