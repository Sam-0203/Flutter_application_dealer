import 'package:dealershub_/src/utils/app_costants.dart';
import 'package:dealershub_/src/utils/route/route.dart';
import 'package:flutter/material.dart';

class Onboardscreen_5 extends StatelessWidget {
  const Onboardscreen_5({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 600;
            final isSmallHeight = constraints.maxHeight <= 700;
            final sidePadding = isTablet ? 34.0 : 10.0;
            final buttonMaxWidth = isTablet ? 620.0 : double.infinity;
            final buttonHeight = isTablet ? 56.0 : 50.0;
            final logoWidth = isTablet ? 90.0 : 85.0;
            final titleSize = isTablet ? 48.0 : 30.0;
            final titleTopGap = isSmallHeight ? 34.0 : (isTablet ? 42.0 : 50.0);

            final mainContent = SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  sidePadding,
                  isSmallHeight ? 14 : 22,
                  sidePadding,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // logo
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Image.asset(
                            'assets/on boarding screens/logo.png',
                            width: logoWidth,
                          ),
                          SizedBox(height: titleTopGap),

                          // text
                          Text(
                            'EMPOWERING\nBUSINESSES,\nCONNECTING\nOPPORTUNITIES.',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: titleSize,
                              color: const Color.fromRGBO(31, 39, 159, 1),
                              height: 1.05,
                            ),
                          ),
                          SizedBox(height: isTablet ? 42 : 32),
                        ],
                      ),
                    ),

                    // Buttons -- Get Started and Sign In ->
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: sidePadding),
                      child: Align(
                        alignment: Alignment.center,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: buttonMaxWidth),
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: buttonHeight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      Userrole,
                                      arguments: {
                                        'auth_type': 'register',
                                        'appbar_hide': 'No',
                                      },
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
                                    Navigator.pushNamed(
                                      context,
                                      Userrole,
                                      arguments: {
                                        'auth_type': 'login',
                                        'appbar_hide': 'No',
                                      },
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
                                  child: Text(
                                    'SIGN IN',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2E3F8F),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 22 : 16),
                  ],
                ),
              ),
            );

            final imageSection = Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/on boarding screens/5-BG-car-Image.png',
                width: double.infinity,
                fit: isTablet ? BoxFit.contain : BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
              ),
            );

            if (isTablet && constraints.maxWidth > constraints.maxHeight) {
              return Row(
                children: [
                  Expanded(flex: 5, child: mainContent),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: SizedBox(
                          height: constraints.maxHeight * 0.9,
                          child: imageSection,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mainContent,
                Expanded(child: imageSection),
              ],
            );
          },
        ),
      ),
    );
  }
}
