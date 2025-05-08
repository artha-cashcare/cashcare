// // lib/models/auth_model.dart
// import 'dart:convert';
//
// // Model for Login
// class LoginModel {
//   final String email;
//   final String password;
//
//   LoginModel({required this.email, required this.password});
//
//   factory LoginModel.fromJson(Map<String, dynamic> json) {
//     return LoginModel(email: json['email'], password: json['password']);
//   }
//
//   Map<String, dynamic> toJson() {
//     return {'email': email, 'password': password};
//   }
// }
//
// // Model for Registration
// class RegisterModel {
//   final String email;
//   final String password;
//   final String firstName;
//   final String lastName;
//   final String phoneNumber;
//
//   RegisterModel({
//     required this.email,
//     required this.password,
//     required this.firstName,
//     required this.lastName,
//     required this.phoneNumber,
//   });
//
//   factory RegisterModel.fromJson(Map<String, dynamic> json) {
//     return RegisterModel(
//       email: json['email'],
//       password: json['password'],
//       firstName: json['first_name'],
//       lastName: json['last_name'],
//       phoneNumber: json['phone_number'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'email': email,
//       'password': password,
//       'first_name': firstName,
//       'last_name': lastName,
//       'phone_number': phoneNumber,
//     };
//   }
// }
//
// // Model for Token Response (Access & Refresh Tokens)
// class TokenResponse {
//   final String accessToken;
//   final String refreshToken;
//   final String? userName;
//
//   TokenResponse({
//     required this.accessToken,
//     required this.refreshToken,
//     this.userName,
//   });
//
//   factory TokenResponse.fromJson(Map<String, dynamic> json) {
//     return TokenResponse(
//       accessToken: json['access'],
//       refreshToken: json['refresh'],
//       userName: json['user']?['first_name'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'access': accessToken,
//       'refresh': refreshToken,
//       'user': {'first_name': userName},
//     };
//   }
// }
//
// // Model for Password Reset Request
// class PasswordResetRequest {
//   final String email;
//
//   PasswordResetRequest({required this.email});
//
//   factory PasswordResetRequest.fromJson(Map<String, dynamic> json) {
//     return PasswordResetRequest(email: json['email']);
//   }
//
//   Map<String, dynamic> toJson() {
//     return {'email': email};
//   }
// }
