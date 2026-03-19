import 'dart:convert';

import 'package:dealershub_/src/models/user%20models/reponses/login_verification.dart';
import 'package:dealershub_/src/models/user%20models/reponses/user_verify_response.dart';
import 'package:dealershub_/src/models/user%20models/requests/agent_delear_register_verify.dart';
import 'package:dealershub_/src/models/user%20models/reponses/register_response.dart';
import 'package:dealershub_/src/models/user%20models/requests/login_request.dart';
import 'package:dealershub_/src/models/user%20models/requests/login_verification_request.dart';
import 'package:dealershub_/src/models/user%20models/requests/user_register_model.dart';
import 'package:dealershub_/src/utils/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// User Authentication API Service user registration
class AuthApiService {
  Future<RegisterResponse> registerUser(RegisterRequest request) async {
    final response = await http.post(
      Uri.parse(ApiUrls.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    // 🔥 RAW BACKEND RESPONSE
    debugPrint("🌐 RAW REGISTER RESPONSE:");
    debugPrint(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      return RegisterResponse.fromJson(decoded);
    } else {
      throw Exception("Registration failed: ${response.body}");
    }
  }
}

// User Authentication API OTP Verification Service
class OtpVerificationService {
  Future<UserVerifyResponse> userRegister(VerifyRegistrationModel model) async {
    final response = await http.post(
      Uri.parse(ApiUrls.verifyOTP),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(model.toJson()),
    );

    debugPrint('Signup OTP Verify Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return UserVerifyResponse.fromJson(json); // ✅ IMPORTANT
    } else {
      throw Exception("OTP verification failed: ${response.body}");
    }
  }
}

// Language Service to fetch languages
class LanguageService {
  Future<http.Response> fetchLanguages() async {
    final response = await http.get(Uri.parse(ApiUrls.languages));
    return response;
  }
}

// ✅ LOGIN API
class LoginUser {
  Future<UserOTPResponse> loginUser(LoginRequestModel request) async {
    final response = await http.post(
      Uri.parse(ApiUrls.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      print('Login Response : ${response.body}');
      return UserOTPResponse.fromJson(json); // ✅ CORRECT
    } else {
      throw Exception('OTP send failed');
    }
  }
}

// Dealer or Agent OTP verfication service
class LoginOtpVerifyService {
  Future<UserVerifyResponse> verifyLoginOtp(LoginOtpVerifyModel model) async {
    final response = await http.post(
      Uri.parse(ApiUrls.verifyOTP),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(model.toJson()),
    );

    print('Login OTP Verify Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return UserVerifyResponse.fromJson(json); // ✅ PARSE RESPONSE
    } else {
      throw Exception('Login OTP verification failed: ${response.body}');
    }
  }
}

