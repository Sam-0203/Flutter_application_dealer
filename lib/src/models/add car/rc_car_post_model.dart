// To parse this JSON data, do
//
//     final rcUploadResponse = rcUploadResponseFromJson(jsonString);

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

RcUploadResponse rcUploadResponseFromJson(String str) =>
    RcUploadResponse.fromJson(json.decode(str));

String rcUploadResponseToJson(RcUploadResponse data) =>
    json.encode(data.toJson());

class RcUploadResponse {
  bool success;
  Data data;

  RcUploadResponse({required this.success, required this.data});

  factory RcUploadResponse.fromJson(Map<String, dynamic> json) =>
      RcUploadResponse(
        success: json["success"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data.toJson()};
}

class Data {
  final String registrationNumber; // Car registrationNumber
  final String makerModel; // Car Model
  final String maker; // Car company
  final String fuelType; // Fuel
  final String manufacturingYear; // Car manufacturingYear
  final DateTime registrationDate; // registrationDate
  final String ownerName; // Owner Name
  final String engineNumber; // Engine Number
  final String chassisNumber; // Chassis Number
  final String rto; // RTO
  final String vehicleClass; // VehicleClass
  final String color; // Vehicle Color
  final String variant; // Car variant
  final String kmRange; // kilometer driven
  final String carPrice; // kilometer driven
  final List<String> extraFeatures; // Features
  final List<File> images; // Car mages
  final String status; // Car status

  Data({
    required this.registrationNumber,
    required this.makerModel,
    required this.maker,
    required this.fuelType,
    required this.manufacturingYear,
    required this.registrationDate,
    required this.ownerName,
    required this.engineNumber,
    required this.chassisNumber,
    required this.rto,
    required this.vehicleClass,
    required this.color,
    required this.variant,
    required this.kmRange,
    required this.carPrice,
    this.extraFeatures = const [],
    this.images = const [],
    String status = "inactive",
  }) : status = _normalizeStatus(status);

  static String _normalizeStatus(String value) {
    final normalized = value.trim().toLowerCase();
    return normalized == 'active' ? 'active' : 'inactive';
  }

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    registrationNumber: json["registration_number"],
    makerModel: json["maker_model"],
    maker: json["maker"],
    fuelType: json["fuel_type"],
    manufacturingYear: json["manufacturing_year"],
    registrationDate: DateTime.parse(json["registration_date"]),
    ownerName: json["owner_name"],
    engineNumber: json["engine_number"],
    chassisNumber: json["chassis_number"],
    rto: json["rto"],
    vehicleClass: json["vehicle_class"],
    color: json["color"],
    variant: json["variant"],
    kmRange: json["kmRange"],
    carPrice: json["carPrice"],
    extraFeatures: json["extraFeatures"] != null
        ? List<String>.from(json["extraFeatures"])
        : const [],
    status: json["status"] ?? "inactive",
  );

  Map<String, dynamic> toJson() => {
    "registration_number": registrationNumber,
    "maker_model": makerModel,
    "maker": maker,
    "fuel_type": fuelType,
    "manufacturing_year": manufacturingYear,
    "registration_date":
        "${registrationDate.year.toString().padLeft(4, '0')}-${registrationDate.month.toString().padLeft(2, '0')}-${registrationDate.day.toString().padLeft(2, '0')}",
    "owner_name": ownerName,
    "engine_number": engineNumber,
    "chassis_number": chassisNumber,
    "rto": rto,
    "vehicle_class": vehicleClass,
    "color": color,
    "variant": variant,
    "kmRange": kmRange,
    "carPrice": carPrice,
    "extraFeatures": extraFeatures,
    "status": status,
  };

  http.MediaType _imageMediaType(String path) {
    final lowerPath = path.toLowerCase();

    if (lowerPath.endsWith('.png')) {
      return http.MediaType('image', 'png');
    }
    if (lowerPath.endsWith('.jpg') || lowerPath.endsWith('.jpeg')) {
      return http.MediaType('image', 'jpeg');
    }

    // Fallback keeps current behavior for unknown image extensions.
    return http.MediaType('image', 'jpeg');
  }
}
