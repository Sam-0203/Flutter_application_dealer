import 'dart:async';
import 'dart:convert';
import 'package:dealershub_/src/models/user%20models/reponses/user_verify_response.dart';
import 'package:dealershub_/src/models/user%20models/requests/agent_delear_register_verify.dart';
import 'package:dealershub_/src/models/user%20models/reponses/register_response.dart';
import 'package:dealershub_/src/models/user%20models/requests/login_verification_request.dart';
import 'package:dealershub_/src/utils/helper/secure_storage.dart';
import 'package:dealershub_/src/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:provider/provider.dart';

import '../../utils/app_costants.dart';
import '../../utils/route/route.dart';

class OtpScreen extends StatefulWidget {
  final String value; // phone number from login or signup
  final dynamic registerResponse; // RegisterResponse OR UserVerifyResponse

  const OtpScreen({
    super.key,
    required this.value,
    required this.registerResponse,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // ---------------- OTP State ----------------
  String _code = '';
  late final FocusNode _pinFocusNode;
  bool get isLoginFlow => widget.registerResponse is UserOTPResponse;
  bool get isSignupFlow => widget.registerResponse is RegisterResponse;

  // ---------------- Backend OTP ----------------
  String get backendOtp {
    if (widget.registerResponse is RegisterResponse) {
      return (widget.registerResponse as RegisterResponse).data.otp;
    } else if (widget.registerResponse is UserOTPResponse) {
      return (widget.registerResponse as UserOTPResponse).data.otp;
    } else {
      throw Exception('Invalid OTP response type');
    }
  }

  // ---------------- Resend Timer ----------------
  Timer? _timer;
  int _seconds = 60;
  bool _isTimerRunning = false;

  static const int otpLength = 4;

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();

    _pinFocusNode = FocusNode();
    // Start SMS autofill listener (optional - works if SMS autofill is available)
    // SmsAutoFill().listenForCode();
  }

  // ---------------- DISPOSE ----------------
  @override
  void dispose() {
    _timer?.cancel();
    _pinFocusNode.dispose();
    // SmsAutoFill().unregisterListener();
    super.dispose();
  }

  // ---------------- Get OTP ----------------
  String get _otp => _code;

  // ---------------- Verify OTP ----------------
  Future<void> _verifyOtp() async {
    final enteredOtp = _otp;

    print("Enterd otp $enteredOtp");

    /// ================= LOGIN FLOW =================
    if (isLoginFlow) {
      final loginResponse = widget.registerResponse as UserOTPResponse;
      final loginOtpVM = context.read<LoginOtpViewModel>();

      print(loginResponse);
      final model = LoginOtpVerifyModel(
        mobile: loginResponse.data.mobile,
        loginType: 'mobile',
        roleType: loginResponse.data.roleType,
        authType: 'login',
        otp: enteredOtp,
      );

      final response = await loginOtpVM.verifyOtp(model);

      if (response == null) {
        _showError(
          loginOtpVM.error is String
              ? loginOtpVM.error as String
              : 'OTP verification failed',
        );

        return;
      }

      // 🔐 SAVE ONLY ACCESS TOKEN
      await SecureStorage.saveTokenAndRole(
        token: response.data.accessToken,
        role: response.data.role,
      );

      debugPrint('Saved Token: ${response.data.accessToken}');
      debugPrint('Saved Role: ${response.data.role}');

      // ✅ LOGIN SUCCESS → HOME
      Navigator.pushNamedAndRemoveUntil(
        context,
        mainHomeScreen,
        (route) => false,
        arguments: {'role': loginResponse.data.roleType},
      );
      return;
    }

    /// ================= SIGNUP FLOW =================
    if (isSignupFlow) {
      final signupResponse = widget.registerResponse as RegisterResponse;
      final dealerVM = context.read<DealerViewModel>();

      final verifyModel = VerifyRegistrationModel(
        dealershipName: signupResponse.data.dealershipName ?? '',
        contactPerson: signupResponse.data.contactPerson ?? '',
        pincode: signupResponse.data.pincode,
        stateId: signupResponse.data.stateId,
        cityId: signupResponse.data.cityId,
        preferredLanguageId: signupResponse.data.preferredLanguageId,
        mobile: signupResponse.data.mobile,
        loginType: 'mobile',
        roleType: signupResponse.data.roleType,
        authType: signupResponse.data.authType,
        otp: enteredOtp,

        email: signupResponse.data.email,
        gstNumber: signupResponse.data.gstNumber,
        alternateMobileNumber: signupResponse.data.alternateMobileNumber,
        instagramProfile: signupResponse.data.instagramProfile,
        facebookProfile: signupResponse.data.facebookProfile,
        websiteUrl: signupResponse.data.websiteUrl,
      );

      // ✅ CAPTURE VERIFY RESPONSE (THIS WAS MISSING)
      final response = await dealerVM.registerDealer(model: verifyModel);

      if (response == null) {
        String errorMsg = dealerVM.errorMessage is String
            ? dealerVM.errorMessage as String
            : 'Registration failed';

        debugPrint("ErrorMsg: $errorMsg");

        String? extractedMessage;
        try {
          // Format: "Exception: Registration failed: {json}"
          if (errorMsg.contains('Registration failed:')) {
            String jsonPart = errorMsg.split('Registration failed: ').last;
            Map<String, dynamic> json = jsonDecode(jsonPart);
            extractedMessage = json['message'];
            debugPrint("Extracted message: $extractedMessage");
          }
        } catch (e) {
          debugPrint("Error parsing error message: $e");
        }

        if (extractedMessage == 'User already exists') {
          debugPrint("Showing user already exists dialog");
          _userAlreadyExistsDialog();
        } else {
          debugPrint("Showing generic error dialog");
          _showError(errorMsg);
        }

        return;
      }

      // 🔐 SAVE TOKEN + ROLE
      await SecureStorage.saveTokenAndRole(
        token: response.data.accessToken,
        role: response.data.role,
      );

      debugPrint('🔐 Saved Token: ${response.data.accessToken}');
      debugPrint('👤 Saved Role: ${response.data.role}');

      // ✅ SIGNUP SUCCESS → HOME
      Navigator.pushNamedAndRemoveUntil(
        context,
        mainHomeScreen,
        (route) => false,
        arguments: {'role': signupResponse.data.roleType},
      );
    }
  }

  // User already exists error dialog
  void _userAlreadyExistsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'OTP Verification',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        content: Text(
          "User with this phone number already exists. Please try logging in instead.",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xffF47B39),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Generic error dialog for OTP verification failures
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'OTP Verification',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        content: Text(
          "Wrong OTP entered. Please try again.",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xffF47B39),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // KeyboardActions config that shows a Done button for the pin field
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _pinFocusNode,
          toolbarButtons: [(node) => DoneButton(onTap: node.unfocus)],
        ),
      ],
    );
  }

  // ---------------- Mask Phone ----------------
  String maskPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(' ', '');
    if (cleaned.length < 4) return cleaned;
    final last4 = cleaned.substring(cleaned.length - 4);
    return '${'*' * (cleaned.length - 4)}$last4';
  }

  // ---------------- Timer ----------------
  void _startTimer() {
    setState(() {
      _seconds = 60;
      _isTimerRunning = true;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds--;
        if (_seconds <= 0) {
          _seconds = 0;
          timer.cancel();
          _isTimerRunning = false;
        }
      });
    });
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    debugPrint("OTP Screen ${widget.registerResponse}");

    final width = MediaQuery.of(context).size.width;
    final dealerVM = context.watch<DealerViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Row(
            children: [
              const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.black,
              ),
              const SizedBox(width: 6),
              Text(
                TextViews.Backbutton1.data!,
                style: TextViews.Backbutton1.style,
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: KeyboardActions(
          config: _buildConfig(context),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 24),

                Image.asset('assets/placeholders/Enter_OTP_text.png'),
                const SizedBox(height: 20),

                Image.asset(
                  'assets/placeholders/Enter_otp_Img.png',
                  width: width * 0.55,
                ),

                const SizedBox(height: 24),

                Text(
                  'A 4-digit code has been sent to\n ${maskPhoneNumber(widget.value)}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: const Color.fromRGBO(41, 68, 135, 1),
                  ),
                ),

                const SizedBox(height: 32),

                // Pin field with SMS autofill support
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Focus(
                    focusNode: _pinFocusNode,
                    child: PinFieldAutoFill(
                      codeLength: otpLength,
                      currentCode: _code,
                      onCodeChanged: (code) {
                        setState(() {
                          _code = code ?? '';
                        });
                        if (code != null && code.length == otpLength) {
                          // Optionally auto-verify when filled
                          _verifyOtp();
                        }
                      },
                      decoration: BoxLooseDecoration(
                        strokeColorBuilder: FixedColorBuilder(
                          const Color(0xFFB7C7FF),
                        ),
                        bgColorBuilder: FixedColorBuilder(Colors.white),
                        gapSpace: 16,
                        strokeWidth: 1.5,
                        radius: const Radius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(41, 68, 135, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _otp.length == 4 ? _verifyOtp : null,
                    child: dealerVM.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : TextViews.submit,
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color.fromRGBO(41, 68, 135, 1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isTimerRunning
                        ? null
                        : () {
                            _startTimer();
                            debugPrint('Resend OTP');
                          },
                    child: _isTimerRunning
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_seconds Seconds',
                                style: GoogleFonts.mulish(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          )
                        : TextViews.ResendOTP,
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // OTP input handled by PinFieldAutoFill
}

// ---------------- DONE BUTTON ----------------
// Reusable custom Done button
class DoneButton extends StatelessWidget {
  final VoidCallback onTap;
  const DoneButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const Text(
          "Done",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
