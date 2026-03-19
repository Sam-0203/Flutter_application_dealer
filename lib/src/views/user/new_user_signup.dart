import 'dart:convert';

import 'package:dealershub_/src/models/user%20models/requests/user_register_model.dart';
import 'package:dealershub_/src/utils/app_costants.dart';
import 'package:dealershub_/src/utils/route/route.dart';
import 'package:dealershub_/src/utils/widgets/input_field.dart';
import 'package:dealershub_/src/viewmodels/auth_view_model.dart';
import 'package:dealershub_/src/viewmodels/state_cities_viemodel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:provider/provider.dart';
import '../../utils/colors.dart';
import '../../viewmodels/language_viewmodel.dart';

class NewUserSignUp extends StatefulWidget {
  const NewUserSignUp({
    super.key,
    required this.authType,
    required this.roleType,
  });
  final String authType;
  final String roleType;

  @override
  State<NewUserSignUp> createState() => _NewUserSignUpState();
}

class _NewUserSignUpState extends State<NewUserSignUp> {
  // <=== : selectedStateName : ===>
  String get selectedStateName {
    if (selectedState == null) return '';
    final state = _vmState.stateslist.firstWhere(
      (s) => s.id.toString() == selectedState,
      orElse: () => _vmState.stateslist.first,
    );
    return state.name;
  }

  // -------- Mandatory Controllers --------
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  // -------- Optional Controllers --------
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _alternatePhoneController =
      TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  // FocucNodes --
  late FocusNode _companyNameFocus;
  late FocusNode _fullNameFocus;
  late FocusNode _phoneNumFocus;
  late FocusNode _pincodeNumberFocus;
  late FocusNode _gstinNumberFocus;
  late FocusNode _emailFocus;
  late FocusNode _alterNumberFocus;
  late FocusNode _instaFocus;
  late FocusNode _facebookFocus;
  late FocusNode _webFocus;

  // UI State
  bool showOptionalFields = false;

  // Dropdown values
  String? selectedState;
  String? selectedCity;
  String? selectedPreferdLanguage;

  late LanguageViewModel _vmLang;
  late StateViemodel _vmState;
  late CitiesViemodel _vmCities;

