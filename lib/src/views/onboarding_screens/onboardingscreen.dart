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
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = onboardingPages.values.toList(growable: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      body: Stack(
        children: [
          PageView(controller: _controller, children: _pages),
          Positioned(
            bottom: isTablet ? 30 : 25,
            left: 0,
            right: 0,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isTablet ? 44 : 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmoothPageIndicator(
                      controller: _controller,
                      count: _pages.length,
                      effect: WormEffect(
                        activeDotColor: Colors.white,
                        dotColor: Colors.white54,
                        dotHeight: isTablet ? 12 : 10,
                        dotWidth: isTablet ? 12 : 10,
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
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
          ),
        ],
      ),
    );
  }
}
