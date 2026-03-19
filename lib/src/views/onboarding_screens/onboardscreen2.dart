import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Onboardscreen_2 extends StatelessWidget {
  const Onboardscreen_2({super.key});

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
                Image.asset('assets/on boarding screens/logo.png', width: 85),

                const SizedBox(height: 50),

                /// TITLE
                Text(
                  'EFFICIENT \nSEARCH',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 48,
                    color: const Color.fromRGBO(31, 39, 159, 1),
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 14),

                /// SUBTEXT
                Text(
                  'Quickly find car models, \ncolors, and specs to meet \ncustomer needs.',
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
              'assets/on boarding screens/2-BG-car-Image.png',
              width: double.infinity,
              fit: BoxFit.contain, // ✅ changed from cover
            ),
          ),
        ],
      ),
    );
  }
}
