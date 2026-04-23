// To parse this JSON data, do
//
//     final dealerPofileResponse = dealerPofileResponseFromJson(jsonString);

import 'dart:convert';

DealerPofileResponse dealerPofileResponseFromJson(String str) =>
    DealerPofileResponse.fromJson(json.decode(str));

String dealerPofileResponseToJson(DealerPofileResponse data) =>
    json.encode(data.toJson());

class DealerPofileResponse {
  String message;
  bool status;
  int statusCode;
  Data data;

  DealerPofileResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory DealerPofileResponse.fromJson(Map<String, dynamic> json) =>
      DealerPofileResponse(
        message: json["message"],
        status: json["status"],
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
  String dealershipName;
  String mobile;
  String? email;
  bool isVerified;
  int stateId;
  int cityId;
  int preferredLanguageId;

  Data({
    required this.id,
    required this.dealershipName,
    required this.mobile,
    this.email,
    required this.isVerified,
    required this.stateId,
    required this.cityId,
    required this.preferredLanguageId,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    dealershipName: json["dealership_name"],
    mobile: json["mobile"],
    email: json["email"],
    isVerified: json["is_verified"],
    stateId: json["state_id"],
    cityId: json["city_id"],
    preferredLanguageId: json["preferred_language_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "dealership_name": dealershipName,
    "mobile": mobile,
    "email": email,
    "is_verified": isVerified,
    "state_id": stateId,
    "city_id": cityId,
    "preferred_language_id": preferredLanguageId,
  };
}
