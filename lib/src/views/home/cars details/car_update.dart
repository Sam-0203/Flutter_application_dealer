import 'dart:io';

import 'package:dealershub_/src/models/add%20car/car_update_request_model.dart';
import 'package:dealershub_/src/viewmodels/add_car_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
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
  if (trimmed.isEmpty) return '';

  final uri = Uri.tryParse(trimmed);
  if (uri == null) return '';

  if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return uri.toString();
  }

  return 'http://13.204.62.17' + trimmed;
}

Future<bool> _checkImageExists(String url) async {
  try {
    final response = await http.head(Uri.parse(url));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

class _CarUpdateDetailsState extends State<CarUpdateDetails> {
  late PageController _pageController;
  int _currentIndex = 0;

  final ImagePicker _picker = ImagePicker();
  final List<File> carImages = [];
  bool isUploading = false;

  // Local state for selected features
  List<dynamic> _selectedSafety = [];
  List<dynamic> _selectedComfort = [];
  List<dynamic> _selectedInfotainment = [];
  List<dynamic> _selectedInterior = [];
  List<dynamic> _selectedExterior = [];

  // Track loading states for API calls
  String? _updateError;
  bool _isInitialized = false;
  bool _isSaving = false;

  void _initializeLocalFeatures(dynamic singleCar) {
    if (singleCar == null) return;
    _selectedSafety = List.from(singleCar.features.safety ?? []);
    _selectedComfort = List.from(singleCar.features.comfort ?? []);
    _selectedInfotainment = List.from(singleCar.features.infotainment ?? []);
    _selectedInterior = List.from(singleCar.features.interior ?? []);
    _selectedExterior = List.from(singleCar.features.exterior ?? []);
    _isInitialized = true;
  }

  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        '🚀 Initializing SingleCarDetailsViewModel with carId: ${widget.carId}',
      );
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
                left: 12,
                right: 12,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Select $title',
                      style: GoogleFonts.mulish(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Features Chips - Scrollable Container
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
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
                                  style: GoogleFonts.mulish(
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
                                    style: GoogleFonts.mulish(
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
                                  backgroundColor: Colors.grey[200],
                                  selectedColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Clear',
                              style: GoogleFonts.mulish(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
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
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Select',
                              style: GoogleFonts.mulish(
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

  Future<File> _compressImage(File file) async {
    final filePath = file.absolute.path;
    final extension = filePath.split('.').last.toLowerCase();

    CompressFormat format;

    switch (extension) {
      case 'png':
        format = CompressFormat.png;
        break;
      case 'webp':
        format = CompressFormat.webp;
        break;
      case 'jpg':
      case 'jpeg':
      default:
        format = CompressFormat.jpeg;
    }

    final targetPath =
        "${file.parent.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.$extension";

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
    if (carImages.length >= 10) return;

    setState(() {
      isUploading = true;
    });

    try {
      /// 📁 Gallery
      if (source == ImageSource.gallery) {
        final List<XFile> pickedFiles = await _picker.pickMultiImage();

        for (final file in pickedFiles) {
          if (carImages.length >= 10) break;

          final original = File(file.path);
          final compressed = await _compressImage(original);

          carImages.add(compressed);
        }
      }

      /// 📸 Camera
      if (source == ImageSource.camera) {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
        );

        if (pickedFile != null) {
          final original = File(pickedFile.path);
          final compressed = await _compressImage(original);

          carImages.add(compressed);
        }
      }

      setState(() {});
    } finally {
      setState(() {
        isUploading = false;
      });
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// HEADER
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: FutureBuilder<bool>(
                          future: _checkImageExists(
                            _normalizeImagePath(images[currentIndex].imageUrl),
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              );
                            }
                            if (snapshot.hasData && snapshot.data == true) {
                              return Image.network(
                                _normalizeImagePath(
                                  images[currentIndex].imageUrl,
                                ),
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                ),
                              );
                            } else {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.broken_image),
                              );
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// DELETE
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
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
                              content: Text("Image deleted successfully"),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Failed to delete image: ${deleteVM.error}",
                              ),
                            ),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 10),
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
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// HEADER
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: isUploading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Image.file(
                                images[currentIndex],
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// SAVE AND DELETE BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final imageVM = context
                                .read<CarImageUploadViewModel>();
                            await imageVM.uploadCarImages(
                              carId: widget.carId,
                              imagePaths: carImages.map((f) => f.path).toList(),
                            );
                            if (imageVM.isSuccess) {
                              carImages.clear();
                              setState(() {});
                              Navigator.pop(context);

                              // call single car details to refresh images
                              await context
                                  .read<SingleCarDetailsViewModel>()
                                  .fetchedSingleCardetails(widget.carId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "✅ Images uploaded successfully",
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "❌ Upload failed: ${imageVM.errorMessage}",
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.save, color: Colors.white),
                          label: const Text('Save'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
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
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
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
          final imageVM = context.read<CarImageUploadViewModel>();
          await imageVM.uploadCarImages(
            carId: widget.carId,
            imagePaths: carImages.map((f) => f.path).toList(),
          );

          if (imageVM.isSuccess) {
            carImages.clear();
            setState(() {});
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
      } else {
        setState(() {
          _updateError = updateVM.errorMessage;
        });
        debugPrint("❌ Update failed: ${_updateError}");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Update failed: ${_updateError}")),
        );
      }
    } catch (e) {
      setState(() {
        _updateError = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Update failed: ${_updateError}")),
      );
      debugPrint("❌ Update failed: ${_updateError}");
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
      'Single car data : ${singleCar?.brand.name}, ${singleCar?.model.name}',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
                  SizedBox(width: 5),
                  Text(
                    '${singleCar?.model.name}',
                    style: GoogleFonts.mulish(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: _isSaving ? null : _saveChanges,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.blue),
                      ),
                    )
                  : Text(
                      'Save',
                      style: GoogleFonts.mulish(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Carousel
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: SizedBox(
                    height: 300,
                    child: singleCar == null
                        ? const Center(child: CircularProgressIndicator())
                        : (singleCar.images.isEmpty)
                        ? GestureDetector(
                            onTap: () => _showImagePickerOptions(context),
                            child: Container(
                              height: double.infinity,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Tap to upload images',
                                    style: GoogleFonts.mulish(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              PageView.builder(
                                controller: _pageController,
                                itemCount: singleCar.images.length,
                                onPageChanged: (index) {
                                  setState(() => _currentIndex = index);
                                },
                                itemBuilder: (context, index) {
                                  final imageUrl = _normalizeImagePath(
                                    singleCar.images[index].imageUrl,
                                  );
                                  // 👆 change this field name if needed

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                    ),
                                    child: GestureDetector(
                                      onTap: () => _showExistingImagePreview(
                                        context,
                                        singleCar.images,
                                        index,
                                      ),
                                      child: FutureBuilder<bool>(
                                        future: _checkImageExists(imageUrl),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            );
                                          }
                                          if (snapshot.hasData &&
                                              snapshot.data == true) {
                                            return Image.network(
                                              imageUrl,
                                              fit: BoxFit.contain,
                                              width: double.infinity,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                    ),
                                                  ),
                                            );
                                          } else {
                                            return Container(
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.broken_image,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),

                              Positioned(
                                bottom: 5,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ), // Add some space on the left
                                    Row(
                                      children: List.generate(
                                        singleCar.images.length,
                                        (index) => AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 4,
                                          ),
                                          width: _currentIndex == index
                                              ? 10
                                              : 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: _currentIndex == index
                                                ? Colors.orange
                                                : Colors.grey,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () {
                                        _showImagePickerOptions(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.blue,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          "Update Image",
                                          style: GoogleFonts.mulish(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              // Car Details Form
              _infoCard(
                children: [
                  // Car Title + Chips
                  Text(
                    singleCar?.brand.name.toString() ?? '',
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
                        singleCar?.fuelType.name.toString() ?? '',
                        isFuelChip: true,
                      ),
                      _infoChip(
                        context,
                        singleCar?.manufacturingYear.toString() ?? '',
                      ),
                      _infoChip(context, singleCar?.rto.code.toString() ?? ''),
                    ],
                  ),

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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5FF),
          borderRadius: BorderRadius.circular(12),
          border: onTap != null
              ? Border.all(color: Colors.blue, width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo,
                    ),
                  ),
                  if (featureCount != null && featureCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$featureCount selected',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.mulish(
              fontSize: 16,
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
              fontSize: 16,
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
