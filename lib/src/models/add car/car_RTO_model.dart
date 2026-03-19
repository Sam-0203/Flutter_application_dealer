// To parse this JSON data, do
//
//     final carRtOsResponse = carRtOsResponseFromJson(jsonString);

import 'dart:convert';

CarRtOsResponse carRtOsResponseFromJson(String str) =>
    CarRtOsResponse.fromJson(json.decode(str));

String carRtOsResponseToJson(CarRtOsResponse data) =>
    json.encode(data.toJson());

class CarRtOsResponse {
  String message;
  bool status;
  int statusCode;
  List<CarRTOsDatum> data;

  CarRtOsResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory CarRtOsResponse.fromJson(Map<String, dynamic> json) =>
      CarRtOsResponse(
        message: json["message"],
        status: json["status"],
        statusCode: json["status_code"],
        data: List<CarRTOsDatum>.from(
          json["data"].map((x) => CarRTOsDatum.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CarRTOsDatum {
  int id;
  String code;
  DateTime createdAt;
  DateTime updatedAt;

  CarRTOsDatum({
    required this.id,
    required this.code,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarRTOsDatum.fromJson(Map<String, dynamic> json) => CarRTOsDatum(
    id: json["id"],
    code: json["code"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
