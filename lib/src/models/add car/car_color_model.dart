// To parse this JSON data, do
//
//     final carColorsResponse = carColorsResponseFromJson(jsonString);
import 'dart:convert';

import 'package:flutter/material.dart';

CarColorsResponse carColorsResponseFromJson(String str) =>
    CarColorsResponse.fromJson(json.decode(str));

String carColorsResponseToJson(CarColorsResponse data) =>
    json.encode(data.toJson());

extension HexColor on String {
  Color toColor() {
    final hex = replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}

class CarColorsResponse {
  String message;
  bool status;
  int statusCode;
  List<CarColorDatum> data;

  CarColorsResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory CarColorsResponse.fromJson(Map<String, dynamic> json) =>
      CarColorsResponse(
        message: json["message"],
        status: json["status"],
        statusCode: json["status_code"],
        data: List<CarColorDatum>.from(
          json["data"].map((x) => CarColorDatum.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CarColorDatum {
  int id;
  String name;
  String? colorCode;
  int? variantId;
  DateTime createdAt;
  DateTime updatedAt;

  CarColorDatum({
    required this.id,
    required this.name,
    required this.colorCode,
    required this.variantId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ✅ SAFE COLOR FOR UI
  Color get uiColor {
    if (colorCode == null || colorCode!.isEmpty) {
      return Colors.grey.shade400; // fallback color
    }
    return HexColor(colorCode!).toColor();
  }

  factory CarColorDatum.fromJson(Map<String, dynamic> json) => CarColorDatum(
    id: json["id"],
    name: json["name"],
    colorCode: json["color_code"],
    variantId: json["variant_id"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "color_code": colorCode,
    "variant_id": variantId,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
