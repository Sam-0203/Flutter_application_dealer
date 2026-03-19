// To parse this JSON data, do
//
//     final favoriteCarsResponse = favoriteCarsResponseFromJson(jsonString);

import 'dart:convert';

FavoriteCarsResponse favoriteCarsResponseFromJson(String str) =>
    FavoriteCarsResponse.fromJson(json.decode(str));

String favoriteCarsResponseToJson(FavoriteCarsResponse data) =>
    json.encode(data.toJson());

class FavoriteCarsResponse {
  String message;
  bool status;
  int statusCode;
  Data data;

  FavoriteCarsResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory FavoriteCarsResponse.fromJson(Map<String, dynamic> json) =>
      FavoriteCarsResponse(
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
  int carId;
  DateTime createdAt;

  Data({required this.id, required this.carId, required this.createdAt});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    carId: json["car_id"],
    createdAt: DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "car_id": carId,
    "created_at": createdAt.toIso8601String(),
  };
}
