import 'package:flutter/material.dart';

class TextViews {
  static Text LoginText = Text(
    'Log in and Unlock endless opportunities!',
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 18,
      color: const Color.fromRGBO(41, 68, 135, 1),
      fontWeight: FontWeight.w700,
    ),
  );

  static Text ResendOTP = Text(
    'RESEND OTP',
    style: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Color.fromRGBO(41, 68, 135, 1),
    ),
  );
  static Text submit = Text(
    'SUBMIT',
    style: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Colors.white,
    ),
  );
  static Text cancel = Text(
    'Cancel',
    style: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: const Color.fromRGBO(75, 119, 227, 1),
    ),
  );

  static Widget mandatory = RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: 'Mandatory fields',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F3C88),
          ),
        ),
        TextSpan(
          text: '*',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
      ],
    ),
  );

  static Text OptionalFields = Text(
    'Optional Fields',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1F3C88),
    ),
  );

  static Text Backbutton1 = Text(
    'Edit Details',
    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
  );

  static Row Skip = Row(
    children: [
      Text(
        'Skip',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      const SizedBox(width: 4),
      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
    ],
  );
  static Text GetStarted = Text(
    'GET STARTED',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );
  static Text SignUp = Text(
    'SIGN UP',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: const Color.fromRGBO(41, 68, 135, 1),
    ),
  );

  static Text newUserSignUp = Text(
    'SIGN UP',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );
  static Text next = Text(
    'NEXT',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );
}

// -:: Input placeholders ::-
class InputFieldPlaceholder {
  static String LoginInputNumber = 'Mobile Number';

  static String DealerCompanyName = 'Dealer(company) Name';

  static String DealerFullName = 'Contact Person (Full Name)';

  static String DealerNumber = 'Mobile Number';

  static String StateSelection = 'State';

  static String CitySelection = 'City';

  static String Pincode = 'Pincode';

  static String PreferedLanguage = 'Preferred Language';

  static String GSTIN = 'GSTIN (To get verified badge)';

  static String EmailAddress = 'Email Address (Recommended)';

  static String AlternateMobileNumber = 'Alternate Mobile Number';

  static String InstagramProfileURL = 'Instagram Profile URL';

  static String FacebookProfileURL = 'Facebook Profile URL';

  static String WebsiteURL = 'Website URL';

  static Widget TermsConditions = RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: 'By signing up, you’re agree to our ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(59, 59, 59, 1),
          ),
        ),
        TextSpan(
          text: 'Terms & Conditions ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(41, 68, 135, 1),
          ),
        ),
        TextSpan(
          text: 'and ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(59, 59, 59, 1),
          ),
        ),
        TextSpan(
          text: ' Privacy Policy',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(41, 68, 135, 1),
          ),
        ),
      ],
    ),
  );

  static Text SignUp = Text(
    'SIGN UP',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color.fromRGBO(255, 255, 255, 1),
    ),
  );
  static Text signIn = Text(
    'SIGN IN',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  );
  static Text logSignIn = Text(
    'SIGN IN',
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );

  static Text Search = Text(
    'Search',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(59, 59, 59, 1),
    ),
  );

  // New Car Entry Placeholders
  static String manufactorYear = 'Manufacturing year';
  static String make = 'Car Brand';
  static String model = 'Car Model';
  static String fuelType = 'Fuel type';
  static String variant = 'Car Variant';
  static String transmission = 'Transmission type';
  static String color = 'Color';
  static String kilometersDriven = 'Kilometers Driven';
  static String registrationCity = 'Registration city(RTO)';
  static String carOwner = 'Number of Owners ';
}

class CarOptinalDetails {
  // Add a car details (Optionals) - Headings
  static Text otherDetaisl = Text(
    'Other details (optional)',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(41, 68, 135, 1),
    ),
  );

  static Text safety = Text(
    'Safety Features (optional)',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(41, 68, 135, 1),
    ),
  );

  static Text comfort = Text(
    'Comfort & Convenience (optional)',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(41, 68, 135, 1),
    ),
  );

  static Text info = Text(
    'Infotainment & Connectivity (optional) ',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(41, 68, 135, 1),
    ),
  );

  static Text inter = Text(
    'Interior Features (optional) ',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(41, 68, 135, 1),
    ),
  );

  static Text exter = Text(
    'Exterior Features (optional) ',
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(41, 68, 135, 1),
    ),
  );

  static Widget serivceNo = RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: 'NO',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        TextSpan(
          text: ', Service History is Available',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
  static Widget serivceYes = RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: 'Yes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        TextSpan(
          text: ', Service History is Available',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );

  // Add a car details (Optionals) - Input fields (Hint Text)
  static String insurance = 'Insurance Validity :';
  static String service = 'Service History';
  static String generalHintText = 'Mention, if anything else specific...';
}
