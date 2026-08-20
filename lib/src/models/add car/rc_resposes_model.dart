// To parse this JSON data, do
//
//     final rcUploadResponse = rcUploadResponseFromJson(jsonString);

import 'dart:convert';

RcUploadDetailedResponse rcUploadResponseFromJson(String str) =>
    RcUploadDetailedResponse.fromJson(json.decode(str));

String rcUploadResponseToJson(RcUploadDetailedResponse data) =>
    json.encode(data.toJson());

class RcUploadDetailedResponse {
  RcUploadResponseData data;
  String message;
  String source;
  bool status;

  RcUploadDetailedResponse({
    required this.data,
    required this.message,
    required this.source,
    required this.status,
  });

  factory RcUploadDetailedResponse.fromJson(Map<String, dynamic> json) =>
      RcUploadDetailedResponse(
        data: RcUploadResponseData.fromJson(json["data"]),
        message: json["message"] ?? '',
        source: json["source"] ?? '',
        status: json["status"] ?? false,
      );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
    "message": message,
    "source": source,
    "status": status,
  };
}

class RcUploadResponseData {
  RCData data;
  dynamic message;
  String messageCode;
  int statusCode;
  bool success;

  RcUploadResponseData({
    required this.data,
    required this.message,
    required this.messageCode,
    required this.statusCode,
    required this.success,
  });

  factory RcUploadResponseData.fromJson(Map<String, dynamic> json) =>
      RcUploadResponseData(
        data: RCData.fromJson(json["data"]),
        message: json["message"],
        messageCode: json["message_code"] ?? '',
        statusCode: json["status_code"] ?? 0,
        success: json["success"] ?? false,
      );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
    "message": message,
    "message_code": messageCode,
    "status_code": statusCode,
    "success": success,
  };
}

class RCData {
  String blacklistStatus;
  String bodyType;
  dynamic challanDetails;
  String clientId;
  String color;
  String cubicCapacity;
  String fatherName;
  bool financed;
  String financer;
  DateTime? fitUpTo;
  String fuelType;
  String insuranceCompany;
  String insurancePolicyNumber;
  DateTime? insuranceUpto;
  DateTime? latestBy;
  bool lessInfo;
  String makerDescription;
  String makerModel;
  String manufacturingDate;
  String manufacturingDateFormatted;
  bool maskedName;
  String mobileNumber;
  dynamic nationalPermitIssuedBy;
  String nationalPermitNumber;
  dynamic nationalPermitUpto;
  String noCylinders;
  String nocDetails;
  dynamic nonUseFrom;
  dynamic nonUseStatus;
  dynamic nonUseTo;
  String normsType;
  String ownerName;
  String ownerNumber;
  String permanentAddress;
  dynamic permitIssueDate;
  String permitNumber;
  String permitType;
  dynamic permitValidFrom;
  dynamic permitValidUpto;
  String presentAddress;
  String puccNumber;
  dynamic puccUpto;
  String rcNumber;
  String rcStatus;
  String registeredAt;
  DateTime? registrationDate;
  ResponseMetadata responseMetadata;
  String rtoCode;
  String seatCapacity;
  String sleeperCapacity;
  String standingCapacity;
  DateTime? taxPaidUpto;
  DateTime? taxUpto;
  String unladenWeight;
  dynamic variant;
  String vehicleCategory;
  String vehicleCategoryDescription;
  String vehicleChasiNumber;
  String vehicleEngineNumber;
  String vehicleGrossWeight;
  String wheelbase;

