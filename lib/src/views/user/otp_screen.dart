import 'dart:async';
import 'dart:convert';
import 'package:dealershub_/src/models/user%20models/reponses/user_verify_response.dart';
import 'package:dealershub_/src/models/user%20models/requests/agent_delear_register_verify.dart';
import 'package:dealershub_/src/models/user%20models/reponses/register_response.dart';
import 'package:dealershub_/src/models/user%20models/requests/login_request.dart';
import 'package:dealershub_/src/models/user%20models/requests/login_verification_request.dart';
import 'package:dealershub_/src/models/user%20models/requests/user_register_model.dart';
import 'package:dealershub_/src/utils/helper/secure_storage.dart';
import 'package:dealershub_/src/viewmodels/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

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

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  // ---------------- OTP State ----------------
  String _code = '';
  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;
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
  int _seconds = 30;
  bool _isTimerRunning = false;
  bool _isResendingOtp = false;

  static const int otpLength = 4;
  static const int resendSeconds = 30;

  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();

    _otpControllers = List.generate(otpLength, (_) => TextEditingController());
    _otpFocusNodes = List.generate(otpLength, (_) => FocusNode());
    listenForCode();
  }

  // ---------------- DISPOSE ----------------
  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final node in _otpFocusNodes) {
      node.dispose();
    }
    cancel();
    unregisterListener();
    super.dispose();
  }

  // ---------------- Get OTP ----------------
  String get _otp => _code;

  @override
  void codeUpdated() {
    if (code == null || code!.isEmpty) return;
    _fillOtpFrom(0, code!, shouldVerify: true);
  }

  void _syncOtpCode() {
    final updated = _otpControllers.map((controller) => controller.text).join();
    if (!mounted) return;
    setState(() {
      _code = updated;
    });
  }

  void _fillOtpFrom(
    int startIndex,
    String rawValue, {
    bool shouldVerify = false,
  }) {
    final digits = rawValue.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty || startIndex >= otpLength) return;

    var currentIndex = startIndex;
    for (var i = 0; i < digits.length && currentIndex < otpLength; i++) {
      _otpControllers[currentIndex].text = digits[i];
      _otpControllers[currentIndex].selection = const TextSelection.collapsed(
        offset: 1,
      );
      currentIndex++;
    }

    _syncOtpCode();

    final nextEmptyIndex = _otpControllers.indexWhere(
      (controller) => controller.text.isEmpty,
    );
    if (nextEmptyIndex == -1) {
      FocusScope.of(context).unfocus();
      if (shouldVerify && _otp.length == otpLength) {
        _verifyOtp();
      }
    } else {
      FocusScope.of(context).requestFocus(_otpFocusNodes[nextEmptyIndex]);
    }
  }

  void _handleOtpChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');

    // ✅ BACKSPACE HANDLING (IMPORTANT FIX)
    if (digits.isEmpty) {
      _otpControllers[index].clear();

      if (index > 0) {
        FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
        _otpControllers[index - 1].selection = TextSelection.collapsed(
          offset: _otpControllers[index - 1].text.length,
        );
      }

      _syncOtpCode();
      return;
    }

    // Paste case
    if (digits.length > 1) {
      _fillOtpFrom(index, digits, shouldVerify: true);
      return;
    }

    // Normal input
    _otpControllers[index].value = TextEditingValue(
      text: digits,
      selection: const TextSelection.collapsed(offset: 1),
    );

    _syncOtpCode();

    if (index < otpLength - 1) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
    } else {
      FocusScope.of(context).unfocus();
      if (_otp.length == otpLength) {
        _verifyOtp();
      }
    }
  }

  Widget _buildOtpBox(int index, bool isTablet) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace) {
            if (_otpControllers[index].text.isEmpty && index > 0) {
              _otpControllers[index - 1].clear();
              FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
              _syncOtpCode();
              return KeyEventResult.handled;
            }
          }

          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _otpFocusNodes[index],
          autofocus: false,
          showCursor: true,
          cursorColor: const Color.fromRGBO(41, 68, 135, 1),
          keyboardType: TextInputType.number,
          textInputAction: index == otpLength - 1
              ? TextInputAction.done
              : TextInputAction.next,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isTablet ? 28 : 24,
            fontWeight: FontWeight.w600,
            color: const Color.fromRGBO(41, 68, 135, 1),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofillHints: const [AutofillHints.oneTimeCode],
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color.fromRGBO(41, 68, 135, 1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color.fromRGBO(41, 68, 135, 1),
                width: 1,
              ),
            ),
          ),
          onTap: () {
            _otpControllers[index].selection = TextSelection(
              baseOffset: 0,
              extentOffset: _otpControllers[index].text.length,
            );
          },
          onChanged: (value) => _handleOtpChanged(index, value),
        ),
      ),
    );
  }

  // ---------------- Verify OTP ----------------
  Future<void> _verifyOtp() async {
    final enteredOtp = _otp;

    if (enteredOtp.length != otpLength) {
      _showError('Please enter a valid 4-digit OTP.');
      return;
    }

    debugPrint("Entered otp $enteredOtp");

    /// ================= LOGIN FLOW =================
    if (isLoginFlow) {
      final loginResponse = widget.registerResponse as UserOTPResponse;
      final loginOtpVM = context.read<LoginOtpViewModel>();

      debugPrint(loginResponse.toString());
      final model = LoginOtpVerifyModel(
        mobile: loginResponse.data.mobile,
        loginType: 'mobile',
        roleType: loginResponse.data.roleType,
        authType: 'login',
        otp: enteredOtp,
      );

      final response = await loginOtpVM.verifyOtp(model);
      if (!mounted || !context.mounted) return;

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
      if (!mounted || !context.mounted) return;

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
      if (!mounted || !context.mounted) return;

      if (response == null) {
        String rawErrorMsg = dealerVM.errorMessage is String
            ? dealerVM.errorMessage as String
            : 'Registration failed';

        String friendlyError = _getFriendlyError("Wrong OTP");

        debugPrint("ErrorMsg: $rawErrorMsg");
        debugPrint("Friendly Error: $friendlyError");

        if (friendlyError.toLowerCase().contains('user already exists')) {
          debugPrint("Showing user already exists dialog");
          _userAlreadyExistsDialog();
        } else {
          debugPrint("Showing generic error dialog");
          _showError(friendlyError);
        }

        return;
      }

      // 🔐 SAVE TOKEN + ROLE
      await SecureStorage.saveTokenAndRole(
        token: response.data.accessToken,
        role: response.data.role,
      );
      if (!mounted || !context.mounted) return;

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
    if (!mounted || !context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Dealershub',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        content: Text(
          "User with this phone number already exists. Please try logging in instead.",
          style: TextStyle(
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
              style: TextStyle(
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

  String _getFriendlyError(String rawError) {
    final message = rawError.trim();

    if (message.isEmpty) return 'Something went wrong. Please try again.';

    // Direct messages from API
    if (!message.startsWith('Exception:')) {
      return message;
    }

    // Parse the "Exception: Registration failed" payload if present
    try {
      if (message.contains('Registration failed:')) {
        final jsonPart = message.split('Registration failed:').last.trim();
        final decoded = jsonDecode(jsonPart);
        if (decoded is Map<String, dynamic>) {
          final serverMsg = decoded['message']?.toString();
          if (serverMsg != null && serverMsg.isNotEmpty) {
            final errors = decoded['errors'];
            if (errors is Map<String, dynamic>) {
              final details = errors.values
                  .whereType<List>()
                  .expand((e) => e.whereType<String>())
                  .join(', ');
              return details.isNotEmpty ? '$serverMsg: $details' : serverMsg;
            }
            return serverMsg;
          }
        }
      }
    } catch (_) {
      // Fall back to raw text
    }

    return message;
  }

  // Generic error dialog for OTP verification failures
  void _showError(String message) {
    if (!mounted || !context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Dealershub',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        content: Text(
          message.isNotEmpty
              ? message
              : 'Something went wrong. Please try again.',
          style: TextStyle(
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
              style: TextStyle(
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
      _seconds = resendSeconds;
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

  String _normalizeMobileForApi(String mobile) {
    final trimmed = mobile.trim();
    if (trimmed.startsWith('+')) return trimmed;

    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return '+91$digits';
    if (digits.length == 12 && digits.startsWith('91')) return '+$digits';
    return digits.isNotEmpty ? '+$digits' : trimmed;
  }

  KeyboardActionsConfig _buildKeyboardActionsConfig() {
    KeyboardActionsItem buildAction(FocusNode focusNode) {
      return KeyboardActionsItem(
        focusNode: focusNode,
        displayActionBar: true,
        displayArrows: false,
        displayDoneButton: true,
        toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
      );
    }

    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: false,
      actions: _otpFocusNodes.map(buildAction).toList(),
    );
  }

  Future<void> _handleResendOtp() async {
    if (_isTimerRunning || _isResendingOtp) return;

    setState(() {
      _isResendingOtp = true;
    });

    bool resendSucceeded = false;

    try {
      if (isLoginFlow) {
        final loginResponse = widget.registerResponse as UserOTPResponse;
        final loginVM = context.read<LoginViewModel>();

        final request = LoginRequestModel(
          mobile: _normalizeMobileForApi(
            widget.value.isNotEmpty ? widget.value : loginResponse.data.mobile,
          ),
          loginType: 'mobile',
          roleType: loginResponse.data.roleType,
          authType: loginResponse.data.authType,
        );

        final response = await loginVM.login(request);

        if (response == null) {
          debugPrint('Failed to resend OTP');
        } else {
          resendSucceeded = true;
        }
      } else if (isSignupFlow) {
        final signupResponse = widget.registerResponse as RegisterResponse;
        final signupVM = context.read<AuthViewModel>();
        final data = signupResponse.data;

        final request = RegisterRequest(
          dealershipName: data.dealershipName ?? '',
          contactPerson: data.contactPerson ?? '',
          mobile: _normalizeMobileForApi(data.mobile),
          pincode: data.pincode,
          stateId: data.stateId,
          cityId: data.cityId,
          preferredLanguageId: data.preferredLanguageId,
          loginType: 'mobile',
          roleType: data.roleType,
          authType: data.authType,
          gstNumber: data.gstNumber ?? '',
          email: data.email ?? '',
          alternateMobileNumber: data.alternateMobileNumber,
          instagramProfile: data.instagramProfile ?? '',
          facebookProfile: data.facebookProfile ?? '',
          websiteUrl: data.websiteUrl ?? '',
        );

        final response = await signupVM.register(request);

        if (response == null) {
          debugPrint('Failed to resend OTP');
        } else {
          resendSucceeded = true;
        }
      }

      if (!mounted) return;

      if (!resendSucceeded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to resend OTP. Please try again.'),
            backgroundColor: Color(0xffF47B39),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resending OTP. Please try again later.'),
          backgroundColor: const Color(0xffF47B39),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResendingOtp = false;
        });
      }
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    debugPrint("OTP Screen ${widget.registerResponse}");

    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= 600;
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
          config: _buildKeyboardActionsConfig(),
          disableScroll: false,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 24),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isTablet ? 700 : 440),
                child: Column(
                  children: [
                    SizedBox(height: isTablet ? 24 : 24),

                    Image.asset(
                      'assets/placeholders/Enter_OTP_text.png',
                      width: isTablet ? 280 : null,
                    ),
                    SizedBox(height: isTablet ? 16 : 20),

                    Image.asset(
                      'assets/placeholders/Enter_otp_Img.png',
                      width: isTablet ? 240 : width * 0.55,
                    ),

                    SizedBox(height: isTablet ? 24 : 24),

                    Text(
                      'A 4-digit code has been sent to\n ${maskPhoneNumber(widget.value)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isTablet ? 20 : 16,
                        color: const Color.fromRGBO(41, 68, 135, 1),
                      ),
                    ),

                    SizedBox(height: isTablet ? 28 : 32),

                    SizedBox(
                      width: isTablet ? 540 : double.infinity,
                      child: AutofillGroup(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: isTablet ? 14 : 12,
                          children: List.generate(
                            otpLength,
                            (index) => _buildOtpBox(index, isTablet),
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
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
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
                        onPressed: (_isTimerRunning || _isResendingOtp)
                            ? null
                            : _handleResendOtp,
                        child: _isResendingOtp
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                ),
                              )
                            : _isTimerRunning
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
                                    style: TextStyle(
                                      fontSize: 16,
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
        ),
      ),
    );
  }
}

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
        child: Text(
          "Done",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
