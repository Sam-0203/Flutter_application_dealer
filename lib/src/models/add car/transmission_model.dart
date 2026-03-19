// To parse this JSON data, do
//
//     final carTrasmissionTypeResponse = carTrasmissionTypeResponseFromJson(jsonString);

import 'dart:convert';

CarTrasmissionTypeResponse carTrasmissionTypeResponseFromJson(String str) =>
    CarTrasmissionTypeResponse.fromJson(json.decode(str));

String carTrasmissionTypeResponseToJson(CarTrasmissionTypeResponse data) =>
    json.encode(data.toJson());

class CarTrasmissionTypeResponse {
  String message;
  bool status;
  int statusCode;
  List<CarTransmissionDatum> data;

  CarTrasmissionTypeResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory CarTrasmissionTypeResponse.fromJson(Map<String, dynamic> json) =>
      CarTrasmissionTypeResponse(
        message: json["message"],
        status: json["status"],
        statusCode: json["status_code"],
        data: List<CarTransmissionDatum>.from(
          json["data"].map((x) => CarTransmissionDatum.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CarTransmissionDatum {
  int id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;

  CarTransmissionDatum({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarTransmissionDatum.fromJson(Map<String, dynamic> json) =>
      CarTransmissionDatum(
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
