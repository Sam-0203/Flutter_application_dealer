import 'dart:io';

import 'package:dealershub_/src/utils/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:dealershub_/src/utils/responsive/responsive_helper.dart';
import 'package:dealershub_/src/viewmodels/add_car_viewmodel.dart';
import 'package:provider/provider.dart';

const Color _defaultChipColor = Color(0xFFE0E0E0);

Color _colorFromHex(String hexCode, {Color fallback = _defaultChipColor}) {
  var hex = hexCode.trim();
  if (hex.isEmpty) return fallback;

  if (hex.startsWith('0x') || hex.startsWith('0X')) {
    hex = hex.substring(2);
  }
  if (hex.startsWith('#')) {
    hex = hex.substring(1);
  }

  if (hex.length == 6) {
    hex = 'FF$hex';
  }

  if (hex.length != 8) {
    return fallback;
  }

  final parsed = int.tryParse(hex, radix: 16);
  if (parsed == null) return fallback;

  return Color(parsed);
}

Color _getFuelColor(BuildContext context, String fuelType) {
  final colorCode = context.watch<CarFueltypeListView>().fuelTypeColorCode(
    fuelType,
  );
  return _colorFromHex(colorCode);
}

Color _getChipTextColor(Color bgColor) {
  return bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

Widget _buildCardActionButton({
  required Widget icon,
  required VoidCallback? onPressed,
  required bool isMobile,
}) {
  final buttonSize = isMobile ? 34.0 : 38.0;
  return Padding(
    padding: EdgeInsets.only(left: isMobile ? 6 : 8),
    child: SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFF3F3F3),
          shape: BoxShape.circle,
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Center(child: icon),
          ),
        ),
      ),
    ),
  );
}

String _normalizeImagePath(String? imagePath) {
  final trimmed = (imagePath ?? '').trim();
  if (trimmed.isEmpty) return '';

  final uri = Uri.tryParse(trimmed);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return trimmed;
  }

  if (uri != null && uri.scheme == 'file') {
    return uri.toFilePath();
  }

  if (trimmed.startsWith('/var/') || trimmed.startsWith('/data/')) {
    return trimmed;
  }

  if (trimmed.startsWith('/')) {
    return '${ApiUrls.baseURl}$trimmed';
  }

  return '${ApiUrls.baseURl}/$trimmed';
}

Widget _imagePlaceholder({double iconSize = 50}) {
  return Container(
    color: const Color(0xFFF2F2F2),
    child: Icon(Icons.image, size: iconSize, color: Colors.grey),
  );
}

Widget _imageError({double iconSize = 50}) {
  return Container(
    color: const Color(0xFFF2F2F2),
    child: Icon(Icons.broken_image, size: iconSize, color: Colors.grey),
  );
}

Widget _buildImageFromPath(
  String? imagePath, {
  double iconSize = 50,
  BoxFit fit = BoxFit.cover,
}) {
  final normalizedPath = _normalizeImagePath(imagePath);
  if (normalizedPath.isEmpty) {
    return _imagePlaceholder(iconSize: iconSize);
  }

  final isNetwork =
      normalizedPath.startsWith('http://') ||
      normalizedPath.startsWith('https://');

  if (isNetwork) {
    return Image.network(
      normalizedPath,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      errorBuilder: (_, __, ___) => _imageError(iconSize: iconSize),
    );
  }

  return Image.file(
    File(normalizedPath),
    fit: fit,
    errorBuilder: (_, __, ___) => _imageError(iconSize: iconSize),
  );
}

// ------------Single Car Details starts here----------------
class Car {
  final int id;
  final String title;
  final String image;
  final String fuel;
  final String year;
  final String kms;
  final String owner;
  final String reg;
  final String dealer;
  final String city;
  final String state;
  final String carPostDate;

