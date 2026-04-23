import 'dart:convert';
import 'package:dealershub_/src/models/add car/car_details_model.dart';

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
  final DealerCarDetailsDatum car;

  CarUpdateData({required this.updatedFields, required this.car});

  factory CarUpdateData.fromJson(Map<String, dynamic> json) => CarUpdateData(
    updatedFields: List<String>.from(json["updated_fields"].map((x) => x)),
    car: DealerCarDetailsDatum.fromJson(json["car"]),
  );
}
