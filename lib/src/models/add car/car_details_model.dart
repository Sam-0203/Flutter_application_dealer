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
        data: DealerCarDetailsDatum.fromJson(json["data"] ?? {}),
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
  Brand models;
  Brand variant;
  CarColor color;
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

  // Backward compatibility
  Brand get model => models;

  DealerCarDetailsDatum({
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
    required this.models,
    required this.variant,
    required this.color,
    required this.fuelType,
    required this.transmission,
    required this.manufacturingYear,
    required this.kmRange,
    required this.owner,
    required this.ownerType,
    required this.rto,
    this.otherDetails,
    required this.features,
    required this.images,
    required this.isFavorite,
  });

  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  factory DealerCarDetailsDatum.fromJson(Map<String, dynamic> json) =>
      DealerCarDetailsDatum(
        dealer: Dealer.fromJson(json["dealer"] ?? {}),
        id: json["id"] ?? 0,
        status: json["status"] ?? "",
        registrationNumber: json["registration_number"] ?? "",
        rcStatus: json["rc_status"] ?? "",
        insuranceUpto: _tryParseDate(json["insurance_upto"]),
        policyNumber: json["policy_number"] ?? "",
        engineNumber: json["engine_number"] ?? "",
        cubicCapacity: json["cubic_capacity"] ?? "",
        vehicleChasiNumber: json["vehicle_chasi_number"] ?? "",
        registrationDate: _tryParseDate(json["registration_date"]),
        financer: json["financer"] ?? "",
        financed: _asBool(json["financed"]),
        taxPaidUpto: _tryParseDate(json["tax_paid_upto"]),
        brand: Brand.fromJson(json["brand"] ?? {}),
        models: Brand.fromJson(json["model"] ?? json["models"] ?? {}), // ← fix
        variant: Brand.fromJson(json["variant"] ?? {}),
        color: CarColor.fromJson(json["color"] ?? {}),
        fuelType: Brand.fromJson(json["fuel_type"] ?? {}),
        transmission: Brand.fromJson(json["transmission"] ?? {}),
        manufacturingYear: json["manufacturing_year"] ?? "",
        kmRange: json["km_range"] ?? "",
        owner: Brand.fromJson(json["owner"] ?? {}),
        ownerType: Brand.fromJson(json["owner_type"] ?? {}),
        rto: Rto.fromJson(json["rto"] ?? {}),
        otherDetails: json["other_details"] == null
            ? null
            : OtherDetails.fromJson(json["other_details"]),
        features: Features.fromJson(json["features"] ?? {}),
        images: json["images"] == null
            ? []
            : List<CarImage>.from(
                json["images"].map((x) => CarImage.fromJson(x)),
              ),
        isFavorite: _asBool(json["is_favorite"]),
      );

  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Map<String, dynamic> toJson() => {
    "dealer": dealer.toJson(),
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
    "model": models.toJson(),
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
  String registrationNumber;
  String dealershipName;
  String state;
  String city;
  String? createdAt;
  String? updatedAt;
  String? postedDate;

  Dealer({
    required this.id,
    required this.registrationNumber,
    required this.dealershipName,
    required this.state,
    required this.city,
    this.createdAt,
    this.updatedAt,
    this.postedDate,
  });

  factory Dealer.fromJson(Map<String, dynamic> json) => Dealer(
    id: json["id"] ?? 0,
    registrationNumber: json["registration_number"] ?? "",
    dealershipName: json["dealership_name"] ?? "",
    state: json["state"] ?? "",
    city: json["city"]?.trim() ?? "",
    createdAt: json["created_at"],
    updatedAt: json["updated_at"],
    postedDate: json["posted_date"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "registration_number": registrationNumber,
    "dealership_name": dealershipName,
    "state": state,
    "city": city,
    "created_at": createdAt,
    "updated_at": updatedAt,
    "posted_date": postedDate,
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

class CarColor {
  int id;
  String name;
  String colorCode;

  CarColor({required this.id, required this.name, required this.colorCode});

  factory CarColor.fromJson(Map<String, dynamic> json) => CarColor(
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
    imageUrl: json["url"] ?? json["image_url"] ?? "",
    isPrimary: _asBool(json["is_primary"]),
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

// ─── Helpers ────────────────────────────────────────────────────────────────

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
