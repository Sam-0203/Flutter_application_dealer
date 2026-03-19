import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Onboardscreen_1 extends StatelessWidget {
  const Onboardscreen_1({super.key});

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
                  'assets/on boarding screens/logo (1).png',
                  width: 85,
                ),

                const SizedBox(height: 50),

                /// TITLE
                Text(
                  'NATIONWIDE\nNETWORK',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 48,
                    color: const Color.fromRGBO(220, 1, 0, 1),
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 14),

                /// SUBTEXT
                Text(
                  'Connects dealers across\nIndia to drive nationwide\nbusiness success',
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
              'assets/on boarding screens/1-BG-car-Image.png',
              width: double.infinity,
              fit: BoxFit.contain, // ✅ changed from cover
            ),
          ),
        ],
      ),
    );
  }
}
