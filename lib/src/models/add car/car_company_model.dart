// To parse this JSON data, do
//
//     final carCompaniesResponse = carCompaniesResponseFromJson(jsonString);

import 'dart:convert';

CarCompaniesResponse carCompaniesResponseFromJson(String str) =>
    CarCompaniesResponse.fromJson(json.decode(str));

String carCompaniesResponseToJson(CarCompaniesResponse data) =>
    json.encode(data.toJson());

class CarCompaniesResponse {
  String message;
  bool status; // change status to bool
  int statusCode;
  List<DatumCarCompanies> data;

  CarCompaniesResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory CarCompaniesResponse.fromJson(Map<String, dynamic> json) =>
      CarCompaniesResponse(
        message: json["message"],
        status: json["status"],
        statusCode: json["status_code"],
        data: List<DatumCarCompanies>.from(
          json["data"].map((x) => DatumCarCompanies.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class DatumCarCompanies {
  int id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  DatumCarCompanies({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DatumCarCompanies.fromJson(Map<String, dynamic> json) =>
      DatumCarCompanies(
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
