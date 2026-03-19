class LoginOtpVerifyModel {
  final String mobile;
  final String loginType;
  final String roleType;
  final String authType;
  final String otp;

  LoginOtpVerifyModel({
    required this.mobile,
    required this.loginType,
    required this.roleType,
    required this.authType,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      "mobile": mobile,
      "login_type": loginType,
      "role_type": roleType,
      "auth_type": authType,
      "otp": otp,
    };
  }
}
