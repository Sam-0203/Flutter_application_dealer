class VerifyRegistrationModel {
  final String contactPerson;
  final String pincode;
  final int stateId;
  final int cityId;
  final int preferredLanguageId;
  final String mobile;
  final String loginType;
  final String roleType;
  final String authType;
  final String otp;

  // Optional
  final String? email;
  final String? gstNumber;
  final String? dealershipName;

  final String? alternateMobileNumber;
  final String? instagramProfile;
  final String? facebookProfile;
  final String? websiteUrl;

  VerifyRegistrationModel({
    required this.contactPerson,
    required this.pincode,
    required this.stateId,
    required this.cityId,
    required this.preferredLanguageId,
    required this.mobile,
    required this.loginType,
    required this.roleType,
    required this.authType,
    required this.otp,
    this.email,
    this.gstNumber,
    this.dealershipName,
    this.alternateMobileNumber,
    this.instagramProfile,
    this.facebookProfile,
    this.websiteUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      "dealership_name": dealershipName,
      "contact_person": contactPerson,
      "pincode": pincode,
      "state_id": stateId,
      "city_id": cityId,
      "preferred_language_id": preferredLanguageId,
      "gst_number": gstNumber,
      "mobile": mobile,
      "login_type": loginType,
      "role_type": roleType,
      "auth_type": authType,
      "otp": otp,
      if (email != null) "email": email,
      if (alternateMobileNumber != null)
        "alternate_mobile_number": alternateMobileNumber,
      if (instagramProfile != null) "instagram_profile": instagramProfile,
      if (facebookProfile != null) "facebook_profile": facebookProfile,
      if (websiteUrl != null) "website_url": websiteUrl,
    };
  }
}
