import 'package:dealershub_/src/models/add%20car/PostCarRequestModel.dart';
import 'package:dealershub_/src/utils/route/route.dart';
import 'package:dealershub_/src/viewmodels/add_car_view_model.dart';
import 'package:dealershub_/src/utils/responsive/responsive_helper.dart';
import '../../../utils/helper/type_converters.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CarDetailsReview extends StatefulWidget {
  final String? role;
  final Map<String, dynamic> carData;
  final Map<String, dynamic> previewData;
  final bool showAppBar;
  final bool showBottomButtons;
  final bool showtitle;
  final int carId;
  final String? actionIcons;
  const CarDetailsReview({
    super.key,
    this.role,
    required this.carData,
    required this.showAppBar,
    required this.showBottomButtons,
    required this.previewData,
    required this.showtitle,
    required this.carId,
    required this.actionIcons,
  });

  @override
  State<CarDetailsReview> createState() => _CarDetailsReviewState();
}

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

  if (hex.length != 8) return fallback;
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

class _CarDetailsReviewState extends State<CarDetailsReview> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        '🚀 Initializing SingleCarDetailsViewModel with carId: ${widget.carId}',
      );
      context.read<SingleCarDetailsViewModel>().fetchedSingleCardetails(
        widget.carId,
      );

      final fuelVm = context.read<CarFueltypeListView>();
      if (fuelVm.carFuelTypes.isEmpty && !fuelVm.isLoading) {
        fuelVm.fetchCarFuelTypes();
      }
    });
  }

  String _normalizeImagePath(String? path) {
    final trimmed = (path ?? '').trim();
    if (trimmed.isEmpty) return '';

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return '';

    // Handle remote images
    if (uri.scheme == 'http' || uri.scheme == 'https') {
      return uri.toString();
    }

    // Handle file:// URIs (image picker paths on iOS/Android)
    if (uri.scheme == 'file') {
      return uri.toFilePath();
    }

    // Treat absolute local paths (e.g. /var/...) as local files
    if (trimmed.startsWith('/') || trimmed.startsWith('~')) {
      return trimmed;
    }

    // Treat paths containing separators as local files too (e.g. relative paths)
    if (trimmed.contains('/') || trimmed.contains('\\')) {
      return trimmed;
    }

    // Otherwise treat as a server-relative URL
    return 'http://13.204.62.17$trimmed';
  }

  Widget _imageFallback() {
    return Container(
      padding: const EdgeInsets.all(10),
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      child: const Icon(Icons.broken_image, size: 70, color: Colors.grey),
    );
  }

  Widget _buildCarouselImage(String path) {
    final normalizedPath = _normalizeImagePath(path);
    if (normalizedPath.isEmpty) return _imageFallback();

    final isNetwork =
        normalizedPath.startsWith('http://') ||
        normalizedPath.startsWith('https://');

    if (isNetwork) {
      return FutureBuilder<bool>(
        future: _checkImageExists(normalizedPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          }
          if (snapshot.hasData && snapshot.data == true) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                normalizedPath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                errorBuilder: (_, __, ___) => _imageFallback(),
              ),
            );
          } else {
            return _imageFallback();
          }
        },
      );
    } else {
      // Local file
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(normalizedPath),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _imageFallback(),
        ),
      );
    }
  }

  Future<bool> _checkImageExists(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  bool _isVisibleFeatureForCar(dynamic feature, dynamic apiCar) {
    if (apiCar == null || widget.carId <= 0) return true;

    int? featureCreatedBy;
    int? featureCarId;
    bool featureIsAdmin = false;

    if (feature is Map) {
      featureCreatedBy = _toNullableInt(
        feature['created_by'] ??
            feature['created_by_id'] ??
            feature['user_id'] ??
            feature['dealer_id'],
      );
      featureCarId = _toNullableInt(
        feature['car_id'] ?? feature['source_car_id'],
      );
      featureIsAdmin =
          _toBool(feature['is_admin']) ||
          _toBool(feature['admin_feature']) ||
          _toBool(feature['is_default']);
    } else {
      try {
        featureCreatedBy = _toNullableInt(feature.createdByUserId);
      } catch (_) {}
      try {
        featureCarId = _toNullableInt(feature.carId);
      } catch (_) {}
      try {
        featureIsAdmin = _toBool(feature.isAdmin);
      } catch (_) {}
    }

    if (featureIsAdmin) return true;

    if (featureCreatedBy == null || featureCarId == null) return true;

    int? carOwnerId;
    int? currentCarId;

    try {
      carOwnerId = _toNullableInt(apiCar.dealer.id);
    } catch (_) {}
    try {
      currentCarId = _toNullableInt(apiCar.id);
    } catch (_) {}

    if (carOwnerId == null || currentCarId == null) return true;

    return featureCreatedBy == carOwnerId && featureCarId == currentCarId;
  }

  @override
  Widget build(BuildContext context) {
    // To hide APPBAR and BottomSheet
    final bool showAppBar = widget.showAppBar;
    final bool showBottomButtons = widget.showBottomButtons;
    final Map<String, dynamic> carData = widget.carData;
    final Map<String, dynamic> previewData = widget.previewData;
    final deviceType = ResponsiveHelper.getDeviceType(context);
    final bool isWideLayout = deviceType != DeviceType.mobile;
    final double maxContentWidth = deviceType == DeviceType.desktop
        ? 980
        : (isWideLayout ? 860 : double.infinity);
    final double carouselHeight = isWideLayout ? 400 : 300;
    final EdgeInsets cardMargin = isWideLayout
        ? const EdgeInsets.symmetric(vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    // API calling function for single car Details : ===>
    final singleCarVM = context.watch<SingleCarDetailsViewModel>();

    // API data (if fetched)
    final apiCar = singleCarVM.singleCar;

    // DEBUG: Show loading and error states
    if (singleCarVM.isLoading) {
      debugPrint('⏳ Loading car details...');
    }
    if (singleCarVM.error != null) {
      debugPrint('❌ Error loading car details: ${singleCarVM.error}');
    }

    debugPrint('car ID : ${widget.carId}');

    Future<void> postCar(BuildContext context) async {
      final vm = context.read<PostCarViewModel>();

      final model = PostCarRequestModel(
        brandId: toInt(carData['make']),
        modelId: toInt(carData['model']),
        variantId: toInt(carData['variant']),
        fuelTypeId: toInt(carData['fuelType']),
        transmissionId: toInt(carData['transmission']),
        colorId: toInt(carData['color']),
        ownerTypeId: toInt(carData['owner']),
        rtoId: toInt(carData['registration']),

        manufacturingYear: toInt(carData['manufactorYear']),
        kmRange: toStringValue(carData['kilometers']),

        insuranceValidity: toStringValue(carData['insurance']),
        serviceHistory: toStringValue(carData['serviceHistory']),

        safetyFeatureIds: toIntList(carData['safety_feature_ids']),
        comfortFeatureIds: toIntList(carData['comfort_feature_ids']),
        infotainmentFeatureIds: toIntList(carData['infotainment_feature_ids']),
        interiorFeatureIds: toIntList(carData['interior_feature_ids']),
        exteriorFeatureIds: toIntList(carData['exterior_feature_ids']),

        extraSafetyFeatures:
            (carData['extra_safety_features'] as List?)?.cast<String>() ?? [],
        extraComfortFeatures:
            (carData['extra_comfort_features'] as List?)?.cast<String>() ?? [],
        extraInteriorFeatures:
            (carData['extra_interior_features'] as List?)?.cast<String>() ?? [],
        extraExteriorFeatures:
            (carData['extra_exterior_features'] as List?)?.cast<String>() ?? [],
        extraInfotainmentFeatures:
            (carData['extra_infotainment_features'] as List?)?.cast<String>() ??
            [],

        images: (carData['images'] as List? ?? [])
            .map((e) => File(e.toString()))
            .toList(),
      );

      debugPrint('Images for post : ${model.images}');

      final success = await vm.postCar(model);

      if (!mounted) return;

      if (success) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          homeScreenRoute,
          (route) => false,
          arguments: {'role': widget.role, 'showSuccessDialog': true},
        );
      } else {
        debugPrint(' Error : ${vm.errorMessage}');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(vm.errorMessage ?? 'Failed')));
      }
    }

    // <=== : Not data _infoCard : ===>
    List<Widget> buildFeatureSection(dynamic list) {
      if (list == null) return [_bullet('-')];

      if (list is List && list.isNotEmpty) {
        final filtered = list
            .where(
              (dynamic feature) => _isVisibleFeatureForCar(feature, apiCar),
            )
            .toList();

        if (filtered.isEmpty) return [_bullet('-')];

        return filtered.map<Widget>((dynamic e) {
          if (e == null) return _bullet('-');

          // If API returns object with name
          if (e is Map && e.containsKey('name')) {
            return _bullet(e['name'].toString());
          }

          // If using model class (Brand)
          try {
            final name = e.name;
            return _bullet(name.toString());
          } catch (_) {}

          return _bullet(e.toString());
        }).toList();
      }

      return [_bullet('-')];
    }

    // <=== : Not data _infoCard : ===>
    String showNoData(dynamic value) {
      if (value == null) return 'No data';

      if (value is String) {
        return value.trim().isEmpty ? 'No data' : value;
      }

      return value.toString();
    }

    final List<String> imagePaths =
        (apiCar != null
                ? apiCar.images.map((e) => e.imageUrl).toList()
                : (carData['images'] as List? ?? [])
                      .map((e) => e.toString())
                      .toList())
            .map((url) => _normalizeImagePath(url))
            .where((url) => url.isNotEmpty)
            .toList();
    final String agentDealerName =
        apiCar?.dealer.dealershipName.toString() ??
        previewData['dealerName']?.toString() ??
        '';
    final String agentDealerCity =
        apiCar?.dealer.city.toString() ?? previewData['city']?.toString() ?? '';

    debugPrint(
      'arguments: showAppBar and showBottomButtons ${ModalRoute.of(context)?.settings.arguments}',
    );

    // <=== : SHARE CAR FUNCTION : ===>
    Future<void> shareCarWithImage() async {
      final apiCar = context.read<SingleCarDetailsViewModel>().singleCar;

      final String brand = apiCar?.brand.name?.toString() ?? '';
      final String model = apiCar?.model.name?.toString() ?? '';
      final String variant = apiCar?.variant.name?.toString() ?? '';
      final String fuel = apiCar?.fuelType.name?.toString() ?? '';
      final String year = apiCar?.manufacturingYear?.toString() ?? '';
      final String km = apiCar?.kmRange?.toString() ?? '';
      final String dealer =
          apiCar?.dealer.dealershipName?.toString() ?? agentDealerName;
      final String city = apiCar?.dealer.city?.toString() ?? agentDealerCity;

      final title = [
        brand,
        model,
        variant,
      ].where((e) => e.trim().isNotEmpty).join(' ');
      final meta = [
        year,
        fuel,
        km,
      ].where((e) => e.trim().isNotEmpty).join(' • ');
      final dealerLine = [
        dealer,
        city,
      ].where((e) => e.trim().isNotEmpty).join(', ');
      final shareText =
          [
            title,
            meta,
            dealerLine,
          ].where((e) => e.trim().isNotEmpty).join('\n').trim().isEmpty
          ? 'Check out this car listing'
          : [
              title,
              meta,
              dealerLine,
            ].where((e) => e.trim().isNotEmpty).join('\n').trim();

      final imagePath = imagePaths.isNotEmpty ? imagePaths.first : '';
      final imageUri = Uri.tryParse(imagePath);

      Uint8List? bytes;
      if (imagePath.isNotEmpty && imageUri != null) {
        try {
          if (imagePath.startsWith('http://') ||
              imagePath.startsWith('https://')) {
            final response = await http.get(imageUri);
            if (response.statusCode >= 200 && response.statusCode < 300) {
              bytes = response.bodyBytes;
            }
          } else {
            final file = File(imagePath);
            if (await file.exists()) {
              bytes = await file.readAsBytes();
            }
          }
        } catch (e) {
          debugPrint('Image fetch for sharing failed: $e');
        }
      }

      final box = context.findRenderObject() as RenderBox?;
      final shareOrigin = box != null && box.attached
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      if (bytes == null || bytes.isEmpty) {
        if (shareOrigin != null) {
          await Share.share(shareText, sharePositionOrigin: shareOrigin);
        } else {
          await Share.share(shareText);
        }
        return;
      }

      try {
        final codec = await ui.instantiateImageCodec(bytes);
        final frame = await codec.getNextFrame();
        final carImage = frame.image;

        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final paint = Paint();

        const width = 1080.0;
        const height = 1350.0;

        // White background
        paint.color = Colors.white;
        canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

        // Draw car image
        final imageRect = Rect.fromLTWH(0, 0, width, 800);
        paintImage(
          canvas: canvas,
          rect: imageRect,
          image: carImage,
          fit: BoxFit.cover,
        );

        // Gradient overlay
        final gradient = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
          ).createShader(imageRect);

        canvas.drawRect(imageRect, gradient);

        // Text style
        final textPainter = TextPainter(textDirection: TextDirection.ltr);

        final textSpan = TextSpan(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 60,
            fontWeight: FontWeight.bold,
          ),
          text: brand,
        );

        textPainter.text = textSpan;
        textPainter.layout(maxWidth: width - 80);
        textPainter.paint(canvas, const Offset(40, 850));

        final detailsPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            style: const TextStyle(color: Colors.grey, fontSize: 45),
            text: "$year • $fuel • $km\n$dealer",
          ),
        );

        detailsPainter.layout(maxWidth: width - 80);
        detailsPainter.paint(canvas, const Offset(40, 950));

        final picture = recorder.endRecording();
        final img = await picture.toImage(width.toInt(), height.toInt());
        final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/car_share.png');
        await file.writeAsBytes(pngBytes!.buffer.asUint8List());

        if (shareOrigin != null) {
          await Share.shareXFiles(
            [XFile(file.path)],
            text: shareText,
            sharePositionOrigin: shareOrigin,
          );
        } else {
          await Share.shareXFiles([XFile(file.path)], text: shareText);
        }
      } catch (e) {
        debugPrint("Share Error: $e");
        if (shareOrigin != null) {
          await Share.share(shareText, sharePositionOrigin: shareOrigin);
        } else {
          await Share.share(shareText);
        }
      }
    }

    debugPrint('Preview Data : $previewData');
    debugPrint('Post Data : $carData');
    debugPrint('actionIcons : ${widget.actionIcons}');
    debugPrint('insurance : ${apiCar?.otherDetails}');

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Row(
                  children: [
                    Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.black,
                      size: 20,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '${apiCar?.brand.name.toString()} Car Details',
                      style: GoogleFonts.mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              actions: widget.role == 'agent'
                  ? [
                      IconButton(
                        onPressed: shareCarWithImage,
                        icon: Icon(
                          Icons.share,
                          color: Color.fromRGBO(255, 104, 31, 1),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: SizedBox(
                          height: 45,
                          width: 45,
                          child: Image.asset(
                            'assets/placeholders/chat_icon.png', // ✅ FIXED PATH
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.favorite,
                          color: Color.fromRGBO(255, 104, 31, 1), // dark blue
                        ),
                        onPressed: () {
                          // delete action
                        },
                      ),
                    ]
                  : widget.actionIcons == 'listOfCars'
                  ? []
                  : [
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color(0xFF1E3A8A), // dark blue
                        ),
                        onPressed: () async {
                          // delete action
                          final deleteVM = context.read<DeleteCarViewModel>();

                          // 🔥 Confirmation Dialog
                          final confirm = await _deleteCarDialogBox(context);
                          if (confirm == true) {
                            await deleteVM.deleteCar(widget.carId);

                            if (deleteVM.isDeleted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Car deleted successfully",
                                    style: GoogleFonts.mulish(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );

                              //Naaviagting to home screen and refreshing the list of cars by passing initialTab as 1 (My Cars)
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                homeScreenRoute,
                                (route) => false,
                                arguments: {
                                  'role': widget.role,
                                  'initialTab': 1,
                                },
                              );
                            } else if (deleteVM.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(deleteVM.error!)),
                              );
                            }
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF1E3A8A)),
                        onPressed: () {
                          // edit action
                          Navigator.pushNamed(
                            context,
                            carUpdateDetails,
                            arguments: {
                              'role': widget.role,
                              'carId': widget.carId,
                            },
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Color(0xFF1E3A8A)),
                        onPressed: shareCarWithImage,
                      ),
                      const SizedBox(width: 8),
                    ],
            )
          : null,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                children: [
                  // Top Image / Title Section
                  widget.showtitle
                      ? SizedBox(
                          width: double.infinity,
                          height: 150,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('assets/placeholders/add_a_car.png'),
                              const SizedBox(height: 10),
                              Text(
                                'Add your car details to create a listing. \nMake it easier for buyers to \nfind your car. 🚗',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  color: const Color.fromRGBO(41, 68, 135, 1),
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(),

                  // Carousel
                  SizedBox(
                    height: carouselHeight,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: imagePaths.isEmpty
                              ? Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    border: Border.all(
                                      color: Colors.black45,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                )
                              : PageView.builder(
                                  controller: _pageController,
                                  itemCount: imagePaths.length,
                                  onPageChanged: (index) {
                                    setState(() => _currentIndex = index);
                                  },
                                  itemBuilder: (context, index) {
                                    final path = imagePaths[index];
                                    debugPrint('Images paths : $path');
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      child: _buildCarouselImage(path),
                                    );
                                  },
                                ),
                        ),

                        // Dots Indicator
                        if (imagePaths.isNotEmpty)
                          Positioned(
                            bottom: 12,
                            child: Row(
                              children: List.generate(
                                imagePaths.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: _currentIndex == index ? 10 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _currentIndex == index
                                        ? Colors.orange
                                        : Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (widget.role == 'agent')
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: double.infinity,
                        height: isWideLayout ? 44 : 40,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(41, 68, 135, 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/placeholders/user-octagon 2.png',
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  [agentDealerName, agentDealerCity]
                                      .where((value) => value.trim().isNotEmpty)
                                      .join(', '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: isWideLayout ? 13 : 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  _infoCard(
                    margin: cardMargin,
                    children: [
                      // Car Title + Chips
                      Text(
                        apiCar?.model.name.toString() ??
                            widget.previewData['make']?.toString() ??
                            '',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _infoChip(
                            context,
                            apiCar?.fuelType.name.toString() ??
                                previewData['fuelType']?.toString() ??
                                '',
                            isFuelChip: true,
                          ),
                          _infoChip(
                            context,
                            apiCar?.manufacturingYear.toString() ??
                                previewData['manufactorYear']?.toString() ??
                                '',
                          ),
                          _infoChip(
                            context,
                            apiCar?.rto.code.toString() ??
                                previewData['registration']?.toString() ??
                                '',
                          ),
                        ],
                      ),

                      // Car Specs
                      _infoRow(
                        context,
                        'Transmission',
                        apiCar?.transmission.name.toString() ??
                            previewData['transmission']?.toString() ??
                            '',
                      ),
                      _infoRow(
                        context,
                        'Variant',
                        apiCar?.variant.name.toString() ??
                            previewData['variant']?.toString() ??
                            '',
                      ),
                      _infoRow(
                        context,
                        'Color',
                        apiCar?.color.name.toString() ??
                            previewData['color']?.toString() ??
                            '',
                      ),
                      _infoRow(
                        context,
                        'Kilometers',
                        apiCar?.kmRange.toString() ??
                            previewData['kilometers']?.toString() ??
                            '',
                      ),
                      _infoRow(
                        context,
                        'Owner(s)',
                        apiCar?.ownerType.name.toString() ??
                            previewData['owner']?.toString() ??
                            '',
                      ),
                      _infoRow(
                        context,
                        'Insurance',
                        apiCar?.otherDetails?.insuranceValidity ??
                            showNoData(previewData['insurance']),
                      ),

                      _infoRow(
                        context,
                        'Service History',
                        apiCar?.otherDetails?.serviceHistory ??
                            showNoData(previewData['serviceHistory']),
                      ),
                    ],
                  ),

                  // Feature Sections
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final featureCards = [
                        _infoCard(
                          margin: cardMargin,
                          title: 'Safety Features',
                          children: buildFeatureSection(
                            apiCar?.features.safety ??
                                previewData['safetyFeatures'],
                          ),
                        ),
                        _infoCard(
                          margin: cardMargin,
                          title: 'Comfort & Convenience',
                          children: buildFeatureSection(
                            apiCar?.features.comfort ??
                                previewData['comfortFeatures'],
                          ),
                        ),
                        _infoCard(
                          margin: cardMargin,
                          title: 'Infotainment & Connectivity',
                          children: buildFeatureSection(
                            apiCar?.features.infotainment ??
                                previewData['connectivityFeatures'],
                          ),
                        ),
                        _infoCard(
                          margin: cardMargin,
                          title: 'Interior Features',
                          children: buildFeatureSection(
                            apiCar?.features.interior ??
                                previewData['interiorFeatures'],
                          ),
                        ),
                        _infoCard(
                          margin: cardMargin,
                          title: 'Exterior Features',
                          children: buildFeatureSection(
                            apiCar?.features.exterior ??
                                previewData['exteriorFeatures'],
                          ),
                        ),
                      ];

                      if (!isWideLayout) {
                        return Column(children: featureCards);
                      }

                      const double spacing = 12;
                      final double cardWidth =
                          (constraints.maxWidth - spacing) / 2;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: 0,
                        children: featureCards
                            .map(
                              (card) => SizedBox(width: cardWidth, child: card),
                            )
                            .toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // Bottom Buttons
                  if (showBottomButtons)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 170,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    width: 2,
                                    color: const Color.fromRGBO(
                                      255,
                                      104,
                                      31,
                                      1,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'EDIT',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: const Color.fromRGBO(
                                        255,
                                        104,
                                        31,
                                        1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                postCar(context);
                              },
                              child: Container(
                                width: 170,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(255, 104, 31, 1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    'POST',
                                    style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper Widgets ---:>
  // Shows a dialog box to confirm car deletion
  Future<bool?> _deleteCarDialogBox(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Delete Car",
            style: GoogleFonts.mulish(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            "Are you sure you want to delete this car?",
            style: GoogleFonts.mulish(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Cancel",
                style: GoogleFonts.mulish(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "Delete",
                style: GoogleFonts.mulish(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Returns a Chip widget with dynamic background color based on fuel type
Widget _infoChip(BuildContext context, String text, {bool isFuelChip = false}) {
  final Color bgColor = isFuelChip
      ? _getFuelColor(context, text)
      : _defaultChipColor;
  final Color labelColor = _getChipTextColor(bgColor);

  return Chip(
    label: Text(text, style: TextStyle(color: labelColor)),
    backgroundColor: bgColor,
  );
}

// Returns a styled card widget with an optional title and a list of child widgets
Widget _infoCard({
  String? title,
  required List<Widget> children,
  EdgeInsetsGeometry margin = const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  ),
}) {
  return Padding(
    padding: margin,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 8),
          ],
          ...children,
        ],
      ),
    ),
  );
}

Widget _infoRow(BuildContext context, String label, String value) {
  final labelFontSize = ResponsiveHelper.getResponsiveFontSize(
    context,
    mobileSize: 16,
    tabletSize: 17,
    desktopSize: 18,
  );

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.mulish(
              fontSize: labelFontSize,
              color: const Color.fromRGBO(59, 59, 59, 1),
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.mulish(
              fontSize: labelFontSize,
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _bullet(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        const Text('•  '),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

Widget showSuccessfulDialogbox(
  BuildContext context,
  String title,
  String message,
) {
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2DBE60), // green color
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Check Icon
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 40),
          ),

          const SizedBox(height: 20),

          /// Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.mulish(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          /// Message
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.mulish(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}
