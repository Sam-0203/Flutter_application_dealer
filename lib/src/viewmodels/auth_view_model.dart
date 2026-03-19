import 'dart:convert';

import 'package:dealershub_/src/models/user%20models/reponses/login_verification.dart';
import 'package:dealershub_/src/models/user%20models/reponses/user_verify_response.dart';
import 'package:dealershub_/src/models/user%20models/requests/agent_delear_register_verify.dart';
import 'package:dealershub_/src/models/user%20models/reponses/register_response.dart';
import 'package:dealershub_/src/models/user%20models/requests/login_request.dart';
import 'package:dealershub_/src/models/user%20models/requests/login_verification_request.dart';
import 'package:dealershub_/src/models/user%20models/requests/user_register_model.dart';
import 'package:dealershub_/src/services/user_service.dart';
import 'package:flutter/material.dart';

// Dealer or Agent register :=====>
class AuthViewModel extends ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();

  bool isLoading = false;
  String? error;

  Future<RegisterResponse?> register(RegisterRequest request) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.registerUser(request);

      // 🔥 FULL PARSED RESPONSE
      debugPrint("📥 FULL REGISTER RESPONSE (PARSED):");
      debugPrint(jsonEncode(response.toJson()));

      return response;
    } catch (e) {
      error = e.toString();
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
      return response;
    } catch (e) {
      errorMessage = e.toString();
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
      print('LoginViewModel response : ${response.data.otp}');
      return response;
    } catch (e) {
      error = e.toString();
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
      return await _service.verifyLoginOtp(model);
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