  RCData({
    required this.blacklistStatus,
    required this.bodyType,
    required this.challanDetails,
    required this.clientId,
    required this.color,
    required this.cubicCapacity,
    required this.fatherName,
    required this.financed,
    required this.financer,
    required this.fitUpTo,
    required this.fuelType,
    required this.insuranceCompany,
    required this.insurancePolicyNumber,
    required this.insuranceUpto,
    required this.latestBy,
    required this.lessInfo,
    required this.makerDescription,
    required this.makerModel,
    required this.manufacturingDate,
    required this.manufacturingDateFormatted,
    required this.maskedName,
    required this.mobileNumber,
    required this.nationalPermitIssuedBy,
    required this.nationalPermitNumber,
    required this.nationalPermitUpto,
    required this.noCylinders,
    required this.nocDetails,
    required this.nonUseFrom,
    required this.nonUseStatus,
    required this.nonUseTo,
    required this.normsType,
    required this.ownerName,
    required this.ownerNumber,
    required this.permanentAddress,
    required this.permitIssueDate,
    required this.permitNumber,
    required this.permitType,
    required this.permitValidFrom,
    required this.permitValidUpto,
    required this.presentAddress,
    required this.puccNumber,
    required this.puccUpto,
    required this.rcNumber,
    required this.rcStatus,
    required this.registeredAt,
    required this.registrationDate,
    required this.responseMetadata,
    required this.rtoCode,
    required this.seatCapacity,
    required this.sleeperCapacity,
    required this.standingCapacity,
    required this.taxPaidUpto,
    required this.taxUpto,
    required this.unladenWeight,
    required this.variant,
    required this.vehicleCategory,
    required this.vehicleCategoryDescription,
    required this.vehicleChasiNumber,
    required this.vehicleEngineNumber,
    required this.vehicleGrossWeight,
    required this.wheelbase,
  });

  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  factory RCData.fromJson(Map<String, dynamic> json) => RCData(
    blacklistStatus: json["blacklist_status"] ?? '',
    bodyType: json["body_type"] ?? '',
    challanDetails: json["challan_details"],
    clientId: json["client_id"] ?? '',
    color: json["color"] ?? '',
    cubicCapacity: json["cubic_capacity"] ?? '',
    fatherName: json["father_name"] ?? '',
    financed: json["financed"] ?? false,
    financer: json["financer"] ?? '',
    fitUpTo: _tryParseDate(json["fit_up_to"]),
    fuelType: json["fuel_type"] ?? '',
    insuranceCompany: json["insurance_company"] ?? '',
    insurancePolicyNumber: json["insurance_policy_number"] ?? '',
    insuranceUpto: _tryParseDate(json["insurance_upto"]),
    latestBy: _tryParseDate(json["latest_by"]),
    lessInfo: json["less_info"] ?? false,
    makerDescription: json["maker_description"] ?? '',
    makerModel: json["maker_model"] ?? '',
    manufacturingDate: json["manufacturing_date"] ?? '',
    manufacturingDateFormatted: json["manufacturing_date_formatted"] ?? '',
    maskedName: json["masked_name"] ?? false,
    mobileNumber: json["mobile_number"] ?? '',
    nationalPermitIssuedBy: json["national_permit_issued_by"],
    nationalPermitNumber: json["national_permit_number"] ?? '',
    nationalPermitUpto: json["national_permit_upto"],
    noCylinders: json["no_cylinders"] ?? '',
    nocDetails: json["noc_details"] ?? '',
    nonUseFrom: json["non_use_from"],
    nonUseStatus: json["non_use_status"],
    nonUseTo: json["non_use_to"],
    normsType: json["norms_type"] ?? '',
    ownerName: json["owner_name"] ?? '',
    ownerNumber: json["owner_number"] ?? '',
    permanentAddress: json["permanent_address"] ?? '',
    permitIssueDate: json["permit_issue_date"],
    permitNumber: json["permit_number"] ?? '',
    permitType: json["permit_type"] ?? '',
    permitValidFrom: json["permit_valid_from"],
    permitValidUpto: json["permit_valid_upto"],
    presentAddress: json["present_address"] ?? '',
    puccNumber: json["pucc_number"] ?? '',
    puccUpto: json["pucc_upto"],
    rcNumber: json["rc_number"] ?? '',
    rcStatus: json["rc_status"] ?? '',
    registeredAt: json["registered_at"] ?? '',
    registrationDate: _tryParseDate(json["registration_date"]),
    responseMetadata: ResponseMetadata.fromJson(
      json["response_metadata"] ?? const {},
    ),
    rtoCode: json["rto_code"] ?? '',
    seatCapacity: json["seat_capacity"] ?? '',
    sleeperCapacity: json["sleeper_capacity"] ?? '',
    standingCapacity: json["standing_capacity"] ?? '',
    taxPaidUpto: _tryParseDate(json["tax_paid_upto"]),
    taxUpto: _tryParseDate(json["tax_upto"]),
    unladenWeight: json["unladen_weight"] ?? '',
    variant: json["variant"],
    vehicleCategory: json["vehicle_category"] ?? '',
    vehicleCategoryDescription: json["vehicle_category_description"] ?? '',
    vehicleChasiNumber: json["vehicle_chasi_number"] ?? '',
    vehicleEngineNumber: json["vehicle_engine_number"] ?? '',
    vehicleGrossWeight: json["vehicle_gross_weight"] ?? '',
    wheelbase: json["wheelbase"] ?? '',
  );

