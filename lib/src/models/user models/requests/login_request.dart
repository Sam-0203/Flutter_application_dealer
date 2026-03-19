class LoginRequestModel {
  final String mobile;
  final String loginType;
  final String roleType;
  final String authType;

  LoginRequestModel({
    required this.mobile,
    required this.loginType,
    required this.roleType,
    required this.authType,
  });

  Map<String, dynamic> toJson() {
    return {
      "mobile": mobile,
      "login_type": loginType,
      "role_type": roleType,
      "auth_type": authType,
    };
  }
}
