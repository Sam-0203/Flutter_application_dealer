// To parse this JSON data, do
//
//     final statesList = statesListFromJson(jsonString);

import 'dart:convert';

StatesList statesListFromJson(String str) =>
    StatesList.fromJson(json.decode(str));

String statesListToJson(StatesList data) => json.encode(data.toJson());

class StatesList {
  String message;
  bool status;
  int statusCode;
  List<StateDatum> data;

  StatesList({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory StatesList.fromJson(Map<String, dynamic> json) => StatesList(
    message: json["message"],
    status: json["status"],
    statusCode: json["status_code"],
    data: List<StateDatum>.from(
      json["data"].map((x) => StateDatum.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class StateDatum {
  int id;
  String name;
  DateTime createdAt;
  dynamic updatedAt;

  StateDatum({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StateDatum.fromJson(Map<String, dynamic> json) => StateDatum(
    id: json["id"],
    name: json["name"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt,
  };
}
