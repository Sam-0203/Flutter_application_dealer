import 'dart:convert';

import 'package:dealershub_/src/models/user%20models/reponses/login_verification.dart';
import 'package:dealershub_/src/models/user%20models/reponses/user_verify_response.dart';
import 'package:dealershub_/src/models/user%20models/requests/agent_delear_register_verify.dart';
import 'package:dealershub_/src/models/user%20models/reponses/register_response.dart';
import 'package:dealershub_/src/models/user%20models/requests/login_request.dart';
import 'package:dealershub_/src/models/user%20models/requests/login_verification_request.dart';
import 'package:dealershub_/src/models/user%20models/requests/user_register_model.dart';
import 'package:dealershub_/src/models/user%20models/user_porofile%20model/dealer_profile_responses_model.dart';
import 'package:dealershub_/src/utils/api_urls.dart';
import 'package:dealershub_/src/utils/helper/secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

String _extractApiMessage(String body, {required String fallback}) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final message = decoded['message']?.toString().trim();
      final errors = decoded['errors'];

      if (errors is Map<String, dynamic>) {
        final flattenedErrors = errors.entries
            .map((entry) {
              final value = entry.value;
              if (value is List) {
                return value.whereType<String>().join(', ');
              }
              return value?.toString() ?? '';
            })
            .where((e) => e.isNotEmpty)
            .join('\n');

        if (flattenedErrors.isNotEmpty) {
          if (message != null && message.isNotEmpty) {
            return '$message: $flattenedErrors';
          }
          return flattenedErrors;
        }
      } else if (errors is List) {
        final listErrors = errors
            .whereType<String>()
            .where((s) => s.isNotEmpty)
            .join(', ');
        if (listErrors.isNotEmpty) {
          if (message != null && message.isNotEmpty) {
            return '$message: $listErrors';
          }
          return listErrors;
        }
      }

      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
  } catch (e) {
    debugPrint('API message parse failed: $e');
  }

  return fallback;
}

// User Authentication API Service user registration
class AuthApiService {
  String? lastError;

  Future<RegisterResponse?> registerUser(RegisterRequest request) async {
    lastError = null;
    try {
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
      }

      lastError = _extractApiMessage(
        response.body,
        fallback: 'Registration failed. Please try again.',
      );
      return null;
    } catch (e) {
      lastError = 'Registration failed. Please try again.';
      debugPrint('Registration API error: $e');
      return null;
    }
  }
}

// User Authentication API OTP Verification Service
class OtpVerificationService {
  String? lastError;

  Future<UserVerifyResponse?> userRegister(
    VerifyRegistrationModel model,
  ) async {
    lastError = null;
    try {
      final response = await http.post(
        Uri.parse(ApiUrls.verifyOTP),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(model.toJson()),
      );

      debugPrint('Signup OTP Verify Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return UserVerifyResponse.fromJson(json); // ✅ IMPORTANT
      }

      lastError = _extractApiMessage(
        response.body,
        fallback: 'OTP verification failed. Please try again.',
      );
      return null;
    } catch (e) {
      lastError = 'OTP verification failed. Please try again.';
      debugPrint('Signup OTP verification API error: $e');
      return null;
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
  String? lastError;

  Future<UserOTPResponse?> loginUser(LoginRequestModel request) async {
    lastError = null;
    try {
      final response = await http.post(
        Uri.parse(ApiUrls.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        debugPrint('Login Response : ${response.body}');
        return UserOTPResponse.fromJson(json); // ✅ CORRECT
      }

      lastError = _extractApiMessage(
        response.body,
        fallback: 'Your mobile number is not registered. Please sign up first.',
      );
      return null;
    } catch (e) {
      lastError = 'Failed to send OTP. Please try again.';
      debugPrint('Login API error: $e');
      return null;
    }
  }
}

// Dealer or Agent OTP verfication service
class LoginOtpVerifyService {
  String? lastError;

  Future<UserVerifyResponse?> verifyLoginOtp(LoginOtpVerifyModel model) async {
    lastError = null;
    try {
      final response = await http.post(
        Uri.parse(ApiUrls.verifyOTP),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(model.toJson()),
      );

      debugPrint('Login OTP Verify Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        return UserVerifyResponse.fromJson(json); // ✅ PARSE RESPONSE
      }

      lastError = _extractApiMessage(
        response.body,
        fallback: 'Login OTP verification failed. Please try again.',
      );
      return null;
    } catch (e) {
      lastError = 'Login OTP verification failed. Please try again.';
      debugPrint('Login OTP verification API error: $e');
      return null;
    }
  }
}

// Dealer Profile view API Service
class DealerProfileService {
  Future<http.Response> fetchDealerProfile() async {
    final token = await SecureStorage.getToken();
    final uri = Uri.parse(ApiUrls.getDealerUserProfile);

    try {
      return await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      debugPrint('Fetch dealer profile error: $e');
      rethrow;
    }
  }
}

// Agent Profile view API Service
class AgentProfileService {
  Future<http.Response> fetchAgentProfile() async {
    final token = await SecureStorage.getToken();
    final uri = Uri.parse(ApiUrls.getAgentUserProfile);

    try {
      return await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    } catch (e) {
      debugPrint('Fetch agent profile error: $e');
      rethrow;
    }
  }
}

// User Logout API Service
class LogoutService {
  Future<bool> logout() async {
    final token = await SecureStorage.getToken();
    final uri = Uri.parse(ApiUrls.UserLoggedOut);

    try {
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        return true; // ✅ success
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Logout API error: $e');
      return false;
    }
  }
}
