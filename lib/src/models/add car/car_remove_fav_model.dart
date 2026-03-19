// To parse this JSON data, do
//
//     final removedFavoriteCarsResponse = removedFavoriteCarsResponseFromJson(jsonString);

import 'dart:convert';

RemovedFavoriteCarsResponse removedFavoriteCarsResponseFromJson(String str) =>
    RemovedFavoriteCarsResponse.fromJson(json.decode(str));

String removedFavoriteCarsResponseToJson(RemovedFavoriteCarsResponse data) =>
    json.encode(data.toJson());

class RemovedFavoriteCarsResponse {
  String message;
  bool status;
  int statusCode;
  List<dynamic> data;

  RemovedFavoriteCarsResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory RemovedFavoriteCarsResponse.fromJson(Map<String, dynamic> json) =>
      RemovedFavoriteCarsResponse(
        message: json["message"],
        status: json["status"],
        statusCode: json["status_code"],
        data: List<dynamic>.from(json["data"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x)),
  };
}
