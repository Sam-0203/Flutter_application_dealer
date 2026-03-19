import 'package:dealershub_/src/views/home/cars%20details/add_car_details.dart';
import 'package:dealershub_/src/views/home/cars%20details/car_update.dart';
import 'package:dealershub_/src/views/home/cars%20details/details_review.dart';
import 'package:dealershub_/src/views/home/cars%20details/my_fav.dart';
import 'package:dealershub_/src/views/home/tabs/filter_screen.dart';
import 'package:dealershub_/src/views/home/tabs/listofcars.dart';
import 'package:dealershub_/src/views/home/tabs/myinvetory.dart';
import 'package:dealershub_/src/views/home/cars%20details/newcarentry.dart';
import 'package:dealershub_/src/views/user/login.dart';
import 'package:dealershub_/src/views/user/otp_screen.dart';
import 'package:flutter/material.dart';

import 'package:dealershub_/src/views/onboarding_screens/onboardscreen1.dart';
import 'package:dealershub_/src/views/onboarding_screens/onboardscreen2.dart';
import 'package:dealershub_/src/views/onboarding_screens/onboardscreen3.dart';
import 'package:dealershub_/src/views/onboarding_screens/onboardscreen4.dart';
import 'package:dealershub_/src/views/onboarding_screens/onboardscreen5.dart';
import 'package:dealershub_/src/views/user/new_user_signup.dart';
import 'package:dealershub_/src/views/user/user_role.dart';
import 'package:dealershub_/src/views/onboarding_screens/onboardingscreen.dart';
import 'package:dealershub_/src/views/home/tabs/home.dart';

// Routing Names...
const String OnBoardingscreen = 'OnBoarding';
const String OnBoardingscreen1 = 'OnBoarding_1';
const String OnBoardingscreen2 = 'OnBoarding_2';
const String OnBoardingscreen3 = 'OnBoarding_3';
const String OnBoardingscreen4 = 'OnBoarding_4';
const String OnBoardingscreen5 = 'OnBoarding_5';
const String Userrole = 'userrole';
const String NewUserSignup = 'NewUser';
const String userLogin = 'Login';
const String otpScreenRoute = 'OtpScreen';
const String mainHomeScreen = 'MainHomeScreen';
const String homeScreenRoute = 'HomeScreen';
const String myInventoryRoute = 'MyInventory';
const String listOfCarsRoute = 'ListOfCars';
const String newCarEntryRoute = 'NewCarEntry';
const String carOptionalDetails = 'carOptionalDetails';
const String carDetailsReview = 'CarDetails';
const String success = 'Success';
const String filteringScreen = 'FilteringScreen';
const String carUpdateDetails = 'CarUpdateDetails';
const String myfavoriteCarsRoute = 'MyFavoriteCars';

// On Boarding Screens.....
final Map<String, Widget> onboardingPages = {
  OnBoardingscreen1: const Onboardscreen_1(),
  OnBoardingscreen2: const Onboardscreen_2(),
  OnBoardingscreen3: const Onboardscreen_3(),
  OnBoardingscreen4: const Onboardscreen_4(),
};

