// To parse this JSON data, do
//
//     final citiesList = citiesListFromJson(jsonString);

import 'dart:convert';

CitiesList citiesListFromJson(String str) =>
    CitiesList.fromJson(json.decode(str));

String citiesListToJson(CitiesList data) => json.encode(data.toJson());

class CitiesList {
  String message;
  bool status;
  int statusCode;
  List<CitiesDatum> data;

  CitiesList({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory CitiesList.fromJson(Map<String, dynamic> json) => CitiesList(
    message: json["message"],
    status: json["status"],
    statusCode: json["status_code"],
    data: List<CitiesDatum>.from(
      json["data"].map((x) => CitiesDatum.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CitiesDatum {
  int id;
  String name;
  int stateId;
  DateTime createdAt;
  dynamic updatedAt;

  CitiesDatum({
    required this.id,
    required this.name,
    required this.stateId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CitiesDatum.fromJson(Map<String, dynamic> json) => CitiesDatum(
    id: json["id"],
    name: json["name"],
    stateId: json["state_id"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "state_id": stateId,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt,
  };
}