  static String? _formatDate(DateTime? date) {
    if (date == null) return null;
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Map<String, dynamic> toJson() => {
    "blacklist_status": blacklistStatus,
    "body_type": bodyType,
    "challan_details": challanDetails,
    "client_id": clientId,
    "color": color,
    "cubic_capacity": cubicCapacity,
    "father_name": fatherName,
    "financed": financed,
    "financer": financer,
    "fit_up_to": _formatDate(fitUpTo),
    "fuel_type": fuelType,
    "insurance_company": insuranceCompany,
    "insurance_policy_number": insurancePolicyNumber,
    "insurance_upto": _formatDate(insuranceUpto),
    "latest_by": _formatDate(latestBy),
    "less_info": lessInfo,
    "maker_description": makerDescription,
    "maker_model": makerModel,
    "manufacturing_date": manufacturingDate,
    "manufacturing_date_formatted": manufacturingDateFormatted,
    "masked_name": maskedName,
    "mobile_number": mobileNumber,
    "national_permit_issued_by": nationalPermitIssuedBy,
    "national_permit_number": nationalPermitNumber,
    "national_permit_upto": nationalPermitUpto,
    "no_cylinders": noCylinders,
    "noc_details": nocDetails,
    "non_use_from": nonUseFrom,
    "non_use_status": nonUseStatus,
    "non_use_to": nonUseTo,
    "norms_type": normsType,
    "owner_name": ownerName,
    "owner_number": ownerNumber,
    "permanent_address": permanentAddress,
    "permit_issue_date": permitIssueDate,
    "permit_number": permitNumber,
    "permit_type": permitType,
    "permit_valid_from": permitValidFrom,
    "permit_valid_upto": permitValidUpto,
    "present_address": presentAddress,
    "pucc_number": puccNumber,
    "pucc_upto": puccUpto,
    "rc_number": rcNumber,
    "rc_status": rcStatus,
    "registered_at": registeredAt,
    "registration_date": _formatDate(registrationDate),
    "response_metadata": responseMetadata.toJson(),
    "rto_code": rtoCode,
    "seat_capacity": seatCapacity,
    "sleeper_capacity": sleeperCapacity,
    "standing_capacity": standingCapacity,
    "tax_paid_upto": _formatDate(taxPaidUpto),
    "tax_upto": _formatDate(taxUpto),
    "unladen_weight": unladenWeight,
    "variant": variant,
    "vehicle_category": vehicleCategory,
    "vehicle_category_description": vehicleCategoryDescription,
    "vehicle_chasi_number": vehicleChasiNumber,
    "vehicle_engine_number": vehicleEngineNumber,
    "vehicle_gross_weight": vehicleGrossWeight,
    "wheelbase": wheelbase,
  };
}

class ResponseMetadata {
  bool maskedChassis;
  bool maskedEngine;
  bool maskedOwnerName;

  ResponseMetadata({
    required this.maskedChassis,
    required this.maskedEngine,
    required this.maskedOwnerName,
  });

  factory ResponseMetadata.fromJson(Map<String, dynamic> json) =>
      ResponseMetadata(
        maskedChassis: json["masked_chassis"] ?? false,
        maskedEngine: json["masked_engine"] ?? false,
        maskedOwnerName: json["masked_owner_name"] ?? false,
      );

  Map<String, dynamic> toJson() => {
    "masked_chassis": maskedChassis,
    "masked_engine": maskedEngine,
    "masked_owner_name": maskedOwnerName,
  };
}