// Control our page route flow......
Route<dynamic> controller(RouteSettings settings) {
  switch (settings.name) {
    case OnBoardingscreen:
      return MaterialPageRoute(builder: (context) => OnBoardingScreen());
    case OnBoardingscreen1:
      return MaterialPageRoute(builder: (context) => Onboardscreen_1());
    case OnBoardingscreen2:
      return MaterialPageRoute(builder: (context) => Onboardscreen_2());
    case OnBoardingscreen3:
      return MaterialPageRoute(builder: (context) => Onboardscreen_3());
    case OnBoardingscreen4:
      return MaterialPageRoute(builder: (context) => Onboardscreen_4());
    case OnBoardingscreen5:
      return MaterialPageRoute(builder: (context) => Onboardscreen_5());
    case Userrole:
      final args = settings.arguments as Map<String, dynamic>?;

      if (args == null || args['auth_type'] == null) {
        throw ArgumentError('Userrole route requires auth_type');
      }

      final String authType = args['auth_type'];

      return MaterialPageRoute(
        builder: (context) => UserRole(authType: authType),
      );

    // NewUserSignup
    case NewUserSignup:
      debugPrint('NewUserSignup ROUTE ARGS 👉 ${settings.arguments}');

      final args = settings.arguments;

      if (args is! Map<String, String>) {
        throw ArgumentError('userLogin route requires authType and roleType');
      }

      final authType = args['authType'];
      final roleType = args['roleType'];

      if (authType == null || roleType == null) {
        throw ArgumentError(
          'authType or roleType is missing in userLogin route arguments',
        );
      }

      return MaterialPageRoute(
        builder: (_) => NewUserSignUp(authType: authType, roleType: roleType),
      );

    // userLogin
    case userLogin:
      debugPrint('LOGIN ROUTE ARGS 👉 ${settings.arguments}');

      final args = settings.arguments;

      if (args is! Map<String, String>) {
        throw ArgumentError('userLogin route requires authType and roleType');
      }

      final authType = args['authType'];
      final roleType = args['roleType'];

      if (authType == null || roleType == null) {
        throw ArgumentError(
          'authType or roleType is missing in userLogin route arguments',
        );
      }

      return MaterialPageRoute(
        builder: (_) => UserLoginScreen(authType: authType, roleType: roleType),
      );

    // otpScreenRoute
    case otpScreenRoute:
      final args = settings.arguments as Map<String, dynamic>;

      print("args$args");

      return MaterialPageRoute(
        builder: (_) => OtpScreen(
          registerResponse: args['response'], // ✅ SAME KEY
          value: args['value'] ?? '',
        ),
      );

    // homeScreenRoute
    case homeScreenRoute:
      final args = settings.arguments as Map<String, dynamic>?;

      final String? role = args?['role'] as String?;
      final int initialTab = args?['initialTab'] as int? ?? 0;
      final bool showSuccessDialog =
          args?['showSuccessDialog'] as bool? ?? false;

      return MaterialPageRoute(
        builder: (context) => HomeScreen(
          role: role,
          initialTab: initialTab,
          showSuccessDialog: showSuccessDialog,
        ),
      );

    // Home Screen
    case mainHomeScreen:
      final args = settings.arguments as Map<String, dynamic>?;

      final String? role = args?['role'] as String?;
      return MaterialPageRoute(
        builder: (context) => HomeListOfCarsAndMyList(role: role),
      );

    case listOfCarsRoute:
      return MaterialPageRoute(
        builder: (context) => Listofcars(role: settings.arguments as String?),
      );

    case myInventoryRoute:
      final bool? isListOfCars = settings.arguments as bool?;
      if (isListOfCars == null) {
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: SafeArea(
              child: Center(
                child: Text(
                  'Error: isListOfCars not send.',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            ),
          ),
        );
      }
      return MaterialPageRoute(
        builder: (context) => Myinvetory(role: settings.arguments as String?),
      );

    case newCarEntryRoute:
      final role = settings.arguments as String; // ← Directly cast to String

      return MaterialPageRoute(builder: (context) => NewCarDetails(role: role));

    case carOptionalDetails:
      final args = settings.arguments as Map<String, dynamic>;

      return MaterialPageRoute(
        builder: (context) => CarOPtionalDetails(
          carBasicData: args['carData'] as Map<String, dynamic>,
          carPreviewData: args['carPreview'] as Map<String, dynamic>,
          role: args['role'],
        ),
      );

    case carDetailsReview:
      final args = settings.arguments as Map?;

      if (args == null) {
        throw ArgumentError('carDetailsReview route requires arguments');
      }

      final role = args['role'];
      final carData = (args['carData'] as Map?)?.cast<String, dynamic>() ?? {};
      final previewData =
          (args['previewData'] as Map?)?.cast<String, dynamic>() ?? {};
      final carId = (args['carId'] as int?) ?? 0; // Default to 0 if null
      final showtitle = args['headerTitle'] as bool;
      final showAppBar = args['showAppBar'] as bool? ?? true;
      final showBottomButtons = args['showBottomButtons'] as bool? ?? true;
      final actionIcons = args['actionIcons'];

      return MaterialPageRoute(
        settings: settings,
        builder: (context) => CarDetailsReview(
          role: role,
          carData: carData,
          previewData: previewData,
          showAppBar: showAppBar,
          showtitle: showtitle,
          carId: carId,
          showBottomButtons: showBottomButtons,
          actionIcons: actionIcons,
        ),
      );

    case filteringScreen:
      return MaterialPageRoute(
        builder: (context) =>
            FilteringScreenDetails(role: settings.arguments as String),
      );

    case carUpdateDetails:
      final args = settings.arguments as Map?;

      if (args == null) {
        throw ArgumentError('carUpdateDetails route requires arguments');
      }

      final role = args['role'] as String;
      final carId = (args['carId'] as int?) ?? 0;
      return MaterialPageRoute(
        builder: (context) => CarUpdateDetails(carId: carId, role: role),
      );
    case myfavoriteCarsRoute:
      final args = settings.arguments as Map<String, dynamic>?;
      final String? role = args?['role'] as String?;
      return MaterialPageRoute(
        builder: (context) => MyFavoriteCars(role: role),
      );
    default:
      throw ('Page are not found');
  }
}