  const Car({
    required this.id,
    required this.title,
    required this.image,
    required this.fuel,
    required this.year,
    required this.kms,
    required this.owner,
    required this.reg,
    required this.dealer,
    required this.city,
    required this.state,
    required this.carPostDate,
  });
}

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final Widget? icon;

  const CarCard({
    super.key,
    required this.car,
    this.onTap,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile =
        ResponsiveHelper.getDeviceType(context) == DeviceType.mobile;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isTabletLandscape = !isMobile && isLandscape;
    final cardPadding = ResponsiveHelper.getResponsiveCardPadding(context);
    final titleFontSize = ResponsiveHelper.getTitleFontSize(context);
    final chipFontSize = ResponsiveHelper.getChipFontSize(context);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context);
    final effectiveSpacing = isMobile
        ? 10.0
        : (isTabletLandscape ? spacing * 0.72 : spacing);
    final effectiveTitleSize = isMobile
        ? titleFontSize - 2
        : (isTabletLandscape ? titleFontSize - 1.5 : titleFontSize);
    final effectiveChipSize = isMobile
        ? chipFontSize - 0.5
        : (isTabletLandscape ? chipFontSize - 1.0 : chipFontSize);
    final imageAspectRatio = isMobile
        ? 1.95
        : (isTabletLandscape ? 2.2 : (16 / 9));

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Chips
              Row(
                children: [
                  Expanded(
                    child: Text(
                      car.title,
                      style: TextStyle(
                        fontSize: effectiveTitleSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (icon != null)
                    _buildCardActionButton(
                      icon: icon!,
                      onPressed: onPressed,
                      isMobile: isMobile,
                    ),
                ],
              ),
              SizedBox(height: effectiveSpacing / 2),
              Wrap(
                spacing: effectiveSpacing / 2,
                runSpacing: effectiveSpacing / 2,
                children: [
                  _chip(context, car.fuel, effectiveChipSize, isFuelChip: true),
                  _chip(context, car.year, effectiveChipSize),
                  _chip(context, car.kms, effectiveChipSize),
                  _chip(context, car.owner, effectiveChipSize),
                  _chip(context, car.reg, effectiveChipSize),
                  _chip(context, car.carPostDate, effectiveChipSize),
                ],
              ),
              SizedBox(height: effectiveSpacing),

              // Car Image
              AspectRatio(
                aspectRatio: imageAspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 10),
                  child: _buildImageFromPath(car.image, iconSize: 50),
                ),
              ),
              SizedBox(height: effectiveSpacing / 1.5),

              // Dealer & City
              Row(
                children: [
                  Image.asset(
                    'assets/placeholders/user-octagon.png',
                    width: isMobile ? 18 : (isTabletLandscape ? 18 : 20),
                    height: isMobile ? 18 : (isTabletLandscape ? 18 : 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${car.dealer}, ${car.state}, ${car.city}',
                      style: TextStyle(
                        fontSize: effectiveChipSize + (isMobile ? 0.5 : 0),
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String text,
    double fontSize, {
    bool isFuelChip = false,
  }) {
    final Color bgColor = isFuelChip
        ? _getFuelColor(context, text)
        : _defaultChipColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: _getChipTextColor(bgColor),
        ),
      ),
    );
  }
}
// ------------Single Car Details ends here----------------

// ------------Two Car Images Details starts here----------------
class Cars {
  final String title;
  final List<String> images; // ← Changed to List<String>
  final String fuel;
  final String year;
  final String kms;
  final String owner;
  final String reg;
  final String dealer;
  final String city;
  final String state;
  final String carPostDate;

  const Cars({
    required this.title,
    required this.images, // ← Now a list
    required this.fuel,
    required this.year,
    required this.kms,
    required this.owner,
    required this.reg,
    required this.dealer,
    required this.city,
    required this.state,
    required this.carPostDate,
  });
}

class CarsCard extends StatelessWidget {
  final Cars cars;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final Widget? icon;

  const CarsCard({
    super.key,
    required this.cars,
    this.onTap,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile =
        ResponsiveHelper.getDeviceType(context) == DeviceType.mobile;
    final cardPadding = ResponsiveHelper.getResponsiveCardPadding(context);
    final titleFontSize = ResponsiveHelper.getTitleFontSize(context);
    final chipFontSize = ResponsiveHelper.getChipFontSize(context);
    final spacing = ResponsiveHelper.getResponsiveSpacing(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Chips
              Row(
                children: [
                  Expanded(
                    child: Text(
                      cars.title,
                      style: TextStyle(
                        fontSize: isMobile ? titleFontSize - 2 : titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (icon != null)
                    _buildCardActionButton(
                      icon: icon!,
                      onPressed: onPressed,
                      isMobile: isMobile,
                    ),
                ],
              ),
              SizedBox(height: spacing / 2),
              Wrap(
                spacing: spacing / 2,
                runSpacing: spacing / 2,
                children: [
                  _chip(context, cars.fuel, chipFontSize, isFuelChip: true),
                  _chip(context, cars.year, chipFontSize),
                  _chip(context, cars.kms, chipFontSize),
                  _chip(context, cars.owner, chipFontSize),
                  _chip(context, cars.reg, chipFontSize),
                  _chip(context, cars.carPostDate, chipFontSize),
                ],
              ),
              SizedBox(height: spacing),

              // Car Images
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _carImage(
                        cars.images.isNotEmpty ? cars.images[0] : null,
                      ),
                    ),
                    if (cars.images.length > 1) ...[
                      SizedBox(width: spacing / 2),
                      Expanded(child: _carImage(cars.images[1])),
                    ],
                  ],
                ),
              ),

              SizedBox(height: spacing),

              // Dealer & City
              Row(
                children: [
                  Image.asset(
                    'assets/placeholders/user-octagon.png',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${cars.dealer}, ${cars.state}, ${cars.city}',
                      style: TextStyle(
                        fontSize: chipFontSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _carImage(String? imagePath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFFF2F2F2),
        alignment: Alignment.center,
        child: _buildImageFromPath(imagePath, iconSize: 40),
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String text,
    double fontSize, {
    bool isFuelChip = false,
  }) {
    final Color bgColor = isFuelChip
        ? _getFuelColor(context, text)
        : _defaultChipColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: _getChipTextColor(bgColor),
        ),
      ),
    );
  }
}
// ------------Two Car Images Details ends here----------------

// ------------LessCarDetails Details starts here----------------
// less car details card
class LessCarDetails {
  final String title;
  final String fuel;
  final String year;
  final String reg;
  final String image;

  const LessCarDetails({
    required this.title,
    required this.image,
    required this.fuel,
    required this.year,
    required this.reg,
  });
}

class SmallCarsCard extends StatelessWidget {
  final LessCarDetails lessDetails;
  final VoidCallback? onTap;

  const SmallCarsCard({super.key, required this.lessDetails, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cardPadding = ResponsiveHelper.getResponsiveCardPadding(context);
    final chipFontSize = ResponsiveHelper.getChipFontSize(context) - 2;
    final titleFontSize = ResponsiveHelper.getChipFontSize(context) + 2;
    final spacing = ResponsiveHelper.getResponsiveSpacing(context);

    final deviceType = ResponsiveHelper.getDeviceType(context);
    final double iconSize = deviceType == DeviceType.tablet ? 50 : 40;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                lessDetails.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: spacing / 2),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  spacing: spacing / 2,
                  runSpacing: spacing / 2,
                  children: [
                    _chip(
                      context,
                      lessDetails.fuel,
                      chipFontSize,
                      isFuelChip: true,
                    ),
                    _chip(context, lessDetails.year, chipFontSize),
                    _chip(context, lessDetails.reg, chipFontSize),
                  ],
                ),
              ),
              SizedBox(height: spacing),

              // Car Image
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color(0xFFF2F2F2),
                    child: SizedBox.expand(
                      child: _buildImageFromPath(
                        lessDetails.image,
                        iconSize: iconSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String text,
    double fontSize, {
    bool isFuelChip = false,
  }) {
    final Color bgColor = isFuelChip
        ? _getFuelColor(context, text)
        : _defaultChipColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: _getChipTextColor(bgColor),
        ),
      ),
    );
  }
}

// ------------LessCarDetails Details ends here----------------
