import 'dart:io';

import 'package:dealershub_/src/models/add%20car/car_update_request_model.dart';
import 'package:dealershub_/src/viewmodels/add_car_viewmodel.dart';
import 'package:dealershub_/src/utils/helper/error_message_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// Enum for feature categories
enum FeatureCategory { safety, comfort, infotainment, interior, exterior }

class CarUpdateDetails extends StatefulWidget {
  final int carId;
  final String role;
  const CarUpdateDetails({super.key, required this.carId, required this.role});

  @override
  State<CarUpdateDetails> createState() => _CarUpdateDetailsState();
}

// <=== : Not data _infoCard : ===>
List<Widget> buildFeatureSection(dynamic list) {
  if (list == null) return [_bullet('-')];

  if (list is List && list.isNotEmpty) {
    final first = list.first;
    if (first is String || first is Map) {
      return list.map<Widget>((e) => _bullet(e.toString())).toList();
    }

    // Try to access `.name` on model objects
    return list
        .map<Widget>((e) => _bullet(e?.name?.toString() ?? e.toString()))
        .toList();
  }

  return [_bullet('-')];
}

const Color _defaultChipColor = Color(0xFFE0E0E0);
const Color _brandColor = Color(0xFF1E3A8A);
const Color _accentColor = Color(0xFFF47B39);
const Color _screenBg = Color(0xFFF8FAFC);
const Color _cardBorder = Color(0xFFE2E8F0);

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

String _normalizeImagePath(String? path) {
  final trimmed = (path ?? '').trim();
  if (trimmed.isEmpty) {
    debugPrint('⚠️ Image path is empty or null');
    return '';
  }

  final uri = Uri.tryParse(trimmed);
  if (uri == null) {
    debugPrint('⚠️ Failed to parse image URI: $trimmed');
    return '';
  }

  if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
    debugPrint('✅ Using absolute URL: ${uri.toString()}');
    return uri.toString();
  }

  final fullUrl = 'http://13.204.62.17$trimmed';
  debugPrint('✅ Constructed relative URL: $fullUrl');
  return fullUrl;
}

class _CarUpdateDetailsState extends State<CarUpdateDetails> {
  static const int _maxCarImages = 10;

  late PageController _pageController;
  int _currentIndex = 0;

  final ImagePicker _picker = ImagePicker();
  final List<File> carImages = [];
  bool isUploading = false;

  // Track which image URLs have failed to load
  final Set<String> _failedImageUrls = {};

  // Local state for selected features
  List<dynamic> _selectedSafety = [];
  List<dynamic> _selectedComfort = [];
  List<dynamic> _selectedInfotainment = [];
  List<dynamic> _selectedInterior = [];
  List<dynamic> _selectedExterior = [];
  bool _isPublished = false;

  // Track loading states for API calls
  String? _updateError;
  bool _isInitialized = false;
  bool _isSaving = false;

  bool _statusToPublished(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    return normalized == 'active' ||
        normalized == 'published' ||
        normalized == 'true' ||
        normalized == '1';
  }

  String get _selectedStatus => _isPublished ? 'active' : 'inactive';

