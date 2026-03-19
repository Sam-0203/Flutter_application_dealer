import 'dart:convert';

CarUpdateRequestModel carUpdateRequestModelFromJson(String str) =>
    CarUpdateRequestModel.fromJson(json.decode(str));

String carUpdateRequestModelToJson(CarUpdateRequestModel data) =>
    json.encode(data.toJson());

class CarUpdateRequestModel {
  final int? carId;

  final int? brandId;
  final int? modelId;
  final int? variantId;
  final int? fuelTypeId;
  final int? transmissionId;
  final int? colorId;
  final int? ownerTypeId;
  final int? rtoId;

  final String? manufacturingYear;
  final String? kmRange;

  final OtherDetailsRequest? otherDetails;

  final List<int>? safetyFeatureIds;
  final List<int>? comfortFeatureIds;
  final List<int>? infotainmentFeatureIds;
  final List<int>? interiorFeatureIds;
  final List<int>? exteriorFeatureIds;

  CarUpdateRequestModel({
    this.carId,
    this.brandId,
    this.modelId,
    this.variantId,
    this.fuelTypeId,
    this.transmissionId,
    this.colorId,
    this.ownerTypeId,
    this.rtoId,
    this.manufacturingYear,
    this.kmRange,
    this.otherDetails,
    this.safetyFeatureIds,
    this.comfortFeatureIds,
    this.infotainmentFeatureIds,
    this.interiorFeatureIds,
    this.exteriorFeatureIds,
  });

  Map<String, dynamic> toJson() {
    return {
      if (carId != null) "car_id": carId,
      if (brandId != null) "brand_id": brandId,
      if (modelId != null) "model_id": modelId,
      if (variantId != null) "variant_id": variantId,
      if (fuelTypeId != null) "fuel_type_id": fuelTypeId,
      if (transmissionId != null) "transmission_id": transmissionId,
      if (colorId != null) "color_id": colorId,
      if (ownerTypeId != null) "owner_type_id": ownerTypeId,
      if (rtoId != null) "rto_id": rtoId,
      if (manufacturingYear != null) "manufacturing_year": manufacturingYear,
      if (kmRange != null) "km_range": kmRange,
      if (otherDetails != null) "other_details": otherDetails!.toJson(),
      if (safetyFeatureIds != null) "safety_feature_ids": safetyFeatureIds,
      if (comfortFeatureIds != null) "comfort_feature_ids": comfortFeatureIds,
      if (infotainmentFeatureIds != null)
        "infotainment_feature_ids": infotainmentFeatureIds,
      if (interiorFeatureIds != null)
        "interior_feature_ids": interiorFeatureIds,
      if (exteriorFeatureIds != null)
        "exterior_feature_ids": exteriorFeatureIds,
    };
  }

  factory CarUpdateRequestModel.fromJson(Map<String, dynamic> json) =>
      CarUpdateRequestModel(carId: json["car_id"] as int?);
}

class OtherDetailsRequest {
  final String? insuranceValidity;
  final String? serviceHistory;

  OtherDetailsRequest({this.insuranceValidity, this.serviceHistory});

  Map<String, dynamic> toJson() => {
    if (insuranceValidity != null) "insurance_validity": insuranceValidity,
    if (serviceHistory != null) "service_history": serviceHistory,
  };
}