  @override
  void dispose() {
    // Controller
    _companyController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    _gstController.dispose();
    _emailController.dispose();
    _alternatePhoneController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    _websiteController.dispose();

    // FocusNode
    _companyNameFocus.dispose();
    _fullNameFocus.dispose();
    _phoneNumFocus.dispose();
    _pincodeNumberFocus.dispose();
    _gstinNumberFocus.dispose();
    _emailFocus.dispose();
    _alterNumberFocus.dispose();
    _instaFocus.dispose();
    _facebookFocus.dispose();
    _webFocus.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Cotroller ---
    _companyController.addListener(_onFieldChange);
    _fullNameController.addListener(_onFieldChange);
    _phoneController.addListener(_onFieldChange);
    _pincodeController.addListener(_onFieldChange);

    // FocusNode -----
    _companyNameFocus = FocusNode();
    _fullNameFocus = FocusNode();
    _phoneNumFocus = FocusNode();
    _pincodeNumberFocus = FocusNode();
    _gstinNumberFocus = FocusNode();
    _emailFocus = FocusNode();
    _alterNumberFocus = FocusNode();
    _instaFocus = FocusNode();
    _facebookFocus = FocusNode();
    _webFocus = FocusNode();

    // Fetch languages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LanguageViewModel>(context, listen: false).fetchLanguages();
      Provider.of<StateViemodel>(context, listen: false).fetchStates();
    });
  }

  void _onFieldChange() {
    setState(() {});
  }

  // <=== : _showError : ===>
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xffF47B39),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // <=== : _validateMandatoryFields : ===>
  bool _validateMandatoryFields() {
    if (widget.roleType == "dealer") {
      if (_companyController.text.trim().isEmpty) {
        _showError('Please enter company name');
        return false;
      } else if (_companyController.text.trim().length < 4) {
        _showError('Please enter company name morethan 5 characters ');
        return false;
      }
    }

    if (_fullNameController.text.trim().isEmpty) {
      _showError('Please enter full name');
      return false;
    } else if (_fullNameController.text.trim().length < 4) {
      _showError('Please enter Contact name morethan 5 characters ');
      return false;
    }

    if (_phoneController.text.trim().length != 10) {
      _showError('Please enter a valid 10-digit mobile number');
      return false;
    }

    if (_pincodeController.text.trim().length != 6) {
      _showError('Please enter a valid 6-digit pincode');
      return false;
    }

    if (selectedState == null) {
      _showError('Please select state');
      return false;
    }

    if (selectedCity == null) {
      _showError('Please select city');
      return false;
    }

    if (selectedPreferdLanguage == null) {
      _showError('Please select preferred language');
      return false;
    }

    return true; // ✅ everything valid
  }

  // <--------: SUBMIT SIGNUP :-------->
  Future<void> submitSignUp() async {
    // <=== : _validateMandatoryFields : ===>
    if (!_validateMandatoryFields()) {
      return; // ⛔ stop here if invalid
    }

    final vm = context.read<AuthViewModel>();

    final request = RegisterRequest(
      dealershipName: widget.roleType == 'dealer'
          ? _companyController.text.trim()
          : '',
      contactPerson: _fullNameController.text.trim(),
      mobile: "+91${_phoneController.text.trim()}",
      pincode: _pincodeController.text.trim(),
      stateId: int.parse(selectedState!),
      cityId: int.parse(selectedCity!),
      preferredLanguageId: int.parse(selectedPreferdLanguage!),
      loginType: "mobile",
      roleType: widget.roleType,
      authType: "register",
      gstNumber: widget.roleType == 'dealer' ? _gstController.text.trim() : '',
      email: _emailController.text.trim(),
      alternateMobileNumber: widget.roleType == 'dealer'
          ? _alternatePhoneController.text.isEmpty
                ? ''
                : "+91${_alternatePhoneController.text.trim()}"
          : null,
      instagramProfile: _instagramController.text.trim(),
      facebookProfile: _facebookController.text.trim(),
      websiteUrl: _websiteController.text.trim(),
    );

    debugPrint("📤 REGISTER REQUEST:");
    debugPrint(jsonEncode(request.toJson()));

    final response = await vm.register(request);

    if (response != null) {
      Navigator.pushNamed(
        context,
        otpScreenRoute,
        arguments: {
          "response": response,
          "value": response.data.mobile,
          "otp": response.data.otp,
        },
      );
    } else {
      // Handle registration error
      String errorMsg = vm.error is String
          ? vm.error as String
          : 'Registration failed';

      debugPrint("Registration ErrorMsg: $errorMsg");

      String? extractedMessage;
      try {
        // Assuming the format is "Exception: Registration failed: {json}"
        if (errorMsg.contains('Registration failed:')) {
          String jsonPart = errorMsg.split('Registration failed: ').last;
          Map<String, dynamic> json = jsonDecode(jsonPart);
          extractedMessage = json['message'];
        }
      } catch (e) {
        debugPrint("Error parsing registration error message: $e");
      }

      if (extractedMessage == 'User already exists') {
        debugPrint("Showing user already exists dialog");
        _userAlreadyExistsDialog();
      } else {
        debugPrint("Showing generic error snackbar");
        _showError(errorMsg);
      }
    }
  }

  // fields checking
  bool get isMandatoryValid {
    if (widget.roleType == "dealer" && _companyController.text.trim().isEmpty) {
      return false;
    }

    return _fullNameController.text.trim().isNotEmpty &&
        _phoneController.text.trim().isNotEmpty &&
        _pincodeController.text.trim().isNotEmpty &&
        selectedState != null &&
        selectedCity != null &&
        selectedPreferdLanguage != null;
  }

  // User already exists error dialog
  void _userAlreadyExistsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Registration Failed',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        content: Row(
          children: [
            const Icon(Icons.error_outline, size: 30, color: Color(0xffF47B39)),
            const SizedBox(width: 5),
            Text(
              "User with this phone number \nalready exists.",
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xffF47B39),
              ),
            ),
          ],
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

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS, // iOS
      keyboardBarColor: Colors.grey[200],
      nextFocus: true, // Automatically move to next field
      actions: [
        KeyboardActionsItem(
          focusNode: _companyNameFocus,
          toolbarButtons: [(node) => DoneButton(onTap: node.unfocus)],
        ),
        KeyboardActionsItem(
          focusNode: _fullNameFocus,
          toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
        ),
        KeyboardActionsItem(
          focusNode: _phoneNumFocus,
          toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
        ),
        KeyboardActionsItem(
          focusNode: _pincodeNumberFocus,
          toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
        ),
        KeyboardActionsItem(
          focusNode: _gstinNumberFocus,
          toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
        ),
        KeyboardActionsItem(
          focusNode: _emailFocus,
          toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
        ),
        KeyboardActionsItem(
          focusNode: _alterNumberFocus,
          toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
        ),
        KeyboardActionsItem(
          focusNode: _instaFocus,
          toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
        ),
        KeyboardActionsItem(
          focusNode: _facebookFocus,
          toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
        ),
        KeyboardActionsItem(
          focusNode: _webFocus,
          toolbarButtons: [(node) => DoneButton(onTap: () => node.unfocus())],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _vmLang = Provider.of<LanguageViewModel>(context);
    _vmState = Provider.of<StateViemodel>(context);
    _vmCities = Provider.of<CitiesViemodel>(context);

    debugPrint('new user signup ${widget.authType}');
    debugPrint('Role for new user signup ${widget.roleType}');
    debugPrint('languages count: ${_vmLang.languages.length}');
    debugPrint('States count: ${_vmState.stateslist.length}');
    debugPrint('Cities count: ${_vmCities.citieslist.length}');

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: showOptionalFields
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: GestureDetector(
                onTap: () {
                  setState(() {
                    showOptionalFields =
                        false; // 👈 go back to mandatoryInputFields
                  });
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 6),
                    Text('Back', style: TextViews.Backbutton1.style),
                  ],
                ),
              ),
            )
          : null,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              signUpHeader(context, isDealer: widget.roleType == "dealer"),
              const SizedBox(height: 30),
              Expanded(
                child: KeyboardActions(
                  config: _buildConfig(context),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: showOptionalFields
                        ? optionalInputFields()
                        : mandatoryInputFields(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------- HEADER --------
  Widget signUpHeader(BuildContext context, {required bool isDealer}) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Center(
      child: SizedBox(
        width: width * 0.85, // responsive width
        height: height * 0.12, // responsive height
        child: Image.asset(
          widget.roleType == 'dealer'
              ? 'assets/placeholders/Dealers_sign-up.png'
              : 'assets/placeholders/agent_sign-up.png',
          fit: BoxFit.contain, // keeps PNG ratio
        ),
      ),
    );
  }

  // -------- MANDATORY INPUTS --------
  Widget mandatoryInputFields() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextViews.mandatory,
          const SizedBox(height: 16),

          if (widget.roleType == "dealer") ...[
            UserInputField(
              controller: _companyController,
              keyboardType: TextInputType.name,
              hintText: InputFieldPlaceholder.DealerCompanyName,
              maxLength: 50,
              focusNode: _companyNameFocus,
            ),
            const SizedBox(height: 16),
          ],

          UserInputField(
            controller: _fullNameController,
            focusNode: _fullNameFocus,
            keyboardType: TextInputType.name,
            hintText: InputFieldPlaceholder.DealerFullName,
            maxLength: 30,
          ),
          const SizedBox(height: 16),

          UserInputField(
            focusNode: _phoneNumFocus,
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            hintText: InputFieldPlaceholder.DealerNumber,
            maxLength: 10,
          ),
          const SizedBox(height: 16),

          UserDropdownField<String>(
            hintText: InputFieldPlaceholder.StateSelection,
            value: selectedState,
            items: _vmState.isLoading
                ? [
                    DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(Icons.info_outline, size: 30),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Feaching States....!',
                              style: GoogleFonts.mulish(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          CircularProgressIndicator(
                            color: Colors.blue,
                            strokeWidth: 2,
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ]
                : _vmState.stateslist.isEmpty
                ? [
                    DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(Icons.info_outline, size: 30),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'No States....!',
                              style: GoogleFonts.mulish(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          CircularProgressIndicator(
                            color: Colors.blue,
                            strokeWidth: 2,
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ]
                : _vmState.stateslist
                      .map(
                        (state) => DropdownMenuItem<String>(
                          value: state.id.toString(),
                          child: Text(state.name),
                        ),
                      )
                      .toList(),
            onChanged: (value) {
              setState(() {
                selectedState = value;
                selectedCity = null; // reset city
              });

              // 🔥 FETCH CITIES BASED ON STATE
              context.read<CitiesViemodel>().fetchCitiesByState(
                int.parse(value!),
              );
            },
          ),

          const SizedBox(height: 16),

          // Cities
          UserDropdownField<String>(
            hintText: InputFieldPlaceholder.CitySelection,
            value: selectedCity,
            items: _vmCities.isLoading
                ? [
                    DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(Icons.info_outline, size: 30),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Select City first....!', // display State name
                              style: GoogleFonts.mulish(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]
                : _vmCities.citieslist.isEmpty
                ? [
                    DropdownMenuItem(
                      value: null,
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(Icons.info_outline, size: 30),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'No Cities for this $selectedStateName', // display State name
                              style: GoogleFonts.mulish(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          CircularProgressIndicator(
                            color: Colors.blue,
                            strokeWidth: 2,
                          ),
                          SizedBox(width: 10),
                        ],
                      ),
                    ),
                  ]
                : _vmCities.citieslist
                      .map(
                        (city) => DropdownMenuItem<String>(
                          value: city.id.toString(),
                          child: Text(city.name),
                        ),
                      )
                      .toList(),
            onChanged: (value) => setState(() => selectedCity = value),
          ),

          const SizedBox(height: 16),

          UserInputField(
            controller: _pincodeController,
            focusNode: _pincodeNumberFocus,
            keyboardType: TextInputType.number,
            hintText: InputFieldPlaceholder.Pincode,
            maxLength: 6,
          ),
          const SizedBox(height: 16),

          UserDropdownField<String>(
            hintText: InputFieldPlaceholder.PreferedLanguage,
            value: selectedPreferdLanguage,
            items: _vmLang.languages
                .map(
                  (lang) => DropdownMenuItem<String>(
                    value: lang.id.toString(),
                    child: Text(lang.name),
                  ),
                )
                .toList(),
            onChanged: (value) =>
                setState(() => selectedPreferdLanguage = value),
          ),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                if (_validateMandatoryFields()) {
                  setState(() => showOptionalFields = true);
                }
              },
              child: Opacity(
                opacity: isMandatoryValid ? 1.0 : 0.5,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Next',
                      style: GoogleFonts.mulish(
                        fontSize: 18,
                        color: ButtonsColors.GetStartedButton,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: ButtonsColors.GetStartedButton,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------- OPTIONAL INPUTS --------
  Widget optionalInputFields() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextViews.OptionalFields,
          const SizedBox(height: 16),

          if (widget.roleType == "dealer") ...[
            UserInputField(
              focusNode: _gstinNumberFocus,
              controller: _gstController,
              hintText: InputFieldPlaceholder.GSTIN,
              keyboardType: TextInputType.text,
              maxLength: 15,
            ),
            const SizedBox(height: 16),
          ],

          UserInputField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            hintText: InputFieldPlaceholder.EmailAddress,
            maxLength: 50,
            focusNode: _emailFocus,
          ),
          const SizedBox(height: 16),

          UserInputField(
            controller: _alternatePhoneController,
            keyboardType: TextInputType.number,
            hintText: InputFieldPlaceholder.AlternateMobileNumber,
            maxLength: 10,
            focusNode: _alterNumberFocus,
          ),
          const SizedBox(height: 16),

          UserInputField(
            controller: _instagramController,
            keyboardType: TextInputType.url,
            hintText: InputFieldPlaceholder.InstagramProfileURL,
            focusNode: _instaFocus,
          ),
          const SizedBox(height: 16),

          UserInputField(
            controller: _facebookController,
            keyboardType: TextInputType.url,
            focusNode: _facebookFocus,
            hintText: InputFieldPlaceholder.FacebookProfileURL,
          ),
          const SizedBox(height: 16),

          UserInputField(
            controller: _websiteController,
            keyboardType: TextInputType.url,
            focusNode: _webFocus,
            hintText: InputFieldPlaceholder.WebsiteURL,
          ),
          const SizedBox(height: 24),

          InputFieldPlaceholder.TermsConditions,
          const SizedBox(height: 20),

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
              onPressed: submitSignUp,
              child: TextViews.newUserSignUp,
            ),
          ),
        ],
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
          style: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
