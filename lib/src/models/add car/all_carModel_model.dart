// To parse this JSON data, do
//
//     final allCarModelsListResponse = allCarModelsListResponseFromJson(jsonString);

import 'dart:convert';

AllCarModelsListResponse allCarModelsListResponseFromJson(String str) =>
    AllCarModelsListResponse.fromJson(json.decode(str));

String allCarModelsListResponseToJson(AllCarModelsListResponse data) =>
    json.encode(data.toJson());

class AllCarModelsListResponse {
  String message;
  bool status;
  int statusCode;
  List<CarModelsListDatum> data;

  AllCarModelsListResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory AllCarModelsListResponse.fromJson(Map<String, dynamic> json) =>
      AllCarModelsListResponse(
        message: json["message"],
        status: json["status"],
        statusCode: json["status_code"],
        data: List<CarModelsListDatum>.from(
          json["data"].map((x) => CarModelsListDatum.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CarModelsListDatum {
  int id;
  int brandId;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  CarModelsListDatum({
    required this.id,
    required this.brandId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarModelsListDatum.fromJson(Map<String, dynamic> json) =>
      CarModelsListDatum(
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
