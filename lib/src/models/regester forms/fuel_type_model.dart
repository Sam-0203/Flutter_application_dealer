import 'dart:convert';

FuelTypes fuelTypesFromJson(String str) => FuelTypes.fromJson(json.decode(str));

String fuelTypesToJson(FuelTypes data) => json.encode(data.toJson());

class FuelTypes {
  String message;
  bool status;
  int statusCode;
  List<FuelTypeDatum> data;

  FuelTypes({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory FuelTypes.fromJson(Map<String, dynamic> json) => FuelTypes(
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
  String? color; // Color as hex string from API, e.g., "#007BFF"
  DateTime createdAt;
  DateTime? updatedAt;

  FuelTypeDatum({
    required this.id,
    required this.name,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FuelTypeDatum.fromJson(Map<String, dynamic> json) => FuelTypeDatum(
    id: json["id"],
    name: json["name"],
    color: json["color"], // May be null if API doesn't provide
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "color": color,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
