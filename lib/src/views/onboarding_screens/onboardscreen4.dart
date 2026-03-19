import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Onboardscreen_4 extends StatelessWidget {
  const Onboardscreen_4({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔝 TOP CONTENT
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),

                /// LOGO
                Image.asset(
                  'assets/on boarding screens/logo (3).png',
                  width: 85,
                ),

                const SizedBox(height: 50),

                /// TITLE
                Text(
                  'DEDICATED \nSUPPORT',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 48,
                    color: const Color.fromRGBO(119, 147, 31, 1),
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 14),

                /// SUBTEXT
                Text(
                  'Chat live or call us now for \nfast, personalized, expert \nsupport.',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 24,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          /// 🔻 IMAGE SECTION (IMPORTANT FIX)
          Spacer(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/on boarding screens/4-BG-car-Image.png',
              width: double.infinity,
              fit: BoxFit.contain, // ✅ changed from cover
            ),
          ),
        ],
      ),
    );
  }
}
