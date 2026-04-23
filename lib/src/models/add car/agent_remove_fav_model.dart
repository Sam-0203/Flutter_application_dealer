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
        message: _asString(json["message"]),
        status: _asBool(json["status"]),
        statusCode: _asInt(json["status_code"]),
        data: _asList(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x)),
  };
}

List<dynamic> _asList(dynamic value) => value is List ? value : const [];

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return fallback;
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}
