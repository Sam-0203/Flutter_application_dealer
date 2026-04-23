import 'dart:convert';
import 'package:dealershub_/src/utils/app_costants.dart';
import 'package:dealershub_/src/viewmodels/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';
import '../../models/user models/requests/login_request.dart';
import '../../utils/colors.dart';
import '../../utils/route/route.dart';
import '../../utils/widgets/input_field.dart';

class UserLoginScreen extends StatefulWidget {
  final String authType;
  final String roleType;

  const UserLoginScreen({
    super.key,
    required this.authType,
    required this.roleType,
  });

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class IndianPhoneFormatter extends TextInputFormatter {
  String _formatIndianMobile(String digits) {
    try {
      if (digits.length <= 5) {
        return digits;
      }
      return '${digits.substring(0, 5)} ${digits.substring(5)}';
    } catch (e) {
      debugPrint('Error in _formatIndianMobile: $e');
      return digits;
    }
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    try {
      var digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
      if (digitsOnly.startsWith('91') && digitsOnly.length > 10) {
        digitsOnly = digitsOnly.substring(2);
      }

      if (digitsOnly.length > 10) {
        return oldValue;
      }

      if (digitsOnly.isEmpty) {
        return const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
      }

      final formatted = _formatIndianMobile(digitsOnly);
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    } catch (e) {
      debugPrint('Error in formatEditUpdate: $e');
      return oldValue;
    }
  }
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController _loginController = TextEditingController();

  late FocusNode _phoneFocus;
  bool _isDelayingNavigation = false;

  @override
  void initState() {
    _phoneFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  String _uiErrorMessage(String? message) {
    try {
      if (message == null || message.trim().isEmpty) {
        return 'Failed to send OTP';
      }
      return message.trim();
    } catch (e) {
      debugPrint('Error in _uiErrorMessage: $e');
      return 'Failed to send OTP';
    }
  }

  Future<void> _handleSendOTP() async {
    final vm = context.read<LoginViewModel>();
    try {
      final input = _loginController.text.trim();

      if (input.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter your mobile number'),
            backgroundColor: Color(0xffF47B39),
          ),
        );
        return;
      }

      // Accept +91XXXXXXXXXX (or plain 10 digits) and validate only 10 digits after +91.
      final normalizedInput = input.startsWith('+91')
          ? input.substring(3)
          : input;
      final mobileNumber = normalizedInput.replaceAll(RegExp(r'\D'), '');
      final isPhone = RegExp(r'^[0-9]{10}$').hasMatch(mobileNumber);

      if (!isPhone) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid 10-digit mobile number'),
            backgroundColor: Color(0xffF47B39),
          ),
        );
        return;
      }

      final request = LoginRequestModel(
        mobile: '+91$mobileNumber',
        loginType: 'mobile',
        roleType: widget.roleType,
        authType: widget.authType,
      );

      // 🔥 PRINT SUBMITTED DATA
      debugPrint("📤 LOGIN REQUEST DATA:");
      debugPrint(request.toJson().toString());

      // 🔥 PRINT SUBMITTED DATA (POST BODY)
      debugPrint("📤 LOGIN POST DATA:");
      debugPrint(jsonEncode(request.toJson()));

      debugPrint('Sending OTP to Mobile: +91$mobileNumber');
      final response = await vm.login(request);

      if (response == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_uiErrorMessage(vm.error)),
            backgroundColor: const Color(0xffF47B39),
          ),
        );
        return;
      }

      setState(() {
        _isDelayingNavigation = true;
      });

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.pushNamed(
        context,
        otpScreenRoute,
        arguments: {'response': response, 'value': request.mobile},
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Color(0xffF47B39),
        ),
      );
    } finally {
      if (mounted && _isDelayingNavigation) {
        setState(() {
          _isDelayingNavigation = false;
        });
      }
    }
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    try {
      return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: Colors.grey[200],
        nextFocus: false,
        actions: [
          KeyboardActionsItem(
            focusNode: _phoneFocus,
            toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
          ),
        ],
      );
    } catch (e) {
      debugPrint('Error in _buildConfig: $e');
      return KeyboardActionsConfig(
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: Colors.grey[200],
        nextFocus: false,
        actions: [],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('login page ${widget.authType}');
    final loginVM = context.watch<LoginViewModel>();
    final bool isBusy = loginVM.isLoading || _isDelayingNavigation;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () => Navigator.pop(context, true),
          child: Row(
            children: [
              Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
              Text(
                'Back',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: KeyboardActions(
          config: _buildConfig(context),
          disableScroll: true,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // const SizedBox(height: 24),
                // Title image
                Image.asset(
                  'assets/placeholders/LoginText.png',
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                TextViews.LoginText,

                const SizedBox(height: 20),
                Image.asset(
                  'assets/placeholders/Login.png',
                  fit: BoxFit.contain,
                ),
                // ✅ Mobile-only input
                UserInputField(
                  controller: _loginController,
                  focusNode: _phoneFocus,
                  keyboardType: TextInputType.number,
                  scrollPadding: const EdgeInsets.only(bottom: 220),
                  maxLength: 11, // 12345 67890
                  hintText: InputFieldPlaceholder.LoginInputNumber,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8),
                    child: Center(
                      widthFactor: 1,
                      child: Text(
                        '+91',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color.fromRGBO(59, 59, 59, 1),
                        ),
                      ),
                    ),
                  ),
                  inputFormatters: [IndianPhoneFormatter()],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ButtonsColors.GetStartedButton,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isBusy ? null : _handleSendOTP,
                    child: isBusy
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : InputFieldPlaceholder.logSignIn,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Userrole,
                      arguments: {
                        'auth_type': 'register',
                        'appbar_hide': 'yes',
                      },
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Don’t have an account? 👉",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign up",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
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
    return TextButton(
      onPressed: onTap,
      child: Text(
        "Done",
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
    );
  }
}
