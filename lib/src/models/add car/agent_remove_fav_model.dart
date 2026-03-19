// To parse this JSON data, do
//
//     final removeAgentFavoriteCarsResponse = removeAgentFavoriteCarsResponseFromJson(jsonString);

import 'dart:convert';

RemoveAgentFavoriteCarsResponse removeAgentFavoriteCarsResponseFromJson(
  String str,
) => RemoveAgentFavoriteCarsResponse.fromJson(json.decode(str));

String removeAgentFavoriteCarsResponseToJson(
  RemoveAgentFavoriteCarsResponse data,
) => json.encode(data.toJson());

class RemoveAgentFavoriteCarsResponse {
  String message;
  bool status;
  int statusCode;
  List<dynamic> data;

  RemoveAgentFavoriteCarsResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory RemoveAgentFavoriteCarsResponse.fromJson(Map<String, dynamic> json) =>
      RemoveAgentFavoriteCarsResponse(
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
