// To parse this JSON data, do
//
//     final carVarietsTypeResponse = carVarietsTypeResponseFromJson(jsonString);

import 'dart:convert';

CarVarietsTypeResponse carVarietsTypeResponseFromJson(String str) =>
    CarVarietsTypeResponse.fromJson(json.decode(str));

String carVarietsTypeResponseToJson(CarVarietsTypeResponse data) =>
    json.encode(data.toJson());

class CarVarietsTypeResponse {
  String message;
  bool status;
  int statusCode;
  List<CarModelVarientsDatum> data;

  CarVarietsTypeResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory CarVarietsTypeResponse.fromJson(Map<String, dynamic> json) =>
      CarVarietsTypeResponse(
        message: json["message"],
        status: json["status"],
        statusCode: json["status_code"],
        data: List<CarModelVarientsDatum>.from(
          json["data"].map((x) => CarModelVarientsDatum.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CarModelVarientsDatum {
  int id;
  int modelId;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  CarModelVarientsDatum({
    required this.id,
    required this.modelId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarModelVarientsDatum.fromJson(Map<String, dynamic> json) =>
      CarModelVarientsDatum(
        id: json["id"],
        modelId: json["model_id"],
        name: json["name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "model_id": modelId,
    "name": name,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
