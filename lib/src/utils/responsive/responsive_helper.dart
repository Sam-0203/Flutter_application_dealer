import 'package:flutter/material.dart';

class ResponsiveHelper {
  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 900) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Get grid column count based on device type
  static int getGridColumns(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 1;
      case DeviceType.tablet:
        return 2;
      case DeviceType.desktop:
        return 3;
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobileSize,
    double? tabletSize,
    double? desktopSize,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobileSize;
      case DeviceType.tablet:
        return tabletSize ?? mobileSize * 1.1;
      case DeviceType.desktop:
        return desktopSize ?? mobileSize * 1.2;
    }
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(12);
      case DeviceType.tablet:
        return const EdgeInsets.all(16);
      case DeviceType.desktop:
        return const EdgeInsets.all(20);
    }
  }

  /// Get responsive card padding
  static EdgeInsets getResponsiveCardPadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(10);
      case DeviceType.tablet:
        return const EdgeInsets.all(12);
      case DeviceType.desktop:
        return const EdgeInsets.all(16);
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 12;
      case DeviceType.tablet:
        return 16;
      case DeviceType.desktop:
        return 20;
    }
  }

  /// Get responsive chip font size
  static double getChipFontSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 12;
      case DeviceType.tablet:
        return 13;
      case DeviceType.desktop:
        return 14;
    }
  }

  /// Get responsive title font size
  static double getTitleFontSize(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 20;
      case DeviceType.tablet:
        return 22;
      case DeviceType.desktop:
        return 24;
    }
  }

  /// Get responsive card height for two-image layout
  static double getResponsiveCardHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 280;
      case DeviceType.tablet:
        return 320;
      case DeviceType.desktop:
        return 360;
    }
  }

  /// Check if screen width is greater than given value
  static bool isLargerThan(BuildContext context, double width) {
    return MediaQuery.of(context).size.width > width;
  }

  /// Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}

enum DeviceType { mobile, tablet, desktop }
