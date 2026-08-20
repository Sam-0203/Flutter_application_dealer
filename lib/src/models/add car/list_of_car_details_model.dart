// To parse this JSON data, do
//
//     final listOfCarDetailsResponse = listOfCarDetailsResponseFromJson(jsonString);

import 'dart:convert';

ListOfCarDetailsResponse listOfCarDetailsResponseFromJson(String str) =>
    ListOfCarDetailsResponse.fromJson(json.decode(str));

String listOfCarDetailsResponseToJson(ListOfCarDetailsResponse data) =>
    json.encode(data.toJson());

class ListOfCarDetailsResponse {
  String message;
  bool status;
  int statusCode;
  List<ListOfCarsDatum> data;

  ListOfCarDetailsResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory ListOfCarDetailsResponse.fromJson(Map<String, dynamic> json) =>
      ListOfCarDetailsResponse(
        message: _asString(json["message"]),
        status: _asBool(json["status"]),
        statusCode: _asInt(json["status_code"]),
        data: _extractCarsData(
          json["data"],
        ).map((x) => ListOfCarsDatum.fromJson(_asMap(x))).toList(),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class ListOfCarsDatum {
  Dealer dealer;
  int id;
  String status;
  String registrationNumber;
  String rcStatus;
  DateTime? insuranceUpto;
  String policyNumber;
  String engineNumber;
  String cubicCapacity;
  String vehicleChasiNumber;
  DateTime? registrationDate;
  String financer;
  bool financed;
  DateTime? taxPaidUpto;
  Brand brand;
  Brand model;
  Brand variant;
  Color color;
  Brand fuelType;
  Brand transmission;
  String manufacturingYear;
  String kmRange;
  Brand owner;
  Brand ownerType;
  Rto rto;
  OtherDetails? otherDetails;
  Features features;
  List<CarImage> images;
  bool isFavorite;

  ListOfCarsDatum({
    required this.dealer,
    required this.id,
    required this.status,
    required this.registrationNumber,
    required this.rcStatus,
    required this.insuranceUpto,
    required this.policyNumber,
    required this.engineNumber,
    required this.cubicCapacity,
    required this.vehicleChasiNumber,
    required this.registrationDate,
    required this.financer,
    required this.financed,
    required this.taxPaidUpto,
    required this.brand,
    required this.model,
    required this.variant,
    required this.color,
    required this.fuelType,
    required this.transmission,
    required this.manufacturingYear,
    required this.kmRange,
    required this.owner,
    required this.ownerType,
    required this.rto,
    required this.otherDetails,
    required this.features,
    required this.images,
    required this.isFavorite,
  });

  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  factory ListOfCarsDatum.fromJson(Map<String, dynamic> json) {
    final dealerJson = Map<String, dynamic>.from(_asMap(json["dealer"]));
    dealerJson["car_post_date"] = _extractCarPostDate(json, dealerJson);

    return ListOfCarsDatum(
      dealer: Dealer.fromJson(dealerJson),
      id: _asInt(json["id"]),
      status: _asString(json["status"]),
      registrationNumber: _asString(json["registration_number"]),
      rcStatus: _asString(json["rc_status"]),
      insuranceUpto: _tryParseDate(json["insurance_upto"]),
      policyNumber: _asString(json["policy_number"]),
      engineNumber: _asString(json["engine_number"]),
      cubicCapacity: _asString(json["cubic_capacity"]),
      vehicleChasiNumber: _asString(json["vehicle_chasi_number"]),
      registrationDate: _tryParseDate(json["registration_date"]),
      financer: _asString(json["financer"]),
      financed: _asBool(json["financed"]),
      taxPaidUpto: _tryParseDate(json["tax_paid_upto"]),
      brand: Brand.fromJson(_asMap(json["brand"])),
      model: Brand.fromJson(_asMap(json["model"])),
      variant: Brand.fromJson(_asMap(json["variant"])),
      color: Color.fromJson(_asMap(json["color"])),
      fuelType: Brand.fromJson(_asMap(json["fuel_type"])),
      transmission: Brand.fromJson(_asMap(json["transmission"])),
      manufacturingYear: _asString(json["manufacturing_year"]),
      kmRange: _asString(json["km_range"]),
      owner: Brand.fromJson(_asMap(json["owner"])),
      ownerType: Brand.fromJson(_asMap(json["owner_type"])),
      rto: Rto.fromJson(_asMap(json["rto"])),
      otherDetails: json["other_details"] == null
          ? null
          : OtherDetails.fromJson(_asMap(json["other_details"])),
      features: Features.fromJson(_asMap(json["features"])),
      images: _asList(
        json["images"],
      ).map((x) => CarImage.fromJson(_asMap(x))).toList(),
      isFavorite: _asBool(json["is_favorite"]),
    );
  }

  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "registration_number": registrationNumber,
    "rc_status": rcStatus,
    "insurance_upto": _formatDate(insuranceUpto),
    "policy_number": policyNumber,
    "engine_number": engineNumber,
    "cubic_capacity": cubicCapacity,
    "vehicle_chasi_number": vehicleChasiNumber,
    "registration_date": _formatDate(registrationDate),
    "financer": financer,
    "financed": financed,
    "tax_paid_upto": _formatDate(taxPaidUpto),
    "brand": brand.toJson(),
    "model": model.toJson(),
    "variant": variant.toJson(),
    "color": color.toJson(),
    "fuel_type": fuelType.toJson(),
    "transmission": transmission.toJson(),
    "manufacturing_year": manufacturingYear,
    "km_range": kmRange,
    "owner": owner.toJson(),
    "owner_type": ownerType.toJson(),
    "rto": rto.toJson(),
    "other_details": otherDetails?.toJson(),
    "features": features.toJson(),
    "images": List<dynamic>.from(images.map((x) => x.toJson())),
    "is_favorite": isFavorite,
  };
}

class Dealer {
  int id;
  String dealershipName;
  String registrationNumber;
  String state;
  String city;
  String carPostDate;

