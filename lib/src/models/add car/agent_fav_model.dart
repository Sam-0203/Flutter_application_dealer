// To parse this JSON data, do
//
//     final agentFavoriteCarsResponse = agentFavoriteCarsResponseFromJson(jsonString);

import 'dart:convert';

AgentFavoriteCarsResponse agentFavoriteCarsResponseFromJson(String str) =>
    AgentFavoriteCarsResponse.fromJson(json.decode(str));

String agentFavoriteCarsResponseToJson(AgentFavoriteCarsResponse data) =>
    json.encode(data.toJson());

class AgentFavoriteCarsResponse {
  String message;
  bool status;
  int statusCode;
  Data data;

  AgentFavoriteCarsResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory AgentFavoriteCarsResponse.fromJson(Map<String, dynamic> json) =>
      AgentFavoriteCarsResponse(
        message: json["message"],
        status: json["status"],
        statusCode: json["status_code"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "status": status,
    "status_code": statusCode,
    "data": data.toJson(),
  };
}

class Data {
  int count;
  List<AgentFavCarDatum> cars;

  Data({required this.count, required this.cars});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    count: json["count"],
    cars: List<AgentFavCarDatum>.from(
      json["cars"].map((x) => AgentFavCarDatum.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "count": count,
    "cars": List<dynamic>.from(cars.map((x) => x.toJson())),
  };
}

class AgentFavCarDatum {
  Dealer dealer;
  int id;
  String status;
  Brand brand;
  Brand model;
  Brand variant;
  CarColor color;
  Brand fuelType;
  Brand transmission;
  String manufacturingYear;
  String kmRange;
  Brand ownerType;
  Rto rto;
  OtherDetails? otherDetails;
  Features features;
  List<CarImage> images;
  bool isFavorite;

  AgentFavCarDatum({
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

  factory AgentFavCarDatum.fromJson(Map<String, dynamic> json) =>
      AgentFavCarDatum(
        dealer: json["dealer"] != null
            ? Dealer.fromJson(json["dealer"])
            : Dealer(
                id: 0,
                dealershipName: "Unknown",
                state: "Unknown",
                city: "Unknown",
              ),
        id: json["id"] ?? 0,
        status: json["status"] ?? "Unknown",
        brand: json["brand"] != null
            ? Brand.fromJson(json["brand"])
            : Brand(id: 0, name: "Unknown"),
        model: json["model"] != null
            ? Brand.fromJson(json["model"])
            : Brand(id: 0, name: "Unknown"),
        variant: json["variant"] != null
            ? Brand.fromJson(json["variant"])
            : Brand(id: 0, name: "Unknown"),
        color: json["color"] != null
            ? CarColor.fromJson(json["color"])
            : CarColor(id: 0, name: "Unknown", colorCode: "#000000"),
        fuelType: json["fuel_type"] != null
            ? Brand.fromJson(json["fuel_type"])
            : Brand(id: 0, name: "Unknown"),
        transmission: json["transmission"] != null
            ? Brand.fromJson(json["transmission"])
            : Brand(id: 0, name: "Unknown"),
        manufacturingYear: json["manufacturing_year"] ?? "Unknown",
        kmRange: json["km_range"] ?? "Unknown",
        ownerType: json["owner_type"] != null
            ? Brand.fromJson(json["owner_type"])
            : Brand(id: 0, name: "Unknown"),
        rto: json["rto"] != null
            ? Rto.fromJson(json["rto"])
            : Rto(id: 0, code: "Unknown"),
        otherDetails: json["other_details"] == null
            ? null
            : OtherDetails.fromJson(json["other_details"]),
        features: json["features"] != null
            ? Features.fromJson(json["features"])
            : Features(
                safety: [],
                comfort: [],
                infotainment: [],
                interior: [],
                exterior: [],
              ),
        images: json["images"] != null
            ? List<CarImage>.from(
                json["images"].map((x) => CarImage.fromJson(x)),
              )
            : [],
        isFavorite: json["is_favorite"] ?? false,
      );

  Map<String, dynamic> toJson() => {
    "dealer": dealer.toJson(),
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

class Brand {
  int id;
  String name;

  Brand({required this.id, required this.name});

  factory Brand.fromJson(Map<String, dynamic> json) =>
      Brand(id: json["id"] ?? 0, name: json["name"] ?? "Unknown");

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class CarColor {
  int id;
  String name;
  String colorCode;

  CarColor({required this.id, required this.name, required this.colorCode});

  factory CarColor.fromJson(Map<String, dynamic> json) => CarColor(
    id: json["id"] ?? 0,
    name: json["name"] ?? "Unknown",
    colorCode: json["color_code"] ?? "#000000",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "color_code": colorCode,
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
    dealershipName: json["dealership_name"] ?? "Unknown",
    state: json["state"] ?? "Unknown",
    city: json["city"] ?? "Unknown",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "dealership_name": dealershipName,
    "state": state,
    "city": city,
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
    safety: json["safety"] != null
        ? List<Brand>.from(json["safety"].map((x) => Brand.fromJson(x)))
        : [],
    comfort: json["comfort"] != null
        ? List<Brand>.from(json["comfort"].map((x) => Brand.fromJson(x)))
        : [],
    infotainment: json["infotainment"] != null
        ? List<Brand>.from(json["infotainment"].map((x) => Brand.fromJson(x)))
        : [],
    interior: json["interior"] != null
        ? List<Brand>.from(json["interior"].map((x) => Brand.fromJson(x)))
        : [],
    exterior: json["exterior"] != null
        ? List<Brand>.from(json["exterior"].map((x) => Brand.fromJson(x)))
        : [],
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
    id: json["id"] ?? 0,
    imageUrl: json["image_url"] ?? "",
    isPrimary: json["is_primary"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "image_url": imageUrl,
    "is_primary": isPrimary,
  };
}

class OtherDetails {
  String insuranceValidity;
  String serviceHistory;
  dynamic customFeature;

  OtherDetails({
    required this.insuranceValidity,
    required this.serviceHistory,
    required this.customFeature,
  });

  factory OtherDetails.fromJson(Map<String, dynamic> json) => OtherDetails(
    insuranceValidity: json["insurance_validity"] ?? "Unknown",
    serviceHistory: json["service_history"] ?? "Unknown",
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
      Rto(id: json["id"] ?? 0, code: json["code"] ?? "Unknown");

  Map<String, dynamic> toJson() => {"id": id, "code": code};
}
