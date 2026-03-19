class RegisterRequest {
  final String? dealershipName;
  final String contactPerson;
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
  final String loginType;
  final String roleType;
  final String authType;

  RegisterRequest({
    this.dealershipName,
    required this.contactPerson,
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
    required this.loginType,
    required this.roleType,
    required this.authType,
  });

  Map<String, dynamic> toJson() {
    return {
      "dealership_name": dealershipName,
      "contact_person": contactPerson,
      "mobile": mobile,
      "pincode": pincode,
      "state_id": stateId,
      "city_id": cityId,
      "preferred_language_id": preferredLanguageId,
      if (gstNumber != null) "gst_number": gstNumber,
      if (email != null) "email": email,
      if (alternateMobileNumber != null)
        "alternate_mobile_number": alternateMobileNumber,
      if (instagramProfile != null) "instagram_profile": instagramProfile,
      if (facebookProfile != null) "facebook_profile": facebookProfile,
      if (websiteUrl != null) "website_url": websiteUrl,
      "login_type": loginType,
      "role_type": roleType,
      "auth_type": authType,
    };
  }
}
