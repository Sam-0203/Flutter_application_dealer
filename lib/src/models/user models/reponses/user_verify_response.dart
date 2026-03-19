class UserOTPResponse {
  final String message;
  final bool status;
  final int statusCode;
  final UserVerifyData data;

  UserOTPResponse({
    required this.message,
    required this.status,
    required this.statusCode,
    required this.data,
  });

  factory UserOTPResponse.fromJson(Map<String, dynamic> json) {
    return UserOTPResponse(
      message: json['message'],
      status: json['status'].toString().toLowerCase() == 'true',
      statusCode: json['status_code'],
      data: UserVerifyData.fromJson(json['data']),
    );
  }
}

class UserVerifyData {
  final String mobile;
  final String otp;
  final String roleType;
  final String authType;

  UserVerifyData({
    required this.mobile,
    required this.otp,
    required this.roleType,
    required this.authType,
  });

  factory UserVerifyData.fromJson(Map<String, dynamic> json) {
    return UserVerifyData(
      mobile: json['mobile'],
      otp: json['otp'],
      roleType: json['role_type'],
      authType: json['auth_type'],
    );
  }
}
