// To parse this JSON data, do
//
//     final agentPofileResponse = agentPofileResponseFromJson(jsonString);

import 'dart:convert';

AgentPofileResponse agentPofileResponseFromJson(String str) =>
    AgentPofileResponse.fromJson(json.decode(str));

String agentPofileResponseToJson(AgentPofileResponse data) =>
    json.encode(data.toJson());

class AgentPofileResponse {
  String message;
  bool status;
  int statusCode;
  Data data;

  AgentPofileResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory AgentPofileResponse.fromJson(Map<String, dynamic> json) =>
      AgentPofileResponse(
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
  String contactPerson;
  String mobile;
  String? email;
  bool isVerified;
  int stateId;
  int cityId;
  int preferredLanguageId;

  Data({
    required this.id,
    required this.contactPerson,
    required this.mobile,
    this.email,
    required this.isVerified,
    required this.stateId,
    required this.cityId,
    required this.preferredLanguageId,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    contactPerson: json["contact_person"],
    mobile: json["mobile"],
    email: json["email"],
    isVerified: json["is_verified"],
    stateId: json["state_id"],
    cityId: json["city_id"],
    preferredLanguageId: json["preferred_language_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "contact_person": contactPerson,
    "mobile": mobile,
    "email": email,
    "is_verified": isVerified,
    "state_id": stateId,
    "city_id": cityId,
    "preferred_language_id": preferredLanguageId,
  };
}
