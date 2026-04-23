import 'dart:convert';

SearchDetailsResponse searchDetailsResponseFromJson(String str) =>
    SearchDetailsResponse.fromJson(json.decode(str));

String searchDetailsResponseToJson(SearchDetailsResponse data) =>
    json.encode(data.toJson());

class SearchDetailsResponse {
  String message;
  bool status;
  int statusCode;
  SearchData data;

  SearchDetailsResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory SearchDetailsResponse.fromJson(Map<String, dynamic> json) =>
      SearchDetailsResponse(
        message: _asString(json["message"]),
        status: _asBool(json["status"]),
        statusCode: _asInt(json["status_code"]),
        data: SearchData.fromJson(_asMap(json["data"])),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": data.toJson(),
  };
}

// New class to handle pagination + items
class SearchData {
  List<SearchDatum> items;
  int total;
  int page;
  int perPage;
  int pages;

  SearchData({
    required this.items,
    required this.total,
    required this.page,
    required this.perPage,
    required this.pages,
  });

  factory SearchData.fromJson(Map<String, dynamic> json) => SearchData(
    items: _asList(
      json["items"],
    ).map((x) => SearchDatum.fromJson(_asMap(x))).toList(),
    total: _asInt(json["total"]),
    page: _asInt(json["page"]),
    perPage: _asInt(json["per_page"]),
    pages: _asInt(json["pages"]),
  );

  Map<String, dynamic> toJson() => {
    "items": List<dynamic>.from(items.map((x) => x.toJson())),
    "total": total,
    "page": page,
    "per_page": perPage,
    "pages": pages,
  };
}

class SearchDatum {
  Dealer dealer;
  int id;
  String status;
  Brand brand;
  Brand models; // Fixed: matches JSON key "models"
  Brand variant;
  ColorModel color;
  Brand fuelType;
  Brand transmission;
  String manufacturingYear;
  String kmRange;
  Brand ownerType;
  Rto rto;
  OtherDetails? otherDetails;
  Features features;
  List<ImageModel> images;
  bool isFavorite;

  SearchDatum({
    required this.dealer,
    required this.id,
    required this.status,
    required this.brand,
    required this.models,
    required this.variant,
    required this.color,
    required this.fuelType,
    required this.transmission,
    required this.manufacturingYear,
    required this.kmRange,
    required this.ownerType,
    required this.rto,
    this.otherDetails,
    required this.features,
    required this.images,
    required this.isFavorite,
  });

  factory SearchDatum.fromJson(Map<String, dynamic> json) => SearchDatum(
    dealer: Dealer.fromJson(_asMap(json["dealer"])),
    id: _asInt(json["id"]),
    status: _asString(json["status"]),
    brand: Brand.fromJson(_asMap(json["brand"])),
    models: Brand.fromJson(_asMap(json["models"])), // Fixed
    variant: Brand.fromJson(_asMap(json["variant"])),
    color: ColorModel.fromJson(_asMap(json["color"])),
    fuelType: Brand.fromJson(_asMap(json["fuel_type"])),
    transmission: Brand.fromJson(_asMap(json["transmission"])),
    manufacturingYear: _asString(json["manufacturing_year"]),
    kmRange: _asString(json["km_range"]),
    ownerType: Brand.fromJson(_asMap(json["owner_type"])),
    rto: Rto.fromJson(_asMap(json["rto"])),
    otherDetails: json["other_details"] == null
        ? null
        : OtherDetails.fromJson(_asMap(json["other_details"])),
    features: Features.fromJson(_asMap(json["features"] ?? {})),
    images: _asList(
      json["images"],
    ).map((x) => ImageModel.fromJson(_asMap(x))).toList(),
    isFavorite: _asBool(json["is_favorite"]),
  );

  Map<String, dynamic> toJson() => {
    "dealer": dealer.toJson(),
    "id": id,
    "status": status,
    "brand": brand.toJson(),
    "models": models.toJson(), // Fixed
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
  String postedDate;

  Dealer({
    required this.id,
    required this.dealershipName,
    required this.state,
    required this.city,
    required this.postedDate,
  });

  factory Dealer.fromJson(Map<String, dynamic> json) => Dealer(
    id: _asInt(json["id"]),
    dealershipName: _asString(json["dealership_name"]),
    state: _asString(json["state"]),
    city: _asString(json["city"]).trim(), // trim extra space
    postedDate: _asString(json["posted_date"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "dealership_name": dealershipName,
    "state": state,
    "city": city,
    "posted_date": postedDate,
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

class ColorModel {
  int id;
  String name;
  String colorCode;

  ColorModel({required this.id, required this.name, required this.colorCode});

  factory ColorModel.fromJson(Map<String, dynamic> json) => ColorModel(
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

class ImageModel {
  int id;
  String imageUrl;
  bool isPrimary;

  ImageModel({
    required this.id,
    required this.imageUrl,
    required this.isPrimary,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(
    id: _asInt(json["id"]),
    imageUrl: _asString(json["image_url"]),
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

// ====================== Helper Functions ======================

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) => value is List ? value : const [];

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final str = value.toString().trim();
  return str.isEmpty || str.toLowerCase() == 'null' ? null : str;
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