  void _showPickerError(ImageSource source, Object error) {
    if (!mounted || !context.mounted) return;

    final action = source == ImageSource.camera ? 'camera' : 'gallery';
    String message = 'Could not open $action. Please try again.';

    if (error is PlatformException) {
      final raw = '${error.code} ${error.message ?? ''}'.toLowerCase();
      if (raw.contains('denied') || raw.contains('permission')) {
        message =
            'Please allow ${source == ImageSource.camera ? 'Camera' : 'Photos'} permission in Android settings.';
      } else if (raw.contains('activity') || raw.contains('cancel')) {
        message = 'No image selected from $action.';
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xffF47B39),
      ),
    );
  }

  int get _existingServerImageCount =>
      context.read<SingleCarDetailsViewModel>().singleCar?.images.length ?? 0;

  int get _remainingImageSlots {
    final remaining =
        _maxCarImages - (_existingServerImageCount + carImages.length);
    return remaining > 0 ? remaining : 0;
  }

  void _initializeLocalFeatures(dynamic singleCar) {
    if (singleCar == null) return;
    _selectedSafety = List.from(singleCar.features.safety ?? []);
    _selectedComfort = List.from(singleCar.features.comfort ?? []);
    _selectedInfotainment = List.from(singleCar.features.infotainment ?? []);
    _selectedInterior = List.from(singleCar.features.interior ?? []);
    _selectedExterior = List.from(singleCar.features.exterior ?? []);
    _isPublished = _statusToPublished(singleCar.status?.toString());
    _isInitialized = true;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        '🚀 Initializing SingleCarDetailsViewModel with carId: ${widget.carId}',
      );

      // Clear failed images when refreshing data
      _failedImageUrls.clear();

      context.read<SingleCarDetailsViewModel>().fetchedSingleCardetails(
        widget.carId,
      );

      // Initialize all feature view models
      debugPrint('🚀 Fetching all available features');
      context.read<CarSafetyFeaturesViewModel>().fetchCarSafetyFeatures();
      context.read<CarcomfortFeaturesViewModel>().fetchedComfortFeatures();
      context
          .read<CarInfotainmentFeaturesViewModel>()
          .fetchedInfotainmentFeatures();
      context.read<CarInteriorFeaturesViewModel>().fetchInteriorFeayures();
      context.read<CarExteriorFeaturesViewModel>().fetchExteriorFeatures();

      final fuelVm = context.read<CarFueltypeListView>();
      if (fuelVm.carFuelTypes.isEmpty && !fuelVm.isLoading) {
        fuelVm.fetchCarFuelTypes();
      }
    });
    _pageController = PageController();
  }

  void _showImagePickerOptions(BuildContext context) {
    if (_remainingImageSlots <= 0) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 10 images allowed per car'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: 160,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take Photo"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Choose from Gallery"),
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFeaturesBottomSheet(
    String title,
    List<dynamic> currentlySelected,
    String category,
  ) {
    // Get current selected IDs
    final currentSelectedIds = currentlySelected
        .map<int>((e) => e.id ?? 0)
        .toSet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Fetch available features based on category
            late Future<List<dynamic>> futureFeatures;

            switch (category) {
              case 'safety':
                futureFeatures = Future.value(
                  context.watch<CarSafetyFeaturesViewModel>().features,
                );
                debugPrint(
                  'futureFeatures for safety: ${futureFeatures.toString()}',
                );
                break;
              case 'comfort':
                futureFeatures = Future.value(
                  context.watch<CarcomfortFeaturesViewModel>().comfort,
                );
                break;
              case 'infotainment':
                futureFeatures = Future.value(
                  context
                      .watch<CarInfotainmentFeaturesViewModel>()
                      .infotainment,
                );
                break;
              case 'interior':
                futureFeatures = Future.value(
                  context.watch<CarInteriorFeaturesViewModel>().interior,
                );
                break;
              case 'exterior':
                futureFeatures = Future.value(
                  context.watch<CarExteriorFeaturesViewModel>().exterior,
                );
                break;
              default:
                futureFeatures = Future.value([]);
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 12,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Header
                    Text(
                      'Select $title',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Features Chips - Scrollable Container
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.45,
                      ),
                      child: SingleChildScrollView(
                        child: FutureBuilder<List<dynamic>>(
                          future: futureFeatures,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final features = snapshot.data ?? [];

                            if (features.isEmpty) {
                              return Center(
                                child: Text(
                                  'No features available',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            return Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: features.map<Widget>((feature) {
                                final featureId = feature.id ?? 0;
                                final featureName = feature.name ?? '';
                                final isSelected = currentSelectedIds.contains(
                                  featureId,
                                );

                                return FilterChip(
                                  label: Text(
                                    featureName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (bool selected) {
                                    setState(() {
                                      if (selected) {
                                        currentSelectedIds.add(featureId);
                                      } else {
                                        currentSelectedIds.remove(featureId);
                                      }
                                    });
                                  },
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  selectedColor: _brandColor,
                                  checkmarkColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: isSelected
                                          ? _brandColor
                                          : const Color(0xFFD6DEEA),
                                    ),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              currentSelectedIds.clear();
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              side: BorderSide(
                                color: _brandColor.withOpacity(0.35),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _brandColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _updateSelectedFeatures(
                              category,
                              currentSelectedIds,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _brandColor,
                              minimumSize: const Size.fromHeight(46),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Select',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Check if file is a valid image format
  bool _isValidImageFile(String filePath) {
    final validExtensions = [
      'jpg',
      'jpeg',
      'png',
      'webp',
      'bmp',
      'tiff',
      'tif',
      'heic',
      'heif',
    ];
    final name = filePath.split('/').last;
    final dotIndex = name.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == name.length - 1) {
      // Picker sources are image-only; don't reject extension-less temp files.
      return true;
    }
    final extension = name.substring(dotIndex + 1).toLowerCase();
    return validExtensions.contains(extension);
  }

  Future<File> _compressImage(File file) async {
    final filePath = file.absolute.path;
    final name = filePath.split('/').last;
    final dotIndex = name.lastIndexOf('.');
    final extension = (dotIndex == -1 || dotIndex == name.length - 1)
        ? ''
        : name.substring(dotIndex + 1).toLowerCase();

    CompressFormat format;
    String outputExtension;

    switch (extension) {
      case 'png':
        format = CompressFormat.png;
        outputExtension = 'png';
        break;
      case 'webp':
        format = CompressFormat.webp;
        outputExtension = 'webp';
        break;
      case 'jpg':
      case 'jpeg':
      case 'bmp':
      case 'tiff':
      case 'tif':
      case 'heic':
      case 'heif':
      default:
        format = CompressFormat.jpeg;
        outputExtension = 'jpg';
    }

    final targetPath =
        "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.$outputExtension";

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: 30,
      minWidth: 1024,
      minHeight: 1024,
      format: format,
    );

    return compressedFile != null ? File(compressedFile.path) : file;
  }

  Future<void> _pickImage(ImageSource source) async {
    final slotsBeforePick = _remainingImageSlots;
    if (slotsBeforePick <= 0) {
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum 10 images allowed per car'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      /// 📁 Gallery
      if (source == ImageSource.gallery) {
        final List<XFile> pickedFiles = await _picker.pickMultiImage();

        if (pickedFiles.isEmpty) return;

        List<String> invalidFiles = [];
        int skippedByLimit = 0;
        int validCount = 0;

        for (final file in pickedFiles) {
          if (validCount >= slotsBeforePick) {
            skippedByLimit++;
            continue;
          }

          // ✅ Validate file is an image
          if (!_isValidImageFile(file.path)) {
            final fileName = file.path.split('/').last;
            invalidFiles.add(fileName);
            continue;
          }

          final original = File(file.path);
          final compressed = await _compressImage(original);
          carImages.add(compressed);
          validCount++;
        }

        if (skippedByLimit > 0 && mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Only $validCount image(s) added. Maximum $_maxCarImages images allowed per car.',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Show error if any invalid files were attempted
        if (invalidFiles.isNotEmpty && mounted && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ Skipped ${invalidFiles.length} file(s). Only JPG, PNG, WebP, BMP, TIFF allowed.\n'
                'HEIC/HEIF are also supported. No GIF, videos, or other formats.',
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        setState(() {});
      }

      /// 📸 Camera
      if (source == ImageSource.camera) {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
        );

        if (pickedFile != null) {
          // ✅ Validate camera photo is valid image
          if (!_isValidImageFile(pickedFile.path)) {
            if (mounted && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ Invalid file format. Only images allowed.'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
            return;
          }

          final original = File(pickedFile.path);
          final compressed = await _compressImage(original);
          carImages.add(compressed);

          setState(() {});
        }
      }
    } on PlatformException catch (e) {
      _showPickerError(source, e);
    } catch (e) {
      _showPickerError(source, e);
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }

    // Show image preview after picking
    if (carImages.isNotEmpty) {
      _showImagePreview(context, carImages, carImages.length - 1);
    }
  }

  void _showExistingImagePreview(
    BuildContext context,
    List<dynamic> images,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) {
        int currentIndex = initialIndex;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // ✅ SAFETY CHECK
            if (images.isEmpty) {
              Navigator.pop(context);
              return const SizedBox.shrink();
            }

            // ✅ CLAMP INDEX
            if (currentIndex >= images.length) {
              currentIndex = images.length - 1;
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// HEADER
                    Container(
                      decoration: BoxDecoration(
                        color: _accentColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                            ),
                            onPressed: currentIndex > 0
                                ? () {
                                    setDialogState(() {
                                      currentIndex--;
                                    });
                                  }
                                : null,
                          ),
                          Expanded(
                            child: Text(
                              'Photo ${currentIndex + 1}/${images.length}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            ),
                            onPressed: currentIndex < images.length - 1
                                ? () {
                                    setDialogState(() {
                                      currentIndex++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),

                    /// IMAGE
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _normalizeImagePath(images[currentIndex].imageUrl),
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _accentColor,
                                  ),
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              // Silently track failed images without logging stack traces
                              _failedImageUrls.add(
                                _normalizeImagePath(
                                  images[currentIndex].imageUrl,
                                ),
                              );
                              debugPrint(
                                '⚠️ Preview image failed to load: ${images[currentIndex].imageUrl}',
                              );
                              return Container(
                                color: Colors.grey[200],
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Image failed to load',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    /// DELETE BUTTON
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final imageId = images[currentIndex].id;
                            final deleteVM = context
                                .read<DeleteCarImageViewModel>();
                            await deleteVM.deleteImages(
                              carId: widget.carId,
                              imageIds: [imageId],
                            );
                            if (deleteVM.isSuccess) {
                              await context
                                  .read<SingleCarDetailsViewModel>()
                                  .fetchedSingleCardetails(widget.carId);
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("✅ Image deleted successfully"),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "❌ Failed to delete image: ${deleteVM.error}",
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.delete_outline),
                          label: Text(
                            'Delete Image',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
      },
    );
  }

  void _showImagePreview(
    BuildContext context,
    List<File> images,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) {
        int currentIndex = initialIndex;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            // ✅ SAFETY CHECK
            if (images.isEmpty) {
              return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'No images available.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              );
            }

            // ✅ CLAMP INDEX
            if (currentIndex >= images.length) {
              currentIndex = images.length - 1;
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// HEADER
                    Container(
                      decoration: BoxDecoration(
                        color: _accentColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_left,
                              color: Colors.white,
                            ),
                            onPressed: currentIndex > 0
                                ? () {
                                    setDialogState(() {
                                      currentIndex--;
                                    });
                                  }
                                : null,
                          ),
                          Expanded(
                            child: Text(
                              'Photo ${currentIndex + 1}/${images.length}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.chevron_right,
                              color: Colors.white,
                            ),
                            onPressed: currentIndex < images.length - 1
                                ? () {
                                    setDialogState(() {
                                      currentIndex++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),

                    /// IMAGE
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: isUploading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      _accentColor,
                                    ),
                                  ),
                                )
                              : Image.file(
                                  images[currentIndex],
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                    ),

                    /// ACTION BUTTONS
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (carImages.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No images to upload.'),
                                    ),
                                  );
                                  return;
                                }

                                if (_existingServerImageCount +
                                        carImages.length >
                                    _maxCarImages) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Maximum 10 images allowed per car',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  isUploading = true;
                                });

                                try {
                                  final imageVM = context
                                      .read<CarImageUploadViewModel>();
                                  await imageVM.uploadCarImages(
                                    carId: widget.carId,
                                    imagePaths: carImages
                                        .map((f) => f.path)
                                        .toList(),
                                    isPrimary:
                                        context
                                            .read<SingleCarDetailsViewModel>()
                                            .singleCar
                                            ?.images
                                            .isEmpty ??
                                        true,
                                  );

                                  if (imageVM.isSuccess) {
                                    debugPrint('✅ image upload success');

                                    // Close preview dialog first
                                    if (mounted) {
                                      Navigator.pop(context);
                                    }

                                    // Refresh car details from server to ensure images are properly loaded
                                    if (mounted) {
                                      await context
                                          .read<SingleCarDetailsViewModel>()
                                          .fetchedSingleCardetails(
                                            widget.carId,
                                          );
                                    }

                                    // Clear failed image URLs on successful upload
                                    _failedImageUrls.clear();

                                    // Keep UI consistent; clear pending local images
                                    if (mounted) {
                                      setState(() {
                                        carImages.clear();
                                      });
                                    }

                                    // Show success message after dialog is closed and context is stable
                                    if (mounted) {
                                      Future.delayed(
                                        const Duration(milliseconds: 200),
                                        () {
                                          if (mounted && context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.white,
                                                      size: 24,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            'Upload Successful!',
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          Text(
                                                            'Your images have been uploaded successfully',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Colors
                                                                  .white70,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                backgroundColor: const Color(
                                                  0xFF2DBE60,
                                                ),
                                                duration: const Duration(
                                                  seconds: 3,
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 6,
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    }
                                  } else {
                                    debugPrint(
                                      '❌ image upload failed: ${imageVM.errorMessage}',
                                    );
                                    if (mounted && context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '❌ Upload failed: ${imageVM.errorMessage}',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  debugPrint(
                                    '❌ Exception during image upload: $e',
                                  );
                                  if (mounted && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('❌ Upload failed: $e'),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      isUploading = false;
                                    });
                                  }
                                }
                              },
                              icon: const Icon(Icons.cloud_upload_outlined),
                              label: Text(
                                'Upload Image',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // ✅ UPDATE PARENT STATE
                                setState(() {
                                  images.removeAt(currentIndex);
                                });

                                // ✅ UPDATE DIALOG STATE
                                setDialogState(() {
                                  if (currentIndex >= images.length &&
                                      images.isNotEmpty) {
                                    currentIndex = images.length - 1;
                                  }
                                });

                                // ✅ CLOSE IF EMPTY
                                if (images.isEmpty) {
                                  Navigator.pop(context);
                                }
                              },
                              icon: const Icon(Icons.delete_outline),
                              label: Text(
                                'Remove Image',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade500,
                                side: BorderSide(color: Colors.red.shade500),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
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
            );
          },
        );
      },
    );
  }

  void _updateSelectedFeatures(String category, Set<int> selectedIds) {
    late List<dynamic> availableFeatures;
    switch (category) {
      case 'safety':
        availableFeatures = context.read<CarSafetyFeaturesViewModel>().features;
        break;
      case 'comfort':
        availableFeatures = context.read<CarcomfortFeaturesViewModel>().comfort;
        break;
      case 'infotainment':
        availableFeatures = context
            .read<CarInfotainmentFeaturesViewModel>()
            .infotainment;
        break;
      case 'interior':
        availableFeatures = context
            .read<CarInteriorFeaturesViewModel>()
            .interior;
        break;
      case 'exterior':
        availableFeatures = context
            .read<CarExteriorFeaturesViewModel>()
            .exterior;
        break;
      default:
        availableFeatures = [];
    }
    setState(() {
      final selectedFeatures = availableFeatures
          .where((f) => selectedIds.contains(f.id ?? 0))
          .toList();
      switch (category) {
        case 'safety':
          _selectedSafety = selectedFeatures;
          break;
        case 'comfort':
          _selectedComfort = selectedFeatures;
          break;
        case 'infotainment':
          _selectedInfotainment = selectedFeatures;
          break;
        case 'interior':
          _selectedInterior = selectedFeatures;
          break;
        case 'exterior':
          _selectedExterior = selectedFeatures;
          break;
      }
    });
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _failedImageUrls.clear();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    setState(() {
      _isSaving = true;
      _updateError = null;
    });

    try {
      final updateVM = context.read<CarUpdateViewModel>();

      debugPrint('🔍 CarId value: ${widget.carId}');

      // Build update request with all selected features
      final request = CarUpdateRequestModel(
        carId: widget.carId,
        safetyFeatureIds: _selectedSafety.isEmpty
            ? null
            : _selectedSafety.map((e) => e.id as int).toList(),
        comfortFeatureIds: _selectedComfort.isEmpty
            ? null
            : _selectedComfort.map((e) => e.id as int).toList(),
        infotainmentFeatureIds: _selectedInfotainment.isEmpty
            ? null
            : _selectedInfotainment.map((e) => e.id as int).toList(),
        interiorFeatureIds: _selectedInterior.isEmpty
            ? null
            : _selectedInterior.map((e) => e.id as int).toList(),
        exteriorFeatureIds: _selectedExterior.isEmpty
            ? null
            : _selectedExterior.map((e) => e.id as int).toList(),
        status: _selectedStatus,
      );

      debugPrint('📤 Sending update request: ${request.toJson()}');
      await updateVM.updateCar(request);

      if (updateVM.isSuccess) {
        // Refresh car details after update
        await context.read<SingleCarDetailsViewModel>().fetchedSingleCardetails(
          widget.carId,
        );

        // Upload new images if any
        if (carImages.isNotEmpty) {
          if (_existingServerImageCount + carImages.length > _maxCarImages) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Maximum 10 images allowed per car"),
              ),
            );
            return;
          }

          final imageVM = context.read<CarImageUploadViewModel>();
          await imageVM.uploadCarImages(
            carId: widget.carId,
            imagePaths: carImages.map((f) => f.path).toList(),
            isPrimary: true,
          );

          if (imageVM.isSuccess) {
            carImages.clear();
            setState(() {});
            // Refresh car details to show newly uploaded images
            await context
                .read<SingleCarDetailsViewModel>()
                .fetchedSingleCardetails(widget.carId);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ Images uploaded successfully")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("❌ Image upload failed: ${imageVM.errorMessage}"),
              ),
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Features updated successfully")),
        );

        // Navigate back to home screen after successful update
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        });
      } else {
        setState(() {
          _updateError = updateVM.errorMessage;
        });
        debugPrint("❌ Update failed: $_updateError");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ car Update failed: $_updateError")),
        );
      }
    } catch (e) {
      setState(() {
        _updateError = ErrorMessageHelper.userMessage(e);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Update failed: $_updateError")));
      debugPrint("❌ Update failed: $_updateError");
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final singleCarDetailsViewModel = context
        .watch<SingleCarDetailsViewModel>();

    final singleCar = singleCarDetailsViewModel.singleCar;
    if (!_isInitialized && singleCar != null) {
      _initializeLocalFeatures(singleCar);
    }
    debugPrint("Single Car data: ${widget.carId}");
    debugPrint(
      'Single car data : ${singleCar?.brand.name}, ${singleCar?.models.name}',
    );

    return Scaffold(
      backgroundColor: _screenBg,
      appBar: AppBar(
        backgroundColor: _screenBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Row(
          children: [
            SizedBox(width: 5),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: _cardBorder, width: 1),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                color: const Color(0xFF111827),
              ),
            ),
          ],
        ),
        titleSpacing: 0,

        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSaving
                ? const Center(
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation(_brandColor),
                      ),
                    ),
                  )
                : FilledButton(
                    onPressed: _saveChanges,
                    style: FilledButton.styleFrom(
                      backgroundColor: _accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Carousel
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F7),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: _cardBorder, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x10000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: singleCar == null
                      ? const SizedBox(
                          height: 320,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 235,
                              width: double.infinity,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    /// 🔹 IMAGE / PAGEVIEW
                                    Positioned.fill(
                                      child: singleCar.images.isEmpty
                                          ? GestureDetector(
                                              onTap: () =>
                                                  _showImagePickerOptions(
                                                    context,
                                                  ),
                                              child: Container(
                                                color: Colors.white,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                      Icons.image_outlined,
                                                      size: 52,
                                                      color: Colors.grey,
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Text(
                                                      'Tap to upload images',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: const Color(
                                                          0xFF6B7280,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : PageView.builder(
                                              controller: _pageController,
                                              itemCount:
                                                  singleCar.images.length,
                                              onPageChanged: (index) {
                                                setState(
                                                  () => _currentIndex = index,
                                                );
                                              },
                                              itemBuilder: (context, index) {
                                                final imageUrl =
                                                    _normalizeImagePath(
                                                      singleCar
                                                          .images[index]
                                                          .imageUrl,
                                                    );

                                                return GestureDetector(
                                                  onTap: () =>
                                                      _showExistingImagePreview(
                                                        context,
                                                        singleCar.images,
                                                        index,
                                                      ),
                                                  child: Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                  ),
                                                );
                                              },
                                            ),
                                    ),

                                    /// 🔹 DOTS ON IMAGE (BOTTOM CENTER)
                                    if (singleCar.images.isNotEmpty)
                                      Positioned(
                                        bottom: 10,
                                        left: 0,
                                        right: 0,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            singleCar.images.length,
                                            (index) => AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              width: _currentIndex == index
                                                  ? 10
                                                  : 8,
                                              height: _currentIndex == index
                                                  ? 10
                                                  : 8,
                                              decoration: BoxDecoration(
                                                color: _currentIndex == index
                                                    ? Colors.white
                                                    : Colors.white.withOpacity(
                                                        0.5,
                                                      ),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              '${singleCar.brand.name} ${singleCar.models.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                            Text(
                              '${singleCar.manufacturingYear} \u2022 ${singleCar.fuelType.name} \u2022 ${singleCar.kmRange}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            Text(
                              singleCar.dealer.dealershipName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _showImagePickerOptions(context),
                                  icon: const Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: _accentColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    minimumSize: const Size(148, 50),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  label: Text(
                                    "Update Image",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),

              // Car Details Form
              _infoCard(
                children: [
                  // Car Specs
                  _infoRow(
                    'Transmission',
                    singleCar?.transmission.name.toString() ?? '',
                  ),
                  _infoRow('Variant', singleCar?.variant.name.toString() ?? ''),
                  _infoRow('Color', singleCar?.color.name.toString() ?? ''),
                  _infoRow('Kilometers', singleCar?.kmRange.toString() ?? ''),
                  _infoRow(
                    'Owner(s)',
                    singleCar?.ownerType.name.toString() ?? '',
                  ),
                  _infoRow(
                    'Insurance',
                    singleCar?.otherDetails?.insuranceValidity.toString() ??
                        '-',
                  ),

                  _infoRow(
                    'Service History',
                    singleCar?.otherDetails?.serviceHistory.toString() ?? '-',
                  ),
                ],
              ),

              // Feature Sections
              _infoCard(
                title: 'Safety Features',
                children: buildFeatureSection(_selectedSafety),
                featureCount: _selectedSafety.length,
                onTap: () => _showFeaturesBottomSheet(
                  'Safety Features',
                  _selectedSafety,
                  'safety',
                ),
              ),

              _infoCard(
                title: 'Comfort & Convenience',
                children: buildFeatureSection(_selectedComfort),
                featureCount: _selectedComfort.length,
                onTap: () => _showFeaturesBottomSheet(
                  'Comfort & Convenience',
                  _selectedComfort,
                  'comfort',
                ),
              ),

              _infoCard(
                title: 'Infotainment & Connectivity',
                children: buildFeatureSection(_selectedInfotainment),
                featureCount: _selectedInfotainment.length,
                onTap: () => _showFeaturesBottomSheet(
                  'Infotainment & Connectivity',
                  _selectedInfotainment,
                  'infotainment',
                ),
              ),

              _infoCard(
                title: 'Interior Features',
                children: buildFeatureSection(_selectedInterior),
                featureCount: _selectedInterior.length,
                onTap: () => _showFeaturesBottomSheet(
                  'Interior Features',
                  _selectedInterior,
                  'interior',
                ),
              ),

              _infoCard(
                title: 'Exterior Features',
                children: buildFeatureSection(_selectedExterior),
                featureCount: _selectedExterior.length,
                onTap: () => _showFeaturesBottomSheet(
                  'Exterior Features',
                  _selectedExterior,
                  'exterior',
                ),
              ),

              _infoCard(
                children: [
                  Row(
                    children: [
                      const Text(
                        'Published',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.indigo,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _selectedStatus,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _isPublished
                              ? const Color(0xFF2DBE60)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _isPublished,
                        activeColor: _accentColor,
                        onChanged: (value) {
                          setState(() {
                            _isPublished = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper Widgets
Widget _infoCard({
  String? title,
  required List<Widget> children,
  VoidCallback? onTap,
  int? featureCount,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  if (featureCount != null && featureCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _brandColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$featureCount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _brandColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (onTap != null)
                    Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: _brandColor.withOpacity(0.7),
                      size: 22,
                    ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            ...children,
          ],
        ),
      ),
    ),
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF475569),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF111827),
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
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 3),
          child: Icon(Icons.circle, size: 7, color: _brandColor),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF1F2937),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _infoChip(BuildContext context, String text, {bool isFuelChip = false}) {
  final Color bgColor = isFuelChip
      ? _getFuelColor(context, text)
      : const Color(0xFFEAEFF7);
  final Color labelColor = _getChipTextColor(bgColor);

  return Chip(
    labelPadding: const EdgeInsets.symmetric(horizontal: 2),
    side: BorderSide.none,
    visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
    label: Text(
      text,
      style: TextStyle(
        color: labelColor,
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
      ),
    ),
    backgroundColor: bgColor,
  );
}
