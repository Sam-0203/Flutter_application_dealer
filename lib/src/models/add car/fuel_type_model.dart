// To parse this JSON data, do
//
//     final fuleTypeResponse = fuleTypeResponseFromJson(jsonString);

import 'dart:convert';

FuleTypeResponse fuleTypeResponseFromJson(String str) =>
    FuleTypeResponse.fromJson(json.decode(str));

String fuleTypeResponseToJson(FuleTypeResponse data) =>
    json.encode(data.toJson());

class FuleTypeResponse {
  String message;
  bool status;
  int statusCode;
  List<FuelTypeDatum> data;

  FuleTypeResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory FuleTypeResponse.fromJson(Map<String, dynamic> json) =>
      FuleTypeResponse(
        message: json["message"],
        status: json["status"],
        statusCode: json["status_code"],
        data: List<FuelTypeDatum>.from(
          json["data"].map((x) => FuelTypeDatum.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class FuelTypeDatum {
  int id;
  String name;
  String colorName;
  String colorCode;
  DateTime createdAt;
  DateTime updatedAt;

  FuelTypeDatum({
    required this.id,
    required this.name,
    required this.colorName,
    required this.colorCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FuelTypeDatum.fromJson(Map<String, dynamic> json) => FuelTypeDatum(
    id: json["id"],
    name: (json["name"] ?? '').toString(),
    colorName: (json["color_name"] ?? '').toString(),
    colorCode: (json["color_code"] ?? '').toString(),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  String get normalizedColorCode {
    final raw = colorCode.trim();
    if (raw.isEmpty) return '#E0E0E0';

    var value = raw;
    if (value.startsWith('0x') || value.startsWith('0X')) {
      value = value.substring(2);
    }
    if (!value.startsWith('#')) {
      value = '#$value';
    }

    if (value.length == 7 || value.length == 9) {
      return value.toUpperCase();
    }

    return '#E0E0E0';
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "color_name": colorName,
    "color_code": colorCode,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
