// To parse this JSON data, do
//
//     final carNoOfOwnersResponse = carNoOfOwnersResponseFromJson(jsonString);

import 'dart:convert';

CarNoOfOwnersResponse carNoOfOwnersResponseFromJson(String str) =>
    CarNoOfOwnersResponse.fromJson(json.decode(str));

String carNoOfOwnersResponseToJson(CarNoOfOwnersResponse data) =>
    json.encode(data.toJson());

class CarNoOfOwnersResponse {
  String message;
  bool status;
  int statusCode;
  List<CarNoOfOwnersDatum> data;

  CarNoOfOwnersResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory CarNoOfOwnersResponse.fromJson(Map<String, dynamic> json) =>
      CarNoOfOwnersResponse(
        message: json["message"],
        status: json["status"],
        statusCode: json["status_code"],
        data: List<CarNoOfOwnersDatum>.from(
          json["data"].map((x) => CarNoOfOwnersDatum.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CarNoOfOwnersDatum {
  int id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  CarNoOfOwnersDatum({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarNoOfOwnersDatum.fromJson(Map<String, dynamic> json) =>
      CarNoOfOwnersDatum(
        id: json["id"],
        name: json["name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
