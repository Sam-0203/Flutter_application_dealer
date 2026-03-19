// To parse this JSON data, do
//
//     final userVerifyResponse = userVerifyResponseFromJson(jsonString);

import 'dart:convert';

UserVerifyResponse userVerifyResponseFromJson(String str) =>
    UserVerifyResponse.fromJson(json.decode(str));

String userVerifyResponseToJson(UserVerifyResponse data) =>
    json.encode(data.toJson());

class UserVerifyResponse {
  String message;
  bool status; // change status
  int statusCode;
  Data data;

  UserVerifyResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory UserVerifyResponse.fromJson(Map<String, dynamic> json) =>
      UserVerifyResponse(
        message: json["message"],
        status: json["status"] as bool,
        statusCode: json["status_code"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": data.toJson(),
  };
}

class Data {
  int id;
  String mobile;
  String role;
  String accessToken;

  Data({
    required this.id,
    required this.mobile,
    required this.role,
    required this.accessToken,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    mobile: json["mobile"],
    role: json["role"],
    accessToken: json["access_token"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "mobile": mobile,
    "role": role,
    "access_token": accessToken,
  };
}
