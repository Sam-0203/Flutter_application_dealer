// To parse this JSON data, do
//
//     final carModelsResponse = carModelsResponseFromJson(jsonString);

import 'dart:convert';

CarModelsResponse carModelsResponseFromJson(String str) =>
    CarModelsResponse.fromJson(json.decode(str));

String carModelsResponseToJson(CarModelsResponse data) =>
    json.encode(data.toJson());

class CarModelsResponse {
  String message;
  bool status;
  int statusCode;
  List<DatumCarModels> data;

  CarModelsResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory CarModelsResponse.fromJson(Map<String, dynamic> json) =>
      CarModelsResponse(
        message: json["message"],
        status: json["status"],
        statusCode: json["status_code"],
        data: List<DatumCarModels>.from(
          json["data"].map((x) => DatumCarModels.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class DatumCarModels {
  int id;
  int brandId;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  DatumCarModels({
    required this.id,
    required this.brandId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DatumCarModels.fromJson(Map<String, dynamic> json) => DatumCarModels(
    id: json["id"],
    brandId: json["brand_id"],
    name: json["name"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "brand_id": brandId,
    "name": name,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
