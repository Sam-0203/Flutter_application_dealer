import 'package:flutter/material.dart';
import 'package:dealershub_/src/views/onboarding_screens/onboarding_intro_slide.dart';

class Onboardscreen_1 extends StatelessWidget {
  const Onboardscreen_1({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingIntroSlide(
      logoAsset: 'assets/on boarding screens/logo (1).png',
      title: 'NATIONWIDE\nNETWORK',
      description:
          'Connects dealers across \nIndia to drive nationwide \nbusiness success',
      titleColor: Color.fromRGBO(220, 1, 0, 1),
      imageAsset: 'assets/on boarding screens/1-BG-car-Image.png',
      tabletTitleSize: 56,
      tabletBodySize: 29,
    );
  }
}
