import 'dart:convert';
import 'package:dealershub_/src/utils/app_costants.dart';
import 'package:dealershub_/src/viewmodels/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If empty, allow empty (so hint shows)
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // If user starts typing digits, prepend +91
    if (!newValue.text.startsWith('+91')) {
      final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

      if (digitsOnly.isEmpty) {
        return oldValue;
      }

      final text = '+91$digitsOnly';

      if (digitsOnly.length > 10) {
        return oldValue;
      }

      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    // After +91, allow only digits
    final number = newValue.text.substring(3);

    if (!RegExp(r'^[0-9]*$').hasMatch(number)) {
      return oldValue;
    }

    if (number.length > 10) {
      return oldValue;
    }

    return newValue;
  }
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  final TextEditingController _loginController = TextEditingController();

  late FocusNode _phoneFocus;

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

  Future<void> _handleSendOTP() async {
    final vm = context.read<LoginViewModel>();

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

    // ✅ Mobile number validation (10 digits)
    bool isPhone = RegExp(r'^[0-9]{10}$').hasMatch(input);

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
      mobile: '+91$input',
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

    print('Sending OTP to Mobile: $input');
    final response = await vm.login(request);

    // print("response$response");

    Navigator.pushNamed(
      context,
      otpScreenRoute,
      arguments: {'response': response, 'value': input},
    );
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS, // iOS + Android
      keyboardBarColor: Colors.grey[200],
      nextFocus: true, // Automatically move to next field
      actions: [
        KeyboardActionsItem(
          focusNode: _phoneFocus,
          toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('login page ${widget.authType}');
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: KeyboardActions(
          config: _buildConfig(context),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 24),
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
                  // onlyDigits: true,
                  maxLength: 10, // +91 + 10 digits
                  hintText: InputFieldPlaceholder.LoginInputNumber,
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
                    onPressed: _handleSendOTP,
                    child: InputFieldPlaceholder.logSignIn,
                  ),
                ),
                SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Userrole,
                      arguments: {'auth_type': 'register'},
                    );
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Don’t have an account? 👉",
                      style: GoogleFonts.mulish(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign up",
                          style: GoogleFonts.mulish(
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          "Done",
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
