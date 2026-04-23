import 'package:flutter/material.dart';

class OnboardingIntroSlide extends StatelessWidget {
  const OnboardingIntroSlide({
    required this.logoAsset,
    required this.title,
    required this.description,
    required this.titleColor,
    required this.imageAsset,
    this.tabletTitleSize = 45,
    this.tabletBodySize = 24,
    super.key,
  });

  final String logoAsset;
  final String title;
  final String description;
  final Color titleColor;
  final String imageAsset;
  final double tabletTitleSize;
  final double tabletBodySize;

  @override
  Widget build(BuildContext context) {
    debugPrint('Device width: ${MediaQuery.sizeOf(context).width}');
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        final isTabletLandscape = isTablet && isLandscape;
        final isCompactHeight = constraints.maxHeight < 760;
        final sidePadding = isTabletLandscape ? 20.0 : (isTablet ? 24.0 : 25.0);
        final titleSize = isTablet
            ? (isTabletLandscape ? 34.0 : tabletTitleSize)
            : 40.0;
        final bodySize = isTablet
            ? (isTabletLandscape ? 16.0 : tabletBodySize)
            : (isCompactHeight ? 18.0 : 20.0);
        final logoWidth = isTablet ? (isTabletLandscape ? 78.0 : 88.0) : 80.0;
        final imageTopGap = isTabletLandscape ? 0.0 : (isTablet ? 8.0 : 10.0);

        return Container(
          color: const Color(0xFFF1F1F1),
          child: SafeArea(
            top: true,
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    sidePadding,
                    isTabletLandscape ? 10 : (isTablet ? 20 : 12),
                    sidePadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(logoAsset, width: logoWidth),
                      const SizedBox(height: 14),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: titleSize,
                          color: titleColor,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        softWrap: true,
                        maxLines: isTabletLandscape ? 3 : 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: bodySize,
                          color: const Color(0xFF2B2B2B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: imageTopGap),
                Expanded(
                  child: ClipRect(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: isTablet ? 12 : 0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Image.asset(
                          imageAsset,
                          width: double.infinity,
                          fit: isTablet ? BoxFit.contain : BoxFit.fitWidth,
                          alignment: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
