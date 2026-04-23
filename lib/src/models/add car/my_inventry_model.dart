// To parse this JSON data, do
//
//     final myInventryCarDetailsResponse = myInventryCarDetailsResponseFromJson(jsonString);

import 'dart:convert';

MyInventryCarDetailsResponse myInventryCarDetailsResponseFromJson(String str) =>
    MyInventryCarDetailsResponse.fromJson(json.decode(str));

String myInventryCarDetailsResponseToJson(MyInventryCarDetailsResponse data) =>
    json.encode(data.toJson());

class MyInventryCarDetailsResponse {
  String message;
  bool status;
  int statusCode;
  List<MultiCarsDatum> data;

  MyInventryCarDetailsResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory MyInventryCarDetailsResponse.fromJson(Map<String, dynamic> json) =>
      MyInventryCarDetailsResponse(
        message: _asString(json["message"]),
        status: _asBool(json["status"]),
        statusCode: _asInt(json["status_code"]),
        data: _extractInventoryList(
          json["data"],
        ).map((x) => MultiCarsDatum.fromJson(_asMap(x))).toList(),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class MultiCarsDatum {
  Dealer dealer;
  int id;
  String status;
  Brand brand;
  Brand model;
  Brand variant;
  Color color;
  Brand fuelType;
  Brand transmission;
  String manufacturingYear;
  String kmRange;
  Brand ownerType;
  Rto rto;
  OtherDetails? otherDetails;
  Features features;
  List<Image> images;
  bool isFavorite;

  MultiCarsDatum({
    required this.dealer,
    required this.id,
    required this.status,
    required this.brand,
    required this.model,
    required this.variant,
    required this.color,
    required this.fuelType,
    required this.transmission,
    required this.manufacturingYear,
    required this.kmRange,
    required this.ownerType,
    required this.rto,
    required this.otherDetails,
    required this.features,
    required this.images,
    required this.isFavorite,
  });

  factory MultiCarsDatum.fromJson(Map<String, dynamic> json) => MultiCarsDatum(
    dealer: Dealer.fromJson(_asMap(json["dealer"])),
    id: _asInt(json["id"]),
    status: _asString(json["status"]),
    brand: Brand.fromJson(_asMap(json["brand"])),
    model: Brand.fromJson(_asMap(json["model"])),
    variant: Brand.fromJson(_asMap(json["variant"])),
    color: Color.fromJson(_asMap(json["color"])),
    fuelType: Brand.fromJson(_asMap(json["fuel_type"])),
    transmission: Brand.fromJson(_asMap(json["transmission"])),
    manufacturingYear: _asString(json["manufacturing_year"]),
    kmRange: _asString(json["km_range"]),
    ownerType: Brand.fromJson(_asMap(json["owner_type"])),
    rto: Rto.fromJson(_asMap(json["rto"])),
    otherDetails: json["other_details"] == null
        ? null
        : OtherDetails.fromJson(_asMap(json["other_details"])),
    features: Features.fromJson(_asMap(json["features"])),
    images: _asList(
      json["images"],
    ).map((x) => Image.fromJson(_asMap(x))).toList(),
    isFavorite: _asBool(json["is_favorite"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "brand": brand.toJson(),
    "model": model.toJson(),
    "variant": variant.toJson(),
    "color": color.toJson(),
    "fuel_type": fuelType.toJson(),
    "transmission": transmission.toJson(),
    "manufacturing_year": manufacturingYear,
    "km_range": kmRange,
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
  String state;
  String city;

  Dealer({
    required this.id,
    required this.dealershipName,
    required this.state,
    required this.city,
  });

  factory Dealer.fromJson(Map<String, dynamic> json) => Dealer(
    id: _asInt(json["id"]),
    dealershipName: _asString(json["dealership_name"]),
    state: _asString(json["state"]),
    city: _asString(json["city"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "dealership_name": dealershipName,
    "state": state,
    "city": city,
  };
}

class Brand {
  int id;
  String name;
  String? colorCode;

  Brand({required this.id, required this.name, this.colorCode});

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
    id: _asInt(json["id"]),
    name: _asString(json["name"]),
    colorCode: _asNullableString(json["color_code"] ?? json["colour_code"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    if (colorCode != null) "color_code": colorCode,
  };
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

class Image {
  int id;
  String imageUrl;
  bool isPrimary;

  Image({required this.id, required this.imageUrl, required this.isPrimary});

  factory Image.fromJson(Map<String, dynamic> json) => Image(
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

List<dynamic> _extractInventoryList(dynamic value) {
  if (value is List) return value;
  if (value is Map) {
    final map = _asMap(value);
    final items = map["items"];
    if (items is List) return items;
  }
  return const [];
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
  }
  return fallback;
}
