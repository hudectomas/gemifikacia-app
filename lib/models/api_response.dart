import 'user.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: fromJsonT != null && json.containsKey('data') 
          ? fromJsonT(json['data']) 
          : null,
      message: json['message'] as String?,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
}

class LoginResponse {
  final bool success;
  final User? user;
  final String? token;
  final String? tokenType;
  final String? message;

  LoginResponse({
    required this.success,
    this.user,
    this.token,
    this.tokenType,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool,
      user: json['user'] != null 
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      token: json['token'] as String?,
      tokenType: json['token_type'] as String?,
      message: json['message'] as String?,
    );
  }
}

