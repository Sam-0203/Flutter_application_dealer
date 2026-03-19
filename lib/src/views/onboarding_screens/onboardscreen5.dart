import 'package:dealershub_/src/utils/app_costants.dart';
import 'package:dealershub_/src/utils/route/route.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Onboardscreen_5 extends StatelessWidget {
  const Onboardscreen_5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            final sidePadding = isTablet ? 28.0 : 18.0;
            final frameWidth = isTablet ? 320.0 : 260.0;
            final buttonMaxWidth = isTablet ? 620.0 : double.infinity;
            final buttonHeight = isTablet ? 56.0 : 52.0;

            return Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: sidePadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 25),

                              /// LOGO
                              Image.asset(
                                'assets/on boarding screens/logo.png',
                                width: 85,
                              ),

                              const SizedBox(height: 50),

                              /// TITLE
                              Text(
                                'EMPOWERING \nBUSINESSES, \nCONNECTING \nOPPORTUNITIES',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 36,
                                  color: const Color.fromRGBO(31, 39, 159, 1),
                                  height: 1.05,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isTablet ? 42 : 32),
                        Align(
                          alignment: Alignment.center,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: buttonMaxWidth,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: buttonHeight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        Userrole,
                                        (route) => false,
                                        arguments: {'auth_type': 'register'},
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2E3F8F),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: TextViews.GetStarted,
                                  ),
                                ),
                                SizedBox(height: isTablet ? 18 : 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: buttonHeight,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        Userrole,
                                        (route) => false,
                                        arguments: {'auth_type': 'login'},
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFF2E3F8F),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: InputFieldPlaceholder.signIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: isTablet ? 44 : 40,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 10 : 0,
                      ),
                      child: Image.asset(
                        'assets/on boarding screens/5-BG-car-Image.png',
                        fit: BoxFit.contain,
                        width: double.infinity,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