  Dealer({
    required this.id,
    required this.dealershipName,
    required this.state,
    required this.city,
    required this.carPostDate,
    required this.registrationNumber,
  });

  factory Dealer.fromJson(Map<String, dynamic> json) => Dealer(
    id: _asInt(json["id"]),
    dealershipName: _asString(json["dealership_name"]),
    state: _asString(json["state"]),
    city: _asString(json["city"]),
    carPostDate: _firstNonEmptyString([
      json["car_post_date"],
      json["carPostDate"],
      json["posted_date"],
      json["posted_at"],
      json["postedAt"],
      json["post_date"],
      json["postDate"],
      json["created_at"],
      json["createdAt"],
      json["created_on"],
      json["createdOn"],
    ]),
    registrationNumber: _asString(json["registration_number"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "dealership_name": dealershipName,
    "state": state,
    "city": city,
    "car_post_date": carPostDate,
    "registration_number": registrationNumber,
  };
}

class Brand {
  int id;
  String name;

  Brand({required this.id, required this.name});

  factory Brand.fromJson(Map<String, dynamic> json) =>
      Brand(id: _asInt(json["id"]), name: _asString(json["name"]));

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class Color {
  int id;
  String name;
  String colorCode;

  Color({required this.id, required this.name, required this.colorCode});

  factory Color.fromJson(Map<String, dynamic> json) => Color(
    id: _asInt(json["id"]),
    name: _asString(json["name"]),
    colorCode: _asString(json["color_code"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "color_code": colorCode,
  };
}

class Features {
  List<Brand> safety;
  List<Brand> comfort;
  List<Brand> infotainment;
  List<Brand> interior;
  List<Brand> exterior;

  Features({
    required this.safety,
    required this.comfort,
    required this.infotainment,
    required this.interior,
    required this.exterior,
  });

  factory Features.fromJson(Map<String, dynamic> json) => Features(
    safety: _asList(
      json["safety"],
    ).map((x) => Brand.fromJson(_asMap(x))).toList(),
    comfort: _asList(
      json["comfort"],
    ).map((x) => Brand.fromJson(_asMap(x))).toList(),
    infotainment: _asList(
      json["infotainment"],
    ).map((x) => Brand.fromJson(_asMap(x))).toList(),
    interior: _asList(
      json["interior"],
    ).map((x) => Brand.fromJson(_asMap(x))).toList(),
    exterior: _asList(
      json["exterior"],
    ).map((x) => Brand.fromJson(_asMap(x))).toList(),
  );

  Map<String, dynamic> toJson() => {
    "safety": List<dynamic>.from(safety.map((x) => x.toJson())),
    "comfort": List<dynamic>.from(comfort.map((x) => x.toJson())),
    "infotainment": List<dynamic>.from(infotainment.map((x) => x.toJson())),
    "interior": List<dynamic>.from(interior.map((x) => x.toJson())),
    "exterior": List<dynamic>.from(exterior.map((x) => x.toJson())),
  };
}

class CarImage {
  int id;
  String imageUrl;
  bool isPrimary;

  CarImage({required this.id, required this.imageUrl, required this.isPrimary});

  factory CarImage.fromJson(Map<String, dynamic> json) => CarImage(
    id: _asInt(json["id"]),
    imageUrl: _asString(json["url"] ?? json["image_url"]),
    isPrimary: _asBool(json["is_primary"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image_url": imageUrl,
    "is_primary": isPrimary,
  };
}

class OtherDetails {
  String? insuranceValidity;
  String? serviceHistory;
  dynamic customFeature;

  OtherDetails({
    this.insuranceValidity,
    this.serviceHistory,
    this.customFeature,
  });

  factory OtherDetails.fromJson(Map<String, dynamic> json) => OtherDetails(
    insuranceValidity: _asNullableString(json["insurance_validity"]),
    serviceHistory: _asNullableString(json["service_history"]),
    customFeature: json["custom_feature"],
  );

  Map<String, dynamic> toJson() => {
    "insurance_validity": insuranceValidity,
    "service_history": serviceHistory,
    "custom_feature": customFeature,
  };
}

class Rto {
  int id;
  String code;

  Rto({required this.id, required this.code});

  factory Rto.fromJson(Map<String, dynamic> json) =>
      Rto(id: _asInt(json["id"]), code: _asString(json["code"]));

  Map<String, dynamic> toJson() => {"id": id, "code": code};
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) => value is List ? value : const [];

List<dynamic> _extractCarsData(dynamic value) {
  if (value is List) return value;

  if (value is Map) {
    final map = _asMap(value);
    const candidateKeys = <String>[
      'data',
      'cars',
      'items',
      'results',
      'records',
    ];

    for (final key in candidateKeys) {
      final nested = map[key];
      final extracted = _extractCarsData(nested);
      if (extracted.isNotEmpty) return extracted;
    }
  }

  return const [];
}

String _extractCarPostDate(
  Map<String, dynamic> carJson, [
  Map<String, dynamic>? dealerJson,
]) {
  const keys = <String>[
    'car_post_date',
    'carPostDate',
    'posted_date',
    'posted_at',
    'postedAt',
    'post_date',
    'postDate',
    'created_at',
    'createdAt',
    'created_on',
    'createdOn',
  ];

  final dealerMap = dealerJson ?? _asMap(carJson["dealer"]);

  return _firstNonEmptyString([
    for (final key in keys) dealerMap[key],
    for (final key in keys) carJson[key],
  ]);
}

String _firstNonEmptyString(Iterable<dynamic> values, {String fallback = ''}) {
  for (final value in values) {
    final parsed = _asString(value).trim();
    if (parsed.isNotEmpty && parsed.toLowerCase() != 'null') {
      return parsed;
    }
  }
  return fallback;
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    if (normalized == 'success' || normalized == 'ok' || normalized == 'yes') {
      return true;
    }
    if (normalized == 'failed' || normalized == 'error' || normalized == 'no') {
      return false;
    }
  }
  return fallback;
}
