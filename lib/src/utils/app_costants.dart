import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TextViews {
  static Text LoginText = Text(
    'Log in and Unlock endless opportunities!',
    textAlign: TextAlign.center,
    style: GoogleFonts.mulish(
      fontSize: 18,
      color: const Color.fromRGBO(41, 68, 135, 1),
      fontWeight: FontWeight.w700,
    ),
  );

  static Text ResendOTP = Text(
    'RESEND OTP',
    style: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Color.fromRGBO(41, 68, 135, 1),
    ),
  );
  static Text submit = Text(
    'SUBMIT',
    style: GoogleFonts.inter(
      fontWeight: FontWeight.w600,
      fontSize: 18,
      color: Colors.white,
    ),
  );
  static Text cancel = Text(
    'Cancel',
    style: GoogleFonts.mulish(
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
          style: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F3C88),
          ),
        ),
        TextSpan(
          text: '*',
          style: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.red,
          ),
        ),
      ],
    ),
  );

  static Text OptionalFields = Text(
    'Optional fields',
    style: GoogleFonts.mulish(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1F3C88),
    ),
  );

  static Text Backbutton1 = Text(
    'Edit details',
    style: GoogleFonts.mulish(fontWeight: FontWeight.w700, fontSize: 16),
  );

  static Row Skip = Row(
    children: [
      Text(
        'Skip',
        style: GoogleFonts.mulish(
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
    style: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );
  static Text SignUp = Text(
    'SIGN UP',
    style: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: const Color.fromRGBO(41, 68, 135, 1),
    ),
  );

  static Text newUserSignUp = Text(
    'SIGN UP',
    style: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );
  static Text next = Text(
    'NEXT',
    style: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );
}

// -:: Input placeholders ::-
class InputFieldPlaceholder {
  static String LoginInputNumber = 'Mobile number';

  static String DealerCompanyName = 'Dealer(company) name';

  static String DealerFullName = 'Contact person (Full name)';

  static String DealerNumber = 'Mobile number';

  static String StateSelection = 'State';

  static String CitySelection = 'City';

  static String Pincode = 'Pincode';

  static String PreferedLanguage = 'Preferred language ';

  static String GSTIN = 'GSTIN (To get verified badge)';

  static String EmailAddress = 'Email address (Recommended)';

  static String AlternateMobileNumber = 'Alternate mobile number';

  static String InstagramProfileURL = 'Instagram profile URL';

  static String FacebookProfileURL = 'Facebook profile URL';

  static String WebsiteURL = 'Website URL';

  static Widget TermsConditions = RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: 'By signing up, you’re agree to our ',
          style: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(59, 59, 59, 1),
          ),
        ),
        TextSpan(
          text: 'Terms & Conditions ',
          style: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(41, 68, 135, 1),
          ),
        ),
        TextSpan(
          text: 'and ',
          style: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color.fromRGBO(59, 59, 59, 1),
          ),
        ),
        TextSpan(
          text: ' Privacy Policy',
          style: GoogleFonts.mulish(
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
    style: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Color.fromRGBO(255, 255, 255, 1),
    ),
  );
  static Text signIn = Text(
    'SIGN IN',
    style: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  );
  static Text logSignIn = Text(
    'SIGN IN',
    style: GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );

  static Text Search = Text(
    'Search',
    style: GoogleFonts.mulish(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(59, 59, 59, 1),
    ),
  );

  // New Car Entry Placeholders
  static String manufactorYear = 'Manufacturing year';
  static String make = 'Make';
  static String model = 'Model';
  static String fuelType = 'Fuel type';
  static String variant = 'Variant';
  static String transmission = 'Transmission type';
  static String color = 'Color';
  static String kilometersDriven = 'No.of Kilometers';
  static String registrationCity = 'Registration city';
  static String carOwner = 'Owner(s)';
}

class CarOptinalDetails {
  // Add a car details (Optionals) - Headings
  static Text otherDetaisl = Text(
    'Other details (optional)',
    style: GoogleFonts.mulish(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(41, 68, 135, 1),
    ),
  );

  static Text safety = Text(
    'Safety Features (optional)',
    style: GoogleFonts.mulish(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(41, 68, 135, 1),
    ),
  );

  static Text comfort = Text(
    'Comfort & Convenience (optional)',
    style: GoogleFonts.mulish(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(41, 68, 135, 1),
    ),
  );

  static Text info = Text(
    'Infotainment & Connectivity (optional) ',
    style: GoogleFonts.mulish(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(41, 68, 135, 1),
    ),
  );

  static Text inter = Text(
    'Interior Features (optional) ',
    style: GoogleFonts.mulish(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Color.fromRGBO(41, 68, 135, 1),
    ),
  );

  static Text exter = Text(
    'Exterior Features (optional) ',
    style: GoogleFonts.mulish(
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
          style: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        TextSpan(
          text: ', Service History is Available',
          style: GoogleFonts.mulish(
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
          style: GoogleFonts.mulish(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        TextSpan(
          text: ', Service History is Available',
          style: GoogleFonts.mulish(
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
