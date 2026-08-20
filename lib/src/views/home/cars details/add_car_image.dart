import 'dart:io';
import 'package:dealershub_/src/utils/route/route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class CarImageUploadScreen extends StatefulWidget {
  final List<File> initialImages;
  final int maxImages;
  final String role;
  final Map<String, dynamic> carDetails;

  const CarImageUploadScreen({
    super.key,
    this.initialImages = const [],
    this.maxImages = 10,
    required this.carDetails,
    required this.role,
  });

  @override
  State<CarImageUploadScreen> createState() => _CarImageUploadScreenState();
}

class _CarImageUploadScreenState extends State<CarImageUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  late List<File> carImages;
  bool isUploading = false;

  int get _remainingImageSlots {
    final remaining = widget.maxImages - carImages.length;
    return remaining > 0 ? remaining : 0;
  }

  @override
  void initState() {
    super.initState();
    carImages = List<File>.from(widget.initialImages);
  }

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

  void _showPickerError(ImageSource source, Object error) {
    if (!mounted) return;

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
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showBottomSheet() {
    if (_remainingImageSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${widget.maxImages} images allowed'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xffF47B39),
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromRGBO(218, 218, 218, 1),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.20,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.camera);
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    color: Colors.white,
                    child: const Center(
                      child: Text(
                        'Take Photo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.gallery);
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    color: Colors.white,
                    child: const Center(
                      child: Text(
                        'Choose from Gallery',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
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

  void _showImagePreview(int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) {
        int currentIndex = initialIndex;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (carImages.isEmpty) {
              Navigator.pop(context);
              return const SizedBox.shrink();
            }

            if (currentIndex >= carImages.length) {
              currentIndex = carImages.length - 1;
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
                              'Photo ${currentIndex + 1}/${carImages.length}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: currentIndex < carImages.length - 1
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
                                carImages[currentIndex],
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.black54),
                      onPressed: () {
                        setState(() {
                          carImages.removeAt(currentIndex);
                        });

                        setDialogState(() {
                          if (currentIndex >= carImages.length &&
                              carImages.isNotEmpty) {
                            currentIndex = carImages.length - 1;
                          }
                        });

                        if (carImages.isEmpty) {
                          Navigator.pop(context);
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

  Future<void> _pickImage(ImageSource source) async {
    final slotsBeforePick = _remainingImageSlots;
    if (slotsBeforePick <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${widget.maxImages} images allowed'),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xffF47B39),
          behavior: SnackBarBehavior.floating,
          showCloseIcon: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
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

          if (file.path.isEmpty) {
            invalidFiles.add('unknown');
            continue;
          }

          final fileName = file.path.split('/').last;

          if (!_isValidImageFile(file.path)) {
            invalidFiles.add(fileName);
            continue;
          }

          final originalFile = File(file.path);
          if (!await originalFile.exists()) {
            invalidFiles.add(fileName);
            continue;
          }

          try {
            final compressed = await _compressImage(originalFile);
            carImages.add(compressed);
            validCount++;
          } catch (e) {
            invalidFiles.add(fileName);
          }
        }

        if (skippedByLimit > 0 && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Only $validCount image(s) added. Maximum ${widget.maxImages} images allowed.',
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xffF47B39),
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }

        if (invalidFiles.isNotEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ Skipped ${invalidFiles.length} file(s). Only JPG, PNG, WebP, BMP, TIFF allowed.\n'
                'HEIC/HEIF are also supported. No GIF, videos, or other formats.',
              ),
              backgroundColor: const Color(0xffF47B39),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              showCloseIcon: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }

        setState(() {});
      }

      if (source == ImageSource.camera) {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
        );

        if (pickedFile != null) {
          if (!_isValidImageFile(pickedFile.path)) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    '❌ Invalid file format. Only images allowed.',
                  ),
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xffF47B39),
                  behavior: SnackBarBehavior.floating,
                  showCloseIcon: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  margin: const EdgeInsets.all(16),
                ),
              );
            }
            return;
          }

          final originalFile = File(pickedFile.path);
          final compressed = await _compressImage(originalFile);
          carImages.add(compressed);

          setState(() {});
        }
      }
    } on PlatformException catch (e) {
      _showPickerError(source, e);
    } on MissingPluginException catch (e) {
      _showPickerError(source, e);
    } catch (e, stackTrace) {
      debugPrint('Image pick failed: $e\n$stackTrace');
      _showPickerError(source, e);
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('${widget.carDetails}');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(
          'Car Photos (${carImages.length}/${widget.maxImages})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color.fromRGBO(41, 68, 135, 1),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Stack(
            children: [
              AbsorbPointer(
                absorbing: isUploading,
                child: GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: widget.maxImages,
                  itemBuilder: (context, index) {
                    final hasImage = index < carImages.length;

                    return GestureDetector(
                      onTap: () {
                        if (isUploading) return;

                        if (hasImage) {
                          _showImagePreview(index);
                        } else {
                          _showBottomSheet();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: hasImage
                              ? Image.file(carImages[index], fit: BoxFit.cover)
                              : isUploading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Image.asset(
                                  'assets/placeholders/empty_img.png',
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: GestureDetector(
            onTap: () {
              if (carImages.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Please upload at least 1 or 2 car images',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    backgroundColor: const Color(0xffF47B39),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                    showCloseIcon: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
                return;
              }

              final carData = {
                ...widget.carDetails,
                'images': carImages.map((f) => f.path).toList(),
                'status': 'inactive',
              };

              final previewData = {
                ...widget.carDetails,
                'images': carImages.map((f) => f.path).toList(),
              };

              Navigator.pushNamed(
                context,
                carDetailsReview,
                arguments: {
                  'carId': 0,
                  'showAppBar': false,
                  'showBottomButtons': true,
                  'carData': carData,
                  'previewData': previewData,
                  'role': widget.role,
                  'headerTitle': true,
                },
              );
            },
            child: Container(
              width: double.infinity,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xffF47B39),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Proceed",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
