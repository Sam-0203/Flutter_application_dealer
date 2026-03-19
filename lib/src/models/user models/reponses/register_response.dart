class RegisterResponse {
  final String message;
  final bool status;
  final int statusCode;
  final Data data;

  RegisterResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json["message"],
      status: json["status"],
      statusCode: json["status_code"],
      data: Data.fromJson(json["data"]),
    );
  }

  // ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "status": status,
      "status_code": statusCode,
      "data": data.toJson(),
    };
  }
}

class Data {
  final String? dealershipName;
  final String? contactPerson;
  final String mobile;
  final String pincode;
  final int stateId;
  final int cityId;
  final int preferredLanguageId;
  final String? gstNumber;
  final String? email;
  final String? alternateMobileNumber;
  final String? instagramProfile;
  final String? facebookProfile;
  final String? websiteUrl;
  final String otp;
  final String roleType;
  final String authType;

  Data({
    this.dealershipName,
    this.contactPerson,
    required this.mobile,
    required this.pincode,
    required this.stateId,
    required this.cityId,
    required this.preferredLanguageId,
    this.gstNumber,
    this.email,
    this.alternateMobileNumber,
    this.instagramProfile,
    this.facebookProfile,
    this.websiteUrl,
    required this.otp,
    required this.roleType,
    required this.authType,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      dealershipName: json["dealership_name"],
      contactPerson: json["contact_person"],
      mobile: json["mobile"],
      pincode: json["pincode"],
      stateId: json["state_id"],
      cityId: json["city_id"],
      preferredLanguageId: json["preferred_language_id"],
      gstNumber: json["gst_number"],
      email: json["email"],
      alternateMobileNumber: json["alternate_mobile_number"],
      instagramProfile: json["instagram_profile"],
      facebookProfile: json["facebook_profile"],
      websiteUrl: json["website_url"],
      otp: json["otp"],
      roleType: json["role_type"],
      authType: json["auth_type"],
    );
  }

  // ✅ ADD THIS
  Map<String, dynamic> toJson() {
    return {
      "dealership_name": dealershipName,
      "contact_person": contactPerson,
      "mobile": mobile,
      "pincode": pincode,
      "state_id": stateId,
      "city_id": cityId,
      "preferred_language_id": preferredLanguageId,
      "gst_number": gstNumber,
      "email": email,
      "alternate_mobile_number": alternateMobileNumber,
      "instagram_profile": instagramProfile,
      "facebook_profile": facebookProfile,
      "website_url": websiteUrl,
      "otp": otp,
      "role_type": roleType,
      "auth_type": authType,
    };
  }
}
