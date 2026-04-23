import 'package:flutter/material.dart';
import 'package:dealershub_/src/views/onboarding_screens/onboarding_intro_slide.dart';

class Onboardscreen_2 extends StatelessWidget {
  const Onboardscreen_2({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingIntroSlide(
      logoAsset: 'assets/on boarding screens/logo.png',
      title: 'EFFICIENT\nSEARCH',
      description:
          'Quickly find car models, \ncolors, and specs to meet \ncustomer needs.',
      titleColor: Color.fromRGBO(31, 39, 159, 1),
      imageAsset: 'assets/on boarding screens/2-BG-car-Image.png',
      tabletTitleSize: 56,
      tabletBodySize: 29,
    );
  }
}
