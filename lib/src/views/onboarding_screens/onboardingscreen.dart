import 'package:dealershub_/src/utils/app_costants.dart';
import 'package:dealershub_/src/utils/route/route.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Intro Screens
          PageView(
            controller: _controller,
            children: onboardingPages.values.toList(),
          ),

          // Bottom controls (responsive)
          Positioned(
            bottom: isTablet ? 32 : 20,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isTablet ? 30 : 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: onboardingPages.length,
                    effect: WormEffect(
                      activeDotColor: Colors.white,
                      dotColor: Colors.grey,
                      dotHeight: isTablet ? 12 : 10,
                      dotWidth: isTablet ? 12 : 10,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        OnBoardingscreen5,
                        (route) => false,
                      );
                    },
                    child: TextViews.Skip,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
