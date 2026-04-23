import 'package:flutter/material.dart';
import 'package:dealershub_/src/views/onboarding_screens/onboarding_intro_slide.dart';

class Onboardscreen_3 extends StatelessWidget {
  const Onboardscreen_3({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingIntroSlide(
      logoAsset: 'assets/on boarding screens/logo (2).png',
      title: 'MARKETING\nINSIGHTS',
      description:
          'We analyze used car trends & \ncustomer preferences for \nsmarter platform decisions.',
      titleColor: Color.fromRGBO(210, 102, 3, 1),
      imageAsset: 'assets/on boarding screens/3-BG-car-Image.png',
      tabletTitleSize: 56,
      tabletBodySize: 29,
    );
  }
}
