// To parse this JSON data, do
//
//     final carExteriorResponse = carExteriorResponseFromJson(jsonString);

import 'dart:convert';

CarExteriorResponse carExteriorResponseFromJson(String str) =>
    CarExteriorResponse.fromJson(json.decode(str));

String carExteriorResponseToJson(CarExteriorResponse data) =>
    json.encode(data.toJson());

class CarExteriorResponse {
  String message;
  bool status; // change status to bool
  int statusCode;
  List<CarExteriorDatum> data;

  CarExteriorResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory CarExteriorResponse.fromJson(Map<String, dynamic> json) =>
      CarExteriorResponse(
        message: json["message"],
        status: json["status"],
        statusCode: json["status_code"],
        data: List<CarExteriorDatum>.from(
          json["data"].map((x) => CarExteriorDatum.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CarExteriorDatum {
  int id;
  String name;
  int? createdByUserId;
  int? carId;
  bool isAdmin;

  CarExteriorDatum({
    required this.id,
    required this.name,
    this.createdByUserId,
    this.carId,
    this.isAdmin = false,
  });

  factory CarExteriorDatum.fromJson(Map<String, dynamic> json) =>
      CarExteriorDatum(
        id: json["id"],
        name: json["name"],
        createdByUserId: _asNullableInt(
          json["created_by"] ??
              json["created_by_id"] ??
              json["user_id"] ??
              json["dealer_id"],
        ),
        carId: _asNullableInt(json["car_id"] ?? json["source_car_id"]),
        isAdmin:
            _asBool(json["is_admin"]) ||
            _asBool(json["admin_feature"]) ||
            _asBool(json["is_default"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "created_by": createdByUserId,
    "car_id": carId,
    "is_admin": isAdmin,
  };
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}
