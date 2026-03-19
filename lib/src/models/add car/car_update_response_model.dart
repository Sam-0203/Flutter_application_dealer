import 'dart:convert';

CarUpdateResponse carUpdateResponseFromJson(String str) =>
    CarUpdateResponse.fromJson(json.decode(str));

class CarUpdateResponse {
  final String message;
  final bool status;
  final int statusCode;
  final CarUpdateData data;

  CarUpdateResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory CarUpdateResponse.fromJson(Map<String, dynamic> json) =>
      CarUpdateResponse(
        message: json["message"],
        status: json["status"],
        statusCode: json["status_code"],
        data: CarUpdateData.fromJson(json["data"]),
      );
}

class CarUpdateData {
  final List<String> updatedFields;
  final UpdatedCar car;

  CarUpdateData({required this.updatedFields, required this.car});

  factory CarUpdateData.fromJson(Map<String, dynamic> json) => CarUpdateData(
    updatedFields: List<String>.from(json["updated_fields"].map((x) => x)),
    car: UpdatedCar.fromJson(json["car"]),
  );
}

class UpdatedCar {
  final int id;
  final String status;
  final String manufacturingYear;
  final String kmRange;

  UpdatedCar({
    required this.id,
    required this.status,
    required this.manufacturingYear,
    required this.kmRange,
  });

  factory UpdatedCar.fromJson(Map<String, dynamic> json) => UpdatedCar(
    id: json["id"],
    status: json["status"],
    manufacturingYear: json["manufacturing_year"],
    kmRange: json["km_range"],
  );
}
