import 'dart:convert';

import 'package:dealershub_/src/models/user%20models/reponses/login_verification.dart';
import 'package:dealershub_/src/models/user%20models/reponses/user_verify_response.dart';
import 'package:dealershub_/src/models/user%20models/requests/agent_delear_register_verify.dart';
import 'package:dealershub_/src/models/user%20models/reponses/register_response.dart';
import 'package:dealershub_/src/models/user%20models/requests/login_request.dart';
import 'package:dealershub_/src/models/user%20models/requests/login_verification_request.dart';
import 'package:dealershub_/src/models/user%20models/requests/user_register_model.dart';
import 'package:dealershub_/src/models/user%20models/user_porofile%20model/agent_profile_responses_model-copy.dart';
import 'package:dealershub_/src/models/user%20models/user_porofile%20model/dealer_profile_responses_model.dart';
import 'package:dealershub_/src/services/user_service.dart';
import 'package:dealershub_/src/utils/helper/secure_storage.dart';
import 'package:flutter/material.dart';

// Dealer or Agent register :=====>
class AuthViewModel extends ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();

  bool isLoading = false;
  String? error;

  Future<RegisterResponse?> register(RegisterRequest request) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _apiService.registerUser(request);
      if (response == null) {
        error = _apiService.lastError ?? 'Registration failed.';
        debugPrint("❌ REGISTER ERROR: $error");
        return null;
      }

      // 🔥 FULL PARSED RESPONSE
      debugPrint("📥 FULL REGISTER RESPONSE (PARSED):");
      debugPrint(jsonEncode(response.toJson()));

      return response;
    } catch (e) {
      error = 'Registration failed. Please try again.';
      debugPrint("❌ REGISTER ERROR: $error");
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Dealer or Agent register verification :=====>
class DealerViewModel extends ChangeNotifier {
  final OtpVerificationService _service = OtpVerificationService();

  bool isLoading = false;
  String? errorMessage;

  Future<UserVerifyResponse?> registerDealer({
    required VerifyRegistrationModel model,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await _service.userRegister(model);
      if (response == null) {
        errorMessage = _service.lastError ?? 'OTP verification failed.';
        return null;
      }
      return response;
    } catch (e) {
      errorMessage = 'OTP verification failed. Please try again.';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Dealer or Agent login :=====>
class LoginViewModel extends ChangeNotifier {
  final LoginUser _apiService = LoginUser();

  bool isLoading = false;
  String? error;

  Future<UserOTPResponse?> login(LoginRequestModel request) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _apiService.loginUser(request);
      if (response == null) {
        error = _apiService.lastError ?? 'Failed to send OTP';
        return null;
      }
      debugPrint('LoginViewModel response : ${response.data.otp}');
      return response;
    } catch (e) {
      error = 'Failed to send OTP';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Dealer or Agent login verification :=====>
class LoginOtpViewModel extends ChangeNotifier {
  final LoginOtpVerifyService _service = LoginOtpVerifyService();

  bool isLoading = false;
  String? error;
  UserVerifyResponse? user; // ✅ STORE USER DATA

  Future<UserVerifyResponse?> verifyOtp(LoginOtpVerifyModel model) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.verifyLoginOtp(model);
      if (response == null) {
        error = _service.lastError ?? 'OTP verification failed.';
        return null;
      }
      return response;
    } catch (e) {
      error = 'OTP verification failed. Please try again.';
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

// Dealer Profile View :=====>
class DealerProfileViewModel extends ChangeNotifier {
  final DealerProfileService _service = DealerProfileService();

  DealerPofileResponse? _profile;
  bool _isLoading = false;
  String? _error;

  // 🔓 Getters
  DealerPofileResponse? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 🚀 Fetch Dealer Profile
  Future<void> fetchDealerProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.fetchDealerProfile();

      if (response.statusCode == 200) {
        _profile = dealerPofileResponseFromJson(response.body);
      } else {
        _error = "Failed to load profile (${response.statusCode})";
      }
    } catch (e) {
      _error = e.toString();
      debugPrint("Dealer Profile Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}

// Agent Profile View :=====>
class AgentProfileViewModel extends ChangeNotifier {
  final AgentProfileService _service = AgentProfileService();

  AgentPofileResponse? _profile;
  bool _isLoading = false;
  String? _error;

  // 🔓 Getters
  AgentPofileResponse? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 🚀 Fetch Agent Profile
  Future<void> fetchAgentProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _service.fetchAgentProfile();

      if (response.statusCode == 200) {
        _profile = agentPofileResponseFromJson(response.body);
      } else {
        _error = "Failed to load profile (${response.statusCode})";
      }
    } catch (e) {
      _error = e.toString();
      debugPrint("Agent Profile Error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}

// User Logout :=====>
class LogoutViewModel extends ChangeNotifier {
  final LogoutService _service = LogoutService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    final success = await _service.logout();
    debugPrint('User logged out: $success');

    if (success) {
      // ✅ Clear local data
      await SecureStorage.clearAll(); // or delete token
    }

    _isLoading = false;
    notifyListeners();

    return success;
  }
}
