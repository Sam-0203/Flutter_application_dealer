import 'package:flutter/material.dart';
import 'package:dealershub_/src/views/onboarding_screens/onboarding_intro_slide.dart';

class Onboardscreen_4 extends StatelessWidget {
  const Onboardscreen_4({super.key});

  @override
  Widget build(BuildContext context) {
    return const OnboardingIntroSlide(
      logoAsset: 'assets/on boarding screens/logo (3).png',
      title: 'DEDICATED\nSUPPORT',
      description:
          'Chat live or call us now for \nfast, personalized, expert \nsupport.',
      titleColor: Color.fromRGBO(119, 147, 31, 1),
      imageAsset: 'assets/on boarding screens/4-BG-car-Image.png',
      tabletTitleSize: 56,
      tabletBodySize: 29,
    );
  }
}
