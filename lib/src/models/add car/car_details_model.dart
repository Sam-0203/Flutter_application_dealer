import 'dart:convert';

CarDetailsResponse carDetailsResponseFromJson(String str) =>
    CarDetailsResponse.fromJson(json.decode(str));

String carDetailsResponseToJson(CarDetailsResponse data) =>
    json.encode(data.toJson());

class CarDetailsResponse {
  String message;
  bool status;
  int statusCode;
  DealerCarDetailsDatum data;

  CarDetailsResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory CarDetailsResponse.fromJson(Map<String, dynamic> json) =>
      CarDetailsResponse(
        message: json["message"] ?? "",
        status: json["status"] ?? false,
        statusCode: json["status_code"] ?? 0,
        data: DealerCarDetailsDatum.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": data.toJson(),
  };
}

class DealerCarDetailsDatum {
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
  List<CarImage> images;

  DealerCarDetailsDatum({
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
    this.otherDetails,
    required this.features,
    required this.images,
  });

  factory DealerCarDetailsDatum.fromJson(Map<String, dynamic> json) =>
      DealerCarDetailsDatum(
        dealer: Dealer.fromJson(json["dealer"]),
        id: json["id"],
        status: json["status"] ?? "",
        brand: Brand.fromJson(json["brand"]),
        model: Brand.fromJson(json["model"]),
        variant: Brand.fromJson(json["variant"]),
        color: Color.fromJson(json["color"]),
        fuelType: Brand.fromJson(json["fuel_type"]),
        transmission: Brand.fromJson(json["transmission"]),
        manufacturingYear: json["manufacturing_year"] ?? "",
        kmRange: json["km_range"] ?? "",
        ownerType: Brand.fromJson(json["owner_type"]),
        rto: Rto.fromJson(json["rto"]),
        otherDetails: json["other_details"] == null
            ? null
            : OtherDetails.fromJson(json["other_details"]),
        features: Features.fromJson(json["features"] ?? {}),
        images: json["images"] == null
            ? []
            : List<CarImage>.from(
                json["images"].map((x) => CarImage.fromJson(x)),
              ),
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
    id: json["id"] ?? 0,
    dealershipName: json["dealership_name"] ?? "",
    state: json["state"] ?? "",
    city: json["city"] ?? "",
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
  int? createdByUserId;
  int? carId;
  bool isAdmin;

  Brand({
    required this.id,
    required this.name,
    this.createdByUserId,
    this.carId,
    this.isAdmin = false,
  });

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    createdByUserId: _asNullableInt(
      json["created_by"] ??
          json["created_by_id"] ??
          json["user_id"] ??
          json["dealer_id"],
    ),
    carId: _asNullableInt(json["car_id"] ?? json["source_car_id"]),
    isAdmin:
        _asBool(json["is_admin"]) ||
        _asBool(json["admin_feature"]) ||
        _asBool(json["is_default"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "created_by": createdByUserId,
    "car_id": carId,
    "is_admin": isAdmin,
  };
}

class Color {
  int id;
  String name;
  String colorCode;

  Color({required this.id, required this.name, required this.colorCode});

  factory Color.fromJson(Map<String, dynamic> json) => Color(
    id: json["id"] ?? 0,
    name: json["name"] ?? "",
    colorCode: json["color_code"] ?? "",
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
    safety: json["safety"] == null
        ? []
        : List<Brand>.from(json["safety"].map((x) => Brand.fromJson(x))),
    comfort: json["comfort"] == null
        ? []
        : List<Brand>.from(json["comfort"].map((x) => Brand.fromJson(x))),
    infotainment: json["infotainment"] == null
        ? []
        : List<Brand>.from(json["infotainment"].map((x) => Brand.fromJson(x))),
    interior: json["interior"] == null
        ? []
        : List<Brand>.from(json["interior"].map((x) => Brand.fromJson(x))),
    exterior: json["exterior"] == null
        ? []
        : List<Brand>.from(json["exterior"].map((x) => Brand.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "safety": List<dynamic>.from(safety.map((x) => x.toJson())),
    "comfort": List<dynamic>.from(comfort.map((x) => x.toJson())),
    "infotainment": List<dynamic>.from(infotainment.map((x) => x.toJson())),
    "interior": List<dynamic>.from(interior.map((x) => x.toJson())),
    "exterior": List<dynamic>.from(exterior.map((x) => x.toJson())),
  };
}

class OtherDetails {
  String? insuranceValidity;
  String? serviceHistory;

  OtherDetails({this.insuranceValidity, this.serviceHistory});

  factory OtherDetails.fromJson(Map<String, dynamic> json) => OtherDetails(
    insuranceValidity: json["insurance_validity"],
    serviceHistory: json["service_history"],
  );

  Map<String, dynamic> toJson() => {
    "insurance_validity": insuranceValidity,
    "service_history": serviceHistory,
  };
}

class CarImage {
  int id;
  String imageUrl;
  bool isPrimary;

  CarImage({required this.id, required this.imageUrl, required this.isPrimary});

  factory CarImage.fromJson(Map<String, dynamic> json) => CarImage(
    id: json["id"] ?? 0,
    imageUrl: json["image_url"] ?? "",
    isPrimary:
        json["is_primary"] == true ||
        json["is_primary"] == 1 ||
        json["is_primary"] == "true",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image_url": imageUrl,
    "is_primary": isPrimary,
  };
}

class Rto {
  int id;
  String code;

  Rto({required this.id, required this.code});

  factory Rto.fromJson(Map<String, dynamic> json) =>
      Rto(id: json["id"] ?? 0, code: json["code"] ?? "");

  Map<String, dynamic> toJson() => {"id": id, "code": code};
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == 'true' || normalized == '1';
  }
  return false;
}
